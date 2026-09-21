# Cybersecurity Lab

Covers the Kali Linux environments, the rules of engagement, and the testing workflow.

---

## 1. Scope and authorization — read first

**All testing described here is performed only against systems built by me, for this lab, on my
own hardware and network.** No system outside the lab is a target. No third-party, school,
employer, or public system is in scope, and nothing in this repository should be read as
describing testing against anything else.

Practical rules this lab follows:

1. Targets must be lab-owned VMs or lab-owned devices that I configured for the purpose.
2. Scanning is bounded to lab subnets — never the household LAN and never the upstream
   `192.168.1.0/24` network.
3. Findings stay in the lab. Nothing is reported as a finding against software vendors or
   third parties.
4. No credentials, keys, or exploit payloads are published in this repository.

## 2. Two intentionally separate Kali environments

| VM | Purpose | Rule |
|---|---|---|
| `KALI-LAB01` | School coursework VM | **Do not touch.** Reserved for graded assignments; not modified for this project |
| `Kali-HomeLab` | This project's testing VM | All home-lab testing happens here |

Keeping them separate is a deliberate discipline, and the reasoning is the same one that applies
professionally: a machine that has to stay in a known, reproducible state for assessed work
should not also be the machine where tooling is installed, configuration is changed, and things
are broken on purpose. Mixing the two risks either corrupting coursework or contaminating lab
results.

### KALI-LAB01 — coursework context only

Coursework on that VM has involved tooling such as Burp Suite, OWASP ZAP, GoBuster/DirBuster,
Nikto, and Greenbone/OpenVAS. That is listed here only to record where prior tool exposure came
from. **No results from `KALI-LAB01` appear in this repository**, and that VM is not part of
this project's architecture.

### Kali-HomeLab — build status

**Not yet built.** The `Kali-HomeLab` VM is still being created for this project. Its
specification, installed tooling, and every stage described below are **planned work — no test
has been run and no result exists.**

## 3. Testing workflow (planned — not yet performed)

The lab follows a five-stage workflow, run in order. The order matters: each stage narrows the
target set for the next, and skipping ahead produces noise instead of findings.

```
Recon → Scanning → Enumeration → Web Testing → Vulnerability Assessment
```

Diagram: [`diagrams/security-workflow.md`](../diagrams/security-workflow.md).

### Stage 1 — Reconnaissance

**Question it answers:** what exists in the authorized scope?

Passive and low-impact information gathering about lab-owned systems: which subnets are in
scope, which hosts are expected to be live, what the addressing plan says should be there.
Recon in this lab starts from the documented [architecture](architecture.md#addressing-plan),
which is a useful contrast with a real engagement where the map is what you are trying to build.

**Status: not yet performed.** No recon has been run.

### Stage 2 — Scanning

**Question it answers:** which hosts are actually up, and which ports respond?

Host discovery across the authorized lab subnet, then port scanning of discovered hosts.
Expected to confirm or contradict the documented inventory — a host that answers but is not in
the documentation is itself a finding, in a lab as in production.

**Status: not yet performed.** No scan has been run.

### Stage 3 — Enumeration

**Question it answers:** what are those services, and what do they disclose?

Service and version identification on the open ports, and enumeration of what each service
reveals without authentication — share names, directory listings, banners, supported protocol
versions.

**Status: not yet performed.** No enumeration has been run.

### Stage 4 — Web application testing

**Question it answers:** how does a lab-hosted web application behave under inspection?

Directory and content discovery, inspection of requests and responses through an intercepting
proxy, and review of how input is handled — against a web application deliberately stood up in
the lab for testing.

**Status: not yet performed.** No web testing has been run.

### Stage 5 — Vulnerability assessment

**Question it answers:** which of the findings actually matter, and in what order?

Automated vulnerability scanning of lab targets, followed by manual review of the output.
The manual review is the part worth practising: scanner output contains false positives and
severity ratings that ignore context, and turning raw output into a short, prioritized,
verified list is the skill being built.

**Status: not yet performed.** No vulnerability assessment has been run.

## 4. Reporting format (planned)

Each completed test will be written up in the same structure, which is the habit this section is
really practising:

1. **Scope** — exact targets and the authorization for them
2. **Method** — what was run and with what parameters
3. **Observations** — raw results
4. **Analysis** — what the results mean, false positives removed
5. **Recommendation** — what would be remediated first, and why
6. **Evidence** — command output supporting each finding

**No completed test reports exist yet.** This section describes the intended format only.

## 5. Defensive side (planned)

The lab is not only an offensive exercise. The same equipment supports defensive practice:

- *Planned:* reviewing FortiGate logs to see what a scan looks like from the
  firewall's side
- *Planned:* testing whether VLAN segmentation and policy actually contain
  traffic the way the design claims
- *Planned:* observing Windows event logs on `LAB-DC01` during authentication
  events

Running a scan and then reading what the FortiGate and the domain controller recorded about it
is the exercise that connects the two halves of the lab.

## 6. Honesty statement

This is lab practice with security tooling in a controlled environment I built. It is not
professional penetration testing experience, not authorized engagement work, and not a
credential. The value claimed here is fundamentals: a repeatable workflow, correct scoping, and
the discipline to verify findings instead of pasting scanner output.
