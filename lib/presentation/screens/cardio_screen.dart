/// Tela de Calculadora de Risco Cardiovascular
/// Implementa interface rápida para cálculo de risco conforme diretriz SUS

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/logic/risk_engine.dart';
import '../../core/utils/soap_formatter.dart';

class CardioScreen extends StatefulWidget {
  const CardioScreen({Key? key}) : super(key: key);

  @override
  State<CardioScreen> createState() => _CardioScreenState();
}

class _CardioScreenState extends State<CardioScreen> {
  static const Color susGreen = Color(0xFF007A33);
  static const Color susGrey = Color(0xFF666666);

  int age = 45;
  String gender = 'MALE';
  int points = 0;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  /// Recalcula pontuação baseado nos valores atuais
  void _calculate() {
    if (!RiskEngine.isValidInput(gender, age)) {
      setState(() => points = 0);
      return;
    }

    setState(() {
      points = RiskEngine.getAgeScore(gender, age);
      // TODO: Somar outros fatores (Tabagismo, PA, Colesterol, etc)
    });
  }

  @override
  Widget build(BuildContext context) {
    final risk = RiskEngine.getFinalRisk(points);
    final riskLevel = risk['level'] as String;
    final riskColor = Color(risk['color'] as int);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Risco Cardiovascular'),
        backgroundColor: susGreen,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Seção: Dados do Paciente
              _buildSectionHeader('Dados Clínicos'),
              const SizedBox(height: 12),

              // Gênero
              _buildGenderSelector(),
              const SizedBox(height: 16),

              // Idade com Slider
              _buildAgeSlider(),
              const SizedBox(height: 24),

              // Seção: Resultado (Semáforo)
              _buildSectionHeader('Classificação de Risco'),
              const SizedBox(height: 12),

              _buildRiskCard(riskLevel, riskColor, risk),
              const SizedBox(height: 24),

              // Seção: Recomendações
              _buildSectionHeader('Conduta Terapêutica'),
              const SizedBox(height: 12),

              _buildRecommendationCard(risk),
              const SizedBox(height: 24),

              // Botão de Ação: Copiar para Prontuário
              _buildCopyButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget: Seletor de Gênero
  Widget _buildGenderSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'MALE',
                    label: Text('Homem'),
                    icon: Icon(Icons.male),
                  ),
                  ButtonSegment(
                    value: 'FEMALE',
                    label: Text('Mulher'),
                    icon: Icon(Icons.female),
                  ),
                ],
                selected: {gender},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    gender = newSelection.first;
                    _calculate();
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget: Slider de Idade
  Widget _buildAgeSlider() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Idade',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '$age anos',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: susGreen,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Slider(
              value: age.toDouble(),
              min: 20,
              max: 80,
              divisions: 60,
              label: age.toString(),
              onChanged: (value) {
                setState(() => age = value.toInt());
                _calculate();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Widget: Card de Resultado de Risco
  Widget _buildRiskCard(
    String riskLevel,
    Color riskColor,
    Map<String, dynamic> risk,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: riskColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: riskColor, width: 2),
      ),
      child: Column(
        children: [
          Text(
            riskLevel,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: riskColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pontuação: ${risk['score']}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: susGrey,
                ),
          ),
        ],
      ),
    );
  }

  /// Widget: Card de Recomendação Terapêutica
  Widget _buildRecommendationCard(Map<String, dynamic> risk) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Meta de LDL',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              risk['goal'] as String,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: susGreen,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Medicação SUS Disponível',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Text(
                risk['drug'] as String,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget: Botão para copiar para e-SUS
  Widget _buildCopyButton() {
    final risk = RiskEngine.getFinalRisk(points);
    return ElevatedButton.icon(
      icon: const Icon(Icons.copy),
      label: const Text('COPIAR SOAP PARA e-SUS'),
      onPressed: () {
        _copySoapCardio(risk);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: susGreen,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  /// Copia nota SOAP para prontuário
  void _copySoapCardio(Map<String, dynamic> risk) {
    final soap = SOAPFormatter.generateCardioSOAP(
      score: points.toDouble(),
      riskLevel: risk['level'] as String,
      label: risk['label'] as String,
      ldlGoal: risk['goal'] as String,
      medication: risk['drug'] as String,
    );

    // Sanitiza para e-SUS
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

  /// Exibe snackbar de confirmação (legado)
  void _showCopiedSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Texto copiado para a área de transferência!'),
        duration: Duration(seconds: 2),
      ),
    );
    // TODO: Implementar lógica real de cópia
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
