/// Tela de Dashboard de Economia SUS
/// Exibe "contador de poupança" com métricas de impacto e economia

import 'package:flutter/material.dart';
import '../widgets/telemetry_savings_widget.dart';

class SavingsDashboardScreen extends StatelessWidget {
  const SavingsDashboardScreen({Key? key}) : super(key: key);

  static const Color susGreen = Color(0xFF007A33);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Economia SUS - FluxSUS'),
        backgroundColor: susGreen,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Icon
              Center(
                child: Icon(Icons.savings, size: 48, color: susGreen),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Impacto de Decisões Racionais',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
              ),
              const SizedBox(height: 24),

              // Main Widget
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: const TelemetrySavingsWidget(),
              ),

              const SizedBox(height: 32),

              // Info Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Como Funciona',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoItem(
                      context,
                      '🩺 Wells IMPROVÁVEL',
                      'D-Dímero evita CTA (R\$ 1.500 economizados)',
                    ),
                    const SizedBox(height: 8),
                    _buildInfoItem(
                      context,
                      '💊 Medicamento Otimizado',
                      'Escolha de genérico reduz custo mensal',
                    ),
                    const SizedBox(height: 8),
                    _buildInfoItem(
                      context,
                      '📊 Decisão Baseada em Evidências',
                      'MBE garante racionalidade no uso de recursos',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Disclaimer
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Text(
                    'ℹ️ Estes números representam potencial de economia baseado em decisões clínicas racionais. '
                    'O objetivo é demonstrar o impacto de medicina baseada em evidências no SUS.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget: Item de Informação
  Widget _buildInfoItem(BuildContext context, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          child: Text(
            '',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
