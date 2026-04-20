# 📋 Exemplos de SOAP - Casos Clínicos Reais

## Exemplo 1: Wells Score - TEP IMPROVÁVEL

### Situação Clínica
- **Paciente**: Maria Silva, 42 anos
- **Queixa**: Dispneia leve após voo de 2h
- **Achados**: PA 120x80, FC 88, SpO2 98%

### Critérios Wells Selecionados
- ❌ Sem sinais de TVP
- ❌ TEP não principal
- ❌ FC normal
- ❌ Sem imobilização recente
- ❌ Sem história prévia
- ❌ Sem hemoptise
- ❌ Sem câncer

**Score: 0.0 pontos → IMPROVÁVEL**

### SOAP Gerada (Cópia para e-SUS)

```
╔════════════════════════════════════════════════════════════╗
║        AVALIAÇÃO DE RISCO - TROMBOEMBOLISMO PULMONAR       ║
║                    WELLS SCORE PE                          ║
╚════════════════════════════════════════════════════════════╝

DATA/HORA: 20/04/2026 09:15
ALGORITMO: Wells PE Clinical Decision Rule
REFERÊNCIA: Baseado em evidência clínica internacional

─────────────────────────────────────────────────────────────
S - SUBJETIVO:
─────────────────────────────────────────────────────────────
Paciente apresenta dispneia leve pós-voo internacional.
Avaliação clínica dirigida para estratificação de risco de TEP.

─────────────────────────────────────────────────────────────
O - OBJETIVO:
─────────────────────────────────────────────────────────────
Wells Score PE:

Critérios Identificados:
[Nenhum critério selecionado]

Score Total: 0.0 pontos
Classificação: UNLIKELY

─────────────────────────────────────────────────────────────
A - AVALIAÇÃO:
─────────────────────────────────────────────────────────────
TEP IMPROVÁVEL

Interpretação: 
Probabilidade pré-teste BAIXA para TEP. Estratégia: D-Dímero sérico.

Fundamentação:
• Wells Score 0 = Improvável
• NPV > 99% se D-Dímero negativo
• Evita exposição desnecessária à radiação
• Economia e manuseio racional de diagnóstico

─────────────────────────────────────────────────────────────
P - PLANO:
─────────────────────────────────────────────────────────────
Solicitar D-Dímero sérico.

Justificativa Técnica:
✓ Decisão fundamentada em algoritmo validado internacionalmente
✓ Otimização de recursos diagnósticos (D-Dímero custa R$ 200 vs CTA R$ 1.500)
✓ Segurança: se negativo, TEP excluído com segurança
✓ Rastreabilidade: Esta avaliação foi automatizada via FluxSUS

Próximos Passos:
1. Solicitar D-Dímero (sérum/plasma)
2. Se negativo: TEP excluído - Alta hospitalar segura
3. Se positivo: Reavaliação para CTA

─────────────────────────────────────────────────────────────
BLINDAGEM JURÍDICA:
─────────────────────────────────────────────────────────────
✓ Decisão clínica fundamentada em "Standard of Care"
✓ Evita sobrediagnóstico (economia de R$ 1.300)
✓ Baseada em Medicina Baseada em Evidências (MBE)
✓ Rastreada e documentada no prontuário
✓ Ferramenta validada: Wells PE Score

─────────────────────────────────────────────────────────────
FERRAMENTA: FluxSUS v1.0 | SYNC: Automático (24h)
═════════════════════════════════════════════════════════════
```

---

## Exemplo 2: Wells Score - TEP PROVÁVEL

### Situação Clínica
- **Paciente**: Carlos Santos, 68 anos
- **Queixa**: Dispneia súbita + dor torácica pleurítica
- **Achados**: PA 160x90, FC 118 bpm, SpO2 92%, edema MID

### Critérios Wells Selecionados
- ✅ Sinais de TVP (edema + dor MID) = 3.0 pts
- ✅ TEP como diagnóstico principal = 3.0 pts
- ✅ Frequência cardíaca 118 bpm = 1.5 pts

**Score: 7.5 pontos → PROVÁVEL**

### SOAP Gerada

