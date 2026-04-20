/// Gerador de Notas SOAP para Prontuário Eletrônico
/// Garante blindagem jurídica e rastreabilidade de decisões clínicas
/// Usa padrão SOAP (Subjetivo, Objetivo, Avaliação, Plano)

import 'package:intl/intl.dart';

class SOAPFormatter {
  /// Gera nota SOAP para Wells Score (TEP)
  static String generateWellsSOAP({
    required double score,
    required String riskLevel,
    required String label,
    required String action,
    required List<String> selectedCriteria,
    required Map<String, double> criteriaScores,
  }) {
    final now = DateTime.now();
    final dateTime = DateFormat('dd/MM/yyyy HH:mm').format(now);
    
    // Monta breakdown de critérios
    final criteriaBreakdown = selectedCriteria
        .map((c) => '  └─ $c: +${criteriaScores[c]?.toStringAsFixed(1)} pts')
        .join('\n');

    return '''
╔════════════════════════════════════════════════════════════╗
║        AVALIAÇÃO DE RISCO - TROMBOEMBOLISMO PULMONAR       ║
║                    WELLS SCORE PE                          ║
╚════════════════════════════════════════════════════════════╝

DATA/HORA: $dateTime
ALGORITMO: Wells PE Clinical Decision Rule
REFERÊNCIA: Baseado em evidência clínica internacional

─────────────────────────────────────────────────────────────
S - SUBJETIVO:
─────────────────────────────────────────────────────────────
Paciente avaliado com avaliação clínica dirigida para estratificação 
de risco de Tromboembolismo Pulmonar (TEP) conforme protocolo Wells Score.

─────────────────────────────────────────────────────────────
O - OBJETIVO:
─────────────────────────────────────────────────────────────
Aplicado escore de Wells para TEP (versão simplificada - dois níveis):

Critérios Identificados:
$criteriaBreakdown

Score Total: ${score.toStringAsFixed(1)} pontos
Classificação: $riskLevel

─────────────────────────────────────────────────────────────
A - AVALIAÇÃO:
─────────────────────────────────────────────────────────────
$label

Interpretação: 
${riskLevel == 'UNLIKELY' ? 
  'Probabilidade pré-teste BAIXA para TEP. Estratégia: D-Dímero sérico.' :
  'Probabilidade pré-teste ALTA para TEP. Estratégia: Imagem diagnóstica (CTA).'
}

Fundamentação:
• Wells Score é ferramenta validada para estratificação clínica
• Score ≤ 4.0 = Improvável (NPV > 99% se D-Dímero negativo)
• Score > 4.0 = Provável (CTA indicada para confirmação)
• Evita exposição à radiação desnecessária (manuseio racional)

─────────────────────────────────────────────────────────────
P - PLANO:
─────────────────────────────────────────────────────────────
$action

Justificativa Técnica:
✓ Decisão fundamentada em algoritmo validado internacionalmente
✓ Otimização de recursos diagnósticos (uso racional)
✓ Segurança do paciente (evita radiação ou atraso diagnóstico)
✓ Rastreabilidade: Esta avaliação foi automatizada via FluxSUS

Próximos Passos:
${riskLevel == 'UNLIKELY' 
  ? '1. Solicitar D-Dímero (sérum/plasma)\n2. Se negativo: TEP excluído\n3. Se positivo: Reavalia para CTA'
  : '1. Encaminhar para CTA Tórax com protocolo PE\n2. NÃO aguardar D-Dímero\n3. Considerar anticoagulação conforme protocolo'
}

─────────────────────────────────────────────────────────────
BLINDAGEM JURÍDICA:
─────────────────────────────────────────────────────────────
✓ Decisão clínica fundamentada em "Standard of Care"
✓ Evita sobrediagnóstico (exposição à radiação desnecessária)
✓ Baseada em Medicina Baseada em Evidências (MBE)
✓ Rastreada e documentada no prontuário
✓ Ferramenta validada: Wells PE Score

─────────────────────────────────────────────────────────────
FERRAMENTA: FluxSUS v1.0 | SYNC: Automático (24h)
═════════════════════════════════════════════════════════════
''';
  }

  /// Gera nota SOAP para Risco Cardiovascular
  static String generateCardioSOAP({
    required double score,
    required String riskLevel,
    required String label,
    required String ldlGoal,
    required String medication,
  }) {
    final now = DateTime.now();
    final dateTime = DateFormat('dd/MM/yyyy HH:mm').format(now);

    return '''
╔════════════════════════════════════════════════════════════╗
║          AVALIAÇÃO DE RISCO CARDIOVASCULAR                 ║
║                 FRAMINGHAM SCORE                           ║
╚════════════════════════════════════════════════════════════╝

DATA/HORA: $dateTime
ALGORITMO: Framingham Risk Score (adaptado SUS)
REFERÊNCIA: Diretriz SUS/RENAME para Lipidemia

─────────────────────────────────────────────────────────────
S - SUBJETIVO:
─────────────────────────────────────────────────────────────
Paciente avaliado para estratificação de risco cardiovascular.

─────────────────────────────────────────────────────────────
O - OBJETIVO:
─────────────────────────────────────────────────────────────
Escore calculado: ${score.toStringAsFixed(0)} pontos
Classificação: $riskLevel

─────────────────────────────────────────────────────────────
A - AVALIAÇÃO:
─────────────────────────────────────────────────────────────
$label

Meta de LDL: $ldlGoal
Medicação SUS Disponível (RENAME): $medication

─────────────────────────────────────────────────────────────
P - PLANO:
─────────────────────────────────────────────────────────────
1. Prescrição: $medication conforme protocolo SUS
2. Dosar: LDL basal, então em 8 semanas
3. Intensificar medicação se LDL não atingir meta
4. Acompanhamento clínico contínuo

─────────────────────────────────────────────────────────────
NOTA: Decisão baseada em protocolos SUS/RENAME de acesso público
═════════════════════════════════════════════════════════════
''';
  }

  /// Sanitiza SOAP para compatibilidade com e-SUS
  static String sanitizeForESUS(String soap) {
    return soap
        .replaceAll('║', '|')
        .replaceAll('╔', '[')
        .replaceAll('╗', ']')
        .replaceAll('╚', '[')
        .replaceAll('╝', ']')
        .replaceAll('─', '-')
        .replaceAll('✓', '[X]')
        .replaceAll('└─', '└');
  }

  /// Gera texto curto para copiar (resumo)
  static String generateQuickCopy({
    required String calculatorType,
    required String result,
    required String action,
  }) {
    final timestamp = DateFormat('dd/MM/yy HH:mm').format(DateTime.now());

    return '''SOAP - $calculatorType ($timestamp)
Resultado: $result
Ação: $action
[Gerado por FluxSUS - Ferramenta SUS]''';
  }
}
