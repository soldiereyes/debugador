# Debugador

Software Architecture & Execution Explorer.

## MVP

- Java 21
- Spring Boot 4.1.1
- PostgreSQL 17
- Flyway
- Redis
- React + TypeScript + Vite
- Java Agent skeleton

## Subir ambiente

```bash
docker compose up --build
```

URLs:

- Web: http://localhost:5173
- API: http://localhost:8080/api/v1
- Health: http://localhost:8080/actuator/health

## Criar projeto

```bash
curl -X POST http://localhost:8080/api/v1/projects   -H 'Content-Type: application/json'   -d '{
    "name":"chat-service",
    "repository":{
      "provider":"GITHUB",
      "url":"https://github.com/example/chat-service",
      "defaultBranch":"main"
    }
  }'
```
