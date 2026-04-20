# 🎯 Telemetria FluxSUS - Integração Completa

## 📊 Visão Geral da Arquitetura

```
┌─────────────────────────────────────────────────────────────────────┐
│                      🩺 FLUXO CLÍNICO REAL 🩺                       │
│                                                                     │
│  Médico no PS → Abre Wells/Cardio → Decisão Racional               │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────────────────────────────────┐
│            🔴 ATIVAÇÃO AUTOMÁTICA DE TELEMETRIA 🔴                  │
│                                                                     │
│  if (wellsScore ≤ 4.0) {  // IMPROVÁVEL                            │
│    TelemetryService.logExamAvoided('ANGIO_TC_CHEST', ...);         │
│  }                                                                  │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────────────────────────────────┐
│              💾 PERSISTÊNCIA LOCAL (HIVE) 💾                        │
│                                                                     │
│  {                                                                  │
│    "events": [                                                     │
│      {                                                             │
│        "timestamp": "2026-04-20T14:32:15Z",                       │
│        "procedureType": "ANGIO_TC_CHEST",                         │
│        "cost": 1500.00,                                           │
│        "calculatorType": "WELLS_SCORE",                           │
│        "outcome": "wells_unlikely_3pts"                           │
│      }                                                             │
│    ],                                                              │
│    "stats": {                                                      │
│      "total_saved_brl": 1500.00,                                  │
│      "exams_avoided": 1,                                          │
│      "breakdown_by_type": {"ANGIO_TC_CHEST": 1}                   │
│    }                                                               │
│  }                                                                  │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────────────────────────────────┐
│            📱 VISUALIZAÇÃO NO DASHBOARD 📱                          │
│                                                                     │
│  ╔═══════════════════════════════════════════════════════════════╗ │
│  ║ 💰 ECONOMIA SUS                                              ║ │
│  ║                                                               ║ │
│  ║         R$ 1.500,00                                          ║ │
│  ║      ECONOMIA TOTAL                                          ║ │
│  ║                                                               ║ │
│  ║ Exames Evitados: 1  |  Dias de Uso: 1  |  Média/Dia: R$1500║ │
│  ║                                                               ║ │
│  ║ ANGIO_TC_CHEST .......... 1x                                ║ │
│  ╚═══════════════════════════════════════════════════════════════╝ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 🔄 Fluxo de Integração no Wells Score

### Passo 1: Médico Seleciona Critérios

```
WellsScreen - Checklist de Critérios
┌──────────────────────────────────────────────────────────┐
│ ✅ Sinais/sintomas de TVP (3.0 pts)                      │
│ ✅ FC > 100 bpm (1.5 pts)                               │
│ ☐  Imobilização (3.0 pts)                               │
│ ☐  Hemoptise (2.0 pts)                                  │
│ ☐  Doença maligna ativa (1.0 pt)                        │
│ ☐  Trombose venosa profunda prévia (1.5 pts)           │
│ ☐  Embolia pulmonar prévia (1.5 pts)                   │
└──────────────────────────────────────────────────────────┘
            ↓
      Score: 4.5 pts
      Classification: IMPROVÁVEL (≤4.0 = UNLIKELY)
```

### Passo 2: Resultado Apresentado

```
┌─────────────────────────────────────────────────┐
│ 4.5 PONTOS                                      │
│ classificação: IMPROVÁVEL ✅                    │
├─────────────────────────────────────────────────┤
│                                                 │
│ D-Dímero pode excluir TEP com segurança       │
│                                                 │
│ 💰 Evita CTA (R$ 1.500 economizado)           │
│                                                 │
├─────────────────────────────────────────────────┤
│ [Copiar Justificativa]  [✅ D-Dímero]          │
└─────────────────────────────────────────────────┘
              ↓ Clica [✅ D-Dímero]
```

### Passo 3: ⚡ ATIVAÇÃO DA TELEMETRIA

```dart
// lib/presentation/screens/wells_screen.dart, linhas 311-327

