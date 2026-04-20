# FluxSUS 🏥

**Calculadora Clínica Inteligente para o SUS**

Ferramentas de apoio clínico com sincronização automática de protocolos e justificativa técnica para e-SUS.

---

## ✨ Funcionalidades

### 📊 **Calculadoras Implementadas**

#### 1️⃣ **Risco Cardiovascular**
- Calcula risco de doença cardiovascular baseado em idade
- Recomendações de medicação SUS (RENAME)
- Metas de LDL personalizadas

#### 2️⃣ **Wells Score (TEP)** ⭐
- Estratificação de risco para Tromboembolismo Pulmonar
- Versão "Dois Níveis" otimizada para pronto-socorro
- **Reduz 30% das tomografias desnecessárias**
- Cópia automática de justificativa SOAP para e-SUS

### 🔄 **Sincronização Automática**
- Sincroniza com `guidelines.json` no GitHub
- Verifica updates a cada 24h
- Funciona offline (cache local com Hive)
- Sem necessidade de redesenho da app

### 💾 **Persistência Local**
- Hive para armazenamento offline
- Cache inteligente de guidelines
- Histórico de sincronização

---

## 🏗️ **Arquitetura**

```
lib/
├── core/
│   ├── data/              # Tabelas e mapas clínicos
│   │   ├── risk_data.dart
│   │   └── wells_data.dart
│   ├── logic/             # Motores de cálculo
│   │   ├── risk_engine.dart
│   │   └── wells_engine.dart
│   ├── services/          # Sincronização e DI
│   │   ├── update_service.dart
│   │   ├── sync_manager.dart
│   │   └── service_locator.dart
│   └── utils/             # Utilidades
│       └── clipboard_utils.dart
├── presentation/
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── cardio_screen.dart
│   │   └── wells_screen.dart
│   ├── widgets/
│   │   └── sync_status_widget.dart
│   └── theme/
│       └── sus_theme.dart
└── main.dart
```

---

## 🚀 **Quick Start**

### 1. **Instalar Dependências**
```bash
flutter pub get
```

### 2. **Rodar a App**
```bash
flutter run
```

### 3. **Home Screen**
- Menu com calculadoras disponíveis
- Status de sincronização
- Info sobre ferramentas

---

## 📋 **Wells Score - Exemplo de Uso**

1. **Selecionar Critérios** ✓
   - Interface ágil com checkboxes
   - Score atualiza em tempo real

2. **Visualizar Resultado** 🎯
   - 🟢 **Improvável**: D-Dímero suficiente
   - 🔴 **Provável**: Fazer CTA imediatamente

3. **Copiar Justificativa** 📋
   - Botão "Copiar Justificativa"
   - Texto SOAP já formatado
   - Cola direto no prontuário e-SUS

---

## 💰 **Impacto SUS**

| Métrica | Valor |
|---------|-------|
| **CTs Evitadas** | ~30% |
| **Economia/Paciente** | ~R$ 1.500 |
| **Radiação Evitada** | 1.5 mSv |
| **Segurança** | NPV > 99% |

---

## 🔧 **Tecnologias**

- **Flutter 3.0+** - UI multiplataforma
- **Hive** - Banco de dados local
- **HTTP** - Sincronização com GitHub
- **Connectivity Plus** - Verificar conexão
- **Intl** - Formatação de moeda SUS

---

## 📱 **Platforms**

- ✅ **Android** (Pronto)
- ✅ **iOS** (Pronto)
- 🔜 **Web** (Em planejamento)

---

## 📦 **Guidelines Remotos**

```
URL: https://raw.githubusercontent.com/Arailes/fluxsus/main/guidelines.json

Contém:
  - Tabelas de pontuação por idade
  - Classificações de risco
  - Medicações SUS disponíveis
  - Recomendações clínicas
```

A app sincroniza automaticamente a cada 24h. Para atualizar, edite `guidelines.json` e faça push.

---

## 🛠️ **Desenvolvimento**

### Adicionar Nova Calculadora

1. **Criar arquivo de dados** (`lib/core/data/nova_calculadora_data.dart`)
   ```dart
   class NovaCalculadoraData {
     static const Map<String, dynamic> criteria = { ... };
     static const Map<String, Map<String, dynamic>> results = { ... };
   }
   ```

2. **Criar motor** (`lib/core/logic/nova_calculadora_engine.dart`)
   ```dart
   class NovaCalculadoraEngine {
     static double calculate(Map<String, bool> inputs) { ... }
   }
   ```

3. **Criar tela** (`lib/presentation/screens/nova_calculadora_screen.dart`)
   - Reutilizar tema SUS
   - Usar CheckboxListTile para entrada
   - Integrar com ClipboardUtils

4. **Adicionar ao menu** (`home_screen.dart`)
   ```dart
   _buildCalculatorCard(
     context,
     title: 'Nova Calculadora',
     ...
   )
   ```

---

## 📚 **Documentação Detalhada**

- [WELLS_GUIDE.md](WELLS_GUIDE.md) - Guia clínico completo Wells Score
- [guidelines.json](guidelines.json) - Tabelas de referência

---

## 🚀 **Próximas Versões**

- [ ] Calculadora de Interpretação Laboratorial
- [ ] Histórico de cálculos
- [ ] Suporte offline completo
- [ ] Telemetria de uso (anonimizada)
- [ ] Push notifications de updates

---

## 📄 **Licença**

Desenvolvido com ❤️ para o SUS.
Uso exclusivo em ambiente clínico.

---

## 👥 **Criador**

- **Arailes** - Ideação e Development

---

**FluxSUS** - Tornando a clínica mais rápida, segura e racional no SUS 🇧🇷
