# Authorized SSH Attack, Hardening & Retest — HomeLab Case Study

**Environment:** HomeLab security exercise on equipment owned and controlled by the project author.

**Status (October 11, 2026):** The attack → hardening → detection → retest cycle is complete and technically verified. A separate network-isolation control remains unfinished.

## Purpose

Test whether an intentionally weak SSH credential on a repurposed Ubuntu Linux target could be compromised from a Kali Linux system, then change the defensive configuration and retest the **same attack**. The goal was to validate a correction and observe a prevention control, rather than merely report an open service.

## Lab setup and scope

- **Target:** owned Dell computer repurposed as an Ubuntu Server host, with an intentionally weak test-user password and SSH enabled.
- **Testing system:** Kali Linux in the HomeLab.
- **Tools and evidence:** Hydra for the authorized password test; Ubuntu SSH logs, OpenSSH configuration readback, systemd service checks, and fail2ban's `sshd` jail for defensive verification.
- **Boundaries:** the work was confined to lab-owned equipment. Hostnames, account identifiers, credentials, and exact target addresses are intentionally omitted.

The target was an ordinary Linux installation with a **deliberately weak credential**. The tested weakness was the credential itself, not an operating-system vulnerability.

## Verified sequence

| Stage | What was observed |
| --- | --- |
| **Initial test** | The weak lab password was recovered during the authorized SSH password test. A successful SSH login and privilege escalation to root were confirmed. Login attempts appeared in the target's authentication log. |
| **Password remediation** | Replaced the intentionally weak password with a strong one. |
| **SSH configuration** | Applied `PermitRootLogin no` and `MaxAuthTries 3` in an SSH configuration drop-in. The effective settings were confirmed with `sshd -T`. |
| **Detection and prevention** | Installed and verified a running fail2ban service with the SSH jail enabled. |
| **Control retest** | Confirmed the target was still reachable before repeating the **same** password test with the **same** wordlist. This time no password was recovered. |
| **Defensive evidence** | fail2ban reported one attacker ban; the repeated connection attempts were blocked, and the test stalled after the ban. |

**Interpretation:** The before/after test showed that the original weak-password path no longer succeeded after the credential and SSH controls were changed, while fail2ban detected and blocked the repeated attempts. This result is specific to the tested SSH path; broader host hardening was outside the scope of this exercise.

## Troubleshooting encountered

After editing SSH settings, the configuration check reported a missing `/run/sshd` runtime directory and service restart failed. The missing directory was restored; the SSH configuration check then passed and the service restarted. A separate service check showed SSH was not enabled on boot, so startup was enabled and verified.

This reinforced the difference between a service running in the current session and a service configured to start after reboot.

## Validation and remaining work

- Effective SSH settings were read back from the active configuration rather than assumed from the file alone.
- The target remained reachable before the second test, so the failed retest was not simply caused by a connectivity outage.
- fail2ban's SSH jail recorded the attacker ban.
- **Network segmentation remains a follow-up:** the attacker's traffic reached the target from the main lab subnet rather than exclusively through the intended test VLAN. The VLAN-only firewall path still needs to be implemented and verified.
- Polished, sanitized terminal screenshots are still being prepared for the public case study.

## Skills exercised

Authorized test scoping, SSH authentication analysis, Linux configuration, service management, authentication-log review, fail2ban detection, controlled retesting, and troubleshooting.

**Last verified:** October 11, 2026.
