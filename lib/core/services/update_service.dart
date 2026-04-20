/// Serviço de Sincronização e Atualização de Guidelines
/// Verifica atualizações em remote e sincroniza com armazenamento local (Hive)

import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';

class UpdateService {
  static const String _settingsBoxName = 'settings';
  static const String _guidelinesUrl =
      'https://raw.githubusercontent.com/Arailes/fluxsus/main/guidelines.json';

  final http.Client _httpClient;
  final Connectivity _connectivity;

  UpdateService({
    http.Client? httpClient,
    Connectivity? connectivity,
  })  : _httpClient = httpClient ?? http.Client(),
        _connectivity = connectivity ?? Connectivity();

  /// Verifica se existe uma nova versão disponível no remoto
  Future<bool> hasNewUpdate() async {
    try {
      // Verifica se há conexão de rede
      final result = await _connectivity.checkConnectivity();
      if (result == ConnectivityResult.none) {
        print('❌ Sem conexão de rede');
        return false;
      }

      final response = await _httpClient.get(
        Uri.parse(_guidelinesUrl),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final remoteData = json.decode(response.body) as Map<String, dynamic>;
        final remoteVersion = remoteData['version'] as double;

        // Obtém versão local
        final box = Hive.box(_settingsBoxName);
        final localVersion = box.get('version', defaultValue: 1.0) as double;

        final hasUpdate = remoteVersion > localVersion;
        print('📊 Versão local: $localVersion | Remota: $remoteVersion | '
            'Atualização disponível: $hasUpdate');

        return hasUpdate;
      } else {
        print('❌ Erro ao buscar guidelines (HTTP ${response.statusCode})');
        return false;
      }
    } on SocketException catch (e) {
      print('❌ Erro de conexão: $e');
      return false;
    } catch (e) {
      print('❌ Erro ao verificar atualização: $e');
      return false;
    }
  }

  /// Baixa e sincroniza guidelines remotas com armazenamento local
  /// Retorna true se atualização foi bem-sucedida
  Future<bool> downloadAndSyncUpdate() async {
    try {
      print('⏳ Sincronizando guidelines...');

      final response = await _httpClient.get(
        Uri.parse(_guidelinesUrl),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        print('❌ Erro ao baixar (HTTP ${response.statusCode})');
        return false;
      }

      final remoteData = json.decode(response.body) as Map<String, dynamic>;
      final remoteVersion = remoteData['version'] as double;
      final data = remoteData['data'] as Map<String, dynamic>;

      // Valida estrutura básica
      if (!_validateGuidelinesStructure(data)) {
        print('❌ Estrutura de guidelines inválida');
        return false;
      }

      // Persiste no Hive
      final box = Hive.box(_settingsBoxName);
      await box.putAll({
        'version': remoteVersion,
        'data': data,
        'last_sync': DateTime.now().toIso8601String(),
      });

      print('✅ Guidelines sincronizados com sucesso (v$remoteVersion)');
      return true;
    } on SocketException catch (e) {
      print('❌ Erro de conexão: $e');
      return false;
    } catch (e) {
      print('❌ Erro ao sincronizar: $e');
      return false;
    }
  }

  /// Obtém guidelines locais (cache)
  Map<String, dynamic>? getLocalGuidelines() {
    try {
      final box = Hive.box(_settingsBoxName);
      return box.get('data') as Map<String, dynamic>?;
    } catch (e) {
      print('❌ Erro ao carregar guidelines locais: $e');
      return null;
    }
  }

  /// Obtém versão local
  Future<double> getLocalVersion() async {
    try {
      final box = Hive.box(_settingsBoxName);
      return box.get('version', defaultValue: 1.0) as double;
    } catch (e) {
      print('❌ Erro ao obter versão local: $e');
      return 1.0;
    }
  }

  /// Obtém timestamp da última sincronização
  Future<DateTime?> getLastSyncTime() async {
    try {
      final box = Hive.box(_settingsBoxName);
      final lastSync = box.get('last_sync') as String?;
      if (lastSync != null) {
        return DateTime.parse(lastSync);
      }
    } catch (e) {
      print('❌ Erro ao obter hora de sincronização: $e');
    }
    return null;
  }

  /// Valida estrutura básica do JSON de guidelines
  bool _validateGuidelinesStructure(Map<String, dynamic> data) {
    try {
      // Verifica se contém campos obrigatórios
      if (!data.containsKey('age_points') || !data.containsKey('risk_levels')) {
        return false;
      }

      final agePoints = data['age_points'] as Map<String, dynamic>;
      if (!agePoints.containsKey('MALE')) {
        return false;
      }

      final riskLevels = data['risk_levels'] as Map<String, dynamic>;
      if (riskLevels.isEmpty) {
        return false;
      }

      return true;
    } catch (e) {
      print('❌ Erro ao validar estrutura: $e');
      return false;
    }
  }

  /// Força sincronização (ignora intervalo de tempo)
  Future<bool> forceSync() async {
    print('🔄 Forçando sincronização de guidelines...');
    return downloadAndSyncUpdate();
  }

  /// Limpa dados locais (útil para reset)
  Future<void> clearLocalCache() async {
    try {
      final box = Hive.box(_settingsBoxName);
      await box.delete('version');
      await box.delete('data');
      await box.delete('last_sync');
      print('🗑️ Cache local limpo');
    } catch (e) {
      print('❌ Erro ao limpar cache: $e');
    }
  }
}
