# Authorized Security Testing — HomeLab

This repository documents controlled exercises on **personally owned and authorized lab systems**. It does not describe school, employer, public, or third-party testing, a professional penetration test, or an enterprise security assessment.

## Completed project: SSH attack → hardening → detection → retest

In October 2026, an Ubuntu Linux lab target was deliberately configured with a weak SSH password. From Kali Linux, the authorized password test succeeded; authentication logs recorded the attempts. The target was then hardened with a stronger password, SSH settings (`PermitRootLogin no` and `MaxAuthTries 3`), and fail2ban's SSH jail.

On **October 11, 2026**, the same test was repeated after confirming that network connectivity to the target still worked. The password test no longer succeeded, and fail2ban recorded a ban of the attacker.

**Full evidence-based write-up:** [Authorized SSH hardening and retest](ssh-hardening-and-retest.md).

## Important limitations

- The test involved **an intentionally weak credential**, not a flaw discovered in Ubuntu/OpenSSH.
- Only one service (SSH) was hardened; this is not a full system-hardening benchmark.
- The intended VLAN-only network isolation for the target **has not been validated**. The attacker reached the target from the main lab subnet; the firewall restriction remains future work.
- All stages were completed with substantial step-by-step AI guidance; skills are *practiced*, not independent or resume-ready under the HomeLab's verification standard.
- The original attack screenshots and later monitor photographs have not been curated into sanitized public artifacts.

## Authorization and evidence rules

Testing is limited to owned, intentionally prepared targets. Credentials, host/account names, exact target identifiers, and private technical handoffs are withheld from public documentation. Published material focuses on objective, method, observed outcomes, and limits.

The broader recon → scanning → enumeration → web testing → assessment sequence remains a **learning roadmap**; only the specific verified SSH attack-and-defend cycle above is represented as completed. Exposure to other tools or school coursework is not attributed to this project.
