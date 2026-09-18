# Skill: DevOps

## Objetivo
Garantir que o Debugador possa ser construído, executado, observado e entregue de forma reproduzível.

## Herança
Esta skill herda Produto, Desenvolvedores, Qualidade e DBA.

## Responsabilidades
- Docker e Docker Compose.
- CI/CD.
- Configuração.
- Secrets.
- Observabilidade.
- Logs, métricas e tracing.
- Health checks.
- Artefatos e deploy.
- Rollback.

## Pipeline
Commit → Build → Testes → Análise estática → Segurança → Docker Build → Artifact → Deploy → Smoke Test → Observabilidade.

## Regras
- Builds reproduzíveis.
- Artefatos imutáveis.
- Secrets fora do repositório.
- Configuração fora do código quando apropriado.
- Health checks devem refletir dependências reais.
- Falhas devem ser observáveis e acionáveis.

## Saída
Pipeline, configuração, imagens, documentação operacional e evidências de execução.
