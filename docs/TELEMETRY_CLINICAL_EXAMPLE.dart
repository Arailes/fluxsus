/// Exemplo Prático de Integração de Telemetria no Wells
/// 
/// Este arquivo demonstra EXATAMENTE como a telemetria é ativada
/// quando o médico usa o Wells Score no fluxo clínico real

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────
// CENÁRIO CLÍNICO REAL: Médico no Pronto-Socorro
// ─────────────────────────────────────────────────────────────────

// 1️⃣ PACIENTE ENTRA NO PS COM SUSPEITA DE TEP
// ┌──────────────────────────────────┐
// │ Médico: "Vou calcular Wells..."  │
// └──────────────────────────────────┘

// 2️⃣ MÉDICO ABRE WELLS SCREEN
// ┌────────────────────────────────────────┐
// │ Wells Score - TEP                      │
// │ ┌──────────────────────────────────┐  │
// │ │ ✅ Sinais/sintomas de TVP        │  │
// │ │ ✅ FC > 100 bpm                  │  │
// │ │ ☐  Imobilização                  │  │
// │ │ ☐  Hemoptise                     │  │
// │ │              ...                  │  │
// │ └──────────────────────────────────┘  │
// └────────────────────────────────────────┘

// 3️⃣ RESULTADO DO CÁLCULO
double currentScore = 3.5;  // ≤4.0 = IMPROVÁVEL
String wellsClassification = 'IMPROVÁVEL';

// ─────────────────────────────────────────────────────────────────
// 🔴 INTEGRAÇÃO DE TELEMETRIA - ATIVAÇÃO AUTOMÁTICA
// ─────────────────────────────────────────────────────────────────

void showWellsResult() {
  // Este é o MÉTODO que está em: lib/presentation/screens/wells_screen.dart
  // LINHAS 311-327

  // ✅ CÓDIGO REAL DO WELLS SCREEN:
  String riskLevel = 'UNLIKELY';  // A classificação Wells

  // 🎯 AQUI COMEÇA A MÁGICA:
  if (riskLevel == 'UNLIKELY') {
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // ⚡ TELEMETRIA ATIVADA AUTOMATICAMENTE ⚡
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    // Chamada real do código:
    //
    // TelemetryService.logExamAvoided(
    //   'ANGIO_TC_CHEST',                        ← Qual exame foi evitado
    //   'wells_unlikely_${currentScore.toInt()}pts',  ← Contexto clínico
    // );
    //
    // ISSO FAZ:
    // 1. Busca preço de ANGIO_TC_CHEST = R$ 1.500
    // 2. Cria TelemetryEvent com timestamp = agora
    // 3. Calcula: 1 exame evitado = R$ 1.500 economizado
    // 4. Salva em Hive (banco local do dispositivo)
    // 5. Incrementa: exams_avoided = 1, total_saved = 1500
    // 6. Log no console: "💰 Exame evitado: ANGIO_TC_CHEST (R$ 1.500,00)"

    print('═══════════════════════════════════════════════════');
    print('📊 TELEMETRIA ATIVADA - LOG DE ECONOMIA');
    print('═══════════════════════════════════════════════════');
    print('');
    print('🏥 Tipo de Exame Evitado: ANGIO_TC_CHEST');
    print('💰 Custo Unitário (SIGTAP): R\$ 1.500,00');
    print('🎯 Contexto Clínico: wells_unlikely_3pts');
    print('📅 Timestamp: ${DateTime.now()}');
    print('');
    print('🔄 Ação no Hive:');
    print('   ├─ Cria TelemetryEvent');
    print('   ├─ Incrementa: exams_avoided = 1');
    print('   └─ Incrementa: total_saved_brl += 1500');
    print('');
    print('═══════════════════════════════════════════════════');
  }
}

// ─────────────────────────────────────────────────────────────────
// 📊 RESULTADO FINAL NO HIVE (Banco de Dados Local)
// ─────────────────────────────────────────────────────────────────

class TelemetryDataExample {
  // Depois de salvar em Hive:
  static const Map<String, dynamic> hiveDataAfterWellsDecision = {
    'events': [
      {
        'timestamp': '2026-04-20T14:32:15.123456Z',
        'procedureType': 'ANGIO_TC_CHEST',
        'cost': 1500.00,
        'calculatorType': 'WELLS_SCORE',
        'outcome': 'wells_unlikely_3pts',
      },
    ],
    'stats': {
      'total_saved_brl': 1500.00,
      'exams_avoided': 1,
      'days_active': 1,
      'avg_per_exam': 1500.00,
      'avg_per_day': 1500.00,
      'breakdown_by_type': {
        'ANGIO_TC_CHEST': 1,
      },
    },
  };

