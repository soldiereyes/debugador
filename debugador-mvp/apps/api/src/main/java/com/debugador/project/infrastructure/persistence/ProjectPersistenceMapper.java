package com.debugador.project.infrastructure.persistence;

import com.debugador.project.domain.Project;

public final class ProjectPersistenceMapper {

    private ProjectPersistenceMapper() {}

    public static Project toDomain(ProjectJpaEntity entity) {
        return new Project(entity.getId(), entity.getName(), null, null);
    }

    public static ProjectJpaEntity toEntity(Project domain) {
        return new ProjectJpaEntity(domain.id(), domain.name());
    }
}
