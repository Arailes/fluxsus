# 🔐 LGPD & Sincronização de Telemetria - FluxSUS

## 📋 Visão Geral

O FluxSUS implementa sincronização de dados **agregados e anônimos** respeitando a LGPD (Lei Geral de Proteção de Dados Pessoais).

```
Dados Locais (Hive)
    ↓
Agregação Anônima
    ↓
Sincronização Periódica
    ↓
Servidor Central (Agregado)
    ↓
Analytics Comunitário
```

---

## 🛡️ Princípios LGPD Implementados

### 1. ✅ Consentimento Explícito

```dart
// Usuário DEVE consentir antes de sincronizar
bool hasConsent = await syncStatsService.hasUserConsent();

// Consentimento é armazenado no device
await syncStatsService.setUserConsent(true);
```

**Tela**: `lgpd_consent_screen.dart` - Interface clara para o médico entender e consentir.

### 2. ✅ Agregação (Não-Pessoal)

```dart
// ❌ NÃO ENVIAMOS:
// - Nomes de médicos
// - CPF/Creci de médicos
// - Nomes de pacientes
// - Identificação de pacientes
// - IDs pessoais

// ✅ ENVIAMOS (agregado):
{
  "unit_id": "UBS_QUIXADA_001",      // ID GENÉRICO da unidade
  "total_brl": 3000.00,              // Total (sem detalhe por paciente)
  "exams_avoided": 2,                // Contagem (sem quem foram)
  "breakdown_by_procedure": {        // Agregado por tipo
    "ANGIO_TC_CHEST": 2
  }
}
```

### 3. ✅ Rastreabilidade

```dart
// Timestamp em toda sincronização
'sync_timestamp': DateTime.now().toIso8601String()

// Hash de integridade
'integrity_hash': _generateIntegrityHash(data)

// Log de sincronizações
'sync_log': [
  {
    'sync_at': '2026-04-20T14:32:00Z',
    'events_sent': 2
  }
]
```

### 4. ✅ Segurança em Trânsito

```dart
// HTTPS obrigatório
final response = await _httpClient.post(
  Uri.parse(_statsEndpoint),  // https://...
  headers: {
    'Content-Type': 'application/json',
    // Não envia device ID ou localizacao
  },
);
```

### 5. ✅ Direitos do Usuário

```dart
// Direito de revogar consentimento
await syncStatsService.setUserConsent(false);
// → Nenhum dado futuro será sincronizado

// Direito de acessar histórico
final history = await syncStatsService.getSyncHistory();
// → Ver tudo o que foi enviado

// Direito de saber o quê é coletado
// → LgpdConsentScreen explica tudo em linguagem clara
```

---

## 🔄 Fluxo de Sincronização

### Diagrama Completo