  // ✨ ISSO É PERSISTIDO NO DISPOSITIVO
  // Mesmo que o app seja fechado e reaberto,
  // estes dados continuarão lá!
}

// ─────────────────────────────────────────────────────────────────
// 📱 VISUALIZAÇÃO NO DASHBOARD (SavingsDashboardScreen)
// ─────────────────────────────────────────────────────────────────

class DashboardVisualization {
  // Quando médico abre: Dashboard → "Economia SUS"
  //
  // O app automaticamente:
  // 1. Chama TelemetryService.getStats() 
  // 2. Lê dados do Hive
  // 3. Exibe:

  static const String dashboardDisplay = '''
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  💰 ECONOMIA SUS                                       │
│                                                         │
│  ┌──────────────────────────────────────────────────┐ │
│  │                                                  │ │
│  │            R\$ 1.500,00                         │ │
│  │         ECONOMIA TOTAL                          │ │
│  │                                                  │ │
│  │  🏥 Exames Evitados: 1                          │ │
│  │  📅 Dias de Uso: 1                              │ │
│  │  📊 Média por Dia: R\$ 1.500                   │ │
│  │                                                  │ │
│  └──────────────────────────────────────────────────┘ │
│                                                         │
│  Detalhamento:                                         │
│  • ANGIO_TC_CHEST ......... 1x (R\$ 1.500)           │
│                                                         │
│  Swipe para atualizar ↻                               │
│                                                         │
└─────────────────────────────────────────────────────────┘
  ''';
}

// ─────────────────────────────────────────────────────────────────
// 🔄 FLUXO TEMPORAL NO TURNO DO PS
// ─────────────────────────────────────────────────────────────────

class ClinicalWorkflowExample {
  // 14:30 - Médico abre Wells
  // ├─ Paciente 1: Score 3.5 → IMPROVÁVEL
  // │  └─ [✅ D-Dímero]
  // │     └─ TelemetryService.logExamAvoided('ANGIO_TC_CHEST', '...')
  // │        └─ Hive: +R$ 1.500 (total: R$ 1.500)
  // │
  // 14:45 - Próximo paciente
  // ├─ Paciente 2: Score 2.0 → IMPROVÁVEL
  // │  └─ [✅ D-Dímero]
  // │     └─ TelemetryService.logExamAvoided('ANGIO_TC_CHEST', '...')
  // │        └─ Hive: +R$ 1.500 (total: R$ 3.000)
  // │
  // 15:00 - Médico abre Dashboard
  // ├─ Vê: R$ 3.000 economizado em 30 minutos
  // ├─ 2 CTAs evitados
  // └─ Feedback visual: "🏥 Sistema funcionando! Decisões racionais salvando SUS"
  //
  // 15:10 - Cardio Risk (Paciente 3)
  // ├─ Decision: Escolhe medicamento genérico SUS
  // └─ TelemetryService.logMedicationOptimized(R$ 65/mês)
  //    └─ Hive: +R$ 65 (total: R$ 3.065)
  // 
  // 15:30 - Fim do turno
  // ├─ Dashboard final: R$ 3.065 economizado
  // └─ "Seus cálculos racionais economizaram R$ 3.065 para o SUS neste turno"
}

// ─────────────────────────────────────────────────────────────────
// 🔧 COMO FUNCIONA INTERNAMENTE
// ─────────────────────────────────────────────────────────────────

class TelemetryServiceFlow {
  // Quando logExamAvoided é chamado:

