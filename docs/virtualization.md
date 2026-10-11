# Virtualization — Windows Server and Windows 11

**Scope:** self-directed HomeLab practice, verified through October 8, 2026.

VirtualBox 7.2 runs a Windows Server 2025 domain-controller VM and a Windows 11 Pro domain-workstation VM. The host remains usable for school and normal desktop work rather than being dedicated to a bare-metal hypervisor.

## Network design

- A **host-only** network carries AD DS and DNS traffic between the two VMs. It intentionally has **no default gateway**.
- Separate **NAT** connectivity provides guest Internet access.
- The virtual domain network does **not** traverse the physical FortiGate, which is a conscious simplification and a future area of lab expansion.

## Verified results

- The Windows domain controller provides AD DS/DNS; the client was successfully joined to the domain and signed in with a lab account.
- Domain name-resolution and client Group Policy application were checked from the Windows 11 workstation.
- A 15-minute inactivity GPO was verified by client `gpresult` output and its corresponding registry setting.
- A VM black-screen issue was resolved by changing its graphics controller.

## Still open

Department drive mapping through Group Policy is **not completed**, and any future move of the AD traffic onto a firewall-routed segment is **planned**, not deployed. No VM performance or uptime benchmark is claimed.

See [Active Directory](active-directory.md) for authentication and access-control results.
