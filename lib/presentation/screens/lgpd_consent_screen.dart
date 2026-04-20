/// Tela de Configurações: Consentimento LGPD e Sincronização
/// Interface para o médico consentir com envio anônimo de dados

import 'package:flutter/material.dart';
import '../../core/services/sync_stats_service.dart';
import '../../core/services/service_locator.dart';

class LgpdConsentScreen extends StatefulWidget {
  const LgpdConsentScreen({Key? key}) : super(key: key);

  @override
  State<LgpdConsentScreen> createState() => _LgpdConsentScreenState();
}

class _LgpdConsentScreenState extends State<LgpdConsentScreen> {
  static const Color susGreen = Color(0xFF007A33);
  
  late SyncStatsService _syncStatsService;
  bool _hasConsent = false;
  bool _isLoading = true;
  Map<String, dynamic> _syncStatus = {};

  @override
  void initState() {
    super.initState();
    _syncStatsService = ServiceLocator.get<SyncStatsService>();
    _loadConsentStatus();
  }

  Future<void> _loadConsentStatus() async {
    try {
      final hasConsent = await _syncStatsService.hasUserConsent();
      final syncStatus = await _syncStatsService.getSyncStatus();
      
      setState(() {
        _hasConsent = hasConsent;
        _syncStatus = syncStatus;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Erro ao carregar status: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleConsent(bool value) async {
    setState(() => _isLoading = true);
    try {
      await _syncStatsService.setUserConsent(value);
      await _loadConsentStatus();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value 
              ? '✅ Consentimento concedido - Dados serão sincronizados'
              : '🚫 Consentimento revogado - Dados não serão sincronizados',
          ),
          duration: const Duration(seconds: 3),
          backgroundColor: value ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      print('❌ Erro ao alterar consentimento: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Erro ao atualizar configuração'),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações - LGPD'),
        backgroundColor: susGreen,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    const SizedBox(height: 8),
                    Text(
                      'Lei de Proteção de Dados (LGPD)',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: susGreen,
                          ),
                    ),
                    const SizedBox(height: 16),

                    // Explicação
                    _buildInfoCard(
                      context,
                      icon: Icons.info,
                      title: 'O que é Agregação Anônima?',
                      content:
                          'Seus dados de economia são enviados em formato agregado (totalizações), '
                          'sem identificação de pacientes ou médicos. Apenas contadores e estatísticas.',
                    ),
                    const SizedBox(height: 16),

                    // O que é coletado
                    _buildInfoCard(
                      context,
                      icon: Icons.bar_chart,
                      title: 'Dados Agregados Coletados',
                      content:
                          '• Total economizado em R\$\n'
                          '• Quantidade de exames evitados\n'
                          '• Medicamentos otimizados\n'
                          '• ID anônimo da unidade de saúde\n'
                          '• Data e hora da sincronização\n\n'
                          '❌ NÃO ENVIAMOS: Nomes, CPF, identificação de pacientes',
                    ),
                    const SizedBox(height: 16),

                    // O que se faz com os dados
                    _buildInfoCard(
                      context,
                      icon: Icons.target,
                      title: 'Propósito dos Dados',
                      content:
                          '✅ Medir impacto de decisões clínicas racionais\n'
                          '✅ Demonstrar economia para o SUS\n'
                          '✅ Gerar relatórios agregados da região\n'
                          '✅ Melhorar protocolos clínicos\n'
                          '✅ Validar efetividade de calculadoras',
                    ),
                    const SizedBox(height: 24),

                    // Toggle de Consentimento
                    _buildConsentToggle(),
                    const SizedBox(height: 24),

                    // Status de Sincronização
                    _buildSyncStatusCard(),
                    const SizedBox(height: 16),

                    // Histórico de Sincronizações
                    _buildSyncHistoryCard(),
                    const SizedBox(height: 16),

                    // Disclaimer Legal
                    _buildLegalDisclaimer(context),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  /// Widget: Card de informação
  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: susGreen, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: susGreen,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    height: 1.6,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget: Toggle de Consentimento
  Widget _buildConsentToggle() {
    return Card(
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              susGreen.withOpacity(0.1),
              susGreen.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Autorizar Sincronização de Dados',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Ao consentir, seus dados de economia serão periodicamente sincronizados '
              'com o servidor central FluxSUS (agregados anonimamente).',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _hasConsent ? '✅ Consentido' : '❌ Não Consentido',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _hasConsent ? Colors.green : Colors.red,
                      ),
                ),
                Switch(
                  value: _hasConsent,
                  onChanged: _toggleConsent,
                  activeColor: susGreen,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Widget: Status de Sincronização
  Widget _buildSyncStatusCard() {
    final lastSync = _syncStatus['last_sync'] as String? ?? 'Nunca';
    final syncCount = _syncStatus['sync_count'] as int? ?? 0;
    final status = _syncStatus['telemetryStatus'] as String? ?? 'pending';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status de Sincronização',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildStatusRow('Última sincronização', lastSync),
            const SizedBox(height: 8),
            _buildStatusRow(
              'Sincronizações completadas',
              '$syncCount',
            ),
            const SizedBox(height: 8),
            _buildStatusRow(
              'Status',
              status == 'success' ? '✅ Sucesso' : '⏳ Pendente',
              statusColor: status == 'success' ? Colors.green : Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  /// Widget: Linha de status
  Widget _buildStatusRow(
    String label,
    String value, {
    Color? statusColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
        ),
      ],
    );
  }

  /// Widget: Histórico de Sincronizações
  Widget _buildSyncHistoryCard() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _syncStatsService.getSyncHistory(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final history = snapshot.data!;
        final recentSyncs = history.take(3).toList();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Histórico Recente',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                ...recentSyncs.map((sync) {
                  final timestamp = sync['sync_at'] as String? ?? 'N/A';
                  final count = sync['events_sent'] as int? ?? 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '• $timestamp: $count eventos sincronizados',
                      style: Theme.of(context).textTheme.bodySmall,
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

  /// Widget: Disclaimer Legal
  Widget _buildLegalDisclaimer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.gavel, color: Colors.amber.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Aviso Legal',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Seus dados são protegidos pela LGPD (Lei Geral de Proteção de Dados '
            'Pessoais). O FluxSUS mantém criptografia em trânsito e nunca compartilha '
            'informações pessoais. Esta aplicação é de uso clínico responsável.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }
}
