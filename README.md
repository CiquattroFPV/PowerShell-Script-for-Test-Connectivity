# NetTools Interactive (PowerShell)

**NetTools Interactive** is a PowerShell-based network troubleshooting tool designed for Windows systems.
It provides an interactive interface to quickly test network connectivity, perform traceroute diagnostics, and run DNS queries using a selected network adapter.

The script is intended for **network engineers, system administrators, and security engineers** who need a fast and repeatable way to diagnose connectivity issues without switching between multiple tools.

---

# Features

* Interactive **network adapter selection**
* Option to **include or filter virtual adapters**
* Automatic display of:

  * Adapter name
  * MAC address
  * IPv4 address
  * Link speed
* **Traceroute test** with automatic timeout (10 seconds)
* **TCP connectivity testing** using `Test-NetConnection`
* **DNS resolution testing** using a custom DNS server
* Built-in **quick test presets**
* Continuous **interactive loop** for repeated testing
* Works on **Windows PowerShell 5.x and later**

---

# Quick Presets

The script includes predefined diagnostic presets for common services:

| Preset | Description     | Port         | DNS Query                |
| ------ | --------------- | ------------ | ------------------------ |
| 1      | HTTPS           | 443          | A                        |
| 2      | DNS             | 53           | A                        |
| 3      | LDAP            | 389          | SRV `_ldap._tcp.domain`  |
| 4      | LDAPS           | 636          | SRV `_ldaps._tcp.domain` |
| 5      | RDP             | 3389         | A                        |
| 6      | SMTP            | 25           | MX                       |
| 7      | SMTP Submission | 587          | MX                       |
| 8      | Custom          | User defined | User defined             |

These presets allow fast troubleshooting of common infrastructure services.

---

# What the Script Tests

The tool performs three primary diagnostics:

## 1. Network Adapter Information

Displays:

* Adapter name
* MAC address
* IPv4 address
* Status
* Link speed

This helps confirm which interface is being used for connectivity tests.

---

## 2. Traceroute Test

Runs a traceroute using PowerShell:

```
Test-NetConnection <destination> -TraceRoute
```

A timeout mechanism stops the traceroute if it runs longer than **10 seconds**, allowing the script to continue automatically.

This helps quickly identify routing issues or blocked paths.

---

## 3. TCP Connectivity Test

The script tests a specific TCP port using:

```
Test-NetConnection <host> -Port <port>
```

If supported by the system, the script will automatically use the adapter's **source IP address**.

Example output fields include:

* Remote address
* Remote port
* Interface used
* TCP success status

---

## 4. DNS Resolution Test

DNS queries are performed using:

```
Resolve-DnsName
```

The user can specify:

* DNS record type (A, AAAA, MX, SRV, etc.)
* DNS server to query

This allows testing DNS resolution independently from the system configuration.

---

# Requirements

* Windows PowerShell **5.0 or later**
* Windows **10 / 11 / Server**
* No administrative privileges required

The script relies only on built-in PowerShell networking modules.

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
2. Select a network adapter
3. Choose a preset or custom test
4. Run traceroute
5. Perform TCP connectivity testing
6. Run DNS resolution tests

After each run, you can:

* Press **Enter** to repeat the test
* Press **A** to select another adapter
* Press **Q** to exit the tool

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
* Validating LDAP reachability to Active Directory
* Verifying SMTP server connectivity
* Troubleshooting DNS resolution issues
* Diagnosing routing problems with traceroute

---

# Compatibility Notes

Some older Windows builds may not support the `-SourceAddress` parameter for `Test-NetConnection`.

If this parameter is not available, the script automatically falls back to standard routing behavior.

---

# Future Improvements

Potential enhancements include:

* TCP-based traceroute
* Multi-port testing
* Export results to **CSV or JSON**
* Non-interactive CLI mode
* Automatic domain detection for LDAP SRV queries

---

# License

MIT License
