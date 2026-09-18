# Glossário — linguagem ubíqua (MVP)

Vocabulário único do Debugador, alinhado ao fluxo em [mvp.md](../product/mvp.md) e à persistência em `V1__initial_schema.sql`. Sinônimos proibidos em documentação e API: usar sempre o termo desta lista.

**Cadeia de valor do MVP:** `Project` → `Repository` → `SourceSnapshot` → `Analysis` → `SoftwareElement` / `Relationship` → `Scenario` → `Diagram` → `Execution` → `Trace` / `Span` → `Correlation` → visualização.

**Ordem operacional (jornada):** após análise, o usuário define `Scenario` e `Diagram` e então dispara `Execution` ([journeys.md](../product/journeys.md), decisão D-05).

---

## Project

**Significado:** Workspace lógico que agrupa um serviço sob exploração — ponto de entrada do engenheiro no produto.

**Não é:** repositório Git, pasta no disco, tenant, equipe ou conta de usuário.

**Relações:** 1:1 com `Repository` no MVP; 1:N com `SourceSnapshot` e `Scenario`.

**Persistência / API:** tabela `project`; `POST/GET /api/v1/projects` ([openapi.yaml](../openapi.yaml)). O contrato HTTP atual achata URL/branch no recurso `Project`; no domínio e no banco, isso pertence ao agregado `Repository` (ver inconsistências em [domain-model.md](./domain-model.md)).

**No fluxo:** raiz da ingestão e do catálogo de cenários.

---

## Repository

**Significado:** Origem versionada do código do `Project` (provedor, URL, branch padrão).

**Não é:** clone local, snapshot, nem o conteúdo dos arquivos.

**Relações:** pertence a exatamente um `Project` (unicidade `project_id`).

**Persistência / API:** tabela `repository`; embutido em `CreateProjectRequest.repository` na API; ainda sem recurso REST dedicado.

**No fluxo:** precede `SourceSnapshot`; define de onde commits são obtidos.

---

## SourceSnapshot

**Significado:** Versão fixa do código identificada por `commit_hash` (e `branch` opcional), imutável para análise e cenário.

**Não é:** análise, execução, branch “viva” sem commit, nem artefato de build.

**Relações:** pertence a um `Project`; único por `(project_id, commit_hash)`; referenciado por `Analysis`, `Scenario`, `Diagram`, `Execution`, `Interaction`.

**Persistência / API:** tabela `source_snapshot`; API ainda não exposta no OpenAPI 0.1.0.

**No fluxo:** ancora determinismo (D-05: cenário e diagrama no mesmo snapshot da análise exibida).

---

## Analysis

**Significado:** Processo assíncrono que extrai o **modelo de software** (`SoftwareElement`, `Relationship`) a partir de um `SourceSnapshot`.

**Não é:** o snapshot, o worker em si, nem a visualização do grafo.

**Relações:** N:1 com `SourceSnapshot`; 1:N com elementos e relações; pode haver histórico de várias análises por snapshot (política de substituição a documentar na API — [journeys.md](../product/journeys.md) jornada 2).

**Ciclo de vida:** `status` ∈ {`RUNNING`, `SUCCEEDED`, `FAILED`}; `error_message` obrigatório quando `FAILED`; `finished_at` quando terminal.

**Persistência / API:** tabela `analysis`; API não exposta no OpenAPI atual.

**No fluxo:** ponte entre ingestão e modelo estático consultável.

---

## SoftwareElement

**Significado:** Nó do modelo estático extraído (tipo, nome, FQN, âncoras em arquivo/linhas/símbolo).

**Não é:** participante de diagrama, span de trace, nem classe Java em tempo de execução.

**Relações:** pertence a uma `Analysis`; opcionalmente ligado a `Participant` e a `Span` (`source_element_id` / `target_element_id`).

**Persistência / API:** tabela `software_element`.

**No fluxo:** materializa o eixo “código”; alimenta diagrama assistido (D-02).

---

## Relationship

**Significado:** Aresta tipada entre dois `SoftwareElement` na mesma análise (ex.: chamada, dependência).

**Não é:** `Interaction` do diagrama sequencial nem parentesco de spans.

**Relações:** `source_element_id` → `target_element_id`; escopo de uma `Analysis`.

**Persistência / API:** tabela `relationship`.

**No fluxo:** grafo estático para exploração (jornada 3) e base para sugerir participantes.

---

## Scenario

**Significado:** Fluxo de negócio nomeado que o engenheiro quer validar, com ponto de entrada e amarrado a um snapshot.

**Não é:** execução, diagrama UML completo, nem caso de teste automatizado.

**Relações:** `Project` + `SourceSnapshot` obrigatórios; 1:1 com `EntryPoint`; 1:N `Diagram`; 1:N `Execution`.

**Persistência / API:** tabela `scenario`.

**No fluxo:** intenção do fluxo antes da execução; dispara `Execution` (D-05).

---

## EntryPoint

**Significado:** Onde o fluxo do `Scenario` começa (ex.: rota HTTP, método público), identificado por `type` + `identifier`.

