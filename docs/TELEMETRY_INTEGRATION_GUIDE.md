# Guia de Integração de Telemetria no Fluxo Clínico

## 🎯 Objetivo

Registrar automaticamente todas as decisões clínicas racionais que economizam recursos do SUS, criando um "contador de economia" em tempo real.

---

## 📊 Fluxo Clinical Wells: Passo a Passo

### Cena 1: Médico abre o Wells Score

```
┌─────────────────────────────────────────────────┐
│  FluxSUS Home                                    │
│  [Risco Cardiovascular] [Wells TEP] [Economia]  │
│                                                  │
│  👆 Clica em "Wells Score - TEP"                │
└─────────────────────────────────────────────────┘
                        ↓
         lib/presentation/screens/wells_screen.dart
                        ↓
         WellsScreen iniciado (initState)
         selectedCriteria = {} (vazio)
         currentScore = 0.0
```

### Cena 2: Médico seleciona critérios clínicos

```
┌─────────────────────────────────────────────────┐
│  Wells Screen - Checklist                       │
│                                                  │
│  ✅ Sinais/sintomas de TVP                     │
│  ✅ FC > 100 bpm                               │
│  ☐  Imobilização                               │
│  ☐  Hemoptise                                  │
│  ☐  Doença maligna ativa                       │
│                                                  │
│  Score: 4.5 pts (IMPROVÁVEL)                   │
└─────────────────────────────────────────────────┘
                        ↓
         _updateScore() chamado
         currentScore = 4.5
         setState() atualiza UI
```

### Cena 3: Score IMPROVÁVEL (≤4.0)

```
┌─────────────────────────────────────────────────┐
│  Classificação de Risco                         │
│  ┌───────────────────────────────────────────┐  │
│  │ 4.5                                       │  │
│  │ IMPROVÁVEL ✅                             │  │
│  ├───────────────────────────────────────────┤  │
│  │ D-Dímero pode excluir TEP                 │  │
│  │ com segurança                             │  │
│  ├───────────────────────────────────────────┤  │
│  │ 💰 Evita CTA (R$ 1.500 economizado)      │  │
│  └───────────────────────────────────────────┘  │
│                                                  │
│  [Copiar Justificativa] [✅ D-Dímero]          │
└─────────────────────────────────────────────────┘
```

### Cena 4: Médico aprova resultado

```
Usuário toca: [✅ D-Dímero]
                ↓
         _showResultSnackbar('UNLIKELY') chamado
```

### 🔴 **ATIVAÇÃO AUTOMÁTICA DA TELEMETRIA**

```dart
// ISSO ACONTECE AUTOMATICAMENTE NO CÓDIGO:
// wellsscreen.dart, linha 315-320

void _showResultSnackbar(String riskLevel) {
  
  // 1️⃣ Se score ≤ 4.0 (IMPROVÁVEL), registro economia
  if (riskLevel == 'UNLIKELY') {
    
    // 2️⃣ Chama telemetria com contexto clínico completo
    TelemetryService.logExamAvoided(
      'ANGIO_TC_CHEST',                    // Qual exame foi evitado
      'wells_unlikely_${currentScore.toInt()}pts', // Contexto clínico
    );
    // ↓
    // 3️⃣ O serviço faz isso automaticamente:
    //   - Busca preço de ANGIO_TC_CHEST (R$ 1.500) na tabela SIGTAP
    //   - Cria TelemetryEvent com timestamp e metadata
    //   - Persiste em Hive (banco local)
    //   - Incrementa contador 'exams_avoided'
    //   - Adiciona R$ 1.500 ao total economizado
  }
  
  // 4️⃣ Mostra feedback ao médico
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('✅ D-Dímero pode excluir TEP com segurança'),
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.green,
    ),
  );
}
```

---

## 💾 O que Acontece nos Bastidores

### TelemetryService.logExamAvoided()

