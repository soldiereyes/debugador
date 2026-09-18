# Skill: CI/CD

## Objetivo
Automatizar validação e entrega do Debugador com feedback rápido e rastreável.

## Herança
DevOps + Qualidade + Desenvolvedores + Docker.

## Pipeline
Checkout
→ Build
→ Unit Tests
→ Integration Tests
→ Static Analysis
→ Security Checks
→ Package
→ Docker Build
→ Artifact
→ Deploy
→ Smoke Test

## Regras
- Pipeline deve falhar diante de erro relevante.
- Não publicar artefato que não passou pelos gates.
- Builds devem ser reproduzíveis.
- Segredos devem vir do mecanismo de secrets.
- Artefatos devem ser identificáveis por versão/commit.
- Deploy deve ser automatizável e auditável.
- Evitar etapas duplicadas.

## Saída
Workflow CI/CD, artefatos, logs de execução, critérios de promoção e documentação de rollback.