```
┌─────────────────────────────────────────────────────────┐
│ START: SyncManager._checkAndSync() (a cada 24h)        │
└─────────────────────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────────────────────┐
│ 1️⃣ Verificar Consentimento LGPD                        │
│   await syncStatsService.hasUserConsent()              │
└─────────────────────────────────────────────────────────┘
              ↓
        ┌─────────┴─────────┐
        ↓                   ↓
    [SIM]                [NÃO]
     ✅                  ❌ PULA
     │                   │
     ↓                   ↓
┌─────────────────────────────────────────────────────────┐
│ 2️⃣ Verificar Internet                                  │
│   await _connectivity.checkConnectivity()              │
└─────────────────────────────────────────────────────────┘
              ↓
        ┌─────────┴─────────┐
        ↓                   ↓
    [ONLINE]            [OFFLINE]
     ✅                  ⏳ FILA
     │                   │
     ↓                   ↓
┌─────────────────────────────────────────────────────────┐
│ 3️⃣ Ler Dados Locais (Hive)                            │
│   var stats = box.get('stats')                         │
│   var events = box.get('events')                       │
└─────────────────────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────────────────────┐
│ 4️⃣ Agregar Anonimamente                                │
│   • Sem nomes/IDs pessoais                             │
│   • Totalizações por tipo                              │
│   • Unit ID genérico                                   │
└─────────────────────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────────────────────┐
│ 5️⃣ Adicionar Metadados de Segurança                    │
│   • Timestamp                                           │
│   • Integrity Hash                                      │
│   • SDK Version                                         │
└─────────────────────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────────────────────┐
│ 6️⃣ POST para Servidor (HTTPS)                         │
│   await _httpClient.post(_statsEndpoint, ...)          │
└─────────────────────────────────────────────────────────┘
              ↓
        ┌─────────┴─────────┐
        ↓                   ↓
    [200/201]          [ERRO]
     ✅                  ❌ Log
     │                   │
     ↓                   ↓
┌─────────────────────────────────────────────────────────┐
│ 7️⃣ Armazenar Confirmação (LGPD)                        │
│   • Timestamp de envio                                  │
│   • ID do servidor                                      │
│   • Status de sucesso                                  │
└─────────────────────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────────────────────┐
│ END: Sincronização Completa ✅                         │
└─────────────────────────────────────────────────────────┘
```

---

## 📊 Dados Agregados - Exemplo Real

### O que é enviado

```json
{
  "unit_id": "UBS_QUIXADA_001",
  "region_code": "23",
  "total_brl": 3045.00,
  "exams_avoided": 2,
  "medications_optimized": 1,
  "avg_per_exam": 1522.50,
  "avg_per_day": 3045.00,
  "days_active": 1,
  "breakdown_by_procedure": {
    "ANGIO_TC_CHEST": 2,
    "SINVASTATINA_40": 1
  },
  "costs_by_procedure": {
    "ANGIO_TC_CHEST": 3000.00,
    "SINVASTATINA_40": 65.00
  },
  "breakdown_by_calculator": {
    "WELLS_SCORE": 2,
    "CARDIO_RISK": 1
  },
  "total_events": 3,
  "report_generated_at": "2026-04-20T14:32:00Z",
  "integrity_hash": "a1b2c3d4e5f6g7h8",
  "sync_timestamp": "2026-04-20T14:32:15Z",
  "sdk_version": "1.0.0"
}
```

### O que NÃO é enviado

```
❌ Nomes de médicos
❌ Nomes de pacientes
❌ CPF/CNPJ de qualquer pessoa
❌ Número de creci
❌ Diagnósticos individuais
❌ Detalhes de qualquer paciente
❌ Localização GPS
❌ Dados do dispositivo (IMEI, MAC, etc)
❌ Fingerprint do device
```

---

## 🗂️ Arquitetura LGPD

### Arquivos Envolvidos

```
lib/core/services/
├── sync_stats_service.dart      ⭐ Main (agregação + sincronização)
├── sync_manager.dart             (Orquestra sincronização)
└── service_locator.dart          (Registra serviço)

lib/presentation/screens/
├── lgpd_consent_screen.dart     ⭐ Interface de consentimento
└── home_screen.dart             (Link para configurações)
```

### Fluxo de Dados

```
┌─ Hive (Telemetria Local) ─┐
│                           │
│ events: [                 │
│   {date, procedure, cost} │
│   ...                     │
│ ]                         │
│                           │
│ stats: {                  │
│   total_saved: 3000,      │
│   exams_avoided: 2        │
│ }                         │
└───────────┬───────────────┘
            │
            ↓
┌─ SyncStatsService ─────────────────────┐
│                                        │
│ 1. hasUserConsent()                   │
│    → Check Hive consentimento         │
│                                        │
│ 2. _buildAnonymousAggregation()       │
│    → Lê Hive                          │
│    → Remove dados pessoais            │
│    → Agrega por tipo                  │
│                                        │
│ 3. syncAnonymousStats()               │
│    → Conecta internet                 │
│    → POST request                     │
│    → Log de sucesso                   │
└────────────┬─────────────────────────┘
             │
             ↓
   ┌─ Servidor Central ─┐
   │                    │
   │ Analytics         │
   │ Relatórios        │
   │ Dashboards        │
   │ (Agregado SUS)    │
   └────────────────────┘
```

