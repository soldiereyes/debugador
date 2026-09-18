CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE project (
    id UUID PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE repository (
    id UUID PRIMARY KEY,
    project_id UUID NOT NULL UNIQUE REFERENCES project(id),
    provider VARCHAR(30) NOT NULL,
    url TEXT NOT NULL,
    default_branch VARCHAR(255) NOT NULL
);

CREATE TABLE source_snapshot (
    id UUID PRIMARY KEY,
    project_id UUID NOT NULL REFERENCES project(id),
    commit_hash VARCHAR(64) NOT NULL,
    branch VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(project_id, commit_hash)
);

CREATE TABLE analysis (
    id UUID PRIMARY KEY,
    snapshot_id UUID NOT NULL REFERENCES source_snapshot(id),
    status VARCHAR(30) NOT NULL,
    started_at TIMESTAMPTZ,
    finished_at TIMESTAMPTZ,
    error_message TEXT
);

CREATE TABLE software_element (
    id UUID PRIMARY KEY,
    analysis_id UUID NOT NULL REFERENCES analysis(id),
    type VARCHAR(30) NOT NULL,
    name VARCHAR(500) NOT NULL,
    fully_qualified_name TEXT,
    file_path TEXT,
    symbol TEXT,
    signature TEXT,
    start_line INTEGER,
    end_line INTEGER
);

CREATE INDEX idx_software_element_analysis ON software_element(analysis_id);

CREATE TABLE relationship (
    id UUID PRIMARY KEY,
    analysis_id UUID NOT NULL REFERENCES analysis(id),
    source_element_id UUID NOT NULL REFERENCES software_element(id),
    target_element_id UUID NOT NULL REFERENCES software_element(id),
    type VARCHAR(30) NOT NULL
);

CREATE INDEX idx_relationship_source ON relationship(source_element_id);
CREATE INDEX idx_relationship_target ON relationship(target_element_id);

CREATE TABLE scenario (
    id UUID PRIMARY KEY,
    project_id UUID NOT NULL REFERENCES project(id),
    snapshot_id UUID NOT NULL REFERENCES source_snapshot(id),
    name VARCHAR(200) NOT NULL,
    description TEXT
);

CREATE TABLE entry_point (
    id UUID PRIMARY KEY,
    scenario_id UUID NOT NULL UNIQUE REFERENCES scenario(id),
    type VARCHAR(30) NOT NULL,
    identifier TEXT NOT NULL
);

CREATE TABLE diagram (
    id UUID PRIMARY KEY,
    scenario_id UUID NOT NULL REFERENCES scenario(id),
    snapshot_id UUID NOT NULL REFERENCES source_snapshot(id),
    type VARCHAR(30) NOT NULL,
    version INTEGER NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE participant (
    id UUID PRIMARY KEY,
    diagram_id UUID NOT NULL REFERENCES diagram(id),
    element_id UUID REFERENCES software_element(id),
    name VARCHAR(500) NOT NULL
);

CREATE TABLE interaction (
    id UUID PRIMARY KEY,
    diagram_id UUID NOT NULL REFERENCES diagram(id),
    source_participant_id UUID NOT NULL REFERENCES participant(id),
    target_participant_id UUID NOT NULL REFERENCES participant(id),
    type VARCHAR(40) NOT NULL,
    operation VARCHAR(500),
    snapshot_id UUID NOT NULL REFERENCES source_snapshot(id),
    file_path TEXT,
    symbol TEXT,
    signature TEXT,
    start_line INTEGER,
    end_line INTEGER
);

CREATE TABLE execution (
    id UUID PRIMARY KEY,
    scenario_id UUID NOT NULL REFERENCES scenario(id),
    snapshot_id UUID NOT NULL REFERENCES source_snapshot(id),
    status VARCHAR(30) NOT NULL,
    started_at TIMESTAMPTZ,
    finished_at TIMESTAMPTZ
);

CREATE TABLE trace (
    id UUID PRIMARY KEY,
    execution_id UUID NOT NULL UNIQUE REFERENCES execution(id),
    trace_id VARCHAR(100) NOT NULL
);

CREATE TABLE span (
    id UUID PRIMARY KEY,
    trace_id UUID NOT NULL REFERENCES trace(id),
    external_span_id VARCHAR(100) NOT NULL,
    parent_span_id VARCHAR(100),
    type VARCHAR(40) NOT NULL,
    source_element_id UUID REFERENCES software_element(id),
    target_element_id UUID REFERENCES software_element(id),
    started_at TIMESTAMPTZ NOT NULL,
    duration_ms BIGINT NOT NULL,
    thread_name VARCHAR(500),
    file_path TEXT,
    symbol TEXT,
    signature TEXT,
    start_line INTEGER,
    end_line INTEGER
);

CREATE INDEX idx_span_trace ON span(trace_id);
CREATE INDEX idx_span_parent ON span(parent_span_id);

CREATE TABLE correlation (
    id UUID PRIMARY KEY,
    interaction_id UUID REFERENCES interaction(id),
    span_id UUID REFERENCES span(id),
    type VARCHAR(30) NOT NULL,
    confidence NUMERIC(5,4) NOT NULL CHECK (confidence >= 0 AND confidence <= 1)
);

CREATE TABLE evidence (
    id UUID PRIMARY KEY,
    correlation_id UUID NOT NULL REFERENCES correlation(id),
    type VARCHAR(30) NOT NULL,
    source TEXT NOT NULL
);
