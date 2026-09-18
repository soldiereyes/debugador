package com.debugador.shared.api;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
public class RootController {
    @GetMapping("/api/v1")
    public Map<String, Object> api() {
        return Map.of("service", "debugador-api", "version", "0.1.0");
    }
}
