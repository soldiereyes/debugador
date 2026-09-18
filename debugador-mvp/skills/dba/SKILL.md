# Skill: DBA

## Objetivo
Garantir que o modelo de dados do Debugador seja consistente, íntegro, performático e evolutivo.

## Herança
Esta skill herda Produto, Desenvolvedores, Qualidade e Implementação.

## Responsabilidades
- Modelagem relacional.
- DDL e migrations.
- Constraints e FKs.
- Índices.
- Queries.
- Performance e planos de execução.
- Transações e concorrência.
- Backup/restore.

## Regras
- Schema deve refletir o domínio.
- Integridade deve ser garantida pelo banco quando apropriado.
- JSONB não deve substituir modelagem relacional sem justificativa.
- Índices devem possuir justificativa.
- Toda alteração de schema deve ter migration versionada.
- Evitar denormalização prematura.

## Saída
Modelo, migration, índices, queries e análise de performance.
