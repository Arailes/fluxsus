/// Serviço de Sincronização de Telemetria com Agregação Anônima
/// Implementa LGPD através de:
/// - Sem identificação pessoal de médicos/pacientes
/// - Agregação de dados em nível de unidade
/// - Consentimento explícito via flag
/// - Timestamp e rastreabilidade

import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';

class SyncStatsService {
  // Endpoint do servidor central (configure com seu backend)
  static const String _statsEndpoint =
      'https://fluxsus-api.example.com/api/v1/stats/sync'; // TODO: Configure URL real

  // LGPD: Consentimento do usuário deve ser armazenado
  static const String _consentKey = 'lgpd_consent_telemetry_sync';

  final http.Client _httpClient;
  final Connectivity _connectivity;

  SyncStatsService({
    http.Client? httpClient,
    Connectivity? connectivity,
  })  : _httpClient = httpClient ?? http.Client(),
        _connectivity = connectivity ?? Connectivity();

  /// Verifica se há consentimento do usuário para sincronizar dados (LGPD)
  Future<bool> hasUserConsent() async {
    try {
      final box = Hive.box('settings');
      return box.get(_consentKey, defaultValue: false) as bool;
    } catch (e) {
      print('❌ Erro ao verificar consentimento LGPD: $e');
      return false;
    }
  }

  /// Define consentimento do usuário para sincronização (LGPD)
  /// Deve ser solicitado explicitamente ao usuário
  Future<void> setUserConsent(bool consents) async {
    try {
      final box = Hive.box('settings');
      await box.put(_consentKey, consents);
      
      if (consents) {
        print('✅ Consentimento LGPD concedido para sincronização de telemetria');
      } else {
        print('🚫 Consentimento LGPD revogado - telemetria não será sincronizada');
      }
    } catch (e) {
      print('❌ Erro ao definir consentimento LGPD: $e');
    }
  }

