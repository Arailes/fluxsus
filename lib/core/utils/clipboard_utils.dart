/// Utilitário de Clipping para Prontuário Eletrônico
/// Formata texto para cópia segura em sistemas e-SUS

class ClipboardUtils {
  /// Formata texto SOAP padrão para prontuário
  /// Remove caracteres especiais problemáticos para alguns sistemas
  static String sanitizeForSOAP(String text) {
    return text
        .replaceAll('═', '─')
        .replaceAll('✓', '[X]')
        .replaceAll('💰', '[ECONOMIA]')
        .replaceAll('✅', '[OK]')
        .replaceAll('🚨', '[URGÊNCIA]')
        .replaceAll('📋', '[AVALIAÇÃO]')
        .replaceAll('📊', '[DADOS]')
        .replaceAll('🔍', '[ANÁLISE]')
        .replaceAll('💊', '[PLANO]');
  }

  /// Compacta texto removendo linhas vazias excessivas
  static String compactWhitespace(String text) {
    return text.replaceAll(RegExp(r'\n\n\n+'), '\n\n');
  }

  /// Gera referência de algoritmo para justificativa
  static String getAlgorithmReference(String calculatorType) {
    const references = {
      'wells': 'Wells PE Clinical Decision Rule',
      'cardio': 'Framingham Risk Score / ASCVD',
      'lab': 'Protocolo de Interpretação Laboratorial SUS',
    };
    return references[calculatorType] ?? 'Protocolo SUS';
  }

  /// Cria footer padrão para todos os resumos
  static String createStandardFooter() {
    return '''
────────────────────────────────────────────
FluxSUS ∙ Ferramenta de Apoio Clínico SUS
Uso exclusivo em ambiente clínico
────────────────────────────────────────────
''';
  }
}