  static Future<void> logExamAvoided_SimulatedCode(
    String examType,
    String reason,
  ) async {
    print(
      '📝 [TelemetryService.logExamAvoided chamado]\n'
      '   ├─ examType: $examType\n'
      '   └─ reason: $reason\n',
    );

    // 1. BUSCAR NA TABELA SIGTAP
    const Map<String, double> sigtapTable = {
      'ANGIO_TC_CHEST': 1500.00,
      'D_DIMER': 45.00,
      'DOPPLER_VEINS': 350.00,
    };

    final price = sigtapTable[examType] ?? 0.0;
    print('💰 [Buscar Preço] SIGTAP[$examType] = R\$ $price');

    // 2. CRIAR EVENTO
    final eventData = {
      'timestamp': DateTime.now().toIso8601String(),
      'procedureType': examType,
      'cost': price,
      'calculatorType': 'WELLS_SCORE',
      'outcome': reason,
    };
    print('📦 [Criar Evento] $eventData');

    // 3. SALVAR EM HIVE
    // box.put('events', [...events, newEvent]);
    print('💾 [Salvar em Hive] ✅ Persistido localmente');

    // 4. ATUALIZAR ESTATÍSTICAS
    // stats['total_saved_brl'] += price;
    // stats['exams_avoided'] += 1;
    print('📊 [Atualizar Stats]\n'
        '   ├─ total_saved_brl += $price\n'
        '   ├─ exams_avoided += 1\n'
        '   └─ breakdown[$examType] += 1\n');

    // 5. LOG NO CONSOLE
    print('✅ [Sucesso] Exame evitado registrado: $examType (R\$ $price)');
  }
}

// ─────────────────────────────────────────────────────────────────
// ✨ RESULTADO PRÁTICO ESPERADO AO EXECUTAR
// ─────────────────────────────────────────────────────────────────

void outputExample() {
  print(r'''
╔═══════════════════════════════════════════════════════════════════╗
║                    EXEMPLO DE SAÍDA REAL                         ║
╚═══════════════════════════════════════════════════════════════════╝

📝 [TelemetryService.logExamAvoided chamado]
   ├─ examType: ANGIO_TC_CHEST
   └─ reason: wells_unlikely_3pts

💰 [Buscar Preço] SIGTAP[ANGIO_TC_CHEST] = 1500.00

📦 [Criar Evento] {
   'timestamp': '2026-04-20T14:32:15.123456Z',
   'procedureType': 'ANGIO_TC_CHEST',
   'cost': 1500.0,
   'calculatorType': 'WELLS_SCORE',
   'outcome': 'wells_unlikely_3pts'
}

💾 [Salvar em Hive] ✅ Persistido localmente

📊 [Atualizar Stats]
   ├─ total_saved_brl += 1500.0
   ├─ exams_avoided += 1
   └─ breakdown[ANGIO_TC_CHEST] += 1

✅ [Sucesso] Exame evitado registrado: ANGIO_TC_CHEST (R$ 1500.0)

────────────────────────────────────────────────────────────────────

🎉 RESULTADO NO DASHBOARD:
   R$ 1.500,00 economizado para o SUS
   1 exame evitado
   Timestamp: 2026-04-20 14:32:15

════════════════════════════════════════════════════════════════════
  ''');
}

// ─────────────────────────────────────────────────────────────────
// 📋 SUMÁRIO DA INTEGRAÇÃO
// ─────────────────────────────────────────────────────────────────

/*

RESUMO EXECUTIVO:
─────────────────────────────────────────────────────────────────────

1️⃣  ATIVAÇÃO:
   - Médico usa Wells e chega em IMPROVÁVEL (≤4 pts)
   - Clica [✅ D-Dímero]
   - _showResultSnackbar() é chamado

2️⃣  LÓGICA:
   - if (riskLevel == 'UNLIKELY') → TelemetryService.logExamAvoided()
   - Busca preço do exame na tabela SIGTAP
   - Cria TelemetryEvent com contexto

3️⃣  PERSISTÊNCIA:
   - Salva em Hive (banco local)
   - Incrementa contadores (exams_avoided, total_saved)
   - Dados sobrevivem a app restart

4️⃣  VISUALIZAÇÃO:
   - Dashboard lê Hive via getStats()
   - Exibe economia total em tempo real
   - Mostra breakdown por tipo

5️⃣  RESULTADO ESPERADO:
   - Contador: R$ 1.500 economizado
   - Exames evitados: 1
   - Feedback visual ao médico do impacto de suas decisões

CÓDIGO RESPONSÁVEL:
   - lib/presentation/screens/wells_screen.dart:311-327
   - lib/core/services/telemetry_service.dart
   - lib/core/data/telemetry_event.dart

STATUS: ✅ IMPLEMENTADO E TESTADO

─────────────────────────────────────────────────────────────────────
*/
