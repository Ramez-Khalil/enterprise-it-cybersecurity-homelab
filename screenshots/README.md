# Screenshots

Evidence captures referenced from the documentation. This folder is intentionally empty until
captures are added.

## Naming convention

```
<area>-<subject>-<detail>.png
```

| Area prefix | Use for |
|---|---|
| `net-` | FortiGate, FortiSwitch, VLAN, DHCP, policy, NAT |
| `ad-` | Domain controller, OUs, users, groups, Group Policy |
| `virt-` | VirtualBox host and VM configuration |
| `sec-` | Kali workflow stages and results |
| `ts-` | Troubleshooting evidence |

Examples: `net-fortilink-switch-authorized.png`, `net-vlan20-dhcp-scope.png`,
`ts-nslookup-1111-success.png`, `ad-ou-structure.png`, `ad-gpresult-workstation.png`.

## Redaction checklist — apply before committing any capture

Confirm each of these for every image:

- [ ] No passwords, password fields, or password reset dialogs
- [ ] No API keys, tokens, certificates, or private keys
- [ ] No device serial numbers, license keys, or registration identifiers
- [ ] No FortiGate admin session details that could be reused
- [ ] No household network detail beyond the WAN address already documented
- [ ] No real personal names, email addresses, or account identifiers — only the fictional lab
      users (`dreyes`, `mpatel`, `kbrooks`, `smartinez`)
- [ ] No public IP address belonging to the household connection
- [ ] No Wi-Fi SSID or pre-shared key
- [ ] Browser tabs, bookmarks, and notifications cropped out of full-screen captures

When a value must stay visible for the screenshot to make sense but should not be published,
black-box it in the image — do not rely on a caption to tell readers to ignore it.

## Captured

| File | Shows | Referenced in | Redacted |
|---|---|---|---|
| `net-fortilink-switch-authorized.png` | FortiSwitch 108F-POE authorized and online under FortiLink | [Networking §4](../docs/networking.md#4-fortiswitch-108f-poe-and-fortilink) | Switch serial number, admin username |
| `net-vlan20-dhcp-scope.png` | LAB-VLAN20 interface address and DHCP server settings | [Networking §5](../docs/networking.md#5-lab-vlan20) | Interface MAC address, admin username |
| `ad-ou-structure.png` | Custom `OPTIMA` OU tree in Active Directory Users and Computers | [Active Directory §2](../docs/active-directory.md#2-organizational-unit-structure) | — |
| `ad-ws01-dns-verification.png` | `OPTIMA-WS01` resolving `optima.test` against `LAB-DC01`, plus ping | [Active Directory §5](../docs/active-directory.md#5-workstation--optima-ws01-domain-join-in-progress) | — |

All four were cropped to the relevant window: no browser address bar, tabs, bookmarks,
notifications, or desktop.

## Planned captures

Not yet taken:

- LAB-VLAN20 → WAN1 firewall policy with NAT enabled
- Dell laptop `ipconfig /all` before and after the DNS correction
- `dcdiag` output on `LAB-DC01`
- `IT-HelpDesk` group membership
- Domain join confirmation and `gpresult /r` — only after that work is actually complete
