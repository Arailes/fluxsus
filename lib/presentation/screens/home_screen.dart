/// Tela inicial com navegação para as calculadoras clínicas
/// Menu centralizado para acessar diferentes ferramentas de cálculo

import 'package:flutter/material.dart';
import 'cardio_screen.dart';
import 'wells_screen.dart';
import 'savings_dashboard_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static const Color susGreen = Color(0xFF007A33);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FluxSUS - Calculadoras Clínicas'),
        backgroundColor: susGreen,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              const SizedBox(height: 16),
              Text(
                'Ferramentas Disponíveis',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: susGreen,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),

              // Calculator Cards
              _buildCalculatorCard(
                context,
                icon: Icons.favorite,
                title: 'Risco Cardiovascular',
                description: 'Calcule risco de doença cardiovascular baseado em idade',
                color: Colors.red,
                onTap: () => _navigateTo(context, const CardioScreen()),
              ),
              const SizedBox(height: 16),

              _buildCalculatorCard(
                context,
                icon: Icons.lungs,
                title: 'Wells Score - TEP',
                description: 'Estratifique risco de tromboembolismo pulmonar',
                color: Colors.orange,
                onTap: () => _navigateTo(context, const WellsScreen()),
              ),
              const SizedBox(height: 16),

              // Savings Dashboard Card
              _buildCalculatorCard(
                context,
                icon: Icons.savings,
                title: 'Economia SUS',
                description: 'Visualize impacto de decisões racionais na economia',
                color: Colors.green,
                onTap: () => _navigateTo(context, const SavingsDashboardScreen()),
              ),
              const SizedBox(height: 16),

              // Coming Soon
              _buildComingSoonCard(context),
              const SizedBox(height: 32),

              // Info Box
              _buildInfoBox(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget: Card de Calculadora
  Widget _buildCalculatorCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget: Card "Em Breve"
  Widget _buildComingSoonCard(BuildContext context) {
    return Card(
      color: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.science, color: Colors.grey.shade600, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Calculadora de Laboratório',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Interpretação de valores laboratoriais',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                ],
              ),
            ),
            Icon(Icons.lock, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  /// Widget: Caixa de Informações
  Widget _buildInfoBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                'Sobre FluxSUS',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'FluxSUS é uma ferramenta de apoio clínico para cálculo de risco e estratificação em protocolos SUS. '
            'Todos os critérios e recomendações seguem diretrizes oficiais.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  height: 1.6,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Sincronização automática com guidelines atualizados',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Navega para tela com PageRoute customizada
  void _navigateTo(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => page),
    );
  }
}