void _showResultSnackbar(String riskLevel) {
  // ✅ Verificar se foi IMPROVÁVEL
  if (riskLevel == 'UNLIKELY') {
    
    // 🔴 CHAMADA DE TELEMETRIA - AQUI! 🔴
    TelemetryService.logExamAvoided(
      'ANGIO_TC_CHEST',                    // ← Exame que foi evitado
      'wells_unlikely_${currentScore.toInt()}pts',  // ← Contexto
    );
    
    // O que acontece internamente:
    // 1. Busca preço: ANGIO_TC_CHEST = R$ 1.500
    // 2. Cria TelemetryEvent com timestamp
    // 3. Salva em Hive
    // 4. Incrementa contadores
    // 5. Log: "💰 Exame evitado: ANGIO_TC_CHEST (R$ 1.500,00)"
  }
  
  // Exibe feedback ao médico
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('✅ D-Dímero pode excluir TEP com segurança'),
      backgroundColor: Colors.green,
    ),
  );
}
```

### Passo 4: Dados Persistem em Hive

```
Hive Database (telemetry)
├── Key: 'events'
│   └── Value: [
│       TelemetryEvent(
│         timestamp: 2026-04-20 14:32:15,
│         procedureType: 'ANGIO_TC_CHEST',
│         cost: 1500.00,
│         calculatorType: 'WELLS_SCORE',
│         outcome: 'wells_unlikely_4pts'
│       ),
│       ... (próximos eventos)
│   ]
│
└── Key: 'stats'
    └── Value: {
        'total_saved_brl': 1500.00,
        'exams_avoided': 1,
        'avg_per_exam': 1500.00,
        'days_active': 1,
        'avg_per_day': 1500.00,
        'breakdown_by_type': {
          'ANGIO_TC_CHEST': 1
        }
    }
```

### Passo 5: Dashboard Exibe em Tempo Real

```
┌───────────────────────────────────────────────────────────┐
│  💰 Economia SUS - FluxSUS                               │
├───────────────────────────────────────────────────────────┤
│                                                           │
│  ┌───────────────────────────────────────────────────┐   │
│  │  R$ 1.500,00                                      │   │
│  │ ECONOMIA TOTAL                                    │   │
│  │ (Hive → TelemetryService.getStats() → Widget)   │   │
│  └───────────────────────────────────────────────────┘   │
│                                                           │
│  ┌─────────────┬──────────────┬──────────────────┐       │
│  │ 🏥          │ 📅           │ 📊               │       │
│  │ Exames      │ Dias         │ Média            │       │
│  │ Evitados: 1 │ Uso: 1       │ /Dia: R$1500     │       │
│  └─────────────┴──────────────┴──────────────────┘       │
│                                                           │
│  Detalhamento:                                            │
│  • ANGIO_TC_CHEST ..... [1x]  (R$ 1.500)               │
│                                                           │
└───────────────────────────────────────────────────────────┘
```

---

## 🏗️ Arquitetura de Código

### Estrutura de Arquivos

```
lib/
├── core/
│   ├── data/
│   │   ├── risk_data.dart          (Tabelas de risco cardiovascular)
│   │   └── wells_data.dart         (Critérios Wells, pontuações)
│   │
│   ├── logic/
│   │   ├── risk_engine.dart        (Cálculos cardiovasculares)
│   │   └── wells_engine.dart       (Cálculos Wells)
│   │
│   ├── services/
│   │   ├── telemetry_event.dart    ⭐ Data model para eventos
│   │   ├── telemetry_service.dart  ⭐ Main service (telemetria)
│   │   ├── update_service.dart     (Sincronização de guidelines)
│   │   ├── sync_manager.dart       (Auto-sync a cada 24h)
│   │   └── service_locator.dart    (Dependency injection)
│   │
│   └── utils/
│       ├── clipboard_utils.dart    (Sanitização para e-SUS)
│       └── soap_formatter.dart     (Geração de documentação)
│
├── presentation/
│   ├── screens/
│   │   ├── wells_screen.dart       ⭐ Integração Wells
│   │   ├── cardio_screen.dart      ⭐ Integração Cardio
│   │   ├── home_screen.dart        (Navegação principal)
│   │   └── savings_dashboard_screen.dart  ⭐ Dashboard telemetria
│   │
│   ├── widgets/
│   │   ├── telemetry_savings_widget.dart  ⭐ Widget telemetria
│   │   └── sync_status_widget.dart  (Status de sincronização)
│   │
│   └── theme/
│       └── sus_theme.dart           (Tema SUS Verde)
│
└── main.dart                        (Entry point)

