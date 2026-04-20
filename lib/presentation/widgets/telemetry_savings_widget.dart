/// Widget de Dashboard de Economia SUS
/// Exibe "contador de poupança" em tempo real

import 'package:flutter/material.dart';
import '../../core/services/telemetry_service.dart';

class TelemetrySavingsWidget extends StatefulWidget {
  const TelemetrySavingsWidget({Key? key}) : super(key: key);

  @override
  State<TelemetrySavingsWidget> createState() => _TelemetrySavingsWidgetState();
}

class _TelemetrySavingsWidgetState extends State<TelemetrySavingsWidget> {
  static const Color susGreen = Color(0xFF007A33);

  late Future<Map<String, dynamic>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    setState(() {
      _statsFuture = TelemetryService.getStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _statsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard();
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return _buildErrorCard();
        }

        final stats = snapshot.data!;
        final totalSaved = (stats['total_saved_brl'] as double?) ?? 0.0;
        final examsAvoided = (stats['exams_avoided'] as int?) ?? 0;
        final daysActive = (stats['days_active'] as int?) ?? 0;
        final avgPerDay = (stats['avg_per_day'] as double?) ?? 0.0;

        return RefreshIndicator(
          onRefresh: (_) async => _loadStats(),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Main Card: Total Saved
                _buildMainSavingsCard(totalSaved),
                const SizedBox(height: 16),

                // Stats Row
                _buildStatsRow(examsAvoided, daysActive, avgPerDay),
                const SizedBox(height: 16),

                // Breakdown
                _buildBreakdownCard(),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Card Principal: Economia Total
  Widget _buildMainSavingsCard(double totalSaved) {
    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [susGreen, susGreen.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.savings, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                Text(
                  'Economia Total',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'R\$ ${totalSaved.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'para o Sistema SUS',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Linha de Estatísticas: Exames Evitados, Dias, Média/Dia
  Widget _buildStatsRow(int examsAvoided, int daysActive, double avgPerDay) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.local_hospital,
            value: examsAvoided.toString(),
            label: 'Exames\nEvitados',
            color: Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.calendar_today,
            value: daysActive.toString(),
            label: 'Dias de\nUso',
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.trending_up,
            value: 'R\$ ${avgPerDay.toStringAsFixed(0)}',
            label: 'Média\npor Dia',
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  /// Card de Estatística Individual
  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Card de Breakdown por Tipo
  Widget _buildBreakdownCard() {
    return FutureBuilder<Map<String, int>>(
      future: TelemetryService.getBreakdownByType(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final breakdown = snapshot.data!;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detalhamento por Tipo',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                ...breakdown.entries.map((e) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          e.key,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Chip(
                          label: Text('${e.value}x'),
                          backgroundColor: susGreen.withOpacity(0.2),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Card de Carregamento
  Widget _buildLoadingCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              SizedBox(
                height: 40,
                width: 40,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(susGreen),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Carregando estatísticas...',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Card de Erro
  Widget _buildErrorCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 32),
            const SizedBox(height: 8),
            Text(
              'Erro ao carregar estatísticas',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.red,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