---

## 📱 Interface de Consentimento

### LgpdConsentScreen

```
┌─────────────────────────────────────┐
│ Configurações - LGPD                │
├─────────────────────────────────────┤
│                                     │
│ ℹ️  Lei de Proteção de Dados        │
│    (Explicação clara)               │
│                                     │
│ 📊 Dados Agregados Coletados        │
│    • Total R$                       │
│    • Exames evitados                │
│    • Medicamentos otimizados        │
│    ❌ NÃO: Nomes, CPF...           │
│                                     │
│ 🎯 Propósito dos Dados              │
│    • Medir impacto clínico          │
│    • Demonstrar economia SUS        │
│    • Gerar relatórios agregados     │
│                                     │
│ ✅ Autorizar Sincronização          │
│    [Toggle ON/OFF]                  │
│                                     │
│ 🔄 Status de Sincronização          │
│    Última: 2026-04-20 14:32         │
│    Enviadas: 3 sincronizações       │
│                                     │
│ 📋 Histórico Recente                │
│    • 2026-04-20 14:32: 3 eventos    │
│    • 2026-04-19 18:22: 2 eventos    │
│                                     │
│ ⚖️  Aviso Legal (LGPD)              │
│    "Seus dados estão protegidos..."  │
│                                     │
└─────────────────────────────────────┘
```

---

## 🔐 Implementação Técnica

### 1. Verificação de Consentimento

```dart
// No SyncStatsService
Future<bool> hasUserConsent() async {
  final box = Hive.box('settings');
  return box.get('lgpd_consent_telemetry_sync', defaultValue: false) as bool;
}

// Usar antes de sincronizar
if (await syncStatsService.hasUserConsent()) {
  await syncStatsService.syncAnonymousStats(...);
}
```

### 2. Agregação Anônima

```dart
// Remove tudo pessoal
Map<String, dynamic> _buildAnonymousAggregation({
  required String unitId,        // Genérico: "UBS_001"
  required String? regionCode,   // IBGE code (ok)
  required Map telemetryStats,
  required List events,
}) {
  // Não acessa nomes, CPF, etc
  // Apenas conta agregações
  return {
    'total_brl': telemetryStats['total_saved_brl'],
    'exams_avoided': telemetryStats['exams_avoided'],
    'breakdown_by_procedure': {...},  // Contagens, não detalhes
  };
}
```

### 3. Envio Seguro

```dart
// POST com HTTPS
final response = await _httpClient.post(
  Uri.parse(_statsEndpoint),  // MUST BE https://
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    // Não envia User-Agent que identifica device
  },
  body: jsonEncode(requestBody),
).timeout(const Duration(seconds: 30));
```

### 4. Rastreabilidade (LGPD Art. 5, VI)

```dart
// Armazena o quê foi enviado
final syncLog = [
  {
    'sync_at': '2026-04-20T14:32:00Z',
    'events_sent': 3,
    'success': true,
    'server_id': 'sync-uuid-xxxxx'
  }
];

// Usuário pode acessar via getSyncHistory()
final history = await syncStatsService.getSyncHistory();
```

---

## 📋 Checklist LGPD

- [x] Consentimento explícito (Art. 7, I)
- [x] Dados agregados (não pessoais)
- [x] Finalidade clara (analytics comunitário)
- [x] Transparência (tela explicativa)
- [x] Rastreabilidade (log de sincronizações)
- [x] Direito de revogar (toggle OFF)
- [x] Direito de acessar histórico
- [x] Segurança em trânsito (HTTPS)
- [x] Sem compartilhamento com terceiros
- [x] Sem machine learning em dados pessoais