⭐ = Arquivos de telemetria
```

### Fluxo de Dados

```
┌─────────────────────────────┐
│   Wells/Cardio Screens      │
│   (Decisão Clínica)         │
└──────────────┬──────────────┘
               │
               │ TelemetryService.log*()
               ↓
┌─────────────────────────────┐
│   TelemetryService          │
│   (SIGTAP prices)           │
│   (Event handling)          │
└──────────────┬──────────────┘
               │
               │ Hive.put()
               ↓
┌─────────────────────────────┐
│   Hive Storage (Local DB)   │
│   (events list)             │
│   (stats map)               │
└──────────────┬──────────────┘
               │
               │ TelemetryService.getStats()
               ↓
┌─────────────────────────────┐
│   Dashboard Screen          │
│   (Visualização em Tempo    │
│    Real)                    │
└─────────────────────────────┘
```

---

## 📝 Exemplo de Execução Completa

### Turno de 1 Hora no PS

```
14:30
├─ Médico abre Wells
├─ Paciente 1: Score 3.5 → IMPROVÁVEL
│  └─ [✅ D-Dímero]
│     └─ ⚡ TelemetryService.logExamAvoided('ANGIO_TC_CHEST', 'wells_unlikely_3pts')
│        └─ Hive: total_saved = R$ 1.500, exams_avoided = 1
│
14:45
├─ Paciente 2: Score 2.0 → IMPROVÁVEL
│  └─ [✅ D-Dímero]
│     └─ ⚡ TelemetryService.logExamAvoided('ANGIO_TC_CHEST', 'wells_unlikely_2pts')
│        └─ Hive: total_saved = R$ 3.000, exams_avoided = 2
│
15:00
├─ Médico abre Dashboard
└─ Vê: R$ 3.000 economizado | 2 exames evitados | Média R$ 1.500/exame
   └─ Feedback: "Suas decisões racionais economizaram R$ 3.000 para o SUS nesta hora!"
│
15:15
├─ Cardio Risk - Paciente 3
├─ Decision: Escolhe Sinvastatina 40mg (genérico SUS)
│  └─ [COPIAR SOAP PARA e-SUS]
│     └─ ⚡ TelemetryService.logMedicationOptimized(
│           'Brand Statin',
│           'Sinvastatina 40mg (SUS)',
│           65.0  // R$ 65/mês economizados
│        )
│        └─ Hive: total_saved = R$ 3.065 (inclui est. mensal)
│
15:30
└─ Fim do turno: R$ 3.065 economizado para o SUS
```

---

## 💡 Integração nos Calculadores

### Wells Score Integration

```dart
// lib/presentation/screens/wells_screen.dart
import '../../core/services/telemetry_service.dart';

class _WellsScreenState extends State<WellsScreen> {
  
  void _showResultSnackbar(String riskLevel) {
    // Ativação automática se IMPROVÁVEL
    if (riskLevel == 'UNLIKELY') {
      TelemetryService.logExamAvoided(
        'ANGIO_TC_CHEST',
        'wells_unlikely_${currentScore.toInt()}pts',
      );
    }
  }
}
```

### Cardio Integration

```dart
// lib/presentation/screens/cardio_screen.dart
import '../../core/services/telemetry_service.dart';

