package com.debugador.project.infrastructure.persistence;

import jakarta.persistence.*;
import java.util.UUID;

@Entity
@Table(name = "project")
public class ProjectJpaEntity {
    @Id
    private UUID id;
    @Column(nullable = false, length = 150)
    private String name;

    protected ProjectJpaEntity() {}

    public ProjectJpaEntity(UUID id, String name) {
        this.id = id;
        this.name = name;
    }

    public UUID getId() { return id; }
    public String getName() { return name; }
}