```dart
// lib/core/services/telemetry_service.dart

static Future<void> logExamAvoided(
  String examType,          // Ex: 'ANGIO_TC_CHEST'
  String reason,            // Ex: 'wells_unlikely_4pts'
) async {
  // 1. Busca preço do exame
  final price = priceTable[examType] ?? 0.0;
  
  // 2. Cria evento
  final event = TelemetryEvent(
    timestamp: DateTime.now(),
    procedureType: examType,
    cost: price,
    calculatorType: 'WELLS_SCORE',
    outcome: reason,
  );
  
  // 3. Salva em Hive
  final box = Hive.box('telemetry');
  final events = (box.get('events', defaultValue: []) as List).cast<TelemetryEvent>();
  events.add(event);
  await box.put('events', events);
  
  // 4. Atualiza estatísticas
  final stats = box.get('stats', defaultValue: {}) as Map;
  stats['total_saved_brl'] = (stats['total_saved_brl'] ?? 0.0) + price;
  stats['exams_avoided'] = (stats['exams_avoided'] ?? 0) + 1;
  await box.put('stats', stats);
  
  print('💰 Exame evitado: $examType (R\$ ${price.toStringAsFixed(2)})');
}
```

### Hive Storage (Persistência Local)

```
┌─ Hive Database (telemetry) ─────────────────────┐
│                                                  │
│  Key: 'events'                                  │
│  Value: [                                       │
│    TelemetryEvent(                              │
│      timestamp: 2026-04-20 14:32:15             │
│      procedureType: 'ANGIO_TC_CHEST'            │
│      cost: 1500.00                              │
│      calculatorType: 'WELLS_SCORE'              │
│      outcome: 'wells_unlikely_4pts'             │
│    ),                                           │
│    TelemetryEvent(...), // próximo evento       │
│  ]                                              │
│                                                  │
│  Key: 'stats'                                   │
│  Value: {                                       │
│    'total_saved_brl': 3000.00,                  │
│    'exams_avoided': 2,                          │
│    'avg_per_exam': 1500.00,                     │
│    'days_active': 1,                            │
│    'first_use': 2026-04-20 14:30:00             │
│  }                                              │
│                                                  │
└──────────────────────────────────────────────────┘
    ↓ (Persist across app restarts)
    └──→ Hive file storage: ~/.local/share/...
```

---

## 📱 Dashboard de Economia (Visualização)

Quando o médico abre a tela "Economia SUS":

```
┌──────────────────────────────────────────────┐
│  💰 Economia SUS - FluxSUS                   │
├──────────────────────────────────────────────┤
│                                              │
│  ┌────────────────────────────────────────┐ │
│  │         R$ 3.045,00                    │ │
│  │      Economia Total                    │ │
│  └────────────────────────────────────────┘ │
│                                              │
│  ┌──────────┬──────────┬──────────┐        │
│  │   🏥     │   📅     │   📊     │        │
│  │    2     │    1     │  1.522   │        │
│  │  Exames  │   Dia    │ Média/$  │        │
│  │ Evitados │  Uso     │   Dia    │        │
│  └──────────┴──────────┴──────────┘        │
│                                              │
│  Detalhamento por Tipo                      │
│  ┌────────────────────────────────────────┐ │
│  │ ANGIO_TC_CHEST         [2x]            │ │
│  │ D_DIMER                [0x]            │ │
│  │ SINVASTATINA_40        [0x]            │ │
│  └────────────────────────────────────────┘ │
│                                              │
│  ℹ️  Swipe para atualizar estatísticas      │
└──────────────────────────────────────────────┘
   ↑
   │ Dados carregados de Hive em tempo real
   │ via TelemetryService.getStats()
```

---

## 🔄 Exemplo de Uso Prático

### Cenário: Turno de 1 hora no PS

