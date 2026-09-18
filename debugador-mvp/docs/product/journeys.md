# Jornadas de usuário — MVP Debugador

Persona padrão: **engenheiro de software / mantenedor** de um serviço Java.  
Comportamento de UI descreve o **alvo do MVP** (várias telas ainda não implementadas).

Visão e escopo: [mvp.md](./mvp.md).

---

## Jornada 1 — Fluxo vertical completo (prova do MVP)

**Objetivo:** Do zero à visualização que cruza modelo estático, diagrama do cenário e execução correlacionada.

### Trigger

O engenheiro precisa entender um endpoint ou caso de uso antes de uma refatoração e não confia apenas no diagrama do Confluence.

### Pré-condições

- Ambiente local: `docker compose up --build` ([README](../../README.md)).
- Repositório Java de exemplo acessível (URL Git e commit conhecido).

### Passos

| # | Ação do usuário | Sistema (backend/worker/agent) | UI desejada |
|---|-----------------|--------------------------------|-------------|
| 1 | Cria projeto com nome e repositório (provider, URL, branch) | Persiste `project` + `repository`; retorna IDs | Formulário “Novo projeto”; confirmação com link para detalhe |
| 2 | Registra snapshot para um `commit_hash` | Cria `source_snapshot` ligado ao projeto | Seletor de branch/commit ou campo commit; snapshot listado com data |
| 3 | Solicita análise do snapshot | Enfileira job; `analysis` RUNNING → SUCCEEDED/FAILED | Badge de status; erro legível se FAILED |
| 4 | Consulta resultado da análise | Popula `software_element` e `relationship` | Árvore ou lista filtrável (tipos, FQN, arquivo) |
| 5 | Cria cenário no mesmo snapshot e define entry point | `scenario` + `entry_point` | Wizard “Novo cenário”: nome, descrição, método/rota de entrada |
| 6 | Gera ou edita diagrama do cenário | `diagram`, `participant`, `interaction` versionados | Canvas ou lista sequencial de participantes/mensagens com âncoras no código |
| 7 | Inicia execução do cenário (app instrumentada com agent) | `execution` RUNNING; ingestão de `trace`/`span` | Botão “Executar” + instruções do agent; timeline ao vivo via WebSocket |
| 8 | Aguarda correlação automática | `correlation` + `evidence` entre interactions e spans | Indicador “Correlacionando…” depois “N correlações” |
| 9 | Abre visualização integrada | Agrega diagrama + spans + highlights | Vista única: interações destacadas quando há span correlacionado; clique mostra evidência e código |

### Resultado esperado

O engenheiro identifica, em uma única sessão, a sequência esperada (diagrama) e a sequência observada (spans), com ligações explícitas e confidence/evidence — sem alternar entre quatro ferramentas.

### Critérios de aceite (checklist testável)

- [ ] Após passo 1, `GET /projects` inclui o projeto e sobrevive a restart da API.
- [ ] Após passo 2, existe registro único `(project_id, commit_hash)` em `source_snapshot`.
- [ ] Após passo 3 bem-sucedido, `analysis.status = SUCCEEDED` e contagem de elementos > 0.
- [ ] Passo 5: cenário referencia o **mesmo** `snapshot_id` da análise do passo 3.
- [ ] Após passo 7, existe `trace` vinculado à `execution` e ≥ 3 spans em hierarquia coerente (`parent_span_id`).
- [ ] Após passo 8, ≥ 1 linha em `correlation` com `confidence` documentada e ≥ 1 `evidence`.
- [ ] Passo 9: na UI, pelo menos uma interação do diagrama aparece visualmente ligada a um span (mesmo que lista lateral, não grafo fancy).
- [ ] WebSocket em `/ws/executions/{executionId}` emite evento de progresso além de CONNECTED (quando execução implementada).

---

## Jornada 2 — Diagnosticar análise falha

**Objetivo:** Quando o código não pode ser modelado, o usuário entende o porquê e pode corrigir entrada (commit/repo).

### Trigger

Análise retorna FAILED após novo snapshot.

### Passos resumidos

1. Abre detalhe do snapshot com análise em falha.
2. Lê `error_message` e timestamp `finished_at`.
3. Opcional: registra novo snapshot em commit corrigido e reenfileira análise.

### UI desejada

Banner de erro persistente; link para logs do worker; botão “Tentar novamente”.

### Critérios de aceite

- [ ] `analysis.status = FAILED` implica `error_message` não nulo na API.
- [ ] Nova análise no mesmo snapshot cria novo registro `analysis` (histórico) ou política documentada de substituição — comportamento único documentado em OpenAPI.
- [ ] UI não exibe elementos/relaciones da análise falha como se fossem válidos.

---

## Jornada 3 — Explorar modelo estático sem executar

**Objetivo:** Valor parcial antes do agent: navegar grafo de classes/métodos e dependências do snapshot.

### Trigger

Engenheiro quer mapa do código sem rodar o serviço instrumentado.

### Passos resumidos

1. Seleciona projeto e snapshot com análise SUCCEEDED.
2. Filtra elementos por tipo ou `file_path`.
3. Segue relações (ex.: CALLS, DEPENDS) entre dois elementos.

### UI desejada

Lista + painel de detalhe (FQN, linhas, arquivo); grafo simples opcional.

### Critérios de aceite

- [ ] API lista elementos por `analysis_id` ou `snapshot_id` com paginação.
- [ ] API lista relações com `source_element_id` / `target_element_id` resolvíveis.
- [ ] Nenhum dado de execução é necessário para concluir a jornada.

---

## Jornada 4 — Revisar correlação e confiança

**Objetivo:** Auditar se o match diagrama↔span é confiável antes de compartilhar com o time.

### Trigger

Fluxo vertical concluído; engenheiro vê correlação com confidence < 1 ou múltiplos candidatos.

### Passos resumidos

1. Abre painel de correlações da execução.
2. Para cada par interaction↔span, lê `type`, `confidence` e lista de `evidence`.
3. Aceita ou rejeita mentalmente; identifica lacunas (interaction sem span).

### UI desejada

Tabela: Interaction | Span | Confidence | Evidences (tipo + source); destaque para lacunas.

### Critérios de aceite

- [ ] API expõe correlações por `execution_id` ou `diagram_id` com evidências aninhadas.
- [ ] Correlação sem evidence não é retornada como “confirmada” (regra de produto alinhada a D-03 em [mvp.md](./mvp.md)).
- [ ] UI diferencia visualmente confidence alta (ex. ≥ 0.8) de baixa.

---

## Mapa jornada × fluxo de entidades

| Jornada | Cobre fluxo completo? |
|---------|------------------------|
| 1 | Sim — alinhada à cadeia Project → … → Visualização |
| 2 | Parcial — até Analysis |
| 3 | Parcial — até SoftwareElement / Relationship |
| 4 | Parcial — Correlation + Visualização (pós-execução) |

Prioridade de implementação de UI/API: **Jornada 1** primeiro; jornadas 2–4 aumentam robustez e adoção incremental.
