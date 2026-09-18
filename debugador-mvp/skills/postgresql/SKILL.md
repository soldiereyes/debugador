# Skill: PostgreSQL

## Objetivo
Projetar e operar o PostgreSQL do Debugador com integridade e desempenho previsíveis.

## Herança
DBA + Arquitetura + Implementação + DevOps.

## Modelo principal
project
repository
source_snapshot
analysis
software_element
relationship
scenario
entry_point
diagram
participant
interaction
execution
trace
span
correlation
evidence

## Regras
- PK/FK e constraints devem proteger invariantes.
- Índices devem acompanhar padrões de consulta.
- Evitar SELECT * em consultas de produção.
- Analisar queries críticas com EXPLAIN/EXPLAIN ANALYZE.
- Migrations devem ser versionadas.
- Alterações destrutivas devem possuir estratégia de rollout.
- Não armazenar todo o SoftwareModel como JSONB.

## Checklist
- [ ] Migration
- [ ] Constraints
- [ ] Índices
- [ ] Query plan
- [ ] Concorrência
- [ ] Rollback
- [ ] Observabilidade