```
14:30 - Médico abre FluxSUS
        └─ Wells Score (Paciente 1): 3.5 pts → IMPROVÁVEL
           └─ [✅ D-Dímero]
              └─ TelemetryService.logExamAvoided('ANGIO_TC_CHEST', 'wells_unlikely_3pts')
              └─ Hive: economizado R$ 1.500

14:45 - Wells Score (Paciente 2): 2.0 pts → IMPROVÁVEL
        └─ [✅ D-Dímero]
           └─ TelemetryService.logExamAvoided('ANGIO_TC_CHEST', 'wells_unlikely_2pts')
           └─ Hive: economizado R$ 1.500 (total R$ 3.000)

15:10 - Cardio Risk (Paciente 3): INTERMEDIÁRIO
        └─ [COPIAR SOAP PARA e-SUS]
           └─ TelemetryService.logMedicationOptimized(
                'Atorvastatina 80mg', 
                'Sinvastatina 40mg (SUS)',
                65.0  // R$ 65/mês economizados
              )
           └─ Hive: economizado R$ 65

15:30 - Abre Dashboard "Economia SUS":
        ┌──────────────────────┐
        │  R$ 3.065,00         │
        │  Economizado no SUS  │
        │  2 CTAs evitados     │
        │  1 Medicação otimizada
        └──────────────────────┘
```

---

## 🏗️ Arquitetura da Integração

```
┌─────────────────────────────────────────────────────────┐
│                  CAMADA DE APRESENTAÇÃO                 │
│  ┌────────────┐    ┌────────────┐    ┌──────────────┐  │
│  │ Wells      │    │ Cardio     │    │ Dashboard    │  │
│  │ Screen     │    │ Screen     │    │ Screen       │  │
│  └──────┬─────┘    └──────┬─────┘    └──────┬───────┘  │
│         │                 │                 │          │
│         └─────────────────┼────────────┬────┘          │
│                           ▼            ▼               │
│         ┌──────────────────────────────────────┐       │
│         │  import TelemetryService             │       │
│         │   TelemetryService.logExamAvoided()  │       │
│         │   TelemetryService.logMedicationOpt()│       │
│         │   TelemetryService.getStats()        │       │
│         └──────────────┬───────────────────────┘       │
└────────────────────────┼────────────────────────────────┘
                         │
┌────────────────────────┼────────────────────────────────┐
│                  CAMADA DE SERVIÇO                      │
│┌──────────────────────────────────────────────────────┐│
││  telemetry_service.dart                              ││
││  ┌───────────────────────────────────────────────┐  ││
││  │ - SIGTAP Price Table (R$ 1.500, R$ 45, etc) │  ││
││  │ - logExamAvoided(examType, reason)           │  ││
││  │ - logMedicationOptimized(...)                │  ││
││  │ - getStats() → Map<String, dynamic>          │  ││
││  │ - exportAsJson()                             │  ││
││  └───────────────────────────────────────────────┘  ││
│└────────────────┬────────────────────────────────────┘│
└─────────────────┼──────────────────────────────────────┘
                  │
┌─────────────────┼──────────────────────────────────────┐
│         CAMADA DE PERSISTÊNCIA (Hive)                  │
│         ┌──────────────────────────────────────┐       │
│         │ Hive Box: 'telemetry'                │       │
│         │ ┌────────────────────────────────┐  │       │
│         │ │ 'events': List<TelemetryEvent> │  │       │
│         │ │ 'stats': Map<String, dynamic>  │  │       │
│         │ └────────────────────────────────┘  │       │
│         │ Persiste automaticamente no         │       │
│         │ dispositivo (local storage)         │       │
│         └──────────────────────────────────────┘       │
└──────────────────────────────────────────────────────────┘
```

---

## 📝 Implementação Atual (Wells Screen)

### Arquivo: `lib/presentation/screens/wells_screen.dart`

