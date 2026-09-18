package com.debugador.agent;

import java.lang.instrument.Instrumentation;

public final class DebugadorAgent {
    private DebugadorAgent() {}

    public static void premain(String agentArgs, Instrumentation instrumentation) {
        System.out.println("[debugador-agent] started");
        System.out.println("[debugador-agent] instrumentation pipeline is ready for Byte Buddy/OpenTelemetry integration.");
    }
}
