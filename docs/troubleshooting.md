# Troubleshooting

Methodology used in this lab, and written case studies from real faults encountered during the
build.

---

## Methodology

The lab uses a bottom-up, layer-by-layer approach. Each step asks one question and eliminates
one layer, so that a vague report ("the Internet is down") becomes a specific fault.

| Step | Question | Typical test | What a pass proves |
|---|---|---|---|
| 1. Physical / link | Is there a link? | Link lights, switch port status | Cable, port, and PHY are fine |
| 2. Addressing | Did the client get a valid address? | `ipconfig /all` | DHCP reached the client; scope and options delivered |
| 3. Local Layer 3 | Can the client reach its gateway? | `ping <gateway>` | Client and gateway are on the same working subnet |
| 4. Routing / NAT | Can the client reach the Internet by IP? | `ping 8.8.8.8` | Routing, firewall policy, and NAT all work |
| 5. Name resolution | Can the client turn names into addresses? | `ping google.com`, `nslookup` | DNS configuration and resolver path work |
| 6. Application | Does the service itself work? | Browser, domain join, service-specific test | The fault is above the network |

Two principles the lab keeps returning to:

- **Separate "can it get there" from "does it know where to go."** IP reachability and name
  resolution fail in similar-looking ways and have completely different causes.
- **Test the specific component, not the whole chain.** Querying one named DNS server directly
  eliminates the network path in a single command, which is faster than changing settings and
  re-testing end to end.

---

## Case study 1 — IP connectivity works, DNS does not

### Symptom

A physical Dell laptop connected to FortiSwitch Port 1 on `LAB-VLAN20` had what looked like a
working connection but no usable Internet: pages would not load, while the network showed as
connected.

### Environment

| Item | Value |
|---|---|
| VLAN | `LAB-VLAN20`, `192.168.20.0/24` |
| Gateway | `192.168.20.1` (FortiGate) |
| DHCP | FortiGate, range approx. `192.168.20.100`–`192.168.20.200` |
| DNS delivered by DHCP | `1.1.1.1`, `8.8.8.8` |
| Client address | `192.168.20.100` |

### Tests performed, and what each one proved

| # | Test | Result | What it proved |
|---|---|---|---|
| 1 | Check the client's IP configuration | `192.168.20.100` from the expected scope | Link, switch port VLAN assignment, and FortiGate DHCP were all working |
| 2 | `ping 8.8.8.8` | Success | Routing, the LAB-VLAN20 → WAN1 firewall policy, and NAT were all correct — the client could reach the Internet by IP |
| 3 | `ping google.com` | Failure | The fault was isolated to name resolution, not connectivity |
| 4 | `nslookup google.com 1.1.1.1` | Success | The client *could* reach and query a public resolver on demand. The network path to DNS was fine, so the fault had to be in which resolver the client used by default |
| 5 | Inspect the adapter's IPv4 properties | Two DNS servers statically configured, left over from a previous network (addresses redacted) | Root cause found |

Test 4 is the one that mattered. It split "DNS is broken" into two possibilities — the resolver
is unreachable, or the client is asking the wrong resolver — and answered it in one command.

### Root cause

The laptop had been used on a previous network and still had two DNS servers manually configured
on its IPv4 adapter properties. Because those entries were static, they overrode the
`1.1.1.1` / `8.8.8.8` resolvers that the FortiGate DHCP server was correctly supplying. The
client was sending every query to servers it could not usefully reach.

The infrastructure was never at fault. The VLAN, DHCP scope, DHCP DNS options, firewall policy,
and NAT were all correct from the start.

### Correction

Set the adapter's IPv4 properties back to **Obtain DNS server address automatically**. On
renewal the client took the FortiGate-supplied resolvers, and `ping google.com` succeeded.

### Lessons learned

1. **Layer 3 reachability and name resolution are different problems.** `ping 8.8.8.8` working
   while `ping google.com` fails is close to a definitive DNS signal, and recognising that
   pattern saves the time that would otherwise go into checking the firewall.
