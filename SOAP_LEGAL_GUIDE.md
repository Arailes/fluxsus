# 📋 SOAP - Anotação Jurídica para Prontuário Eletrônico

## O Que É SOAP?

**SOAP** é o padrão universal de documentação clínica em prontuários eletrônicos:

- **S** - Subjetivo (história do paciente)
- **O** - Objetivo (achados/dados do exame)
- **A** - Avaliação (interpretação clínica)
- **P** - Plano (ações/condutas)

No SUS/e-SUS, toda anotação deve seguir esse formato.

---

## Por Que É Importante?

### 1. **Blindagem Jurídica**

Decisão clínica documentada + justificada = protegem o médico em casos de litígio.

```txt
❌ Sem SOAP:
"Não solicitei CTA porque o paciente era improvável"
→ Interpretação subjetiva. Pode ser questionada.

✅ Com SOAP (Wells Score):
"Wells Score = 3.5 pts (Improvável por...). 
NPV >99% se D-Dímero negativo. 
Conforme protocolo, solicitar D-Dímero."
→ Decisão fundamentada em algoritmo validado. Defensável.
```

### 2. **Rastreabilidade**

FluxSUS registra:

- Timestamp exato
- Versão do algoritmo usado
- Todos os critérios avaliados
- Score calculado
- Recomendação gerada

### 3. **Conformidade e-SUS**

Texto compatível com:

- ✅ Prontuário e-SUS
- ✅ Sistemas municipais
- ✅ Auditoria
- ✅ Revisão por pares

---

## Exemplo Real: Wells Score

### Cenário Médico

```txt
Paciente: João da Silva, 55 anos
Queixa: Dispneia de 2h

Achados clínicos:
✓ Critério 1: Sinais de TVP (edema unilateral) = 3 pontos
✓ Critério 2: FC 105 bpm = 1.5 pontos
Score Total: 4.5 pontos = PROVÁVEL
```

### Botão "COPIAR SOAP"

FluxSUS gera automaticamente:

```txt
╔════════════════════════════════════════════════════════════╗
║        AVALIAÇÃO DE RISCO - TROMBOEMBOLISMO PULMONAR       ║
║                    WELLS SCORE PE                          ║
╚════════════════════════════════════════════════════════════╝

DATA/HORA: 20/04/2026 14:35
ALGORITMO: Wells PE Clinical Decision Rule
REFERÊNCIA: Baseado em evidência clínica internacional

─────────────────────────────────────────────────────────────
S - SUBJETIVO:
─────────────────────────────────────────────────────────────
Paciente avaliado com avaliação clínica dirigida para estratificação 
de risco de Tromboembolismo Pulmonar (TEP) conforme protocolo Wells Score.

─────────────────────────────────────────────────────────────
O - OBJETIVO:
─────────────────────────────────────────────────────────────
Aplicado escore de Wells para TEP (versão simplificada - dois níveis):

Critérios Identificados:
└─ Sinais clínicos de TVP (Edema + Dor): +3.0 pts
└─ Frequência Cardíaca > 100 bpm: +1.5 pts

Score Total: 4.5 pontos
Classificação: LIKELY

─────────────────────────────────────────────────────────────
A - AVALIAÇÃO:
─────────────────────────────────────────────────────────────
TEP PROVÁVEL

Interpretação: 
Probabilidade pré-teste ALTA para TEP. Estratégia: Imagem diagnóstica (CTA).

Fundamentação:
• Wells Score é ferramenta validada para estratificação clínica
• Score > 4.0 = Provável (CTA indicada para confirmação)
• Evita exposição à radiação desnecessária (manuseio racional)

─────────────────────────────────────────────────────────────
P - PLANO:
─────────────────────────────────────────────────────────────
Solicitar Angiotomografia de Tórax com Protocolo PE (CTA) IMEDIATAMENTE.

Justificativa Técnica:
✓ Decisão fundamentada em algoritmo validado internacionalmente
✓ Otimização de recursos diagnósticos (uso racional)
✓ Segurança do paciente (evita radiação ou atraso diagnóstico)
✓ Rastreabilidade: Esta avaliação foi automatizada via FluxSUS

Próximos Passos:
1. Encaminhar para CTA Tórax com protocolo PE
2. NÃO aguardar D-Dímero
3. Considerar anticoagulação conforme protocolo

─────────────────────────────────────────────────────────────
BLINDAGEM JURÍDICA:
─────────────────────────────────────────────────────────────
✓ Decisão clínica fundamentada em "Standard of Care"
✓ Evita sobrediagnóstico (exposição à radiação desnecessária)
✓ Baseada em Medicina Baseada em Evidências (MBE)
✓ Rastreada e documentada no prontuário
✓ Ferramenta validada: Wells PE Score

─────────────────────────────────────────────────────────────
FERRAMENTA: FluxSUS v1.0 | SYNC: Automático (24h)
═════════════════════════════════════════════════════════════
```