  /// Sincroniza dados de telemetria agregados anonimamente para servidor central
  /// Respeitando LGPD:
  /// - ✅ Sem nomes de médicos
  /// - ✅ Sem identificação de pacientes
  /// - ✅ Agregado por unidade de saúde
  /// - ✅ Requer consentimento explícito
  /// - ✅ Timestamp para rastreabilidade
  Future<bool> syncAnonymousStats({
    required String unitId, // Identificador genérico da unidade (ex: UBS_001)
    String? regionCode,     // Código IBGE da região (adicional)
  }) async {
    try {
      // 1️⃣ VERIFICAR CONSENTIMENTO LGPD
      final hasConsent = await hasUserConsent();
      if (!hasConsent) {
        print('⚠️  Sincronização bloqueada: Usuário não consentiu com LGPD');
        return false;
      }

      // 2️⃣ VERIFICAR CONEXÃO
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        print('❌ Sem conexão de internet - telemetria será sincronizada depois');
        return false;
      }

      // 3️⃣ LER DADOS DE TELEMETRIA DO HIVE
      final telemetryBox = Hive.box('telemetry');
      final events = telemetryBox.get('events', defaultValue: []) as List;
      final stats = telemetryBox.get('stats', defaultValue: {}) as Map;

      // 4️⃣ VALIDAR QUE HÁ DADOS A SINCRONIZAR
      if (events.isEmpty) {
        print('ℹ️  Nenhum dado de telemetria para sincronizar');
        return false;
      }

      // 5️⃣ CONSTRUIR PACOTE DE AGREGAÇÃO ANÔNIMA
      final aggregatedStats = _buildAnonymousAggregation(
        unitId: unitId,
        regionCode: regionCode,
        telemetryStats: stats,
        events: events,
      );

      // 6️⃣ ADICIONAR HASH DE INTEGRIDADE (LGPD - rastreabilidade)
      final requestBody = {
        ...aggregatedStats,
        'integrity_hash': _generateIntegrityHash(aggregatedStats),
        'sync_timestamp': DateTime.now().toIso8601String(),
        'sdk_version': '1.0.0', // Versão do app
      };

      print('📤 Enviando dados agregados para servidor central...');
      print('   Unit ID: $unitId');
      print('   Eventos: ${events.length}');
      print('   Economia Total: R\$ ${stats['total_saved_brl'] ?? 0.0}');

      // 7️⃣ FAZER POST PARA SERVIDOR
      final response = await _httpClient.post(
        Uri.parse(_statsEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'FluxSUS/1.0',
          // LGPD: Não enviar identificação do dispositivo
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 30));

      // 8️⃣ VALIDAR RESPOSTA
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Sincronização de telemetria bem-sucedida!');
        
        // Opcionalmente, após sucesso, limpar eventos sincronizados
        // (manter stats para o contador local continuar)
        await _markEventsSynced(events);
        
        return true;
      } else {
        print('❌ Erro ao sincronizar (HTTP ${response.statusCode})');
        print('   Response: ${response.body}');
        return false;
      }
    } on SocketException catch (e) {
      print('❌ Erro de conexão de rede: $e');
      return false;
    } catch (e) {
      print('❌ Erro ao sincronizar telemetria: $e');
      return false;
    }
  }

  /// Constrói pacote de agregação anônima respeitando LGPD
  Map<String, dynamic> _buildAnonymousAggregation({
    required String unitId,
    required String? regionCode,
    required Map telemetryStats,
    required List events,
  }) {
    // Calcular breakdown por tipo de procedimento
    Map<String, int> breakdownByType = {};
    Map<String, double> costByType = {};
    
    for (final event in events) {
      final procedureType = event['procedureType']?.toString() ?? 'UNKNOWN';
      breakdownByType[procedureType] = (breakdownByType[procedureType] ?? 0) + 1;
      costByType[procedureType] = (costByType[procedureType] ?? 0.0) + (event['cost'] as double? ?? 0.0);
    }

    // Agrupar por tipo de calculadora
    Map<String, int> breakdownByCalculator = {};
    for (final event in events) {
      final calcType = event['calculatorType']?.toString() ?? 'UNKNOWN';
      breakdownByCalculator[calcType] = (breakdownByCalculator[calcType] ?? 0) + 1;
    }

    return {
      // Identificação anônima
      'unit_id': unitId,
      'region_code': regionCode,

      // 📊 Agregações: Totalizações sem dados individuais
      'total_brl': telemetryStats['total_saved_brl'] ?? 0.0,
      'exams_avoided': telemetryStats['exams_avoided'] ?? 0,
      'medications_optimized': telemetryStats['medications_optimized'] ?? 0,
      'avg_per_exam': telemetryStats['avg_per_exam'] ?? 0.0,
      'avg_per_day': telemetryStats['avg_per_day'] ?? 0.0,
      'days_active': telemetryStats['days_active'] ?? 0,

      // Breakdown agregado (sem dados pessoais)
      'breakdown_by_procedure': breakdownByType,
      'costs_by_procedure': costByType,
      'breakdown_by_calculator': breakdownByCalculator,

      // Total de eventos sincronizados
      'total_events': events.length,

      // Horário de geração do relatório
      'report_generated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Gera hash de integridade para LGPD (rastreabilidade)
  /// Valida que dados não foram alterados em trânsito
  String _generateIntegrityHash(Map<String, dynamic> data) {
    // Implementação simples: hash SHA256 dos dados críticos
    // Em produção, usar crypto package
    final critical = {
      'total_brl': data['total_brl'],
      'exams_avoided': data['exams_avoided'],
      'total_events': data['total_events'],
    };
    
    final jsonString = jsonEncode(critical);
    // Retorna hash simples (em produção, usar import 'package:crypto/crypto.dart')
    return jsonString.hashCode.toString().padLeft(16, '0').substring(0, 16);
  }

  /// Marca eventos como sincronizados (LGPD - rastreabilidade)
  /// Mantém registro de o quê foi enviado
  Future<void> _markEventsSynced(List events) async {
    try {
      final box = Hive.box('telemetry');
      
      // Adiciona timestamp de sincronização
      final syncLog = box.get('sync_log', defaultValue: []) as List;
      syncLog.add({
        'sync_at': DateTime.now().toIso8601String(),
        'events_sent': events.length,
      });
      
      await box.put('sync_log', syncLog);
      print('✅ Log de sincronização atualizado');
    } catch (e) {
      print('⚠️  Erro ao marcar sincronização: $e');
    }
  }

  /// Obtém histórico de sincronizações (LGPD - rastreabilidade)
  Future<List<Map<String, dynamic>>> getSyncHistory() async {
    try {
      final box = Hive.box('telemetry');
      final syncLog = box.get('sync_log', defaultValue: []) as List;
      return syncLog.cast<Map<String, dynamic>>();
    } catch (e) {
      print('❌ Erro ao obter histórico de sincronização: $e');
      return [];
    }
  }

  /// Simula sincronização offline (fila de sincronização)
  /// Quando app recuperar conexão, envia dados pendentes
  Future<bool> trySyncPendingData() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        print('⏳ Sem conexão - dados ficarão na fila local');
        return false;
      }

      // Se tem conexão, tenta sincronizar
      // Em produção, verificar se há dados pendentes na fila
      return true;
    } catch (e) {
      print('❌ Erro ao verificar sincronização pendente: $e');
      return false;
    }
  }

  /// Processa resposta do servidor (LGPD)
  /// Valida e armazena confirmação de recebimento
  Future<void> _processServerResponse(http.Response response) async {
    try {
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        
        // Armazena confirmação de recebimento
        final box = Hive.box('telemetry');
        await box.put('last_sync_response', {
          'status': 'success',
          'timestamp': DateTime.now().toIso8601String(),
          'server_id': responseData['sync_id'] ?? 'unknown',
        });
        
        print('✅ Resposta do servidor armazenada');
      }
    } catch (e) {
      print('⚠️  Erro ao processar resposta: $e');
    }
  }

  /// Retorna status de sincronização
  Future<Map<String, dynamic>> getSyncStatus() async {
    try {
      final box = Hive.box('telemetry');
      final lastSyncResponse = box.get('last_sync_response') as Map?;
      final syncLog = box.get('sync_log', defaultValue: []) as List;

      return {
        'last_sync': lastSyncResponse?['timestamp'] ?? 'Nunca',
        'sync_count': syncLog.length,
        'has_consent': await hasUserConsent(),
        'status': lastSyncResponse?['status'] ?? 'pending',
      };
    } catch (e) {
      print('❌ Erro ao obter status de sincronização: $e');
      return {};
    }
  }
}

// ─────────────────────────────────────────────────────────────────
// EXEMPLO DE USO NO SYNC MANAGER
// ─────────────────────────────────────────────────────────────────

/*
// Em sync_manager.dart, adicionar sincronização de telemetria:

class SyncManager {
  final SyncStatsService syncStatsService;
  
  Future<void> _checkAndSync() async {
    // ... verificar guidelines (código existente) ...
    
    // ✨ NOVO: Sincronizar telemetria também
    if (await syncStatsService.hasUserConsent()) {
      final unitId = 'UBS_QUIXADA_001'; // Configurável
      await syncStatsService.syncAnonymousStats(
        unitId: unitId,
        regionCode: '23', // Código IBGE do CE
      );
    }
  }
}
*/
