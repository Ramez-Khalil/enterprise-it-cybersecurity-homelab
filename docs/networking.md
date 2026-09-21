# Networking

Covers the FortiGate 60F edge, the FortiLink-managed FortiSwitch 108F-POE, VLAN segmentation,
DHCP, DNS delivery, NAT, and firewall policy.

---

## 1. FortiGate 60F — role

The FortiGate is the lab's edge device. It provides, in one unit:

- **Routing** between the lab networks and the upstream household network
- **Firewalling** — all traffic leaving a lab network needs an explicit policy
- **NAT** — source NAT so lab subnets can reach the Internet through a single WAN address
- **DHCP** — address, gateway, and DNS delivery for lab clients
- **VLAN gateway** — each lab VLAN terminates on a FortiGate interface
- **Switch management** — FortiLink control of the FortiSwitch

## 2. WAN side

| Item | Value |
|---|---|
| Interface | WAN1 |
| Upstream | Household router, reached over MoCA |
| Addressing | DHCP from the household router |
| Address observed during setup | `192.168.1.59/24` |

The address is DHCP-assigned and can change. It is recorded as observed during setup, not
because the lab depends on it.

**Why MoCA.** The office is too far from the household router for a practical Ethernet run and
the lab host cannot be relocated. The office has a coax jack, so MoCA adapters carry Ethernet
over the existing coax to give the lab a wired uplink.

## 3. Main internal lab network

| Item | Value |
|---|---|
| Network | `192.168.10.0/24` |
| FortiGate internal interface | `192.168.10.1` |
| DHCP | Enabled on the FortiGate for this network |
| DNS delivered by DHCP | `192.168.1.1` (the household router) |
| Purpose | General lab devices and management access |

## 4. FortiSwitch 108F-POE and FortiLink

FortiLink lets the FortiGate manage the FortiSwitch as an extension of itself. Switch ports are
configured from the FortiGate rather than from a separate switch CLI, which is the operational
model used in Fortinet-based environments.

| Item | Value |
|---|---|
| FortiLink physical link | FortiGate **Port A** ↔ FortiSwitch **Port 7** |
| Discovery | FortiSwitch discovered by the FortiGate |
| Authorization | FortiSwitch authorized and shown as managed |
| Management model | Ports assigned to VLANs from the FortiGate managed-switch view |

### Port assignments

| FortiSwitch port | Assignment | Notes |
|---|---|---|
| Port 7 | FortiLink uplink | Control and data path to the FortiGate |
| Port 1 | `LAB-VLAN20` | Physical Dell laptop test endpoint |
| Remaining ports | — | **Not yet assigned** |

## 5. LAB-VLAN20

The first segmented network in the lab, built to practice the full chain: VLAN interface →
DHCP scope → switch port assignment → firewall policy → NAT → verification.

| Item | Value |
|---|---|
| VLAN name | `LAB-VLAN20` |
| Network | `192.168.20.0/24` |
| Gateway (FortiGate VLAN interface) | `192.168.20.1` |
| DHCP range | approximately `192.168.20.100` – `192.168.20.200` |
| DNS delivered by DHCP | `1.1.1.1` and `8.8.8.8` |
| Switch port | FortiSwitch Port 1 |

### Verified results

| Test | Result |
|---|---|
| Physical Dell laptop obtains an address | Received `192.168.20.100` from FortiGate DHCP |
| Outbound IP connectivity | `ping 8.8.8.8` succeeded |
| Name resolution | `ping google.com` succeeded after the DNS correction below |

The DNS step did not work on the first attempt. That failure is written up as a case study in
[Troubleshooting](troubleshooting.md#case-study-1--ip-connectivity-works-dns-does-not); it is
kept because the isolation process is more instructive than the fix.

## 6. Firewall policy

| Field | Value |
|---|---|
| Name | LAB-VLAN20 → WAN1 outbound |
| Incoming interface | `LAB-VLAN20` |
| Outgoing interface | WAN1 |
| Source | `LAB-VLAN20` subnet |
| Destination | all |
| Action | Accept |
| NAT | Enabled |

Two things this made concrete:

- **Nothing leaves a FortiGate interface without a policy.** Correct addressing and a correct
  gateway are not enough; the policy table is the control point.
- **NAT is a property of the policy**, not of the interface. With NAT enabled, traffic from
  `192.168.20.x` leaves WAN1 using the FortiGate's WAN address, so the household router only
  ever sees one device.

Inter-VLAN policies between lab networks: **not yet created.** Today
`LAB-VLAN20` has an outbound path only.

## 7. DNS in the lab

Two DNS domains coexist and serve different purposes:

| Scope | Resolver | Serves |
|---|---|---|
| Main lab network (`192.168.10.0/24`) | `192.168.1.1` (household router) via FortiGate DHCP | Internet name resolution |
| `LAB-VLAN20` (`192.168.20.0/24`) | `1.1.1.1`, `8.8.8.8` via FortiGate DHCP | Internet name resolution |
| Virtual AD network (`192.168.56.0/24`) | `LAB-DC01` at `192.168.56.10` | `optima.test` and all domain service records |

A domain member must use the domain controller for DNS — no resolver outside the domain (public
or the household router) can answer for `optima.test`, and an AD client that cannot resolve its
domain's service records cannot join or authenticate. This is exactly the condition being corrected on `OPTIMA-WS01`; see
[Troubleshooting, case study 2](troubleshooting.md#case-study-2--dns-resolver-priority-on-a-domain-client).

## 8. Other switches

| Switch | Intended use | Status |
|---|---|---|
| Aruba CX 6000 | VLAN and trunking practice in Aruba CLI syntax | **Racked — not yet configured** |
| Cisco Catalyst 9300-series | Cisco IOS-XE CLI practice, VLANs, trunking | **Racked — not yet configured** |

Running the same VLAN design across three vendors is the point: it separates the concept from
one vendor's syntax.

## 9. Planned network work

- Dedicated VLAN for the PS4 and other untrusted consumer devices, with policy limiting it to
  Internet access only
- Separate server, client, and management VLANs with explicit inter-VLAN policies
- Moving the AD network off VirtualBox host-only networking and onto a FortiGate-routed VLAN so
  domain traffic passes through firewall policy
- FortiGate log review as an introductory monitoring exercise