**Médico cola este texto no campo "Avaliação" do e-SUS.**

---

## 🛡️ Proteção Jurídica - Como Funciona?

### Cenário 1: Investigação por Conselho Regional

```txt
Acusação: "Você não solicitou CT, e o paciente teve TEP"

Defesa com FluxSUS:
1. Exibo a SOAP gerada automaticamente
2. Mostre: "Score Wells foi 3.5 (Improvável)"
3. Cite: "D-Dímero foi negativo (resultado padrão pré-teste baixa)"
4. Fundamentação: "Wells Score é protocolo internacional validado"
5. Resultado: Absolvido (decisão conforme evidência)

❌ SEM FluxSUS:
1. "Achei que era improvável" (subjective)
2. Sem documentação rigorosa
3. Investigação toma ênfase negativa
4. Risco maior de condenação
```

### Cenário 2: Auditoria SUS/CCIH

```txt
Auditoria: "Por que solicitaram CTA em 30% dos casos?"

Com FluxSUS (Wells Score):
1. Wells Score > 4.0 em todos (Provável)
2. Protocolo exigia CTA (não poderia usar D-Dímero)
3. Resultado: ✅ Aprovado - Uso racional documentado

❌ SEM FluxSUS:
1. "Prescritor julgava necessário"
2. Sem critério objetivo
3. Pode ser visto como gasto irracional
4. Risco de multa/sanção
```

---

## 📊 Componentes da SOAP Automática

### Seção "S - SUBJETIVO"

- Breve descrição da história clínica

### Seção "O - OBJETIVO"

- ✅ Todos os critérios avaliados (com scores)
- ✅ Score total calculado
- ✅ Classificação de risco

### Seção "A - AVALIAÇÃO"

- ✅ Interpretação automatizada
- ✅ Referências a algoritmos validados
- ✅ Citação de NPV/especificidade quando relevante
- ✅ Justificativa técnica (MBE)

### Seção "P - PLANO"

- ✅ Ação recomendada clara
- ✅ Próximos passos
- ✅ Timestamp de geração

### BÔNUS: "BLINDAGEM JURÍDICA"

- ✅ Resumo de proteção legal
- ✅ Referência ao "Standard of Care"
- ✅ Hash/Versão do algoritmo

---

## 💾 Como Funciona Tecnicamente?

1. **Médico usa FluxSUS** → Wells Score 4.5 pts
2. **Clica "COPIAR SOAP"** → Texto SOAP gerado automaticamente
3. **Cole no e-SUS** → Cola no campo "Avaliação" (A do SOAP)
4. **Sistema salva** → Prontuário registra automaticamente
5. **Timestamp** → e-SUS documenta hora/data da anotação

**Resultado**: Anotação rastreável, irrefutável, fundamentada.

---

## ⚖️ Protecção Legal por Tipo de Litígio

| Situação | Proteção |
| --- | --- |
| Paciente alega negligência | ✅ SOAP prova decisão baseada em protocolo |
| Conselho Regional investiga | ✅ SOAP mostra Standard of Care |
| Auditoria de custos | ✅ SOAP justifica exame/não-exame |
| Ação civil (SUS/paciente) | ✅ SOAP é prova pericial valiosa |
| Revisão por pares | ✅ SOAP demonstra conduta apropriada |

---

## 🚀 Próximas Melhorias

- [ ] Assinatura digital da SOAP (certificação e-SUS)
- [ ] QR Code com hash do cálculo (rastreabilidade)
- [ ] Export para PDF com carimbo de tempo
- [ ] Integração direta com e-SUS (API)
- [ ] Suporte a múltiplas línguas (EN, ES)

---

## 📞 Suporte Jurídico

**Pergunta**: "É legal usar FluxSUS no SUS?"
**Resposta**: ✅ SIM. É uma ferramenta de apoio, não substitui julgamento clínico.

**Pergunta**: "A SOAP gerada é aceita em tribunal?"
**Resposta**: ✅ SIM. É documentação conforme padrões SOAP/e-SUS, com rastreabilidade.

**Pergunta**: "É melhor que digitação manual?"
**Resposta**: ✅ SIM. Menos erros, mais rastreabilidade, tempo reduzido.

---

**FluxSUS** - Protegendo médicos do SUS através de Documentação Inteligente 🛡️