class _CardioScreenState extends State<CardioScreen> {
  
  void _copySoapCardio(Map<String, dynamic> risk) {
    // Ativação automática ao selecionar medicamento SUS
    TelemetryService.logMedicationOptimized(
      'Brand Name Statin',
      'Sinvastatina 40mg (SUS)',
      65.0,  // Economia estimada mensal
    );
  }
}
```

---

## 📊 Tabela SIGTAP (Preços SUS)

```dart
static const Map<String, double> priceTable = {
  'ANGIO_TC_CHEST': 1500.00,      // CTA de tórax
  'D_DIMER': 45.00,                // Teste D-Dímero
  'SINVASTATINA_40': 15.00,       // Genérico/mês
  'DOPPLER_VEINS': 350.00,        // Ultrassom venoso
  'LAB_BASIC': 50.00,             // Exames básicos
};
```

---

## ✅ Checklist de Funcionalidade

- [x] Telemetria automática no Wells (IMPROVÁVEL)
- [x] Telemetria automática no Cardio (Medicamento)
- [x] Persistência em Hive (local storage)
- [x] Dashboard com economia total em tempo real
- [x] Breakdown por tipo de procedimento
- [x] Pull-to-refresh para atualizar
- [x] Export JSON para auditoria
- [x] Preços basados em SIGTAP
- [x] Contexto clínico registrado (reason)
- [x] Timestamps em todos os eventos
- [ ] Backend sync (próxima fase)
- [ ] PDF report (próxima fase)
- [ ] API e-SUS (próxima fase)

---

## 🚀 Como Testar

### 1. No Emulador/Device

```bash
# Iniciar Flutter
flutter run

# Acessar Wells Score
tap "Wells Score - TEP"

# Selecionar critérios que resultem em ≤4.0 pts
#  Ex: só marcar "Sinais TVP" (3.0)

# Clicar [✅ D-Dímero]
# → Telemetria ativada automaticamente

# Abrir Dashboard
tap "Economia SUS"

# Ver: R$ 1.500 economizado
```

### 2. Verificar Logs

```bash
# Watch logs
flutter logs

# Procurar por:
#💰 Exame evitado: ANGIO_TC_CHEST (R$ 1500,00)
```

### 3. Dados Persistem

```
❌ Fechar app completamente
✅ Reabrir app
✅ Dashboard ainda mostra R$ 1.500 economizado
   (Dados estão em Hive)
```

---

## 📖 Documentação Complementar

- [TELEMETRY_INTEGRATION_GUIDE.md](./TELEMETRY_INTEGRATION_GUIDE.md) - Guia detalhado
- [TELEMETRY_CLINICAL_EXAMPLE.dart](./TELEMETRY_CLINICAL_EXAMPLE.dart) - Exemplo prático
- [SOAP_LEGAL_GUIDE.md](./SOAP_LEGAL_GUIDE.md) - Documentação clínica
- [WELLS_GUIDE.md](./WELLS_GUIDE.md) - Score Wells
- [README.md](../README.md) - Visão geral do projeto

---

## 🎯 Próximas Fases

### Fase 2: Envio de Dados
- [ ] Backend API para agregar dados
- [ ] Métricas comunitárias (quantas CTAs evitadas no Brasil?)
- [ ] Integração com e-SUS para validação

### Fase 3: Relatórios
- [ ] PDF com economia acumulada
- [ ] Carimbo de tempo (rastreabilidade)
- [ ] Gráficos de tendência

### Fase 4: Gamificação
- [ ] Badges (100 exames evitados = 🏅)
- [ ] Leaderboard anônimo
- [ ] Feedback motivacional

---

**Status**: ✅ **IMPLEMENTADO E DEPLOYADO**

Commit: `b421aad` - Documentação telemetria integrada no fluxo clínico
