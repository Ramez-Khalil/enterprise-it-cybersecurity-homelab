# Fortinet Segmentation & Firewall Policy Lab

**Self-directed, AI-guided HomeLab.** Verified small-scope network segmentation as of October 8, 2026.

## Purpose and architecture

The lab is attached behind the household router. A MoCA connection provides an uplink to a **FortiGate 60F**, which manages a **FortiSwitch 108F-POE** through FortiLink. The FortiGate supplies DHCP, local VLAN gateways, firewall policies, and outbound NAT.

Two separated lab VLANs were created:

| Segment | Intended purpose | Verified setup |
| --- | --- | --- |
| Test-device VLAN | Isolated lab endpoints | VLAN interface, DHCP scope, switch-port VLAN, and outbound policy with NAT |
| Storage VLAN | Synology NAS | Separate VLAN, DHCP scope/reservation, and limited inter-network management policy |

Switch VLAN assignments were made using FortiGate-managed switch settings. The lab also has an upstream double-NAT relationship with the household router; this is an intentional learning-environment trade-off.

## Firewall-policy work and validation

A NAS address object and a custom service for DSM management were used in a restricted policy. The allowed services were limited to ping and DSM management traffic; NAT was disabled for internal-to-NAS traffic. Outbound lab Internet access used NAT.

**Verified outcome:** before the internal storage-access policy existed, the NAS was unreachable from the relevant lab network as expected. After the scoped allow policy was added, the required connectivity worked. This is a practical block-before/allow-after demonstration, **not** a claim that all undesired traffic or other segments were exhaustively tested.

## Troubleshooting lesson

The unreachable NAS was caused by the missing firewall policy rather than a failed storage device. The policy was added for only the intended management traffic. The NAS itself works; the storage-pool build is postponed because SMART testing flagged the available disks.

## Not yet demonstrated

- No FortiGate traffic-log screenshots have been captured and sanitized for public evidence.
- The planned firewall isolation restricting the Linux test target to only the intended testing network is **not complete**; verified SSH testing reached it from the main lab subnet.
- Aruba and Cisco switches are **racked but not configured**. Multi-vendor trunking and routing practice are not completed work.

The experience is guided lab practice, not professional firewall or network administration.
