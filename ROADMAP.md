# 🚀 FluxSUS - Roadmap & Status

## 📊 Status Atual (v1.0 MVP)

```
████████████████████░░░░░░░░░░░░ 67% (10/16 features)
```

---

## ✅ Fase 1: MVP Básico (Completo)

### Core Features
- ✅ **Estrutura Clean Architecture** (Core/Presentation/Data)
- ✅ **Tema SUS** (Cores oficiais, tipografia)
- ✅ **Risco Cardiovascular** (Idade → Score → Medicação)
- ✅ **Wells Score TEP** (7 critérios → 2 níveis de risco)
- ✅ **Menu de Navegação** (Home Screen com cards)

### Data Layer
- ✅ **guidelines.json** (Remote em GitHub)
- ✅ **RiskData** (Tabelas Framingham)
- ✅ **WellsData** (Tabelas Wells PE)
- ✅ **Service Locator** (Injeção de Dependências)

### Services
- ✅ **UpdateService** (Sincroniza guidelines remotos)
- ✅ **SyncManager** (Agendamento automático 24h)
- ✅ **Hive Persistence** (Armazenamento local)
- ✅ **Connectivity Check** (Funciona offline)

### UI/UX
- ✅ **Checklist Ágil** (Wells com ListView automático)
- ✅ **SOAP Automático** (Cópia para e-SUS)
- ✅ **ClipboardUtils** (Formatação e sanitização)
- ✅ **SyncStatusWidget** (Mostra status)

### Documentation
- ✅ **README.md** (Visão geral + arquitetura)
- ✅ **WELLS_GUIDE.md** (Guia clínico Wells)
- ✅ **SOAP_LEGAL_GUIDE.md** (Blindagem jurídica)
- ✅ **SOAP_EXAMPLES.md** (Casos clínicos reais)

### Commits
- ✅ 10 commits estruturados
- ✅ Message bem-formatadas (feat:/docs:/refactor:)

---

## 🏗️ Fase 2: Expansão (Em Planejamento)

### Features Planejadas

#### **2.1 Calculadora de Lab** (Est: 4 semanas)
```
Objetivo: Interpretação de valores laboratoriais
Escopo:
  - INR (Anticoagulação)
  - Troponina (Infarto)
  - BNP (Insuficiência cardíaca)
  - Creatinina/eGFR (Renal)
  - Taxa de infecção
  
Impacto: Economia + Diagnóstico rápido
```

#### **2.2 Histórico de Cálculos** (Est: 2 semanas)
```
Objetivo: Auditoria e comparação de evoluções
Escopo:
  - Salvar cálculos com timestamp
  - Filtrar por data/tipo
  - Comparar risco ao longo do tempo
  - Exportar em PDF/Excel
  
Impacto: Rastreabilidade + MBE
```

#### **2.3 PDF Export** (Est: 1 semana)
```
Objetivo: Imprimir/compartilhar relatório
Escopo:
  - SOAP em PDF com logo SUS
  - QR Code com link para verificação
  - Assinatura digital (certificado)
  - Compatível com impressoras de SUS
  
Impacto: Praticidade
```

#### **2.4 Multi-Calculadoras Wells** (Est: 2 semanas)
```
Objetivo: Suportar TVP + PE + outras
Escopo:
  - Wells Score PE (feito ✅)
  - Wells Score TVP (novo)
  - Modified Wells
  - Versão pediátrica
  
Impacto: Cobertura clínica ampliada
```

#### **2.5 Telemetria Anonimizada** (Est: 3 semanas)
```
Objetivo: Analytics para pesquisa SUS
Escopo:
  - Contar uso por calculadora
  - Região/Estado de uso
  - Tempo de resposta
  - Scores mais frequentes
  - NUNCA dados do paciente
  
Impacto: Validação real de impacto
```

---

## 🎯 Fase 3: Integração (Futuro)

### API e-SUS (Est: 6 semanas)
```
Objetivo: Integração direta com e-SUS
API Endpoints:
  POST /api/v1/soap          # Enviar SOAP
  GET /api/v1/patient/{id}   # Dados básicos
  POST /api/v1/sync          # Sincronizar guidelines
  
Benefício: Fluxo contínuo, sem copiar/colar
```

### MCP Server (Est: 4 semanas)  
```
Objetivo: FluxSUS como servidor independente
Uso: Hospitais, clínicas, telemedicina
```

### App Web (Est: 8 semanas)
```
Objetivo: Versão web para navegadores
Stack: Flutter Web / Next.js
Acesso: fluxsus.sus.gov.br
```

---

## 📈 Métricas de Sucesso

### Fase 1 MVP
- [x] Código funcional e bem documentado
- [x] Sem crashes ou erros críticos
- [x] Build rápido (< 30s)
- [x] Sincronização automática funcionando
- [x] SOAP formatado corretamente

