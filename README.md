# NetTools Interactive (PowerShell)

**NetTools Interactive** is a PowerShell-based network troubleshooting tool for Windows systems.
It provides an interactive interface to quickly test network connectivity, run traceroute diagnostics, and perform DNS queries using a selected network adapter.

The script is designed for **network engineers, system administrators, and security engineers** who want a fast, repeatable troubleshooting workflow without switching between multiple tools.

---

# Features

* Interactive **network adapter selection**
* Option to **include or filter virtual adapters**
* Automatic display of:

  * Adapter name
  * MAC address
  * IPv4 address
  * Link speed
* **Traceroute test** using the Windows `tracert` command
* Optional **hop name resolution** for traceroute
* **TCP connectivity testing** using `Test-NetConnection`
* **DNS resolution testing** using `Resolve-DnsName`
* Ability to select **DNS record types** (A, MX, TXT, SOA, etc.)
* Custom **DNS server selection**
* Built-in **quick test presets**
* Continuous **interactive loop** for repeated testing

---

# Quick Presets

The script includes predefined diagnostic presets for common services.

| Preset | Service         | Port         | DNS Query    |
| ------ | --------------- | ------------ | ------------ |
| 1      | HTTPS           | 443          | A            |
| 2      | DNS             | 53           | A            |
| 3      | LDAP            | 389          | SRV          |
| 4      | LDAPS           | 636          | SRV          |
| 5      | RDP             | 3389         | A            |
| 6      | SMTP            | 25           | MX           |
| 7      | SMTP Submission | 587          | MX           |
| 8      | Custom          | User-defined | User-defined |

These presets allow rapid troubleshooting of common infrastructure services.

---

# What the Script Tests

The tool performs three main diagnostics.

## 1. Network Adapter Information

Displays:

* Adapter name
* MAC address
* IPv4 address
* Adapter status
* Link speed

This helps confirm which interface is being used for connectivity tests.

---

## 2. Traceroute Test

The script runs traceroute using the Windows `tracert` utility.

Example command:

```
tracert -d google.com
```

Users can choose whether to:

* **Disable hostname resolution (`-d`)** for faster results
* **Enable hostname resolution** to identify intermediate routers

A timeout mechanism stops traceroute automatically after **30 seconds** if the command takes too long.

---

## 3. TCP Connectivity Test

The script tests TCP connectivity using:

```
Test-NetConnection <host> -Port <port>
```

Output includes:

* Remote address
* Remote port
* Interface used
* TCP test success status

If supported by the system, the script attempts to use the adapter's **source IP address**.

---

## 4. DNS Resolution Test

DNS queries are performed using:

```
Resolve-DnsName
```

Users can specify:

* Hostname
* DNS record type
* DNS server

Supported record types include:

* A
* AAAA
* MX
* TXT
* CNAME
* SRV
* NS
* SOA
* PTR

Example:

```
Resolve-DnsName example.com -Type MX -Server 1.1.1.1
```

---

# Requirements

* Windows **10 / 11**
* Windows **Server 2016+**
* **PowerShell 5.0 or later**

The script relies only on **built-in PowerShell networking modules**, so no additional installation is required.

---

# Installation

Clone the repository:

```
git clone https://github.com/yourusername/nettools-interactive
```

Or download the script manually.

---

# Usage

Run the script from PowerShell:

```
powershell -ExecutionPolicy Bypass -File .\NetTools-Interactive.ps1
```

The script will guide you through the following steps:

1. Choose whether to include virtual adapters
2. Select the network adapter to use
3. Choose a preset or manual configuration
4. Run traceroute diagnostics
5. Perform TCP connectivity testing
6. Execute DNS queries

After each run you can:

* Press **Enter** to repeat the test
* Press **A** to change the network adapter
* Press **Q** to exit

---

# Typical Use Cases

This tool is useful for:

* Network troubleshooting
* Firewall validation
* Connectivity verification
* DNS diagnostics
* Infrastructure health checks
* Service availability testing

Example scenarios:

* Testing HTTPS connectivity to external services
* Verifying LDAP reachability to Active Directory
* Validating SMTP server access
* Troubleshooting DNS resolution issues
* Diagnosing routing problems with traceroute

---

# Future Improvements

Potential enhancements include:

* TCP-based traceroute
* Multi-port connectivity testing
* JSON or CSV export for troubleshooting reports
* Non-interactive CLI mode
* Automatic domain detection for LDAP SRV queries

---

# License

MIT License