```dart
// ✅ LINHA 7: Import
import '../../core/services/telemetry_service.dart';

// ✅ LINHAS 311-327: Integração
void _showResultSnackbar(String riskLevel) {
  final message = riskLevel == 'UNLIKELY'
      ? '✅ D-Dímero pode excluir TEP com segurança'
      : '🚨 Realizar Angiotomografia IMEDIATAMENTE';

  // Log telemetry when exam is avoided
  if (riskLevel == 'UNLIKELY') {
    TelemetryService.logExamAvoided(
      'ANGIO_TC_CHEST',
      'wells_unlikely_${currentScore.toInt()}pts',
    );
  }

  ScaffoldMessenger.of(context).showSnackBar(...);
}
```

---

## 🚀 Fluxo de Dados Completo (Resumido)

```
Wells SCREEN              TELEMETRY SERVICE         HIVE STORAGE
    │                          │                         │
    ├─ Score: 3.5    ────→     │                         │
    ├─ IMPROVÁVEL    ────→      ├─ logExamAvoided()      │
    └─ D-Dímero      ────→      ├─ price: 1500.00        │
                                ├─ event: TelemetryEvent │
                                └─ save to Hive   ────→  ├─ events: []
                                                         ├─ stats: {
                                                         │   'total': 1500,
                                                         │   'avoided': 1
                                                         │ }
                                                         └─ Persisted

DASHBOARD SCREEN                                    HIVE RETRIEVAL
    │                                                    │
    ├─ TelemetryService.getStats()  ─────────→  ├─ Read 'stats'
    └─ Display: R$ 1.500 economizado  ←─────────┘
       1 exame evitado
       0 medicamentos otimizados
```

---

## 🔧 Como Adicionar Nova Integração

Se precisar adicionar telemetria em outro calculator (ex: Lab):

```dart
// 1. Import no novo screen
import '../../core/services/telemetry_service.dart';

// 2. Llamar quando decisão clínica é tomada
if (laboratorioResult == 'DESNECESSARIO') {
  TelemetryService.logExamAvoided(
    'TESTE_LAB_X',
    'lab_unnecessary_por_clinico_y',
  );
}

// 3. Preço automaticamente buscado da priceTable
// Se não existe, log com custo 0
```

---

## 📊 Estatísticas Rastreadas

```javascript
{
  "total_saved_brl": 3045.00,           // Total economizado
  "exams_avoided": 2,                   // Quantidade de exames
  "medications_optimized": 1,           // Medicamentos genéricos
  "avg_per_exam": 1500.00,              // Média por exame
  "avg_per_day": 3045.00,               // Média diária
  "days_active": 1,                     // Dias desde primeiro uso
  "first_use": "2026-04-20T14:30:00",  // Primeiro registro
  "last_update": "2026-04-20T15:30:00", // Último registro
  "breakdown_by_type": {
    "ANGIO_TC_CHEST": 2,
    "SINVASTATINA_40": 1
  }
}
```

---

## ✅ Checklist de Funcionalidade

- [x] Telemetria automática ao confirmar Wells IMPROVÁVEL
- [x] Telemetria automática ao confirmar Cardio decision
- [x] Dados persistem em Hive (local storage)
- [x] Dashboard mostra economia total em tempo real
- [x] Breakdown por tipo de procedimento
- [x] Pull-to-refresh para atualizar dados
- [x] Export como JSON para auditoria
- [x] Preços baseados em tabela SIGTAP
- [ ] Backend sync para agregar dados (próxima fase)
- [ ] PDF report com economia acumulada (próxima fase)

---

## 📚 Referências de Código

- **Service**: `lib/core/services/telemetry_service.dart` (200+ linhas)
- **Data Model**: `lib/core/services/telemetry_event.dart`
- **UI Widget**: `lib/presentation/widgets/telemetry_savings_widget.dart`
- **Dashboard Screen**: `lib/presentation/screens/savings_dashboard_screen.dart`
- **Integration Points**: 
  - `lib/presentation/screens/wells_screen.dart` (linhas 311-327)
  - `lib/presentation/screens/cardio_screen.dart` (linhas 265-285)

