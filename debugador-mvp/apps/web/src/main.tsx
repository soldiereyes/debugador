import React from "react";
import { createRoot } from "react-dom/client";

function App() {
  return (
    <main style={{fontFamily: "system-ui", padding: 32}}>
      <h1>Debugador</h1>
      <p>Software Architecture & Execution Explorer</p>
      <p>API: <a href="http://localhost:8080/api/v1">localhost:8080/api/v1</a></p>
      <p>Health: <a href="http://localhost:8080/actuator/health">actuator/health</a></p>
    </main>
  );
}

createRoot(document.getElementById("root")!).render(<App />);
