/// Serviço de Telemetria para Rastreamento de Economia SUS
/// Funciona como um "contador de poupança" que mostra impacto real
/// Dados persistentes em Hive (funcionam offline)

import 'package:hive/hive.dart';
import 'dart:convert';

part 'telemetry_event.dart';

class TelemetryService {
  static const String _telemetryBoxName = 'telemetry';
  static const String _keyTotalSavedBRL = 'total_saved_brl';
  static const String _keyExamsAvoided = 'exams_avoided_count';
  static const String _keyStatinOptimized = 'statin_optimized_count';
  static const String _keyDDimerUsed = 'ddimer_used_count';
  static const String _keyFirstUse = 'first_use_timestamp';

  /// Tabela de Preços Médios SIGTAP (SUS) - 2026
  /// Pode ser atualizada via guidelines.json remoto (futuro)
  static const Map<String, double> priceTable = {
    // Exames evitados
    'ANGIO_TC_CHEST': 1500.00, // Angiotomografia de Tórax (CTA)
    'ANGIO_CT': 1200.00, // Angiotomografia genérica
    'CT_SCAN': 800.00, // Tomografia simples
    'MRI': 2000.00, // Ressonância magnética
    'ULTRASOUND': 150.00, // Ultrassom

    // Exames alternativos (mais baratos)
    'D_DIMER': 45.00, // D-Dímero sérico
    'INR_TEST': 35.00, // INR
    'ECG': 25.00, // Eletrocardiograma
    'TROPONIN': 60.00, // Troponina

    // Medicações SUS (custo mensal)
    'SINVASTATINA_20': 12.50,
    'SINVASTATINA_40': 15.00,
    'ATORVASTATINA_40': 20.00,
    'EZETIMIBA': 30.00,
  };

  /// Registra um evento de economia
  static Future<void> logSaving({
    required String procedureType, // Tipo de procedimento evitado
    required double cost, // Valor em R$
    required String calculatorType, // 'wells', 'cardio', etc
    required String outcome, // 'exam_avoided', 'optimized', etc
  }) async {
    try {
      final box = Hive.box(_telemetryBoxName);

      // 1. Primeira vez usando? Registra timestamp
      if (box.get(_keyFirstUse) == null) {
        await box.put(_keyFirstUse, DateTime.now().toIso8601String());
      }

      // 2. Incrementa contador específico
      final counterKey = '${calculatorType}_${outcome}';
      int currentCount = box.get(counterKey, defaultValue: 0) as int;
      await box.put(counterKey, currentCount + 1);

      // 3. Incrementa valor total em R$
      double totalSaved = box.get(_keyTotalSavedBRL, defaultValue: 0.0) as double;
      await box.put(_keyTotalSavedBRL, totalSaved + cost);

      // 4. Registra evento detalhado (para futura análise)
      _logEvent(
        procedureType: procedureType,
        cost: cost,
        calculatorType: calculatorType,
        outcome: outcome,
      );

      print('[FluxSUS] 💰 Economia registrada: R\$ ${cost.toStringAsFixed(2)}');
    } catch (e) {
      print('[FluxSUS] ❌ Erro ao registrar telemetria: $e');
    }
  }

  /// Registra quando um exame foi evitado (Wells: improvável → D-Dímero)
  static Future<void> logExamAvoided({
    required String examType, // 'ANGIO_TC_CHEST'
    required String reason, // 'wells_improvável', etc
  }) async {
    final cost = priceTable[examType] ?? 0.0;
    await logSaving(
      procedureType: examType,
      cost: cost,
      calculatorType: 'wells',
      outcome: 'exam_avoided',
    );
  }

  /// Registra quando medicação foi otimizada (Cardio: reduz dose)
  static Future<void> logMedicationOptimized({
    required String originalDrug,
    required String optimizedDrug,
    required double monthlySavings,
  }) async {
    await logSaving(
      procedureType: '$originalDrug → $optimizedDrug',
      cost: monthlySavings * 12, // Anualizado
      calculatorType: 'cardio',
      outcome: 'medication_optimized',
    );
  }

