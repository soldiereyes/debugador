# Skill: Arquitetura

## Objetivo
Definir e preservar a arquitetura do Debugador, mantendo separação de responsabilidades e evolução controlada.

## Herança
Desenvolvedores + Produto + Implementação + DevOps + DBA.

## Arquitetura atual
MVP como Modular Monolith, com separação:
Domain → Application → Infrastructure.

Bounded Contexts:
- Project
- Analysis
- Scenario
- Diagram
- Execution
- Correlation

## Regras
- Domain não depende de tecnologia.
- Dependências apontam para dentro.
- Bounded Contexts devem possuir limites claros.
- Aggregates devem proteger invariantes.
- Infraestrutura deve ser substituível através de portas/adapters.
- Não introduzir microserviços prematuramente.
- Decisões arquiteturais relevantes devem ser registradas.
- Diagramas devem representar a realidade do código.

## Processo
Problema → Contexto → Restrições → Alternativas → Trade-offs → Decisão → Consequências → Registro.

## Saída
ADR, modelo, diagramas, dependências, decisões e impactos.
