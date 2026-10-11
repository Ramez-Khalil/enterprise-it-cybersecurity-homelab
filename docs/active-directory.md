# Windows Active Directory — Identity & Access Management Lab

**Self-directed, AI-guided HomeLab.** Core environment and specified controls technically verified as of October 8, 2026. Not professional or production administration.

## Purpose and environment

A Windows Server 2025 domain controller provides AD DS and DNS for a Windows 11 Pro domain-joined workstation in VirtualBox. The VMs communicate over a host-only virtual network. This kept the domain exercises separate from the physical Fortinet lab; **domain traffic does not pass through the FortiGate**.

The lab uses a custom department-based OU structure for users, computers, groups, and service accounts. Four *fictional* users and five security groups were created for IT, Human Resources, Finance, Operations, and help desk delegation.

## Work completed

- Installed and validated AD DS/DNS services, including healthy domain-controller service checks.
- Joined a Windows 11 Pro workstation to the domain and placed the computer object in the intended Workstations OU.
- Verified interactive domain sign-in with `whoami`.
- Configured a **Workstation Baseline** GPO with a 15-minute inactivity lock. Verified application from the client with `gpresult /scope computer /r` and the resulting `InactivityTimeoutSecs = 900` registry value.
- Delegated password-reset and force-change-at-next-logon rights to a help desk group for lab user OUs. Confirmed a test user's password reset and forced change at sign-in.
- Configured an SMB department share with group-based NTFS permissions, removing broad access and restricting department directories by security group.
- Tested **four** fictional department users. Users could access their own departmental folders; cross-department access checks were denied.

## Troubleshooting

- A computer-scope `gpresult` check initially returned Access Denied until run elevated.
- One security group was misnamed and corrected.
- A workstation DNS resolver initially pointed to a non-domain DNS server. Changing it to the domain controller and flushing the cache resolved the domain lookup problem. See [troubleshooting](troubleshooting.md).

## What remains

Department **drive mapping through Group Policy is not complete**, and a stale DNS-forwarder cleanup remains open. A negative delegation test and additional independent skill checks are also pending. No validated screenshot collection is published yet.

This page describes specific lab exercises completed with step-by-step guidance. It does not demonstrate enterprise service-desk or independent Windows Server administration experience.
