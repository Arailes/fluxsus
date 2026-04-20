/// Gerenciador de Sincronização Periódica
/// Executa sincronizações de guidelines em intervalos regulares

import 'dart:async';
import 'package:hive/hive.dart';
import 'update_service.dart';
import 'sync_stats_service.dart';

class SyncManager {
  static const Duration _defaultCheckInterval = Duration(hours: 24);
  static const String _lastCheckKey = 'last_update_check';

  final UpdateService updateService;
  final SyncStatsService syncStatsService;
  Timer? _syncTimer;

  SyncManager({
    required this.updateService,
    required this.syncStatsService,
  });

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

      // 1️⃣ Sincroniza guidelines (código existente)
      final hasUpdate = await updateService.hasNewUpdate();

      if (hasUpdate) {
        print('📥 Atualização encontrada! Baixando...');
        await updateService.downloadAndSyncUpdate();
      } else {
        print('✅ Guidelines estão atualizados');
      }

      // 2️⃣ NOVO: Sincroniza telemetria anônima (LGPD)
      print('\n📊 Verificando sincronização de telemetria...');
      await _checkAndSyncTelemetry();

    } catch (e) {
      print('❌ Erro durante sincronização automática: $e');
    }
  }

  /// Sincroniza dados de telemetria se houver consentimento LGPD
  Future<void> _checkAndSyncTelemetry() async {
    try {
      // Verificar se há consentimento LGPD
      final hasConsent = await syncStatsService.hasUserConsent();
      
      if (!hasConsent) {
        print('⚠️  Telemetria não sincronizada: Sem consentimento LGPD');
        return;
      }

      // Obter identificador da unidade do storage
      final box = Hive.box('settings');
      final unitId = box.get('unit_id') as String? ?? 'FLUXSUS_DEFAULT';
      final regionCode = box.get('region_code') as String?;

      // Sincronizar dados anônimos agregados
      final syncSuccess = await syncStatsService.syncAnonymousStats(
        unitId: unitId,
        regionCode: regionCode,
      );

      if (syncSuccess) {
        print('✅ Telemetria sincronizada com sucesso');
      } else {
        print('⏳ Telemetria está na fila local - será sincronizada quando houver internet');
      }
    } catch (e) {
      print('❌ Erro ao sincronizar telemetria: $e');
    }
  }

  /// Força sincronização imediata (guidelines + telemetria)
  Future<void> syncNow() async {
    print('🚀 Sincronização manual iniciada');
    await _checkAndSync();
  }

  /// Obtém informações de status de sincronização (guidelines + telemetria)
  Future<Map<String, dynamic>> getSyncStatus() async {
    try {
      final localVersion = await updateService.getLocalVersion();
      final lastSync = await updateService.getLastSyncTime();
      final guidelines = updateService.getLocalGuidelines();
      final telemetryStatus = await syncStatsService.getSyncStatus();

      return {
        // Guidelines
        'version': localVersion,
        'lastSync': lastSync?.toString() ?? 'Nunca',
        'hasGuidelines': guidelines != null,
        'isAutoSyncRunning': _syncTimer?.isActive ?? false,
        
        // Telemetria (LGPD)
        'telemetry': {
          'hasConsent': telemetryStatus['has_consent'] ?? false,
          'lastSyncTelemetry': telemetryStatus['last_sync'] ?? 'Nunca',
          'telemetrySyncCount': telemetryStatus['sync_count'] ?? 0,
          'telemetryStatus': telemetryStatus['status'] ?? 'pending',
        },
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
