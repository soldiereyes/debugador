# Skill: Implementação

## Objetivo
Transformar requisitos e decisões técnicas em código executável, preservando a arquitetura e os contratos do Debugador.

## Herança
Esta skill herda princípios de Produto, Desenvolvedores, Qualidade, DevOps e DBA.

## Quando utilizar
- Implementar uma nova funcionalidade.
- Corrigir um defeito.
- Alterar um fluxo existente.
- Criar ou modificar APIs, persistência, eventos ou integrações.

## Processo
1. Entender requisito e critérios de aceitação.
2. Localizar componentes e contratos afetados.
3. Validar a solução contra a arquitetura.
4. Implementar a menor mudança coerente.
5. Criar/ajustar testes.
6. Avaliar impacto em banco, infraestrutura e observabilidade.
7. Executar validações disponíveis.
8. Documentar decisões relevantes.

## Regras
- Não colocar regra de negócio em Controllers.
- Não colocar regra de negócio em entidades de persistência.
- Domain não depende de frameworks ou infraestrutura.
- Não quebrar contratos públicos sem avaliar impacto.
- Não adicionar tecnologia sem necessidade justificada.
- Toda mudança de schema deve ter migration.
- Preferir mudanças pequenas e reversíveis.

## Saídas
Código, testes, migrations quando aplicável, documentação técnica e resumo das decisões.

## Checklist
- [ ] Requisito compreendido
- [ ] Arquitetura respeitada
- [ ] Código implementado
- [ ] Testes atualizados
- [ ] Impactos avaliados
- [ ] Build/validações executados
