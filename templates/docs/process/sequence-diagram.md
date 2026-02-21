# Planning-to-Execution Sequence

## Sequence Diagram

```mermaid
sequenceDiagram
    actor PM as PM/Architect
    participant Plan as Planning Workflow
    participant Research as Research Agents
    participant TeamPlan as Teammate Plan Review
    participant Codex as Codex (Extra High)
    participant Work as Execution Agents
    participant TeamPR as Teammate PR Review
    participant Greptile as Greptile
    participant CI as CI Gates
    participant KB as Knowledge Base

    PM->>Plan: Define problem, outcomes, constraints, non-goals
    loop Planning approval loop (required)
        Plan->>Research: Gather evidence and constraints
        Research-->>Plan: Findings and options
        Plan->>TeamPlan: Review plan draft
        TeamPlan-->>Plan: Findings and blockers
        Plan->>Codex: External plan review (Extra High)
        Codex-->>Plan: Findings and blockers
        Plan->>PM: Ask decision-critical questions
        PM-->>Plan: Answers, priorities, acceptance criteria
        Plan->>Plan: Update plan
    end
    Plan->>KB: Mark plan approved + store review evidence links

    loop Per-epic execution loop
        Plan->>Work: Execute approved plan
        Work->>Work: Update execution tracker in real time
        Work->>CI: Run tests and quality gates
        CI-->>Work: Pass/fail results

        opt Material scope change discovered mid-epic
            Work->>Plan: Trigger epic-delta-loop
            loop Nested delta approval loop
                Plan->>TeamPlan: Review delta plan
                TeamPlan-->>Plan: Delta findings
                Plan->>Codex: External delta review (Extra High)
                Codex-->>Plan: Delta findings
                Plan->>PM: Delta decisions needed
                PM-->>Plan: Delta decisions
                Plan->>Work: Update parent epic plan and tracker
            end
        end

        Work->>TeamPR: PR review gate
        TeamPR-->>Work: PR findings
        Work->>Codex: External PR review gate (Extra High)
        Codex-->>Work: PR findings
        Work->>Greptile: Greptile review gate
        Greptile-->>Work: PR findings
        Work->>PM: Ready for E2E acceptance
        PM-->>Work: Accept or request changes
    end

    Work->>KB: Mark plan implemented + summarize outcomes
```

## Flowchart

```mermaid
flowchart TD
    A["PM defines problem + outcomes"] --> B["Draft or update plan"]
    B --> C["Run teammate plan review"]
    C --> D["Run Codex Extra High plan review"]
    D --> E{"Any blockers?"}
    E -- Yes --> F["Ask PM questions + update plan"]
    F --> C
    E -- No --> G{"PM approves?"}
    G -- No --> F
    G -- Yes --> H["Mark plan approved in knowledge base"]
    H --> I["Execute epic + update tracker"]
    I --> J{"Material scope change?"}
    J -- Yes --> K["Run epic-delta-loop (team + Codex + PM)"]
    K --> I
    J -- No --> L["Open/update PR"]
    L --> M["Teammate PR review"]
    M --> N["Codex Extra High PR review"]
    N --> O["Greptile review"]
    O --> P{"Triple gate passed?"}
    P -- No --> I
    P -- Yes --> Q{"PM E2E accepted?"}
    Q -- No --> I
    Q -- Yes --> R["Deploy + mark implemented"]
```

