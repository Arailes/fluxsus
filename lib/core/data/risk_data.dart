/// Tabelas de Risco Cardiovascular
/// Baseadas em diretrizes SUS/RENAME com adaptações para protocolos clínicos

class RiskTables {
  /// Pontuação por Idade - Homem
  /// Faixa etária de 30 a 54 anos
  static const Map<int, int> maleAgePoints = {
    30: -1, 31: -1, 32: -1, 33: -1, 34: -1,
    35: 0, 36: 0, 37: 0, 38: 0, 39: 0,
    40: 1, 41: 1, 42: 1, 43: 1, 44: 1,
    45: 2, 46: 2, 47: 2, 48: 2, 49: 2,
    50: 3, 51: 3, 52: 3, 53: 3, 54: 3,
  };

  /// Classificação de Risco e Meta de LDL (Foco SUS/RENAME)
  /// Define categorias de risco com cores para UI, metas e medicações disponíveis
  static const Map<String, Map<String, dynamic>> riskLevels = {
    'BAIXO': {
      'min': 0,
      'max': 5,
      'color': 0xFF4CAF50, // Verde
      'goal': 'LDL < 100',
      'drug': 'Sinvastatina 20mg',
    },
    'INTERMEDIARIO': {
      'min': 5,
      'max': 20,
      'color': 0xFFFFC107, // Amarelo
      'goal': 'LDL < 70',
      'drug': 'Sinvastatina 40mg',
    },
    'ALTO': {
      'min': 20,
      'max': 100,
      'color': 0xFFF44336, // Vermelho
      'goal': 'LDL < 50',
      'drug': 'Atorvastatina 40mg',
    },
  };

  /// Obtém a classificação de risco baseado em pontuação
  static String getRiskLevel(int score) {
    for (final entry in riskLevels.entries) {
      final min = entry.value['min'] as int;
      final max = entry.value['max'] as int;
      if (score >= min && score < max) {
        return entry.key;
      }
    }
    return 'ALTO'; // Padrão para score >= 20
  }

  /// Obtém pontos por idade (homem)
  static int? getMaleAgePoints(int age) => maleAgePoints[age];

  /// Valida se idade está na faixa de risco
  static bool isAgeValid(int age) => age >= 30 && age <= 54;
}
