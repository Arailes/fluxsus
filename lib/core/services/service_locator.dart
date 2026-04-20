/// Injeção de Dependências e Inicialização
/// Configura Hive e registra serviços disponíveis globalmente

import 'package:hive/hive.dart';
import 'update_service.dart';
import 'sync_manager.dart';

/// Service Locator simplificado (pode ser substituído por GetIt depois)
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  static final Map<Type, dynamic> _services = {};

  ServiceLocator._internal();

  factory ServiceLocator() {
    return _instance;
  }

  /// Registra um serviço
  static void register<T>(T service) {
    _services[T] = service;
  }

  /// Obtém um serviço registrado
  static T get<T>() {
    return _services[T] as T;
  }

  /// Verifica se serviço está registrado
  static bool has<T>() {
    return _services.containsKey(T);
  }
}

/// Inicializa aplicação
/// Deve ser chamada em main() antes de runApp()
Future<void> initializeApp() async {
  try {
    print('🚀 Inicializando FluxSUS...');

    // Inicializa Hive (armazenamento local)
    print('📦 Configurando Hive...');
    await Hive.openBox('settings');

    // Registra serviços
    print('⚙️ Registrando serviços...');
    final updateService = UpdateService();
    ServiceLocator.register<UpdateService>(updateService);

    final syncManager = SyncManager(updateService: updateService);
    ServiceLocator.register<SyncManager>(syncManager);

    // Inicia sincronização automática
    print('🔄 Iniciando sincronização automática...');
    syncManager.startAutoSync(checkInterval: const Duration(hours: 24));

    // Faz sincronização inicial se necessário
    final hasUpdate = await updateService.hasNewUpdate();
    if (hasUpdate) {
      print('📥 Atualizações disponíveis, sincronizando...');
      await updateService.downloadAndSyncUpdate();
    } else {
      print('✅ Guidelines estão atualizados');
    }

    print('✨ FluxSUS pronto!');
  } catch (e) {
    print('❌ Erro ao inicializar: $e');
    rethrow;
  }
}

/// Limpa resources antes de fechar app
Future<void> cleanupApp() async {
  try {
    print('🧹 Finalizando FluxSUS...');
    
    if (ServiceLocator.has<SyncManager>()) {
      ServiceLocator.get<SyncManager>().dispose();
    }

    await Hive.close();
    print('👋 FluxSUS finalizado');
  } catch (e) {
    print('❌ Erro ao finalizar: $e');
  }
}
