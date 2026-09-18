# Skill: Testes

## Objetivo
Definir e implementar uma estratégia de testes proporcional ao risco do sistema.

## Herança
Qualidade + Desenvolvedores + Implementação.

## Estratégia
Unitários → Integração → Contrato → E2E.

## Regras
- Testar comportamento, não implementação interna sem necessidade.
- Testes devem ser determinísticos.
- Evitar dependência desnecessária de ambiente externo.
- Cobrir casos positivos, negativos e limites.
- Testes de integração devem validar integrações reais relevantes.
- E2E deve proteger fluxos críticos.
- Não usar cobertura percentual como único indicador de qualidade.

## Para o Debugador
Priorizar fluxos:
Project → Snapshot → Analysis → SoftwareModel
Scenario → Diagram
Execution → Trace → Span
Interaction → Correlation → Interactive View

## Saída
Plano de testes, casos, fixtures, testes automatizados e evidências.
