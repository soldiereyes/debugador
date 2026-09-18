# Modelo de domínio — MVP Debugador

Documento de domínio (DBG-002). Regra de negócio vive aqui e no [glossário](./glossary.md); frameworks (Spring, JPA, JavaParser, OpenTelemetry, React) ficam em **infraestrutura**, citados apenas como notas de implementação.

**Prova de valor:** alinhar modelo extraído do código, diagrama do cenário e trace real ([mvp.md](../product/mvp.md)).

---

## Bounded contexts e responsabilidades

| Contexto | Responsabilidade | Agregados raiz |
|----------|------------------|----------------|
| **Project** | Registrar serviço sob exploração, origem Git e snapshots versionados | `Project`, `Repository`, `SourceSnapshot` |
| **Analysis** | Analisar snapshot e publicar modelo estático | `Analysis` (+ elementos e relações como parte do resultado) |
| **Scenario** | Definir fluxo pretendido e ponto de entrada | `Scenario`, `EntryPoint` |
| **Diagram** | Descrever participantes e interações versionadas | `Diagram`, `Participant`, `Interaction` |
| **Execution** | Registrar corrida e árvore de spans | `Execution`, `Trace`, `Span` |
| **Correlation** | Ligar interação a span com confiança e provas | `Correlation`, `Evidence` |

Integração entre contextos: **somente identificadores** (UUID) e regras explícitas (ex.: D-05 — mesmo `snapshot_id` em cenário, diagrama e execução da demo).

```text
Project ──► SourceSnapshot ──► Analysis ──► SoftwareElement / Relationship
                    │
                    ├──► Scenario ──► EntryPoint
                    │         └──► Diagram ──► Participant / Interaction
                    └──► Execution ──► Trace ──► Span
Interaction + Span ──► Correlation ──► Evidence
```

Baseline arquitetural: *SoftwareModel + Diagram + Execution → Correlation* ([architecture/README.md](../architecture/README.md)), onde *SoftwareModel* é o resultado materializado de `Analysis`, não tabela própria.

---

## Agregados

### Project (raiz) — contexto Project

| Item | Descrição |
|------|-----------|
| **Entidades** | `Project`; filho `Repository` (1:1 no MVP) |
| **Value objects** | `Provider` (enum de domínio: ex. `GITHUB`), `GitUrl`, `BranchName` — podem ser strings validadas na aplicação no MVP |
| **Invariantes** | Nome não vazio; exatamente um `Repository` por projeto; URL e branch padrão obrigatórios na criação |
| **Ciclo de vida** | Criado → atualizável (nome); repositório substituível só se política futura permitir (MVP: imutável após criação) |

`SourceSnapshot` é agregado irmão no mesmo contexto (referencia `projectId`):

| Item | Descrição |
|------|-----------|
| **Invariantes** | `commit_hash` obrigatório; único por projeto; branch opcional |
| **Ciclo de vida** | Imutável após criação (novo commit → novo snapshot) |

---

### Analysis (raiz) — contexto Analysis

| Item | Descrição |
|------|-----------|
| **Entidades** | `Analysis`; filhos `SoftwareElement`, `Relationship` (pertencem à mesma análise) |
| **Invariantes** | Uma análise referencia exatamente um `snapshotId`; relações só entre elementos da mesma análise; elementos só persistidos se `SUCCEEDED` (regra de aplicação — jornada 2) |
| **Estados** | `PENDING` (opcional pré-worker), `RUNNING`, `SUCCEEDED`, `FAILED` |
| **Transições** | `RUNNING` → `SUCCEEDED` \| `FAILED`; `FAILED` exige `errorMessage`; `SUCCEEDED` exige `finishedAt` e ≥1 elemento no fluxo feliz |

`Relationship` invariantes: `source` e `target` distintos na mesma análise; `type` do vocabulário MVP (ex. `CALLS`, `DEPENDS` — conjunto fechado a definir em DBG-003/004).

---

### Scenario (raiz) — contexto Scenario

| Item | Descrição |
|------|-----------|
| **Entidades** | `Scenario`; filho `EntryPoint` (1:1) |
| **Invariantes** | `snapshotId` pertence ao mesmo `projectId`; `EntryPoint` obrigatório ao publicar cenário executável |
| **Ciclo de vida** | Rascunho (sem entry point) → **definido** → pode ter execuções |

Decisão **D-05:** o `snapshotId` do cenário deve ser o mesmo da análise apresentada ao usuário na mesma sessão de demo.

---

### Diagram (raiz) — contexto Diagram

| Item | Descrição |
|------|-----------|
| **Entidades** | `Diagram`; filhos `Participant`, `Interaction` |
| **Invariantes** | `snapshotId` alinhado ao `Scenario`; `version` ≥ 1; interactions referenciam participantes do mesmo diagrama; âncoras (`file_path`, linhas) resolvem no snapshot do diagrama |
| **Ciclo de vida** | Nova versão ao editar (incremento de `version`; política: nova linha `diagram` ou mutação — implementação em infra) |

`Participant.elementId` opcional: quando presente, deve apontar para `SoftwareElement` da análise do **mesmo** snapshot (regra de aplicação).

---

### Execution (raiz) — contexto Execution

| Item | Descrição |
|------|-----------|
| **Entidades** | `Execution`; filhos `Trace` (1:1), `Span` (árvore) |
| **Invariantes** | `scenarioId` e `snapshotId` coerentes com o cenário; no máximo um `Trace` por execução; spans com `startedAt` e `durationMs` ≥ 0; hierarquia consistente via `parentSpanId` externo |
| **Estados** | `RUNNING`, `SUCCEEDED`, `FAILED`, `CANCELLED` |
| **Transições** | Início → `RUNNING`; término → estado terminal com `finishedAt` |

