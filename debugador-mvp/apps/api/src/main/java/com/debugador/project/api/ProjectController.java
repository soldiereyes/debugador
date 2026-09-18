package com.debugador.project.api;

import com.debugador.project.domain.Project;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;
import java.util.concurrent.CopyOnWriteArrayList;

@RestController
@RequestMapping("/api/v1/projects")
public class ProjectController {
    private final List<Project> projects = new CopyOnWriteArrayList<>();

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Project create(@RequestBody CreateProjectRequest request) {
        Project project = new Project(
            UUID.randomUUID(),
            request.name(),
            request.repository().url(),
            request.repository().defaultBranch()
        );
        projects.add(project);
        return project;
    }

    @GetMapping
    public List<Project> list() {
        return projects;
    }

    public record CreateProjectRequest(String name, RepositoryRequest repository) {}
    public record RepositoryRequest(String provider, String url, String defaultBranch) {}
}