**Não é:** o primeiro span da trace (embora devam alinhar-se na demo) nem interaction do diagrama.

**Relações:** exatamente um por `Scenario` (`scenario_id` UNIQUE).

**Persistência / API:** tabela `entry_point`.

**No fluxo:** alinha agente, execução e diagrama ao mesmo gatilho.

---

## Diagram

**Significado:** Desenho versionado do cenário (sequência mínima): participantes e mensagens com âncoras no snapshot.

**Não é:** editor UML genérico, diagrama de deployment, nem print de Confluence.

**Relações:** pertence a `Scenario`; referencia o mesmo `SourceSnapshot` (D-05); contém `Participant` e `Interaction`; `version` incrementa revisões.

**Persistência / API:** tabela `diagram`.

**No fluxo:** eixo “intenção”; entrada obrigatória para `Correlation`.

---

## Participant

**Significado:** Ator ou componente lógico no `Diagram` (lifeline), com nome de exibição e ligação opcional a `SoftwareElement`.

**Não é:** obrigatoriamente um processo OS ou pod Kubernetes.

**Relações:** N:1 `Diagram`; `element_id` opcional.

**Persistência / API:** tabela `participant`.

**No fluxo:** extremidades das `Interaction`.

---

## Interaction

**Significado:** Mensagem ou passo dirigido entre dois participantes, com tipo, operação e âncoras no código (`file_path`, `symbol`, linhas no `SourceSnapshot`).

**Não é:** `Relationship` estática nem span OTel bruto.

**Relações:** `source_participant_id` → `target_participant_id`; correlacionável com `Span` via `Correlation`.

**Persistência / API:** tabela `interaction`.

**No fluxo:** unidade que a correlação compara com a execução observada.

---

## Execution

**Significado:** Uma corrida do `Scenario` contra um `SourceSnapshot` (manual ou via app instrumentada).

**Não é:** a análise estática, nem o processo JVM em si fora do registro persistido.

**Relações:** `Scenario` + `SourceSnapshot`; 0:1 `Trace` no MVP (1:1 na schema); origem de spans e correlações.

**Ciclo de vida:** `status` ∈ {`RUNNING`, `SUCCEEDED`, `FAILED`, `CANCELLED`} (valores de domínio; coluna `VARCHAR` sem CHECK no Flyway).

**Persistência / API:** tabela `execution`; WebSocket `/ws/executions/{executionId}` (infra, eventos de progresso).

**No fluxo:** eixo “runtime”; segue diagrama na jornada 1.

---

## Trace

**Significado:** Identificador externo da árvore de observabilidade associada a uma `Execution`.

**Não é:** o mesmo que `execution.id` interno; é o id do backend de tracing (`trace_id` string).

**Relações:** 1:1 com `Execution`; 1:N `Span`.

**Persistência / API:** tabelas `trace` (`trace_id` externo) e FK `execution_id` UNIQUE.

**No fluxo:** agrupa spans ingeridos pelo agente.

---

## Span

**Significado:** Intervalo observado na execução (hierarquia via `parent_span_id` externo), com timing e metadados opcionais de mapeamento ao código.

**Não é:** linha de log solta nem `Interaction` do diagrama até existir `Correlation`.

**Relações:** pertence a `Trace`; pode referenciar `SoftwareElement`; correlacionável com `Interaction`.

**Persistência / API:** tabela `span` (`external_span_id`, `parent_span_id` como strings do agente).

**No fluxo:** evidência temporal do que rodou de fato.

---

## Correlation

**Significado:** Afirmação auditável de que uma `Interaction` e um `Span` descrevem o mesmo passo do fluxo, com `type` e `confidence` ∈ [0, 1].

**Não é:** inferência opaca; sem `Evidence` não é “confirmada” para produto (D-03).

**Relações:** liga `interaction_id` e `span_id`; 1:N `Evidence`.

**Persistência / API:** tabela `correlation`.

**No fluxo:** união dos três eixos (modelo + diagrama + execução) para a visualização.

---

## Evidence

**Significado:** Prova persistida que sustenta uma `Correlation` (`type` + `source` textual ou referência serializada).

**Não é:** substituto da correlação nem log bruto não interpretado sem tipo.

**Relações:** pertence a uma `Correlation`; ≥1 exigida para correlação aceita na UI/API de produto (D-03).

**Persistência / API:** tabela `evidence`.

**No fluxo:** auditoria (jornada 4).

---

## Termos de apoio (não persistidos como entidade)

| Termo | Uso |
|-------|-----|
| **Modelo de software** | Conjunto de `SoftwareElement` + `Relationship` de uma `Analysis` bem-sucedida; citado em [architecture/README.md](../architecture/README.md) como *SoftwareModel*. |
| **Visualização** | Capacidade de UI que sobrepõe diagrama, spans e correlações; não é entidade de domínio. |

---

## Referências

- [MVP](../product/mvp.md)
- [Jornadas](../product/journeys.md)
- [Modelo de domínio](./domain-model.md)
- [Diagrama](./../diagrams/domain-model.mmd)
