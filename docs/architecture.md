# Architecture

## Design goals

1. **Isolation from the household network.** The lab must be able to be misconfigured, broken,
   or rebuilt without affecting anyone else's Internet access. The FortiGate sits *behind* the
   home router, so the household LAN never needs to be reconfigured for lab work.
2. **Real enterprise behaviour.** Where possible the lab uses enterprise gear and enterprise
   workflows (FortiLink-managed switching, AD-integrated DNS, policy-based firewalling) rather
   than consumer equivalents.
3. **Separate planes for network and directory practice.** Networking work happens on the
   FortiGate-routed physical network; Active Directory work happens on an isolated virtual
   network, so a networking mistake cannot take down the domain mid-exercise.
4. **Authorized targets only.** Any security testing is performed against systems built for this
   lab.

## Hardware inventory

| Device | Role | Status |
|---|---|---|
| Dell OptiPlex 7060 Micro | Primary virtualization host (VirtualBox) | In service |
| FortiGate 60F | Lab edge: routing, firewall, NAT, DHCP, VLAN gateway | In service |
| FortiSwitch 108F-POE | Access switch, managed by the FortiGate over FortiLink | In service |
| Aruba CX 6000 | Managed switch for multi-vendor practice | **Racked — not yet configured** |
| Cisco Catalyst 9300-series | Switch for Cisco IOS-XE CLI practice | **Racked — not yet configured** |
| MoCA adapters | Coax-based link from the household router to the office | In service |
| Server rack + PDU | Physical housing and power distribution | In service |
| Older Dell laptop | Physical test endpoint | In service |
| PS4 | Consumer device to be segmented onto its own VLAN | Planned |

## Upstream relationship

The household router remains the Internet edge for the house. The lab attaches to it as a
single downstream client:

- The home router serves the household LAN (`192.168.1.0/24`).
- A MoCA pair carries that connection over existing coax to the office.
- The FortiGate's **WAN1** interface takes an address from the home router by DHCP.
  Address observed during setup: `192.168.1.59/24`.
- Everything the FortiGate serves is behind NAT, so the household network sees only the
  FortiGate.

This is a double-NAT arrangement. It is a deliberate trade: it costs inbound reachability from
the house into the lab, and it buys complete freedom to change lab addressing, VLANs, and
policy without touching household equipment.

## Addressing plan

| Network | Range | Gateway | Served by | Purpose |
|---|---|---|---|---|
| Household LAN | `192.168.1.0/24` | Home router | Home router | Upstream only — not managed by the lab |
| Lab WAN handoff | — | — | Home router DHCP | FortiGate WAN1: `192.168.1.59/24` (observed) |
| Main lab network | `192.168.10.0/24` | `192.168.10.1` (FortiGate internal) | FortiGate DHCP | General lab devices |
| `LAB-VLAN20` | `192.168.20.0/24` | `192.168.20.1` (FortiGate) | FortiGate DHCP `.100`–`.200` | Segmented client VLAN |
| AD host-only network | `192.168.56.0/24` | None (intentionally isolated) | Static addressing | Active Directory traffic between VMs |

Reserved for later use: additional VLANs for servers, management, and consumer/untrusted
devices (PS4). **Not yet created.**

## The two planes, and why they are separate today

**Physical/routed plane.** FortiGate → FortiSwitch → physical endpoints and the virtualization
host. All VLAN, DHCP, NAT, and firewall-policy practice happens here.

**Virtual AD plane.** Inside VirtualBox, `LAB-DC01` and `OPTIMA-WS01` share a host-only network
(`192.168.56.0/24`) with no default gateway. Domain traffic — DNS, Kerberos, LDAP, Netlogon —
never leaves the host. Each VM has a second NAT adapter for Internet access.

The trade-off is honest to record: because the AD network is host-only, domain traffic is *not*
currently passing through the FortiGate, so it is not subject to firewall policy. That is a
simplification chosen to keep the directory build stable while the network was being built.
Moving the AD network onto a FortiGate-routed VLAN is a planned expansion (see the README),
and doing so would let the same domain traffic be inspected and policed.

## Naming conventions

| Object | Convention | Example |
|---|---|---|
| Domain (DNS) | `<org>.test` — reserved TLD, never resolvable on the Internet | `optima.test` |
| Domain (NetBIOS) | Organisation short name, uppercase | `OPTIMA` |
| Servers | `LAB-` prefix + role + index | `LAB-DC01` |
| Workstations | Org prefix + `WS` + index | `OPTIMA-WS01` |
| VLANs | `LAB-VLAN<id>` | `LAB-VLAN20` |
| Security groups | `<Department>-<Function>` | `IT-HelpDesk` |
| User accounts | First initial + last name, lowercase | `dreyes` |

`.test` is used deliberately: it is reserved by RFC 2606 for testing, so the lab domain can
never collide with a real public domain.

## Related documents

- [Networking](networking.md) — FortiGate, FortiLink, VLAN and policy detail
- [Active Directory](active-directory.md) — domain, OUs, users, groups
- [Virtualization](virtualization.md) — host and VM configuration
- [Cybersecurity lab](cybersecurity-lab.md) — testing environment and scope
- [Troubleshooting](troubleshooting.md) — methodology and case studies
