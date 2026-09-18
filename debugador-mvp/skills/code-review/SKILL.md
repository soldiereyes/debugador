# Skill: Code Review

## Objetivo
Revisar alterações com foco em corretude, arquitetura, segurança, manutenção e risco de regressão.

## Herança
Desenvolvedores + Qualidade + Implementação + Arquitetura.

## Ordem da revisão
1. Corretude funcional.
2. Requisitos e contratos.
3. Segurança.
4. Concorrência e consistência.
5. Arquitetura.
6. Testes.
7. Performance.
8. Legibilidade.
9. Manutenibilidade.

## Severidade
- BLOCKER: impede merge.
- HIGH: risco relevante de defeito, segurança ou arquitetura.
- MEDIUM: problema que deve ser corrigido ou justificado.
- LOW: melhoria não bloqueante.

## Regras
- Findings devem apontar arquivo/local e evidência.
- Não sugerir mudança por preferência pessoal.
- Diferenciar defeito de melhoria.
- Não exigir abstração sem benefício demonstrável.
- Verificar se testes protegem o comportamento alterado.

## Saída
Finding com:
- localização
- problema
- impacto
- evidência
- recomendação
- severidade