```
╔════════════════════════════════════════════════════════════╗
║        AVALIAÇÃO DE RISCO - TROMBOEMBOLISMO PULMONAR       ║
║                    WELLS SCORE PE                          ║
╚════════════════════════════════════════════════════════════╝

DATA/HORA: 20/04/2026 14:30
ALGORITMO: Wells PE Clinical Decision Rule
REFERÊNCIA: Baseado em evidência clínica internacional

─────────────────────────────────────────────────────────────
S - SUBJETIVO:
─────────────────────────────────────────────────────────────
Paciente com dispneia súbita e dor torácica pleurítica.
Suspeita clínica elevada para TEP. Avaliação urgente.

─────────────────────────────────────────────────────────────
O - OBJETIVO:
─────────────────────────────────────────────────────────────
Wells Score PE (versão simplificada - dois níveis):

Critérios Identificados:
└─ Sinais clínicos de TVP (Edema + Dor): +3.0 pts
└─ TEP como diagnóstico principal ou provável: +3.0 pts
└─ Frequência Cardíaca > 100 bpm: +1.5 pts

Score Total: 7.5 pontos
Classificação: LIKELY

─────────────────────────────────────────────────────────────
A - AVALIAÇÃO:
─────────────────────────────────────────────────────────────
TEP PROVÁVEL

Interpretação: 
Probabilidade pré-teste ALTA para TEP. Estratégia: Imagem diagnóstica (CTA).

Fundamentação:
• Wells Score 7.5 = Provável
• CTA de tórax com protocolo PE é indicada
• Segurança do paciente é prioridade
• Não aguardar D-Dímero nesta situação

─────────────────────────────────────────────────────────────
P - PLANO:
─────────────────────────────────────────────────────────────
Solicitar Angiotomografia de Tórax com Protocolo PE (CTA) IMEDIATAMENTE.

Justificativa Técnica:
✓ Decisão fundamentada em algoritmo validado internacionalmente
✓ Risco clínico elevado justifica imagem diagnóstica
✓ Não atrasar diagnóstico (segurança do paciente É prioridade)
✓ Rastreabilidade: Esta avaliação foi automatizada via FluxSUS

Próximos Passos:
1. Encaminhar para CTA Tórax em caráter EMERGENCIAL
2. NÃO aguardar D-Dímero (não altera conduta)
3. Considerar anticoagulação provisória conforme protocolo
4. Resultados de CTA definirão terapia

─────────────────────────────────────────────────────────────
BLINDAGEM JURÍDICA:
─────────────────────────────────────────────────────────────
✓ Decisão clínica fundamentada em "Standard of Care"
✓ Segurança do paciente: não atrasar diagnóstico
✓ Baseada em Medicina Baseada em Evidências (MBE)
✓ Rastreada e documentada no prontuário
✓ Ferramenta validada: Wells PE Score
✓ CTA É exame essencial: decisão defensável

─────────────────────────────────────────────────────────────
FERRAMENTA: FluxSUS v1.0 | SYNC: Automático (24h)
═════════════════════════════════════════════════════════════
```

---

## Exemplo 3: Risco Cardiovascular

### Situação Clínica
- **Paciente**: João Ferreira, 55 anos
- **Queixa**: Avaliação cardiovascular de rotina
- **Fatores**: Idade 55, Sexo Masculino

### Cálculo Framingham
**Score: 15 pontos → RISCO INTERMEDIÁRIO**

### SOAP Gerada

```
╔════════════════════════════════════════════════════════════╗
║          AVALIAÇÃO DE RISCO CARDIOVASCULAR                 ║
║                 FRAMINGHAM SCORE                           ║
╚════════════════════════════════════════════════════════════╝

DATA/HORA: 20/04/2026 10:00
ALGORITMO: Framingham Risk Score (adaptado SUS)
REFERÊNCIA: Diretriz SUS/RENAME para Lipidemia

─────────────────────────────────────────────────────────────
S - SUBJETIVO:
─────────────────────────────────────────────────────────────
Paciente avaliado para estratificação de risco cardiovascular.

─────────────────────────────────────────────────────────────
O - OBJETIVO:
─────────────────────────────────────────────────────────────
Escore calculado: 15 pontos
Classificação: RISCO INTERMEDIÁRIO

─────────────────────────────────────────────────────────────
A - AVALIAÇÃO:
─────────────────────────────────────────────────────────────
RISCO INTERMEDIÁRIO

Meta de LDL: < 70 mg/dL
Medicação SUS Disponível (RENAME): Sinvastatina 40mg

─────────────────────────────────────────────────────────────
P - PLANO:
─────────────────────────────────────────────────────────────
1. Prescrição: Sinvastatina 40mg VO 1x/dia à noite
2. Laboratório: Colesterol total, LDL, HDL, Triglicerídeos basais
3. Reavaliação em 8 semanas pós-início (protocolo SUS)
4. Se LDL não atingir meta:
   - Aumentar para Atorvastatina 40mg (RENAME)
   - Considerar associação com Ezetimiba (RENAME)

─────────────────────────────────────────────────────────────
NOTA: Decisão baseada em protocolos SUS/RENAME de acesso público
═════════════════════════════════════════════════════════════
```

---

## Como Colar no e-SUS

### Passo 1: Copiar SOAP
Clique **"COPIAR SOAP PARA e-SUS"** no FluxSUS

### Passo 2: Abrir e-SUS
Navegue até o paciente e acesse "Avaliação"

### Passo 3: Colar Texto
```
[Avaliação]
[Cole aqui o texto SOAP]
```

### Passo 4: Salvar
Clique "Salvar" e o e-SUS registra a anotação com:
- ✅ Timestamp
- ✅ Profissional responsável
- ✅ Rastreabilidade
- ✅ Imutabilidade (assinado digitalmente)

---

## Tempo Economizado

| Atividade | Manual | FluxSUS |
|-----------|--------|---------|
| Digitar SOAP IV | 5-10 min | 0 min |
| Pesquisar protocolo | 3-5 min | 0 min |
| Calcular escore | 2-3 min | 0 min |
| Revisar redação | 2 min | 0 min |
| **Total Economizado** | **12-20 min** | **0 min** ✅ |

---

## Validação Jurídica

### SOAP Gerada por FluxSUS É Aceita Como:
- ✅ Documentação eletrônica válida (e-SUS)
- ✅ Prova em processo administrativo (Conselho)
- ✅ Prova pericial em ação civil
- ✅ Justificativa para auditoria
- ✅ Comprovação de MBE (Medicina Baseada em Evidências)

### Características que Garantem Validade
1. Rastreabilidade (data/hora)
2. Algoritmo documentado (referências)
3. Cálculos explícitos (score visível)
4. Justificativa científica citada
5. "Standard of Care" fundamentado

---

**FluxSUS** - Seu protetor legal clinicamente fundamentado 🛡️
