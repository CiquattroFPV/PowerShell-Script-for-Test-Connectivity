# NetTools Interactive (PowerShell)

Interactive PowerShell troubleshooting tool for Windows networking.

This script helps quickly gather network adapter information and perform common connectivity and DNS diagnostics from the command line.

It is designed for network engineers, system administrators, and security engineers who want a fast way to test connectivity without navigating through multiple Windows tools.

---

# Features

* Interactive adapter selection
* Displays:

  * Network adapter name
  * MAC address
  * IPv4 address
* TCP connectivity testing using `Test-NetConnection`
* DNS resolution using a **specific DNS server**
* Compatible with multiple Windows PowerShell versions
* Automatically detects whether `Test-NetConnection -SourceAddress` is supported

---

# What the Script Does

The script performs three main diagnostic steps.

## 1. Adapter Information

Retrieves information about the selected network adapter:

* Adapter name
* MAC address
* IPv4 address

This helps confirm which interface is being used for network communication.

---

## 2. TCP Connectivity Test

Uses the PowerShell cmdlet `Test-NetConnection` to verify reachability to a remote host and port.

Example test:

```
Destination: google.com
Port: 443
```

The script displays:

* Remote address
* Interface used
* Source address
* TCP test result

This is useful for verifying firewall rules, connectivity, and service availability.

---

## 3. DNS Resolution Test

Uses the `Resolve-DnsName` cmdlet with a **user-specified DNS server**.

Example:

```
Domain: maticmind.it
Record type: MX
DNS server: 1.1.1.1
```

This allows testing DNS resolution independently from the system's configured DNS servers.

---

# Requirements

* Windows PowerShell **5.x or later**
* Windows 10 / Windows 11 / Windows Server
* Administrative privileges **not required**

The script relies only on built-in PowerShell networking modules.

---

# Installation

Clone the repository:

```
git clone https://github.com/yourusername/nettools-interactive
```

Or download the script directly from the repository.

---

# Usage

Run the script using PowerShell:

```
powershell -ExecutionPolicy Bypass -File .\NetTools-Interactive.ps1
```

The script will guide you through a series of interactive prompts.

---

# Interactive Inputs

The script asks the user to provide the following parameters:

| Parameter        | Description                | Example      |
| ---------------- | -------------------------- | ------------ |
| Network Adapter  | Adapter to inspect         | Ethernet 3   |
| Destination Host | Host for connectivity test | google.com   |
| Port             | TCP port to test           | 443          |
| DNS Name         | Domain to resolve          | maticmind.it |
| DNS Record Type  | DNS record type            | MX           |
| DNS Server       | DNS server to query        | 1.1.1.1      |

---

# Example Output

```
--- Adapter info ---

Adapter : Ethernet 3
Name    : Ethernet
MAC     : C4-C6-E6-5C-5D-2C
IP      : 192.168.1.25


--- Test-NetConnection ---

ComputerName     : google.com
RemoteAddress    : 142.250.184.14
RemotePort       : 443
TcpTestSucceeded : True


--- Resolve-DnsName ---

Name          Type TTL Section NameExchange
----          ---- --- ------- ------------
maticmind.it  MX   3600 Answer mail.maticmind.it
```

---

# Typical Use Cases

This tool is useful for:

* Network troubleshooting
* Firewall validation
* DNS diagnostics
* Connectivity verification
* Security testing
* Quick remote service checks

Common examples include:

* Testing HTTPS connectivity
* Validating DNS MX records
* Verifying firewall port accessibility
* Checking network adapter configuration

---

# Compatibility Note

Some Windows builds do not support the `-SourceAddress` parameter in `Test-NetConnection`.

If the parameter is not available, the script automatically falls back to standard routing behavior.

This ensures compatibility across different Windows versions.

---

# Future Improvements

Possible enhancements include:

* Adapter selection menu
* Continuous diagnostic loop
* Export results to CSV or JSON
* Multi-host connectivity testing
* Parallel port testing

---

# License

MIT License