2. **A directed query is the fastest isolation tool.** `nslookup <name> <server>` bypasses the
   client's configured resolvers, which separates "resolver unreachable" from "wrong resolver
   configured" immediately.
3. **Static client settings survive network changes.** Leftover manual configuration from a
   previous network is one of the most common causes of a device that works everywhere except
   here — and it is invisible from the infrastructure side.
4. **Verify the endpoint, not just the infrastructure.** Every device in the path was configured
   correctly; the fault was in the one place the network gear could not see.

---

## Case study 2 — DNS resolver priority on a domain client

> **Status: unresolved.** This fault is understood and the correction is in progress, but the
> final result is not yet confirmed. It is written up here as an open problem, not a fix.

### Symptom

`OPTIMA-WS01` can reach the domain controller and the domain controller answers correctly for
`optima.test`, but the workstation does not resolve the domain by default.

### Environment

| Item | Value |
|---|---|
| Adapter 1 | VirtualBox NAT — Internet access, carries the default route; DNS passed through from the host: `192.168.1.1` (household router) |
| Adapter 2 | Host-only — `192.168.56.20/24`, no gateway, DNS `192.168.56.10` |
| Domain controller | `LAB-DC01`, `192.168.56.10`, AD DS + DNS for `optima.test` |

### Tests performed

| # | Test | Result | What it proved |
|---|---|---|---|
| 1 | `ping 192.168.56.10` | Success | The host-only path to the domain controller works |
| 2 | `nslookup optima.test 192.168.56.10` | Success | The DC is running DNS and answers authoritatively for the domain |
| 3 | `nslookup optima.test` (no server specified) | Fails — the query goes to `192.168.1.1`, which returns *Non-existent domain* | The client is asking the household router, which has no knowledge of `optima.test`, instead of the DC |

### Root cause

The workstation has two adapters supplying DNS. On the NAT adapter, which carries the default
route, VirtualBox passes through the host's DNS configuration — currently the household router at
`192.168.1.1`. Ordinary lookups go to that resolver first. It handles normal Internet names but
cannot answer for the private `.test` domain. The client therefore fails to find the domain's service records even though the
domain controller is one hop away and fully healthy.

This is the same class of fault as case study 1 — the right server is reachable, but the client
is not asking it — with a different cause: adapter priority rather than stale static entries.

### Correction (in progress)

*Planned:* ensure the AD DNS server at `192.168.56.10` is the client's
preferred resolver for domain lookups, then join `optima.test`, sign in as `OPTIMA\dreyes`, move
the computer object into `OPTIMA > Computers > Workstations`, and verify policy with
`gpresult /r`.

### Lessons learned (provisional)

1. **A domain member must use the domain's own DNS.** Resolvers outside the domain — public ones
   or a home router — have no knowledge of a private AD zone, and AD depends on DNS service records for almost everything.
2. **Multi-homed clients make DNS ambiguous.** Two adapters means two sets of resolvers and an
   order that the operating system, not the administrator, decides by default.
3. **"The DC is reachable" is not the same as "the client can find the domain."** Reachability
   tests and resolution tests have to be run separately.

---

## Quick reference — commands used

| Command | Purpose |
|---|---|
| `ipconfig /all` | Full client IP, DHCP, and DNS configuration (Windows) |
| `ping <ip>` | Layer 3 reachability, no DNS involved |
| `ping <hostname>` | Reachability *and* name resolution together |
| `nslookup <name>` | Resolution using the client's configured resolvers |
| `nslookup <name> <server>` | Resolution using one specific server — isolates resolver configuration |
| `ipconfig /flushdns` | Clear cached entries before re-testing |
| `ipconfig /release` + `/renew` | Force a fresh DHCP lease after a scope or option change |
| `gpresult /r` | Show which Group Policy objects applied to the computer and user |
