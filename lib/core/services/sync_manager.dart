/// Gerenciador de Sincronização Periódica
/// Executa sincronizações de guidelines em intervalos regulares

import 'dart:async';
import 'package:hive/hive.dart';
import 'update_service.dart';

class SyncManager {
  static const Duration _defaultCheckInterval = Duration(hours: 24);
  static const String _lastCheckKey = 'last_update_check';

  final UpdateService updateService;
  Timer? _syncTimer;

  SyncManager({required this.updateService});

  /// Inicia sincronização periódica automática
  /// Se [checkInterval] não é fornecido, usa 24 horas
  void startAutoSync({Duration? checkInterval}) {
    final interval = checkInterval ?? _defaultCheckInterval;
    print('🔄 Iniciando sincronização automática a cada ${interval.inHours}h');

    // Verifica imediatamente
    _checkAndSync();

    // Agenda verificações periódicas
    _syncTimer = Timer.periodic(interval, (_) {
      _checkAndSync();
    });
  }

  /// Para sincronização automática
  void stopAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
    print('⏸️ Sincronização automática parada');
  }

  /// Executa sincronização se necessário
  Future<void> _checkAndSync() async {
    try {
      final box = Hive.box('settings');
      final lastCheck = box.get(_lastCheckKey) as String?;

      // Se já verificou recentemente, pula
      if (lastCheck != null) {
        final lastCheckTime = DateTime.parse(lastCheck);
        if (DateTime.now().difference(lastCheckTime).inHours < 1) {
          print('⏭️  Verificação recente, pulando...');
          return;
        }
      }

      // Atualiza timestamp de verificação
      await box.put(_lastCheckKey, DateTime.now().toIso8601String());

      // Verifica se há atualização
      final hasUpdate = await updateService.hasNewUpdate();

      if (hasUpdate) {
        print('📥 Atualização encontrada! Baixando...');
        await updateService.downloadAndSyncUpdate();
      } else {
        print('✅ Guidelines estão atualizados');
      }
    } catch (e) {
      print('❌ Erro durante sincronização automática: $e');
    }
  }

  /// Força sincronização imediata
  Future<void> syncNow() async {
    print('🚀 Sincronização manual iniciada');
    await _checkAndSync();
  }

  /// Obtém informações de status de sincronização
  Future<Map<String, dynamic>> getSyncStatus() async {
    try {
      final localVersion = await updateService.getLocalVersion();
      final lastSync = await updateService.getLastSyncTime();
      final guidelines = updateService.getLocalGuidelines();

      return {
        'version': localVersion,
        'lastSync': lastSync?.toString() ?? 'Nunca',
        'hasGuidelines': guidelines != null,
        'isAutoSyncRunning': _syncTimer?.isActive ?? false,
      };
    } catch (e) {
      print('❌ Erro ao obter status: $e');
      return {};
    }
  }

  /// Destrutor - limpa resources
  void dispose() {
    stopAutoSync();
  }
}
