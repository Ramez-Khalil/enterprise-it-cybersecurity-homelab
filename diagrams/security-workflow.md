# Security Testing Workflow

All stages below run **only** against systems built for this lab. Scope rules are in
[`docs/cybersecurity-lab.md`](../docs/cybersecurity-lab.md#1-scope-and-authorization--read-first).

> **Nothing in this workflow has been run yet.** The `Kali-HomeLab` VM is still being built, and
> no stage below has produced a result.

## The five stages

```mermaid
flowchart LR
    A["1 · Recon<br/><i>what exists<br/>in scope?</i>"] --> B["2 · Scanning<br/><i>which hosts and<br/>ports respond?</i>"]
    B --> C["3 · Enumeration<br/><i>what are the services,<br/>what do they disclose?</i>"]
    C --> D["4 · Web Testing<br/><i>how does the app<br/>behave under inspection?</i>"]
    D --> E["5 · Vulnerability<br/>Assessment<br/><i>what matters,<br/>in what order?</i>"]
    E --> F["Report<br/><i>scope · method · findings<br/>analysis · recommendation</i>"]

    style A fill:#e8f0fe,stroke:#1a73e8
    style B fill:#e8f0fe,stroke:#1a73e8
    style C fill:#e8f0fe,stroke:#1a73e8
    style D fill:#e8f0fe,stroke:#1a73e8
    style E fill:#e8f0fe,stroke:#1a73e8
    style F fill:#e6f4ea,stroke:#137333
```

Each stage narrows the input to the next. Skipping ahead — scanning without a defined scope, or
running a vulnerability scanner before knowing what the services are — produces volume rather
than findings.

## Scope gate

Every test passes through the same authorization check first.

```mermaid
flowchart TD
    T["Proposed target"] --> Q1{"Is it a system<br/>I built for this lab?"}
    Q1 -- No --> STOP["Out of scope — do not test"]
    Q1 -- Yes --> Q2{"Is it on a lab subnet,<br/>not the household LAN?"}
    Q2 -- No --> STOP
    Q2 -- Yes --> Q3{"Is it the school VM<br/>KALI-LAB01 or its coursework?"}
    Q3 -- Yes --> STOP2["Out of scope — coursework<br/>environment stays untouched"]
    Q3 -- No --> GO["In scope — proceed<br/>from Kali-HomeLab"]

    style STOP fill:#fce8e6,stroke:#c5221f
    style STOP2 fill:#fce8e6,stroke:#c5221f
    style GO fill:#e6f4ea,stroke:#137333
```

## Environment separation

```mermaid
flowchart LR
    subgraph SCHOOL["Coursework — out of scope for this project"]
        K1["KALI-LAB01<br/><i>graded assignments<br/>not modified for this lab</i>"]
    end

    subgraph PROJECT["Home lab — this project"]
        K2["Kali-HomeLab<br/><i>build in progress</i>"]
        K2 --> T1["Lab-owned targets<br/><i>VMs and devices<br/>built for testing</i>"]
    end

    K1 -.- |"no results, tooling,<br/>or targets shared"| K2

    style SCHOOL fill:#f1f3f4,stroke:#9aa0a6
    style K2 fill:#e8f0fe,stroke:#1a73e8,stroke-dasharray: 4 3
```

## Offensive and defensive halves

The value of running both sides on the same equipment is seeing one action from two vantage
points.

```mermaid
flowchart LR
    K["Kali-HomeLab<br/><i>runs a scan</i>"] --> TGT["Lab target"]
    K -.-> |"traffic traverses"| FG["FortiGate 60F"]
    FG --> LOG["Firewall logs<br/><i>what the scan looked like<br/>from the defender's side</i>"]
    TGT --> EVT["Host / DC event logs<br/><i>what the target recorded</i>"]
    LOG --> LEARN["Compare attacker view<br/>with defender view"]
    EVT --> LEARN

    style LEARN fill:#e6f4ea,stroke:#137333
    style LOG fill:#fef7e0,stroke:#f9ab00
    style EVT fill:#fef7e0,stroke:#f9ab00
```

**The defensive log-review exercises are planned, not performed.**
