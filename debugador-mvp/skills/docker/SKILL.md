# Skill: Docker

## Objetivo
Padronizar imagens e ambientes containerizados do Debugador.

## Herança
DevOps + Implementação + Qualidade.

## Serviços
- API
- Analyzer
- Web
- PostgreSQL
- Redis

## Regras
- Imagens mínimas e reproduzíveis.
- Multi-stage build quando apropriado.
- Não colocar secrets na imagem.
- Usar health checks.
- Fixar versões relevantes.
- Processos devem executar corretamente como containers.
- Logs devem ir para stdout/stderr.
- Configuração deve ser externa.

## Checklist
- [ ] Dockerfile reproduzível
- [ ] Build isolado
- [ ] Healthcheck
- [ ] Configuração externa
- [ ] Sem secrets
- [ ] Imagem mínima
- [ ] Compose funcional
