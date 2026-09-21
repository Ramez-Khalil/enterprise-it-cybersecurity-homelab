# Active Directory — Structure and Authentication

## Directory structure

```mermaid
flowchart TD
    D["optima.test<br/><i>NetBIOS: OPTIMA</i>"] --> O["OPTIMA<br/><i>custom OU root</i>"]

    O --> U["Users"]
    O --> C["Computers"]
    O --> G["Groups"]
    O --> S["Service Accounts"]

    U --> IT["IT"]
    U --> HR["Human Resources"]
    U --> FIN["Finance"]
    U --> OPS["Operations"]

    C --> WS["Workstations"]
    C --> SRV["Servers"]

    IT --> U1["Daniel Reyes<br/>dreyes"]
    HR --> U2["Maya Patel<br/>mpatel"]
    FIN --> U3["Kevin Brooks<br/>kbrooks"]
    OPS --> U4["Sofia Martinez<br/>smartinez"]

    G --> GRP1["IT-HelpDesk<br/><i>created</i>"]
    G -.-> GRP2["IT-Users · HR-Users<br/>Finance-Users · Operations-Users<br/><i>planned</i>"]

    WS -.-> WS1["OPTIMA-WS01<br/><i>join pending</i>"]

    style D fill:#e8f0fe,stroke:#1a73e8,stroke-width:2px
    style GRP1 fill:#e6f4ea,stroke:#137333
    style GRP2 fill:#f1f3f4,stroke:#9aa0a6,stroke-dasharray: 4 3
    style WS1 fill:#f1f3f4,stroke:#9aa0a6,stroke-dasharray: 4 3
```

Dashed nodes are **not built yet**: the four department security groups and the `OPTIMA-WS01`
computer object are planned or in progress, not done.

## Group membership

```mermaid
flowchart LR
    DR["Daniel Reyes<br/>dreyes · IT"] --> HD["IT-HelpDesk<br/><i>created</i>"]
    HD --> PERM["Delegated help desk rights<br/><i>planned</i>"]

    DR -.-> ITU["IT-Users<br/><i>planned</i>"]
    MP["Maya Patel<br/>mpatel · HR"] -.-> HRU["HR-Users<br/><i>planned</i>"]
    KB["Kevin Brooks<br/>kbrooks · Finance"] -.-> FU["Finance-Users<br/><i>planned</i>"]
    SM["Sofia Martinez<br/>smartinez · Operations"] -.-> OU2["Operations-Users<br/><i>planned</i>"]

    style HD fill:#e6f4ea,stroke:#137333
    style PERM fill:#f1f3f4,stroke:#9aa0a6,stroke-dasharray: 4 3
    style ITU fill:#f1f3f4,stroke:#9aa0a6,stroke-dasharray: 4 3
    style HRU fill:#f1f3f4,stroke:#9aa0a6,stroke-dasharray: 4 3
    style FU fill:#f1f3f4,stroke:#9aa0a6,stroke-dasharray: 4 3
    style OU2 fill:#f1f3f4,stroke:#9aa0a6,stroke-dasharray: 4 3
```

## Authentication flow

What happens when Daniel Reyes signs in to the workstation.
**Steps 3 onward have not happened yet** — they depend on the domain join, which is still in
progress.

```mermaid
sequenceDiagram
    autonumber
    actor DR as Daniel Reyes
    participant WS as OPTIMA-WS01<br/>192.168.56.20
    participant DC as LAB-DC01<br/>192.168.56.10
    participant AD as Active Directory<br/>optima.test

    DR->>WS: signs in as OPTIMA\dreyes
    WS->>DC: DNS query for optima.test<br/>domain controller service records
    DC-->>WS: returns LAB-DC01 as the DC
    WS->>DC: Kerberos authentication request
    DC->>AD: validate credentials
    AD-->>DC: account valid · group membership<br/>(IT-HelpDesk)
    DC-->>WS: issues Kerberos ticket
    WS->>DC: request applicable Group Policy
    DC-->>WS: policy for the computer OU<br/>and the user OU
    WS-->>DR: desktop loads with policy applied
```

The first two steps are the reason DNS matters so much in Active Directory: without the ability
to resolve the domain's service records, the workstation never finds a domain controller and
nothing after step 2 can happen — regardless of whether the DC is reachable by IP.

## Network placement of the AD environment

```mermaid
flowchart TD
    subgraph HOST["Dell OptiPlex 7060 — VirtualBox"]
        subgraph HO["Host-only network · 192.168.56.0/24 · no gateway"]
            DC["LAB-DC01<br/>192.168.56.10<br/>Windows Server 2025<br/>AD DS · DNS"]
            WS["OPTIMA-WS01<br/>192.168.56.20<br/>Windows 11 Pro 25H2<br/>DNS → 192.168.56.10"]
            DC <--> WS
        end
        NAT["VirtualBox NAT adapters<br/><i>Internet access only</i>"]
    end

    DC -.-> NAT
    WS -.-> NAT
    NAT --> INET([Internet])

    style HO fill:#fce8e6,stroke:#c5221f
    style DC fill:#e8f0fe,stroke:#1a73e8
```

Each VM has two adapters: a gateway-less host-only adapter carrying all domain traffic, and a
NAT adapter carrying Internet traffic. Keeping the default route on the NAT adapter is what
creates the resolver-priority problem documented in
[`docs/troubleshooting.md`](../docs/troubleshooting.md#case-study-2--dns-resolver-priority-on-a-domain-client).