Ingestão de spans: porta de infra (agente OTel/Byte Buddy); domínio valida forma, não protocolo.

---

### Correlation (raiz) — contexto Correlation

| Item | Descrição |
|------|-----------|
| **Entidades** | `Correlation`; filhos `Evidence` |
| **Invariantes** | `confidence` ∈ [0, 1]; pelo menos uma `Evidence` para expor como confirmada (D-03); `interactionId` e `spanId` da mesma execução lógica (mesmo `Execution` via join de cenário/trace) |
| **Ciclo de vida** | Proposta (regras) → persistida → consultável na visualização |

Correlação é **determinística** no MVP (sem ML); `type` descreve a regra aplicada (ex. `ANCHOR_MATCH`, `SYMBOL_MATCH`).

---

## Relações entre agregados (MVP)

| De | Para | Cardinalidade | Nota |
|----|------|---------------|------|
| Project | Repository | 1:1 | `repository.project_id` UNIQUE |
| Project | SourceSnapshot | 1:N | |
| SourceSnapshot | Analysis | 1:N | Histórico permitido |
| Analysis | SoftwareElement | 1:N | |
| Analysis | Relationship | 1:N | |
| Project | Scenario | 1:N | |
| SourceSnapshot | Scenario | 1:N | D-05 |
| Scenario | EntryPoint | 1:1 | |
| Scenario | Diagram | 1:N | Versionado |
| Scenario | Execution | 1:N | |
| Execution | Trace | 1:1 | |
| Trace | Span | 1:N | |
| Diagram | Participant | 1:N | |
| Diagram | Interaction | 1:N | |
| Interaction | Correlation | 1:N | |
| Span | Correlation | 1:N | |
| Correlation | Evidence | 1:N | |

---

## Mapeamento domínio ↔ Flyway (`V1__initial_schema.sql`)

| Conceito de domínio | Tabela(s) | Observação |
|---------------------|-----------|------------|
| Project | `project` | `created_at`, `updated_at` — metadados de auditoria |
| Repository | `repository` | 1:1 com projeto |
| SourceSnapshot | `source_snapshot` | UNIQUE `(project_id, commit_hash)` |
| Analysis | `analysis` | `status`, `error_message` |
| SoftwareElement | `software_element` | FK `analysis_id` |
| Relationship | `relationship` | FK `analysis_id` + elementos |
| Scenario | `scenario` | FK `project_id`, `snapshot_id` |
| EntryPoint | `entry_point` | UNIQUE `scenario_id` |
| Diagram | `diagram` | `version`, `type` |
| Participant | `participant` | FK opcional `element_id` |
| Interaction | `interaction` | FK `snapshot_id` + âncoras |
| Execution | `execution` | FK `scenario_id`, `snapshot_id` |
| Trace | `trace` | `trace_id` externo; UNIQUE `execution_id` |
| Span | `span` | `external_span_id`, `parent_span_id` |
| Correlation | `correlation` | CHECK em `confidence` |
| Evidence | `evidence` | FK `correlation_id` |

Nomes de coluna em `snake_case` na persistência; termos de domínio em PascalCase na linguagem ubíqua e em código Java (`commitHash`, etc.).

---

## Fora do domínio (infraestrutura)

| Capacidade | Onde vive |
|------------|-----------|
| JPA entities, repositórios Spring Data | `*.infrastructure.persistence` |
| JavaParser, leitura de disco/Git | worker `analyzer` |
| OpenTelemetry, Byte Buddy, premain | `java-agent` |
| WebSocket STOMP/Spring | `execution.infrastructure.websocket` |
| Fila Redis para jobs de análise | infra + adapter |
| Controllers, DTOs OpenAPI | camada API / aplicação |
| React, canvas de diagrama | `apps/web` |

O domínio define **portas** (ex.: `AnalysisJobPublisher`, `SpanIngestion`, `CorrelationEngine`) sem citar tecnologia — detalhamento em DBG-004.

---

## Decisões de domínio

| ID | Decisão | Consequência |
|----|---------|--------------|
| DD-01 | *SoftwareModel* é conceito composto (`SoftwareElement` + `Relationship`), não agregado raiz separado | Evita tabela e API redundantes; alinha README de arquitetura ao schema |
| DD-02 | `Repository` é entidade no contexto Project, não atributos soltos de `Project` | Alinha ao Flyway; OpenAPI pode continuar achatado na leitura (anti-corruption na API) |
| DD-03 | `SourceSnapshot` imutável | Nova versão de código = novo snapshot + nova análise |
| DD-04 | `Diagram.version` explicita revisões do desenho (D-02) | Correlação referencia interactions do diagrama vigente na execução |
| DD-05 | Correlação sem `Evidence` não é exposta como confirmada (D-03) | Serviço de aplicação filtra ou marca estado |
| DD-06 | IDs de trace/span externos são strings no domínio de execução | Separar `Trace.id` (UUID interno) de `Trace.externalTraceId` |

---

## Alinhamento ao código atual (`debugador-mvp/`)

| Contexto | Código | Gap |
|----------|--------|-----|
| Project | `com.debugador.project.domain.Project` (record achatado com URL/branch) | Separar `Repository` no domínio; persistir tabela `repository` |
| Analysis, Scenario, Diagram, Execution, Correlation | Pacotes reservados; sem entidades de domínio | Implementação futura seguindo este modelo |
| Execution | WebSocket CONNECTED apenas | Eventos de domínio ainda não modelados |

---

## Referências

- [Glossário](./glossary.md)
- [Diagrama Mermaid](../diagrams/domain-model.mmd)
- [MVP](../product/mvp.md) · [Jornadas](../product/journeys.md)
- [Schema Flyway](../../apps/api/src/main/resources/db/migration/V1__initial_schema.sql)
