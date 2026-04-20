/// Tela de Calculadora Wells para Estratificação de Risco de TEP
/// Interface otimizada para pronto-socorro (decisão rápida com segurança)

import 'package:flutter/material.dart';
import '../../core/logic/wells_engine.dart';
import '../../core/data/wells_data.dart';

class WellsScreen extends StatefulWidget {
  const WellsScreen({Key? key}) : super(key: key);

  @override
  State<WellsScreen> createState() => _WellsScreenState();
}

class _WellsScreenState extends State<WellsScreen> {
  static const Color susGreen = Color(0xFF007A33);
  static const Color susRed = Color(0xFFF44336);

  // Rastreamento de critérios selecionados
  late Map<String, bool> selectedCriteria;
  double currentScore = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeCriteria();
  }

  void _initializeCriteria() {
    selectedCriteria = {};
    for (final criterion in WellsData.getCriteriaList()) {
      selectedCriteria[criterion] = false;
    }
  }

  void _recalculateScore() {
    setState(() {
      currentScore = WellsEngine.calculateScore(selectedCriteria);
    });
  }

  void _toggleCriterion(String criterion, bool? value) {
    setState(() {
      selectedCriteria[criterion] = value ?? false;
      _recalculateScore();
    });
  }

  void _resetAll() {
    setState(() {
      _initializeCriteria();
      currentScore = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final recommendation = WellsEngine.getRecommendation(currentScore);
    final riskLevel = recommendation['level'] as String;
    final color = Color(recommendation['color'] as int);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wells Score - TEP'),
        backgroundColor: susGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetAll,
            tooltip: 'Resetar Cálculo',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Seção: Instruções
              _buildInstructionCard(),
              const SizedBox(height: 24),

              // Seção: Critérios (Checklist)
              _buildSectionHeader('Critérios Clínicos'),
              const SizedBox(height: 12),
              _buildCriteriaCheckboxes(),
              const SizedBox(height: 24),

              // Seção: Score Atual
              _buildScoreCard(currentScore),
              const SizedBox(height: 24),

              // Seção: Classificação de Risco
              _buildSectionHeader('Classificação de Risco'),
              const SizedBox(height: 12),
              _buildRiskCard(riskLevel, color, recommendation),
              const SizedBox(height: 24),

              // Seção: Recomendação Clínica
              _buildSectionHeader('Conduta Recomendada'),
              const SizedBox(height: 12),
              _buildConductCard(recommendation),
              const SizedBox(height: 24),

              // Seção: Impacto Clínico (economia SUS)
              _buildSectionHeader('Impacto Clínico'),
              const SizedBox(height: 12),
              _buildImpactCard(currentScore),
              const SizedBox(height: 24),

              // Botão de Ação
              _buildActionButton(riskLevel),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget: Card de Instruções
  Widget _buildInstructionCard() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Wells Score para TEP',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Selecione os critérios presentes. Score ≤ 4 = Improvável; Score > 4 = Provável',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  /// Widget: Checkboxes de Critérios
  Widget _buildCriteriaCheckboxes() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: WellsData.getCriteriaList()
              .map((criterion) {
                final score = WellsData.getCriterionScore(criterion);
                return CheckboxListTile(
                  title: Text(criterion),
                  subtitle: Text(
                    '+${score?.toStringAsFixed(1)} pontos',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  value: selectedCriteria[criterion] ?? false,
                  onChanged: (value) => _toggleCriterion(criterion, value),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                );
              })
              .toList(),
        ),
      ),
    );
  }

  /// Widget: Card de Score Atual
  Widget _buildScoreCard(double score) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade100, Colors.blue.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade300, width: 2),
      ),
      child: Column(
        children: [
          Text(
            'Score Total',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.blue.shade700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '${score.toStringAsFixed(1)} pontos',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.blue.shade900,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            score <= 4.0 ? 'Improvável (≤ 4)' : 'Provável (> 4)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: score <= 4.0 ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  /// Widget: Card de Risco
  Widget _buildRiskCard(
    String riskLevel,
    Color color,
    Map<String, dynamic> recommendation,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                riskLevel == 'UNLIKELY' ? Icons.check_circle : Icons.warning,
                color: color,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recommendation['label'] as String,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      recommendation['description'] as String,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Widget: Card de Conduta
  Widget _buildConductCard(Map<String, dynamic> recommendation) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ação Recomendada',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Text(
                recommendation['action'] as String,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Recomendação: ${recommendation['recommendation']}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade700,
                    fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget: Card de Impacto Clínico/Economia SUS
  Widget _buildImpactCard(double score) {
    final impact = WellsEngine.calculateClinicalImpact(score);
    final potentialSavings = impact['potential_savings'] as String;
    final ctNeeded = impact['ct_scan_needed'] as bool;

    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.savings, color: Colors.green.shade700),
                const SizedBox(width: 8),
                Text(
                  'Impacto SUS',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              potentialSavings,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            if (!ctNeeded)
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Radiação desnecessária evitada',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  /// Widget: Botão de Ação Principal
  Widget _buildActionButton(String riskLevel) {
    return ElevatedButton.icon(
      icon: Icon(riskLevel == 'UNLIKELY' ? Icons.blood_type_outlined : Icons.warning),
      label: Text(riskLevel == 'UNLIKELY' ? 'Solicitar D-Dímero' : 'SOLICITAR CTA TÓRAX'),
      onPressed: () {
        _showResultsSnackbar(riskLevel);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: riskLevel == 'UNLIKELY' ? susGreen : susRed,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }

  /// Exibe resultado em snackbar
  void _showResultsSnackbar(String riskLevel) {
    final message = riskLevel == 'UNLIKELY'
        ? '✅ D-Dímero pode excluir TEP com segurança'
        : '🚨 Realizar Angiotomografia IMEDIATAMENTE';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        backgroundColor: riskLevel == 'UNLIKELY' ? Colors.green : Colors.red,
      ),
    );
  }

  /// Widget: Header de Seção
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: susGreen,
          ),
    );
  }
}
