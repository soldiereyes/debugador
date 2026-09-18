# Architecture

Baseline:

Project -> Snapshot -> Analysis -> SoftwareModel
Scenario -> Diagram
Scenario -> Execution -> Trace -> Span
SoftwareModel + Diagram + Execution -> Correlation

The domain is intentionally independent of JavaParser, OpenTelemetry, JPA and PostgreSQL.
