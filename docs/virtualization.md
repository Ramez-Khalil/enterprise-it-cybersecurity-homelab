# Virtualization

Covers the virtualization host, the virtual machines, and VirtualBox networking.

---

## 1. Host

| Item | Value |
|---|---|
| Machine | Dell OptiPlex 7060 Micro |
| Role | Primary virtualization host |
| Hypervisor | Oracle VirtualBox (type 2, running on the host OS) |

**Why a type 2 hypervisor rather than a bare-metal one.** The host also has to remain a usable
desktop machine for coursework that requires Windows applications. A bare-metal hypervisor would
have taken the machine over entirely. VirtualBox gives up some performance and isolation and
gains the ability to run lab VMs and daily desktop work on one box — an acceptable trade for a
lab whose purpose is configuration practice rather than throughput.

## 2. Virtual machines

| VM | Role | Notes |
|---|---|---|
| `LAB-DC01` | Windows Server 2025 domain controller (AD DS, DNS) | See [Active Directory](active-directory.md) |
| `OPTIMA-WS01` | Windows 11 Pro workstation — domain join in progress | Below |
| `Kali-HomeLab` | Security testing VM for this project | **In progress — not yet built.** See [Cybersecurity lab](cybersecurity-lab.md) |
| `KALI-LAB01` | Coursework VM — **out of scope for this project** | Kept separate and untouched; see [Cybersecurity lab](cybersecurity-lab.md) |

## 3. OPTIMA-WS01

### Specification

| Item | Value |
|---|---|
| VM name | `OPTIMA-WS01` |
| Operating system | Windows 11 Pro 25H2 |
| Memory | 4 GB |
| vCPU | 2 |
| Disk | 80 GB |
| Firmware | EFI |
| Secure Boot | Enabled |
| TPM | 2.0 (virtual) |
| Guest Additions | Installed |

EFI, Secure Boot, and a virtual TPM 2.0 are Windows 11 installation requirements — a practical
constraint worth knowing before building any Windows 11 VM, since a VM configured with legacy
BIOS and no TPM will fail setup outright. Guest Additions provide display resizing, shared
clipboard, and better guest integration.

### Virtual networking

Two adapters, each with one job:

**Adapter 1 — NAT**

| Item | Value |
|---|---|
| Mode | VirtualBox NAT |
| Addressing | IPv4 by VirtualBox's internal DHCP |
| Purpose | Internet access (updates, tooling) |

**Adapter 2 — Host-only (AD-facing)**

| Item | Value |
|---|---|
| Mode | Host-only |
| IPv4 | `192.168.56.20/24` static |
| Default gateway | **None — intentionally omitted** |
| DNS | `192.168.56.10` (`LAB-DC01`) |
| Purpose | All Active Directory traffic |

**Why no gateway on the host-only NIC.** A Windows host uses the presence of a default gateway
to decide which adapter carries off-subnet traffic. If both adapters had a gateway, the routing
table would have two default routes and traffic could take the wrong path. Leaving the
host-only adapter gateway-less makes it carry only `192.168.56.0/24` traffic — exactly the AD
network — while the NAT adapter keeps the single default route to the Internet.

That split is clean for routing but is also the source of the resolver-priority problem
described in [Active Directory](active-directory.md#the-resolver-priority-problem): on the adapter
that carries the default route, VirtualBox passes through the host's DNS configuration, which
currently points to the household router at `192.168.1.1`. That resolver handles normal Internet
names but cannot answer for `optima.test`.

### Verified

| Test | Result |
|---|---|
| Reachability to the DC | `ping 192.168.56.10` succeeded |
| AD DNS answers directly | `nslookup optima.test 192.168.56.10` succeeded |

### Not yet done

- *In progress:* DNS resolver priority correction
- *Planned:* domain join to `optima.test`
- *Planned:* logon as `OPTIMA\dreyes`
- *Planned:* computer object moved to `OPTIMA > Computers > Workstations`
- *Planned:* `gpresult /r` and Group Policy verification

## 4. VirtualBox networking modes used, and why

| Mode | Behaviour | Used for |
|---|---|---|
| NAT | VM reaches the Internet through the host; VMs cannot reach each other on this adapter | Internet access on `OPTIMA-WS01` and `LAB-DC01` |
| Host-only | Private network between the host and its VMs; no Internet path | AD traffic on `192.168.56.0/24` |
| Bridged | VM appears directly on the physical LAN | *Planned* — for putting VMs on FortiGate-routed VLANs |

Choosing host-only for the domain was deliberate: Kerberos, LDAP, and DNS between the DC and the
client stay on a network that cannot be disturbed by, or disturb, the physical lab while the
network side is under construction.

## 5. Planned virtualization work

- *Planned:* complete the `Kali-HomeLab` VM build
- Move VMs to bridged adapters on FortiGate-routed VLANs so virtual traffic is subject to
  firewall policy and inter-VLAN rules
- Add a second Windows client VM to test Group Policy scoping across multiple machines
- Establish a snapshot discipline before each major change (pre-join, pre-GPO, pre-test) so
  exercises can be repeated from a known state
