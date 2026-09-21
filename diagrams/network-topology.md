# Network Topology

## Physical topology

From the household Internet connection down to lab endpoints.

```mermaid
flowchart TD
    INET([Internet]) --> HR["Household Router<br/>192.168.1.0/24<br/><i>not managed by the lab</i>"]
    HR --> M1["MoCA Adapter<br/><i>router side</i>"]
    M1 -.- |"coax run<br/>through the house"| M2["MoCA Adapter<br/><i>office side</i>"]
    M2 --> FG

    subgraph LAB["Home Lab — rack"]
        FG["FortiGate 60F<br/>WAN1: 192.168.1.59/24 (DHCP)<br/>internal: 192.168.10.1/24<br/>LAB-VLAN20 gw: 192.168.20.1<br/><i>routing · firewall · NAT · DHCP</i>"]
        FG --> |"Port A ↔ Port 7<br/>FortiLink"| FS["FortiSwitch 108F-POE<br/><i>managed by the FortiGate</i>"]
        FS --> |"Port 1<br/>LAB-VLAN20"| DELL["Dell Laptop<br/>192.168.20.100<br/><i>physical test endpoint</i>"]
        FS --> HOST["Dell OptiPlex 7060 Micro<br/><i>virtualization host</i>"]
        FS -.-> |"not yet configured"| ARUBA["Aruba CX 6000<br/><i>racked</i>"]
        FS -.-> |"not yet configured"| CISCO["Cisco Catalyst 9300<br/><i>racked</i>"]
        FS -.-> |"planned VLAN"| PS4["PS4<br/><i>planned</i>"]
    end

    style FG fill:#e8f0fe,stroke:#1a73e8,stroke-width:2px
    style FS fill:#e8f0fe,stroke:#1a73e8
    style HOST fill:#e6f4ea,stroke:#137333
    style ARUBA fill:#f1f3f4,stroke:#9aa0a6,stroke-dasharray: 4 3
    style CISCO fill:#f1f3f4,stroke:#9aa0a6,stroke-dasharray: 4 3
    style PS4 fill:#f1f3f4,stroke:#9aa0a6,stroke-dasharray: 4 3
    style HR fill:#fef7e0,stroke:#f9ab00
```

Dashed elements are racked or planned but **not yet configured**: the Aruba CX 6000, the Cisco
Catalyst 9300, and the PS4 VLAN.

## Logical networks

```mermaid
flowchart LR
    subgraph UP["Upstream — household"]
        H["192.168.1.0/24<br/>household LAN"]
    end

    subgraph EDGE["Lab edge"]
        W["FortiGate WAN1<br/>192.168.1.59/24"]
        I["FortiGate internal<br/>192.168.10.1/24"]
        V["LAB-VLAN20 interface<br/>192.168.20.1/24"]
    end

    subgraph LABNETS["Lab networks"]
        N10["192.168.10.0/24<br/>main lab network<br/>DHCP by FortiGate<br/>DNS 192.168.1.1"]
        N20["192.168.20.0/24<br/>LAB-VLAN20<br/>DHCP .100–.200<br/>DNS 1.1.1.1 / 8.8.8.8"]
    end

    subgraph VIRT["Virtual — VirtualBox host-only"]
        N56["192.168.56.0/24<br/>AD network · no gateway<br/>DNS 192.168.56.10"]
    end

    H --> W
    W --- |"NAT"| I
    W --- |"NAT<br/>policy: LAB-VLAN20 → WAN1"| V
    I --> N10
    V --> N20
    N10 -.-> |"host runs VirtualBox"| N56

    style N56 fill:#fce8e6,stroke:#c5221f,stroke-dasharray: 4 3
```

The AD network is drawn detached on purpose: it is a VirtualBox host-only network today, so
domain traffic does **not** pass through the FortiGate and is not subject to firewall policy.
Routing it through a FortiGate VLAN is a planned change.

## Traffic path — a lab client reaching the Internet

```mermaid
sequenceDiagram
    participant C as Client<br/>192.168.20.100
    participant S as FortiSwitch<br/>Port 1
    participant F as FortiGate 60F
    participant R as Household Router
    participant I as Internet

    C->>S: frame on LAB-VLAN20
    S->>F: FortiLink uplink (Port 7 → Port A)
    F->>F: route lookup → WAN1
    F->>F: firewall policy check<br/>LAB-VLAN20 → WAN1 = accept
    F->>F: source NAT<br/>192.168.20.100 → 192.168.1.59
    F->>R: packet from 192.168.1.59
    R->>I: second NAT to public address
    I-->>C: reply follows the path back
```

Two NAT translations happen on the way out — once at the FortiGate and once at the household
router. That double NAT is the cost of keeping the lab fully independent of the household
network.
