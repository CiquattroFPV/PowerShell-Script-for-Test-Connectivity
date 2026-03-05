# NetTools Interactive (PowerShell)

[![PowerShell](https://img.shields.io/badge/PowerShell-5%2B-blue)](https://learn.microsoft.com/powershell/)
[![Platform](https://img.shields.io/badge/Platform-Windows-0078D6)](#requirements)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](#license)
[![Status](https://img.shields.io/badge/Status-Active-success)](#)

**NetTools Interactive** is an interactive PowerShell network troubleshooting toolkit for Windows.
It allows you to quickly run **traceroute**, **TCP connectivity tests**, and **DNS queries** using a selected network adapter.

The tool is designed for **network engineers, system administrators, and security engineers** who need a simple, repeatable diagnostic workflow.

---

# Table of Contents

* [Features](#features)
* [Demo](#demo)
* [Quick Presets](#quick-presets)
* [Requirements](#requirements)
* [Installation](#installation)
* [Usage](#usage)
* [Examples](#examples)
* [Output](#output)
* [Project Structure](#project-structure)
* [Troubleshooting](#troubleshooting)
* [Roadmap](#roadmap)
* [Contributing](#contributing)
* [License](#license)

---

# Features

* Interactive **network adapter selection**
* Option to **include or filter virtual adapters**
* Automatic display of:

  * Adapter name
  * MAC address
  * IPv4 address
  * Status
  * Link speed
* **Traceroute test** using Windows `tracert`

  * Optional hop hostname resolution
  * **Timeout protection** (30 seconds)
* **TCP connectivity testing** using `Test-NetConnection`
* **DNS resolution testing** using `Resolve-DnsName`
* Support for multiple **DNS record types**
* Custom **DNS server selection**
* Built-in **quick service presets**
* Continuous **interactive loop** for repeated diagnostics

---

# Demo

Recommended screenshots for the repository:

```
docs/screenshots/adapter-selection.png
docs/screenshots/run-output.png
```

Example screen sections:

* Adapter selection menu
* Traceroute output
* TCP connectivity test
* DNS resolution output

---

# Quick Presets

The script includes predefined diagnostic presets.

| Preset | Service         | Port         | Default DNS Query            |
| ------ | --------------- | ------------ | ---------------------------- |
| 1      | HTTPS           | 443          | A                            |
| 2      | DNS             | 53           | A                            |
| 3      | LDAP            | 389          | SRV (`_ldap._tcp.<domain>`)  |
| 4      | LDAPS           | 636          | SRV (`_ldaps._tcp.<domain>`) |
| 5      | RDP             | 3389         | A                            |
| 6      | SMTP            | 25           | MX                           |
| 7      | SMTP Submission | 587          | MX                           |
| 8      | Custom          | User defined | User defined                 |

These presets allow rapid troubleshooting of common infrastructure services.

---

# Requirements

* Windows **10 / 11**
* Windows **Server 2016+**
* **PowerShell 5.0 or later**

The script relies only on **built-in Windows networking modules**, so no additional installation is required.

---

# Installation

Clone the repository:

```
git clone https://github.com/<your-username>/nettools-interactive.git
cd nettools-interactive
```

Or download the script manually and run it locally.

---

# Usage

Run the script from PowerShell:

```
powershell -ExecutionPolicy Bypass -File .\NetTools-Interactive.ps1
```

Recommended safer execution method:

```
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\NetTools-Interactive.ps1
```

---

# Examples

## Fast traceroute (no DNS resolution)

When prompted:

```
Traceroute: resolve hop names? (slower) [N]
```

The script runs:

```
tracert -d google.com
```

This disables reverse DNS resolution for faster results.

---

## DNS MX Lookup

Example input:

* Hostname: `example.com`
* Record Type: `MX`
* DNS Server: `1.1.1.1`

Equivalent command:

```
Resolve-DnsName example.com -Type MX -Server 1.1.1.1
```

---

# Output

Typical execution includes:

1. Adapter information
2. Traceroute output
3. TCP connectivity test
4. DNS resolution results

Example TCP result:

```
ComputerName     : example.com
RemoteAddress    : 93.184.216.34
RemotePort       : 443
TcpTestSucceeded : True
```

---

# Project Structure

Recommended repository layout:

```
nettools-interactive/
│
├── NetTools-Interactive.ps1
├── README.md
├── LICENSE
│
└── docs
    ├── screenshots
    │   ├── adapter-selection.png
    │   └── run-output.png
    │
    └── examples
        └── sample-output.txt
```

---

# Troubleshooting

## SourceAddress parameter error

Some Windows builds do not support the `-SourceAddress` parameter in `Test-NetConnection`.

The script automatically detects this and falls back to the default routing method.

---

## Slow traceroute

Disable hop name resolution when prompted.

This forces:

```
tracert -d destination
```

which avoids reverse DNS lookups and significantly speeds up the traceroute.

---

## DNS query failures

Ensure:

* The selected DNS server is reachable
* No firewall policies block DNS requests
* The correct DNS record type is selected

---

# Roadmap

Future improvements may include:

* JSON or CSV **report export**
* **Multi-port connectivity testing**
* Configurable **traceroute hop limits**
* **CLI (non-interactive) mode**
* Automatic **Active Directory SRV query generation**

---

# Contributing

Contributions are welcome.

Typical workflow:

1. Fork the repository
2. Create a feature branch

```
git checkout -b feature/my-feature
```

3. Commit changes

```
git commit -m "Add: new feature"
```

4. Push and open a Pull Request.

Please keep changes minimal and update documentation when necessary.

---

# License

MIT License
