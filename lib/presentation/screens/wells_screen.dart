/// Tela de Calculadora Wells para Estratificação de Risco de TEP
/// Interface otimizada para pronto-socorro (decisão rápida com segurança)
/// Checklist ágil com atualização em tempo real e justificativa técnica

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/logic/wells_engine.dart';
import '../../core/data/wells_data.dart';
import '../../core/utils/clipboard_utils.dart';
import '../../core/utils/soap_formatter.dart';
import '../../core/services/telemetry_service.dart';

class WellsScreen extends StatefulWidget {
  const WellsScreen({Key? key}) : super(key: key);

  @override
  State<WellsScreen> createState() => _WellsScreenState();
}

class _WellsScreenState extends State<WellsScreen> {
  static const Color susGreen = Color(0xFF007A33);
  static const Color susRed = Color(0xFFF44336);

  // Rastreamento de critérios selecionados usando Set (simples e rápido)
  final Set<String> selectedCriteria = {};
  double currentScore = 0.0;

  @override
  void initState() {
    super.initState();
  }

  /// Atualiza score baseado em critérios selecionados
  void _updateScore() {
    setState(() {
      currentScore = selectedCriteria.fold(
        0.0,
        (sum, key) => sum + (WellsData.getCriterionScore(key) ?? 0.0),
      );
    });
  }

  /// Toggle de critério (ágil e simples)
  void _toggleCriterion(String criterion) {
    setState(() {
      if (selectedCriteria.contains(criterion)) {
        selectedCriteria.remove(criterion);
      } else {
        selectedCriteria.add(criterion);
      }
      _updateScore();
    });
  }

  /// Reseta todos os critérios
  void _resetAll() {
    setState(() {
      selectedCriteria.clear();
      currentScore = 0.0;
    });
  }

  /// Copia justificativa técnica SOAP para prontuário
  void _copyTechnicalJustification(Map<String, dynamic> recommendation) {
    final soap = SOAPFormatter.generateWellsSOAP(
      score: currentScore,
      riskLevel: recommendation['level'] as String,
      label: recommendation['label'] as String,
      action: recommendation['action'] as String,
      selectedCriteria: selectedCriteria.toList(),
      criteriaScores: WellsData.criteria,
    );

    // Sanitiza para e-SUS (remove caracteres especiais)
    final sanitized = SOAPFormatter.sanitizeForESUS(soap);

    Clipboard.setData(ClipboardData(text: sanitized));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          '✅ SOAP copiado! Cole no prontuário e-SUS (Avaliação)',
        ),
        duration: const Duration(seconds: 3),
        backgroundColor: susGreen,
      ),
    );
  }

  /// Gera texto em formato SOAP para e-SUS
  String _generateSOAPText(Map<String, dynamic> recommendation) {
    return SOAPFormatter.generateWellsSOAP(
      score: currentScore,
      riskLevel: recommendation['level'] as String,
      label: recommendation['label'] as String,
      action: recommendation['action'] as String,
      selectedCriteria: selectedCriteria.toList(),
      criteriaScores: WellsData.criteria,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obtém recomendação automaticamente do Map (sem IF/ELSE)
    final recommendation = WellsEngine.getRecommendation(currentScore);
    final riskLevel = recommendation['level'] as String;
    final color = Color(recommendation['color'] as int);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wells Score - TEP'),
        backgroundColor: susGreen,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetAll,
            tooltip: 'Resetar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Seção: Checklist de Critérios (ListView gerado automaticamente)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Critérios Wells',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: susGreen,
                        ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: WellsData.getCriteriaList()
                        .map((criterion) {
                          final score = WellsData.getCriterionScore(criterion);
                          final isSelected =
                              selectedCriteria.contains(criterion);

                          return CheckboxListTile(
                            title: Text(criterion),
                            subtitle: Text(
                              '+${score?.toStringAsFixed(1) ?? '0'} pts',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            value: isSelected,
                            onChanged: (_) => _toggleCriterion(criterion),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            activeColor: susGreen,
                          );
                        })
                        .toList(),
                  ),
                ),
              ],
            ),
          ),

          // Seção: Painel de Decisão (Racional, sem IF/ELSE)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              border: Border(
                top: BorderSide(color: color, width: 3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Score em grande (visual)
                Center(
                  child: Column(
                    children: [
                      Text(
                        currentScore.toStringAsFixed(1),
                        style: Theme.of(context)
                            .textTheme
                            .displaySmall
                            ?.copyWith(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'pontos Wells',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Label de classificação
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      recommendation['label'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Ação recomendada
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Text(
                    recommendation['action'] as String,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                        ),
                  ),
                ),
                const SizedBox(height: 12),

                // Chip de Economia (se improvável)
                if (currentScore <= 4.0)
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      Chip(
                        label: Text(
                          '💰 ${recommendation['saving_potential']}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        backgroundColor: Colors.green.shade100,
                        side: BorderSide(color: Colors.green.shade400),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Botões de Ação
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.copy),
                    label: const Text('Copiar Justificativa'),
                    onPressed: () =>
                        _copyTechnicalJustification(recommendation),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: Text(
                      riskLevel == 'UNLIKELY' ? 'D-Dímero' : 'CTA Tórax',
                    ),
                    onPressed: () => _showResultSnackbar(riskLevel),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Exibe resultado em snackbar e registra telemetria
  void _showResultSnackbar(String riskLevel) {
    final message = riskLevel == 'UNLIKELY'
        ? '✅ D-Dímero pode excluir TEP com segurança'
        : '🚨 Realizar Angiotomografia IMEDIATAMENTE';

    // Log telemetry when exam is avoided
    if (riskLevel == 'UNLIKELY') {
      TelemetryService.logExamAvoided(
        'ANGIO_TC_CHEST',
        'wells_unlikely_${currentScore.toInt()}pts',
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        backgroundColor: riskLevel == 'UNLIKELY' ? Colors.green : Colors.red,
      ),
    );
  }
}

