/// Tabelas e Critérios Wells Score para Tromboembolismo Pulmonar (TEP)
/// Estratificação de risco baseada em critérios clínicos simples
/// Versão "Dois Níveis": PE Unlikely vs PE Likely (Otimização para Pronto-Socorro)
/// 
/// Referência: Wells PE Clinical Decision Rule
/// Relevância SUS: Reduz número de tomografias desnecessárias

class WellsData {
  /// Critérios clínicos com pontuação individual
  static const Map<String, double> criteria = {
    'Sinais clínicos de TVP (Edema + Dor)': 3.0,
    'TEP como diagnóstico principal ou provável': 3.0,
    'Frequência Cardíaca > 100 bpm': 1.5,
    'Cirurgia ou Imobilização (últimas 4 semanas)': 1.5,
    'Antecedente de TEP ou TVP': 1.5,
    'Hemoptise (escarro com sangue)': 1.0,
    'Câncer em tratamento ou paliativo': 1.0,
  };

  /// Interpretação dos scores em dois níveis
  /// PE Unlikely (baixo risco) vs PE Likely (alto risco)
  static const Map<String, Map<String, dynamic>> interpretation = {
    'UNLIKELY': {
      'max_score': 4.0,
      'min_score': 0.0,
      'label': 'TEP IMPROVÁVEL',
      'description': 'Baixa probabilidade clínica',
      'action': 'Solicitar D-Dímero. Se negativo, TEP excluído. NÃO pedir Angio-TC.',
      'saving_potential': 'ALTA (Evita Tomografia desnecessária)',
      'color': 0xFF4CAF50, // Verde
      'icon': 'check_circle',
      'recommendation': 'Continue investigação clínica. Alta segura se D-Dímero negativo.',
    },
    'LIKELY': {
      'max_score': 15.0, // Teto teórico para referência
      'min_score': 4.0,
      'label': 'TEP PROVÁVEL',
      'description': 'Alta probabilidade clínica',
      'action': 'Solicitar Angiotomografia de Tórax com Protocolo PE (CTA) IMEDIATAMENTE.',
      'saving_potential': 'N/A (Exame essencial para segurança do paciente)',
      'color': 0xFFF44336, // Vermelho
      'icon': 'warning',
      'recommendation': 'Exame de imagem é indicado. Não adiar. Considerar anticoagulação conforme protocolo.',
    }
  };

  /// Ordem recomendada de abordagem clínica
  static const List<Map<String, String>> clinicalApproach = [
    {
      'step': '1',
      'description': 'Avaliação clínica completa',
      'details': 'Anamnese de risco, exame físico focado em sinais de TVP e insuficiência cardíaca'
    },
    {
      'step': '2',
      'description': 'Calcular Wells Score',
      'details': 'Somar critérios presentes. Score ≤ 4 = Unlikely; Score > 4 = Likely'
    },
    {
      'step': '3',
      'description': 'Se UNLIKELY',
      'details': 'Solicitar D-Dímero. Se negativo, TEP excluído com segurança (NPV > 99%)'
    },
    {
      'step': '4',
      'description': 'Se LIKELY',
      'details': 'NÃO esperar D-Dímero. Solicitar CTA Tórax imediatamente'
    },
  ];

  /// Meta de economia no SUS (redução de exames desnecessários)
  static const Map<String, dynamic> susSavingsPotential = {
    'avoided_ct_scans_percentage': 30, // 30% das TCs poderiam ser evitadas
    'ddimer_cost_saving': 'R$ 150-300 por paciente (vs. CTA R$ 1500+)',
    'efficiency_gain': 'Reduz tempo de espera por fila de CT',
    'safety_improvement': 'Evita exposição à radiação desnecessária',
  };

  /// Obtém classificação baseado em score total
  static String getRiskLevel(double score) {
    if (score <= 4.0) {
      return 'UNLIKELY';
    }
    return 'LIKELY';
  }

  /// Obtém recomendação estruturada
  static Map<String, dynamic> getRecommendation(double score) {
    final riskLevel = getRiskLevel(score);
    final recommendation = interpretation[riskLevel] ?? interpretation['UNLIKELY']!;

    return {
      'level': riskLevel,
      'score': score,
      ...recommendation,
    };
  }

  /// Valida se score está na faixa esperada
  static bool isScoreValid(double score) {
    return score >= 0 && score <= 15.0;
  }

  /// Retorna lista de critérios para checklist UI
  static List<String> getCriteriaList() {
    return criteria.keys.toList();
  }

  /// Obtém pontuação de um critério específico
  static double? getCriterionScore(String criterion) {
    return criteria[criterion];
  }
}
