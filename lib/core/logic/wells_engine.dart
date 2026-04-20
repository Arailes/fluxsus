/// Motor de cálculo Wells Score
/// Implementa algoritmo de estratificação de risco para TEP
/// Baseado em critérios clínicos simples (Versão Dois Níveis)

import '../data/wells_data.dart';

class WellsEngine {
  /// Calcula score Wells baseado em critérios selecionados
  /// 
  /// [selectedCriteria]: Mapa de critério -> selecionado (true/false)
  /// 
  /// Retorna score total em pontos
  static double calculateScore(Map<String, bool> selectedCriteria) {
    double totalScore = 0.0;

    for (final entry in selectedCriteria.entries) {
      if (entry.value) {
        final score = WellsData.getCriterionScore(entry.key);
        if (score != null) {
          totalScore += score;
        }
      }
    }

    return totalScore;
  }

  /// Obtém classificação de risco (UNLIKELY / LIKELY)
  static String getRiskClassification(double score) {
    return WellsData.getRiskLevel(score);
  }

  /// Obtém recomendação clínica completa
  /// 
  /// [score]: Score total do Wells
  /// 
  /// Retorna mapa com: level, label, action, color, etc
  static Map<String, dynamic> getRecommendation(double score) {
    return WellsData.getRecommendation(score);
  }

  /// Valida se entrada é válida
  static bool isValidScore(double score) {
    return WellsData.isScoreValid(score);
  }

  /// Retorna string descritiva do nível de risco
  static String getDescriptiveLevel(double score) {
    final rec = WellsData.getRecommendation(score);
    final label = rec['label'] as String;
    final description = rec['description'] as String;
    return '$label\n$description';
  }

  /// Calcula o "potencial de economia" em exames
  /// Útil para demonstrar valor da ferramenta ao SUS
  static Map<String, dynamic> calculateClinicalImpact(double score) {
    final riskLevel = getRiskClassification(score);

    return {
      'risk_level': riskLevel,
      'ct_scan_needed': riskLevel == 'LIKELY',
      'ddimer_sufficient': riskLevel == 'UNLIKELY',
      'potential_savings': riskLevel == 'UNLIKELY'
          ? 'CT evitada - Economia: ~R$ 1.500'
          : 'CT indicada - Segurança prioritária',
      'radiation_exposure_avoided': riskLevel == 'UNLIKELY',
    };
  }

  /// Debug: Retorna detalhes do cálculo
  static Map<String, dynamic> getCalculationDetails(
    Map<String, bool> selectedCriteria,
  ) {
    final details = <String, double>{};

    for (final entry in selectedCriteria.entries) {
      if (entry.value) {
        final score = WellsData.getCriterionScore(entry.key);
        if (score != null) {
          details[entry.key] = score;
        }
      }
    }

    final totalScore =
        details.values.fold<double>(0.0, (sum, score) => sum + score);

    return {
      'breakdown': details,
      'total_score': totalScore,
      'criteria_count': selectedCriteria.values.where((v) => v).length,
      'risk_level': getRiskClassification(totalScore),
    };
  }
}
