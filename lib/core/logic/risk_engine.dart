/// Motor de cálculo de risco cardiovascular
/// Implementa algoritmo de pontuação baseado em idade, gênero e fatores clínicos

import '../data/risk_data.dart';

class RiskEngine {
  /// Calcula pontuação por idade conforme gênero
  /// 
  /// [gender]: 'MALE' ou 'FEMALE'
  /// [age]: Idade em anos inteiros
  /// 
  /// Retorna pontuação ou valor padrão se fora da faixa
  static int getAgeScore(String gender, int age) {
    if (gender == 'MALE') {
      // Busca a idade ou retorna o valor mais próximo
      if (RiskTables.maleAgePoints.containsKey(age)) {
        return RiskTables.maleAgePoints[age]!;
      }
      // Extrapolação: idade < 30 = -1, idade > 54 = 3
      return age < 30 ? -1 : 3;
    }
    
    if (gender == 'FEMALE') {
      // TODO: Implementar tabela de pontuação para mulheres
      return 0;
    }
    
    throw ArgumentError('Gênero inválido: $gender');
  }

  /// Obtém classificação final de risco baseado em pontos totais
  /// 
  /// [totalPoints]: Suma de pontos do cálculo
  /// 
  /// Retorna mapa com: min, max, color, goal, drug
  static Map<String, dynamic> getFinalRisk(int totalPoints) {
    final exactMatch = RiskTables.riskLevels.entries.firstWhere(
      (e) => totalPoints >= e.value['min'] && totalPoints < e.value['max'],
      orElse: () => RiskTables.riskLevels.entries.last, // ALTO é padrão
    );
    
    return {
      'level': exactMatch.key,
      ...exactMatch.value,
      'score': totalPoints,
    };
  }

  /// Valida se os dados de entrada são válidos
  static bool isValidInput(String gender, int age) {
    if (gender != 'MALE' && gender != 'FEMALE') return false;
    if (age < 18 || age > 120) return false;
    return true;
  }
}