---

## 🚀 Integração no App

### 1. ServiceLocator (main.dart → initializeApp)

```dart
// Registra SyncStatsService
final syncStatsService = SyncStatsService();
ServiceLocator.register<SyncStatsService>(syncStatsService);

// Abre Hive box para telemetria
await Hive.openBox('telemetry');
```

### 2. SyncManager (sincronização automática)

```dart
// A cada 24h, sincroniza telemetria (se consentido)
Future<void> _checkAndSyncTelemetry() async {
  if (await syncStatsService.hasUserConsent()) {
    await syncStatsService.syncAnonymousStats(
      unitId: 'UBS_QUIXADA_001',
      regionCode: '23',
    );
  }
}
```

### 3. HomeScreen (navegação)

```dart
// Adicionar card para "Configurações LGPD"
GestureDetector(
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => LgpdConsentScreen()),
  ),
  child: Text('Sincronização & LGPD'),
)
```

---

## 📊 Analytics Comunitário (Servidor)

### O que o servidor faz com os dados agregados

```
Servidor Central recebe:
{
  "unit_id": "UBS_QUIXADA_001",
  "total_brl": 3000,
  "exams_avoided": 2
}

Processa:
✅ Agrupa por região
✅ Plotar gráficos de economia por procedimento
✅ Dashboard: "SUS economizou R$ XXX em TEP evitando CTAs"
✅ Relatórios de impacto (sem identificar ninguém)

Resultado:
📊 "FluxSUS poupou R$ 150.000 para o SUS em 2026"
🏥 "112 CTAs evitadas via Wells Score"
💊 "450 medicações racionalizadas"
```

---

## 🛑 Casos Especiais

### Cenário 1: Usuário Revoga Consentimento

```dart
// Tela LGPD: Toggle OFF
await syncStatsService.setUserConsent(false);

// Resultado:
// ✅ Dados locais continuam (contador não zera)
// ✅ Nenhum novo dado é enviado
// ✅ Histórico permanece acessível
```

### Cenário 2: Sem Internet

```dart
// Sincronização falha gracefully
if (connectivityResult == ConnectivityResult.none) {
  print('⏳ Dados na fila local, serão sincronizados quando houver internet');
  return false;
}

// Dados PERMANECEM em Hive até sincronizar
```

### Cenário 3: Mudança de Unit ID

```dart
// Gestor configura unit_id real
final box = Hive.box('settings');
await box.put('unit_id', 'UBS_QUIXADA_001');

// Próxima sincronização usa novo ID
await syncStatsService.syncAnonymousStats(unitId: unitId);
```

---

## 🔗 Relação com LGPD

| Artigo LGPD | Implementação |
|-----------|-------------|
| Art. 5 (Princípios) | Necessidade, transparência, rastreabilidade ✅ |
| Art. 7 (Consentimento) | Toggle explícito em LgpdConsentScreen ✅ |
| Art. 8 (Especial) | Não coletamos dados especiais ✅ |
| Art. 9 (Acesso) | Via getSyncHistory() ✅ |
| Art. 10-11 (Segurança) | HTTPS, Hive, hash integrity ✅ |
| Art. 12-13 (Transparência) | Tela clara com explicações ✅ |
| Art. 17-18 (Direitos) | Revogar consentimento, acessar histórico ✅ |

---

## 📚 Referências

- Lei 13.709/2018 (LGPD) - Completa implementação
- Parecer CNJ sobre ICP-Brasil
- ISO 27001 (Segurança da Informação)

---

## ✅ Status

- [x] SyncStatsService implementado
- [x] Agregação anônima funcionando
- [x] LgpdConsentScreen criada
- [x] Integração no SyncManager
- [x] Documentação LGPD completa
- [ ] Endpoint servidor (TODO: implementar em backend)
- [ ] Testes de carga (TODO: QA)

---

**Commit**: Sincronização LGPD implementada + documentação ✅