### Fase 2 (Alvo)
- [ ] 10% de redução em CTs solicitadas (Wells)
- [ ] 100+ médicos usando
- [ ] Feedback positivo de Conselhos Regionais
- [ ] Zero litígios por falta de documentação
- [ ] Economia de R$ 500k+ para SUS (extrapolado)

### Fase 3 (Visão)
- [ ] Integração com 80% dos prontuários eletrônicos SUS
- [ ] 1000+ médicos usando
- [ ] Publicação em revista científica
- [ ] Reconhecimento do Ministério da Saúde

---

## 🛠️ Stack Técnico

### Core
```
Flutter 3.5+ (Dart 3.1+)
Provider/Riverpod (DI/State)
Clean Architecture
```

### Persistência
```
Hive (Offline-first)
Shared Preferences
SQLite (v2 - Histórico)
```

### APIs
```
HTTP (guidelines.json)
Connectivity Plus
Firebase (v2 - Analytics)
e-SUS Integration (v3)
```

### Testing (v2+)
```
Mockito
Bloc Test
Golden Tests
```

---

## 📋 Checklist de Deploy

### MVP (Atual)
- [x] Core features funcionando
- [x] Sincronização testada
- [x] UI/UX polida
- [ ] **→ Testadores SUS** (próximo step)

### v1.1
- [ ] Lab Calculator
- [ ] Histórico
- [ ] PDF Export
- [ ] **→ Fase 2 Release** 

### v2.0
- [ ] API e-SUS
- [ ] Telemetria
- [ ] Web Version

---

## 🤝 Como Contribuir

### Issues Abertas para Contribuidores
1. Adicionar Calculadora de Lab
2. Melhorar UI/UX (Design System)
3. Testes automatizados
4. Documentação em inglês

### Para Reportar Bugs
```bash
GitHub Issues → Label: bug
Template incluso
```

### Para Sugestões
```bash
GitHub Discussions → Category: Feature requests
```

---

## 📞 Contato e Suporte

### Links Importantes
- **GitHub**: https://github.com/Arailes/fluxsus
- **Wiki**: https://github.com/Arailes/fluxsus/wiki
- **Issues**: https://github.com/Arailes/fluxsus/issues
- **Guidelines**: https://raw.githubusercontent.com/Arailes/fluxsus/main/guidelines.json

### Canais
- 📧 Email: [a confirmar]
- 💬 Discussions: GitHub Discussions
- 🐛 Bugs: Issues com label "bug"
- 💡 Features: Discussions + Issues com label "enhancement"

---

## 📜 Licença & Conformidade

### Licença
```
GNU General Public License v3.0
(Código aberto, uso comercial em respeito à GPL)
```

### Conformidade
- ✅ LGPD (Lei Geral de Proteção de Dados)
- ✅ e-SUS compatible
- ✅ SUS protocols
- ✅ Medicina Baseada em Evidências
- ✅ Standard of Care

---

## 🎓 Roadmap Learning

### Para Novos Contribuidores
1. Ler [README.md](README.md)
2. Revisar [WELLS_GUIDE.md](WELLS_GUIDE.md)
3. Explorar arquitetura [lib/](lib/)
4. Teste localmente

### Recursos Úteis
- Flutter Docs: https://flutter.dev
- Clean Architecture: Uncle Bob
- Hive Docs: https://docs.hivedb.dev
- e-SUS Docs: https://aps.saude.gov.br

---

## 🚀 Visão de Longo Prazo

### 3 Anos (2029)
```
FluxSUS é parte do ecossistema SUS digital
  ├─ Integrado em 90% dos prontuários
  ├─ 50k+ médicos usando regularmente
  ├─ Economia nacional: R$ 100M+ anuais
  ├─ Publicações científicas: 5+
  └─ Reconhecimento internacional

Impacto:
  ✓ Diagnóstico mais rápido
  ✓ Uso racional de recursos
  ✓ Protecção legal de médicos
  ✓ Melhor atendimento ao paciente
  ✓ SUS mais eficiente
```

---

## 📊 Estrutura de Releases

```
v1.0  → MVP Core Features        (Atual ✅)
v1.1  → Lab + Histórico          (Próximo Q2 2026)
v1.2  → PDF Export               (Q3 2026)
v2.0  → API e-SUS + Telemetria   (Q4 2026)
v2.5  → Web Version              (Q1 2027)
v3.0  → Mobile App Native        (Q2 2027)
```

---

**FluxSUS** - Tornando a medicina do SUS mais inteligente, rápida e segura 🏥🚀

*Last Updated: 2026-04-20*
*Next Review: 2026-05-20*
