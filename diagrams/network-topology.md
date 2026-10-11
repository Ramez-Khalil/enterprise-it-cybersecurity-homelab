# HomeLab Network Topology — Sanitized Overview

**Based on verified HomeLab evidence through October 11, 2026.** The diagram shows technology relationships, not administrative endpoints or precise device addressing.

```mermaid
flowchart TD
  Home[Household router / Internet] --> MoCA[MoCA uplink]
  MoCA --> FG[FortiGate 60F / firewall / DHCP / NAT]
  FG --> FS[FortiSwitch 108F-POE / FortiLink]
  FS --> Test[Test-device VLAN]
  FS --> Store[Storage VLAN / Synology NAS]
  FS --> Host[VirtualBox host]
  Host --> DC[Windows Server 2025 / AD DS and DNS]
  Host --> Client[Windows 11 Pro / joined client]
  DC <-->|VirtualBox host-only network| Client
```

**Verified:** the test-device and storage VLANs exist; scoped storage-management access worked after a firewall policy was added. A lab-client outbound path uses NAT. The AD environment is separate and its traffic does **not** traverse the FortiGate.

**Not shown as complete:** Aruba/Cisco switch configuration, multi-vendor trunking, a NAS storage pool/RAID, and network isolation of the Ubuntu SSH test target.

See [networking](../docs/networking.md) and [architecture](../docs/architecture.md).
