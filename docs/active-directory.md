# Active Directory

Covers the Windows Server 2025 domain controller, the directory structure, user and group
administration, the workstation being joined to the domain, and planned Group Policy.

---

## 1. Domain

| Item | Value |
|---|---|
| DNS domain name | `optima.test` |
| NetBIOS name | `OPTIMA` |
| Domain controller | `LAB-DC01` |
| Operating system | Windows Server 2025 |
| AD-facing IP | `192.168.56.10` (static, host-only network) |
| Roles | AD DS, DNS |

`.test` is an RFC 2606 reserved TLD, so the lab domain can never conflict with a real public
domain and never leaks to Internet DNS.

### Health verification

The following were confirmed healthy after promotion:

| Service / check | Result |
|---|---|
| AD DS | Running |
| DNS | Running, resolving `optima.test` |
| Kerberos | Running |
| Netlogon | Running |
| Domain controller advertising | Advertising as a DC |

## 2. Organizational Unit structure

Default containers are left in place; all administered objects live in a custom OU tree so that
Group Policy and delegation can be scoped deliberately.

```
optima.test
└── OPTIMA
    ├── Users
    │   ├── IT
    │   ├── Human Resources
    │   ├── Finance
    │   └── Operations
    ├── Computers
    │   ├── Workstations
    │   └── Servers
    ├── Groups
    └── Service Accounts
```

Design reasoning:

- **Departments as sub-OUs of `Users`** — lets a policy or a delegation apply to one department
  without touching the others.
- **`Computers` split into `Workstations` and `Servers`** — workstation and server policy
  requirements diverge immediately (lock screens and drive mappings versus server hardening).
- **`Groups` in its own OU** — groups are not user objects and should not inherit user policy;
  keeping them separate also keeps the department OUs readable.
- **`Service Accounts` isolated** — service accounts need different password and logon-rights
  handling from human accounts, and isolating them makes those differences enforceable.

Diagram: [`diagrams/active-directory-structure.md`](../diagrams/active-directory-structure.md).

## 3. User accounts

| Display name | sAMAccountName | Department | OU |
|---|---|---|---|
| Daniel Reyes | `dreyes` | IT | `OPTIMA > Users > IT` |
| Maya Patel | `mpatel` | Human Resources | `OPTIMA > Users > Human Resources` |
| Kevin Brooks | `kbrooks` | Finance | `OPTIMA > Users > Finance` |
| Sofia Martinez | `smartinez` | Operations | `OPTIMA > Users > Operations` |

These are fictional accounts created for the lab. No credentials are recorded in this
repository.

## 4. Security groups

### Created

| Group | Members | Purpose |
|---|---|---|
| `IT-HelpDesk` | Daniel Reyes (`dreyes`) | Help desk role group — the target for delegated permissions and help-desk-specific policy |

### Planned — not yet created

The following department groups are designed but **have not been created yet**:

| Group | Intended members |
|---|---|
| `IT-Users` | IT department users |
| `HR-Users` | Human Resources users |
| `Finance-Users` | Finance users |
| `Operations-Users` | Operations users |

Do not claim these as built until each has been created and membership verified.

**Why role groups rather than per-user permissions.** Permissions assigned to a group survive
staff changes; permissions assigned to a user have to be rebuilt every time someone moves. This
is the difference between "Daniel can reset passwords" and "the help desk can reset passwords,
and Daniel is on the help desk."

## 5. Workstation — OPTIMA-WS01 (domain join in progress)

Full VM build detail is in [Virtualization](virtualization.md#3-optima-ws01).

### Verified

| Test | Result |
|---|---|
| `OPTIMA-WS01` → `LAB-DC01` reachability | `ping 192.168.56.10` succeeded |
| Direct AD DNS query | `nslookup optima.test 192.168.56.10` succeeded |

Those two results together prove the client can reach the DC and that the DC answers correctly
for the domain — the prerequisites for a domain join.

### Not yet done

The DNS resolver priority correction on the workstation is still in progress, so **none of the
following has happened yet**:

- *Planned:* domain join of `OPTIMA-WS01` to `optima.test`
- *Planned:* interactive logon as `OPTIMA\dreyes`
- *Planned:* moving the `OPTIMA-WS01` computer object into
  `OPTIMA > Computers > Workstations`
- *Planned:* `gpresult /r` output confirming applied policy
- *Planned:* final Group Policy verification

### The resolver-priority problem

The workstation has two adapters. The NAT adapter provides Internet access, and VirtualBox
passes through the host's DNS configuration on it — which currently points to the household
router at `192.168.1.1`. The host-only adapter provides the AD path and is configured with the
domain controller (`192.168.56.10`) as its DNS server.

`192.168.1.1` handles normal Internet names but cannot answer for the private AD domain
`optima.test`. When the client sends an ordinary lookup to `192.168.1.1` instead of
`192.168.56.10`, it fails to find the domain — even though the domain controller is reachable and
answers correctly when asked directly. That is exactly what `nslookup optima.test 192.168.56.10`
succeeding while ordinary resolution fails demonstrates.

The correction is to make the AD DNS server the preferred resolver for the client — see
[Troubleshooting, case study 2](troubleshooting.md#case-study-2--dns-resolver-priority-on-a-domain-client).

## 6. Group Policy (planned)

GPO work is **designed but not yet created, applied, or verified.** This is the plan, scoped to
the OU structure above:

| GPO | Linked to | Purpose |
|---|---|---|
| *Planned* — Workstation baseline | `OPTIMA > Computers > Workstations` | Screen lock timeout, desktop/security baseline |
| *Planned* — Department drive mapping | Department OUs under `Users` | Per-department mapped drive |
| *Planned* — Help desk delegation | `IT-HelpDesk` | Delegated password reset rights |

Verification method, once applied: run `gpresult /r` on `OPTIMA-WS01` as the target user and
confirm the GPO appears under applied policy objects.

## 7. Authentication flow (once the domain join is complete)

How sign-in will work when Daniel Reyes logs on to the joined workstation. **This has not been
performed yet** — it is the target the in-progress work is building toward:

1. `OPTIMA-WS01` resolves `optima.test` service records via `LAB-DC01` DNS at `192.168.56.10`
2. The workstation locates a domain controller from those records
3. Credentials are presented to the Kerberos service on `LAB-DC01`
4. The DC validates them against Active Directory and issues a ticket
5. Group membership (including `IT-HelpDesk`) is evaluated
6. Group Policy for the computer's and user's OUs is applied

Diagram: [`diagrams/active-directory-structure.md`](../diagrams/active-directory-structure.md).

## 8. Planned AD work

- Create and verify the four department security groups
- Complete the domain join and Group Policy verification chain above
- Add a second Windows workstation to test policy scoping across two clients
- Create a service account under `Service Accounts` with an appropriately restricted role
- Move the AD network onto a FortiGate-routed VLAN so domain traffic is subject to firewall
  policy
