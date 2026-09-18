# Skill: React

## Objetivo
Desenvolver a interface do Debugador com React e TypeScript, priorizando clareza, previsibilidade e separação de responsabilidades.

## Herança
Desenvolvedores + Implementação + Qualidade.

## Contexto técnico
- React.
- TypeScript.
- Vite.
- Componentização.
- Estado local e global apenas quando necessário.

## Regras
- Componentes devem possuir responsabilidade clara.
- Evitar componentes monolíticos.
- Separar UI, estado e acesso a API.
- Tipar contratos da API.
- Não duplicar regras de domínio no frontend.
- Estados de loading, erro e vazio devem ser tratados.
- Acessibilidade deve ser considerada.
- Evitar efeitos desnecessários.

## Estrutura sugerida
src/
├── features/
├── components/
├── services/
├── hooks/
├── types/
└── app/

## Checklist
- [ ] TypeScript sem tipos desnecessariamente frágeis
- [ ] Componentes coesos
- [ ] Estados de UI tratados
- [ ] API isolada
- [ ] Testes
- [ ] Acessibilidade