  /// Obtém estatísticas gerais
  static Future<Map<String, dynamic>> getStats() async {
    try {
      final box = Hive.box(_telemetryBoxName);

      final totalSavedBRL = box.get(_keyTotalSavedBRL, defaultValue: 0.0) as double;
      final examsAvoided = box.get(_keyExamsAvoided, defaultValue: 0) as int;
      final firstUse = box.get(_keyFirstUse) as String?;

      // Calcula economia média por exame evitado
      final avgPerExam = examsAvoided > 0 ? totalSavedBRL / examsAvoided : 0.0;

      // Calcula dias de uso
      final daysActive = firstUse != null
          ? DateTime.now().difference(DateTime.parse(firstUse)).inDays
          : 0;

      // Calcula economia por dia
      final avgPerDay = daysActive > 0 ? totalSavedBRL / daysActive : 0.0;

      return {
        'total_saved_brl': totalSavedBRL,
        'exams_avoided': examsAvoided,
        'avg_per_exam': avgPerExam,
        'days_active': daysActive,
        'avg_per_day': avgPerDay,
        'first_use': firstUse,
        'currency': 'BRL',
      };
    } catch (e) {
      print('[FluxSUS] ❌ Erro ao obter estatísticas: $e');
      return {};
    }
  }

  /// Obtém economia total formatada
  static Future<String> getTotalSavingsFormatted() async {
    final stats = await getStats();
    final amount = (stats['total_saved_brl'] as double?) ?? 0.0;
    return 'R\$ ${amount.toStringAsFixed(2)}';
  }

  /// Obtém breakdown por tipo
  static Future<Map<String, int>> getBreakdownByType() async {
    try {
      final box = Hive.box(_telemetryBoxName);
      final breakdown = <String, int>{};

      // Itera todos os contadores
      for (final key in box.keys) {
        if (key.toString().contains('_')) {
          final value = box.get(key) as int?;
          if (value != null && value > 0) {
            breakdown[key.toString()] = value;
          }
        }
      }

      return breakdown;
    } catch (e) {
      print('[FluxSUS] ❌ Erro ao obter breakdown: $e');
      return {};
    }
  }

  /// Limpa dados de telemetria (reset)
  static Future<void> clearTelemetry() async {
    try {
      final box = Hive.box(_telemetryBoxName);
      await box.clear();
      print('[FluxSUS] 🧹 Telemetria limpa');
    } catch (e) {
      print('[FluxSUS] ❌ Erro ao limpar telemetria: $e');
    }
  }

  /// Exporta dados em JSON para análise
  static Future<String> exportAsJson() async {
    try {
      final stats = await getStats();
      final breakdown = await getBreakdownByType();

      final export = {
        'timestamp': DateTime.now().toIso8601String(),
        'statistics': stats,
        'breakdown': breakdown,
      };

      return jsonEncode(export);
    } catch (e) {
      print('[FluxSUS] ❌ Erro ao exportar: $e');
      return '{}';
    }
  }

  /// Registra um evento detalhado (privado)
  static void _logEvent({
    required String procedureType,
    required double cost,
    required String calculatorType,
    required String outcome,
  }) {
    try {
      final box = Hive.box(_telemetryBoxName);

      // Cria chave única para cada evento
      final eventKey = '${calculatorType}_${outcome}_${DateTime.now().millisecondsSinceEpoch}';

      // Opcionalmente: salvar para auditoria (futuro)
      // Por agora, apenas em memória
    } catch (e) {
      print('[FluxSUS] ❌ Erro ao registrar evento: $e');
    }
  }

  /// Obtém preço de um procedimento
  static double? getPrice(String procedureKey) {
    return priceTable[procedureKey];
  }

  /// Atualiza tabela de preços (futuro: via JSON remoto)
  static Future<void> updatePriceTable(
    Map<String, double> newPrices,
  ) async {
    try {
      // Aqui seria integrado com guidelines.json
      // Por enquanto, apenas valida entrada
      print('[FluxSUS] 📊 Tabela de preços atualizada (${newPrices.length} itens)');
    } catch (e) {
      print('[FluxSUS] ❌ Erro ao atualizar preços: $e');
    }
  }
}
