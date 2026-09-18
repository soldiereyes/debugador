# Skill: Java/Spring

## Objetivo
Implementar e revisar o backend Java/Spring do Debugador de forma consistente com sua arquitetura modular.

## Herança
Desenvolvedores + Implementação + Qualidade + Arquitetura.

## Contexto técnico
- Java 21.
- Spring Boot.
- Spring Web.
- Spring Data JPA.
- Spring Security quando aplicável.
- Redis.
- PostgreSQL.
- Maven.
- WebSocket.

## Regras
- Domain não depende de Spring.
- Application coordena casos de uso.
- Infrastructure implementa adapters.
- Controllers traduzem HTTP para comandos/DTOs.
- Não expor entidades de domínio/JPA diretamente na API.
- Transações devem ficar na fronteira apropriada da aplicação.
- Validar entradas na borda.
- Exceções devem possuir tratamento consistente.
- Preferir composição a herança quando apropriado.

## Estrutura
feature/
├── domain/
├── application/
└── infrastructure/

## Checklist
- [ ] Java 21
- [ ] Separação Domain/Application/Infrastructure
- [ ] DTOs
- [ ] Validação
- [ ] Transações
- [ ] Testes
- [ ] Observabilidade
