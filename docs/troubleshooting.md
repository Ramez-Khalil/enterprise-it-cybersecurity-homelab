# Verified Network & DNS Troubleshooting Cases

Both incidents occurred in a **self-directed, AI-guided HomeLab** and were resolved; screenshots have not been confirmed preserved. The tests below come from the verified October 8, 2026 Technical Evidence Handoff.

## Case 1 — IP connectivity works, names do not

| Stage | Observation |
| --- | --- |
| Expected | A test laptop on the lab VLAN should reach the Internet and resolve domain names. |
| Actual | `ping 8.8.8.8` succeeded, while a hostname lookup/connection failed. |
| Isolation test | `nslookup google.com 1.1.1.1` succeeded, demonstrating the resolver was reachable. |
| Root cause | Old manually assigned DNS servers on the laptop overrode the expected DHCP-delivered resolver settings. |
| Fix | Restored automatic DNS server assignment. |
| Verification | Hostnames resolved after the change. |

**Lesson:** successful IP reachability but failed name resolution points to a different layer than basic routing or NAT.

## Case 2 — Domain workstation queries the wrong DNS server

| Stage | Observation |
| --- | --- |
| Expected | A Windows domain client should resolve the test Active Directory domain using its domain controller. |
| Actual | The client queried the household resolver and received a response indicating the internal domain did not exist. |
| Root cause | Its selected DNS resolver was not the AD domain controller. |
| Fix | Directed the client to the domain controller for DNS and flushed the cache with `ipconfig /flushdns`. |
| Verification | Explicit `nslookup` / `Resolve-DnsName` queries against the domain controller succeeded; domain access worked. |

**Lesson:** for an AD lab, name service must point at the domain DNS service rather than a generic upstream router.

## Evidence and limits

The above are two actual recorded troubleshooting stories, not hypothetical interview answers. Both fixes used step-by-step assistance; no independent skill-check or screenshot set is claimed. Only relevant, privacy-safe commands and outcomes are shown.

Related projects: [Active Directory](active-directory.md) · [Networking](networking.md).
