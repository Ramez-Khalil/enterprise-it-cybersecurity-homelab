# Authorized SSH Attack, Hardening & Retest — HomeLab Case Study

**Environment:** Self-directed, AI-guided security learning on equipment owned and controlled by the project author. This is not a professional penetration test or production-security engagement.

**Status (October 11, 2026):** The attack → hardening → detection → retest cycle is complete and technically verified. A separate network-isolation control remains unfinished.

## Purpose

Test whether an intentionally weak SSH credential on a repurposed Ubuntu Linux target could be compromised from a Kali Linux system, then change the defensive configuration and retest the **same attack**. The goal was to validate a correction and observe a prevention control, rather than merely report an open service.

## Lab setup and scope

- **Target:** owned Dell computer repurposed as an Ubuntu Server host, with an intentionally weak test-user password and SSH enabled.
- **Testing system:** Kali Linux in the author's HomeLab.
- **Tools and evidence:** Hydra for the authorized password test; Ubuntu SSH logs, OpenSSH configuration readback, systemd service checks, and fail2ban's `sshd` jail for defensive verification.
- **Boundaries:** the work was confined to the author's lab-owned target. Hostnames, account identifiers, credentials, and exact target address are intentionally omitted.

The target was an ordinary Linux installation with a **deliberately weak credential**. It was not a deliberately vulnerable operating-system distribution, nor a software vulnerability discovery.

## Verified sequence

| Stage | What was observed |
| --- | --- |
| **Initial test** | The weak lab password was recovered during the authorized SSH password test. A successful SSH login and privilege escalation to root were confirmed. Login attempts appeared in the target's authentication log. |
| **Password remediation** | Replaced the intentionally weak password with a strong one. |
| **SSH configuration** | Applied `PermitRootLogin no` and `MaxAuthTries 3` in an SSH configuration drop-in. The effective settings were confirmed with `sshd -T`. |
| **Detection and prevention** | Installed and verified a running fail2ban service with the SSH jail enabled. |
| **Control retest** | Confirmed the target was still reachable before repeating the **same** password test with the **same** wordlist. This time no password was recovered. |
| **Defensive evidence** | fail2ban reported one attacker ban; the repeated connection attempts were blocked, and the test stalled after the ban. |

**Interpretation:** The controlled before/after test supports that the weak-password attack was no longer successful under the revised password and SSH controls, and that fail2ban detected and banned the repeated attempts. It does **not** demonstrate comprehensive Linux hardening or broad resistance to other attacks.

## Troubleshooting encountered

After editing SSH settings, the configuration check reported a missing `/run/sshd` runtime directory and service restart failed. The missing directory was restored; the SSH configuration check then passed and the service restarted. A separate service check showed SSH was not enabled on boot, so startup was enabled and verified.

This reinforced the difference between a service running in the current session and a service configured to start after reboot.

## Validation and limitations

- Effective SSH settings were read back from the active configuration rather than assumed from the file alone.
- The target remained reachable before the second test, so the failure was not simply a connectivity outage.
- fail2ban's SSH jail recorded the attacker ban.
- **Network segmentation is not yet proven for this target.** The attacker's traffic reached the target from the main lab subnet, not exclusively from the intended test VLAN. A stricter VLAN/firewall path is future work and is **not** claimed as complete.
- The lab used guided, step-by-step execution. This is evidence of **practiced** skills, not independent expertise or a professional security role.
- No polished, sanitized terminal screenshots are included yet. The documented outcomes are based on the verified technical evidence handoff; screenshots will be added only if reviewed for sensitive details.

## Skills exercised

Authorized test scoping, SSH authentication analysis, targeted Linux configuration, service management, authentication-log review, fail2ban detection, controlled retesting, and troubleshooting.

**Evidence provenance:** HomeLab Technical Evidence Handoff updated October 11, 2026. Technical execution and results were verified in the HomeLab workflow; this page is a sanitized recruiter-facing summary.
