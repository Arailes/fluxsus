# 📋 Wells Score - Calculadora de Risco de TEP

## 📌 O Que É?

O **Wells Score** é um algoritmo de estratificação de risco clínico para **Tromboembolismo Pulmonar (TEP)**.

Usando apenas **critérios clínicos simples**, permite ao médico decidir:

- 🟢 Se pode fazer apenas D-Dímero (evitando tomografia)
- 🔴 Se precisa fazer Angiotomografia de Tórax (CTA) imediatamente

## 🎯 Objetivo SUS

Reduzir número de **tomografias desnecessárias** mantendo **segurança do paciente**.

- **30% das CTAs poderiam ser evitadas** com estratificação adequada
- **Economia**: ~R$ 1.500 por paciente (vs. D-Dímero de R$ 150-300)
- **Segurança**: D-Dímero negativo exclui TEP com NPV > 99% em casos improvávels

## 📊 Critérios Clínicos

| Critério | Pontos |
| --- | --- |
| Sinais de TVP (Edema + Dor em membros) | 3.0 |
| TEP como diagnóstico principal/provável | 3.0 |
| Frequência Cardíaca > 100 bpm | 1.5 |
| Cirurgia/Imobilização (últimas 4 semanas) | 1.5 |
| Antecedente de TEP ou TVP | 1.5 |
| Hemoptise (escarro com sangue) | 1.0 |
| Câncer em tratamento/paliativo | 1.0 |

## 🚦 Interpretação (Dois Níveis)

### 🟢 **TEP IMPROVÁVEL** (Score ≤ 4.0)

**Ação:** Solicitar D-Dímero  
**Se D-Dímero negativo:** TEP excluído com segurança - **NÃO pedir CTA**

```txt
Benefício: Evita radiação desnecessária (~1.5 mSv por CTA)
Economia: ~R$ 1.500 por caso evitado
```

### 🔴 **TEP PROVÁVEL** (Score > 4.0)

**Ação:** Solicitar **Angiotomografia de Tórax (CTA)** IMEDIATAMENTE

```txt
Razão: Risco clínico justifica exposição à radiação
Urgência: Não adiar. Considerar anticoagulação conforme protocolo.
```

## 🏗️ Arquitetura

### Camada de Dados (`lib/core/data/wells_data.dart`)

```dart
WellsData.criteria          // Mapa de critérios e pontos
WellsData.interpretation    // Tabelas de risco (UNLIKELY/LIKELY)
WellsData.clinicalApproach  // Fluxo de abordagem
WellsData.susSavingsPotential // Economia estimada
```

### Motor de Cálculo (`lib/core/logic/wells_engine.dart`)

```dart
WellsEngine.calculateScore()        // Calcula score total
WellsEngine.getRiskClassification() // Retorna UNLIKELY/LIKELY
WellsEngine.getRecommendation()     // Recomendação clínica completa
WellsEngine.calculateClinicalImpact() // Impacto em economia SUS
```

### Interface (`lib/presentation/screens/wells_screen.dart`)

- ✅ Checklist interativo dos critérios
- ✅ Score em tempo real
- ✅ Classificação visual (Core verde/vermelho)
- ✅ Recomendações estruturadas
- ✅ Impacto SUS (economia/radiação evitada)

## 💻 Como Usar

### 1. Navegar para a calculadora

```txt
// HomeScreen → Tap em "Wells Score - TEP"
```

### 2. Selecionar critérios presentes

```txt
✓ Sinais de TVP
✓ Frequência Cardíaca > 100
```

### 3. Score é calculado automaticamente

```txt
Score: 4.5 → TEP PROVÁVEL
```

### 4. Recomendação é exibida

```txt
🔴 Ação: Solicitar CTA TÓRAX imediatamente
```

## 🔧 Integração com Guidelines.json

O arquivo `guidelines.json` no repositório pode ser atualizado com novos critérios:

```json
{
  "version": 1.1,
  "wells": {
    "criteria": { ... },
    "interpretation": { ... }
  }
}
```

A app sincroniza automaticamente a cada 24h.

## 📚 Referências

- **Wells PE Clinical Decision Rule** - Principal publicação
- **ACEP ou SDUS Guidelines** - Protocolos clínicos

## 🚀 Próximas Versões

- [ ] Adicionar Wells Score para TVP (critérios diferentes)
- [ ] Integrar com telemetria (enviar resultados para analytics)
- [ ] Adicionar histórico de cálculos
- [ ] Suporte offline completo
- [ ] Impressão de recomendação para prontuário e-SUS

---

## Desenvolvido com ❤️ para o SUS
