/// Widget para exibir status de sincronização e atualizar guidelines
/// Pode ser usado em uma tela "Sobre" ou "Configurações"

import 'package:flutter/material.dart';
import '../../core/services/service_locator.dart';
import '../../core/services/sync_manager.dart';
import '../../core/services/update_service.dart';

class SyncStatusWidget extends StatefulWidget {
  const SyncStatusWidget({Key? key}) : super(key: key);

  @override
  State<SyncStatusWidget> createState() => _SyncStatusWidgetState();
}

class _SyncStatusWidgetState extends State<SyncStatusWidget> {
  bool _isLoading = false;
  Map<String, dynamic>? _syncStatus;

  @override
  void initState() {
    super.initState();
    _loadSyncStatus();
  }

  Future<void> _loadSyncStatus() async {
    try {
      final syncManager = ServiceLocator.get<SyncManager>();
      final status = await syncManager.getSyncStatus();
      setState(() => _syncStatus = status);
    } catch (e) {
      print('❌ Erro ao carregar status: $e');
    }
  }

  Future<void> _syncNow() async {
    setState(() => _isLoading = true);
    try {
      final syncManager = ServiceLocator.get<SyncManager>();
      await syncManager.syncNow();
      
      if (mounted) {
        await _loadSyncStatus();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Guidelines sincronizados!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erro: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
            if (_syncStatus != null) ...[
              _buildStatusRow(
                'Versão',
                '${_syncStatus!['version']}',
              ),
              const SizedBox(height: 8),
              _buildStatusRow(
                'Última Sincronização',
                _syncStatus!['lastSync'],
              ),
              const SizedBox(height: 8),
              _buildStatusRow(
                'Auto-sync',
                _syncStatus!['isAutoSyncRunning'] ? '🟢 Ativo' : '🔴 Inativo',
              ),
            ] else
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.sync),
                label: const Text('Sincronizar Agora'),
                onPressed: _isLoading ? null : _syncNow,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
