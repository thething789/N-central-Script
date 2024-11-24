# Bitdefender Status Monitoring Script

## Overview

This PowerShell script is designed to monitor the presence and status of antivirus software on a Windows machine. While it provides detailed information about update and real-time protection statuses for most antivirus solutions, it cannot retrieve this information for **Bitdefender Endpoint Security Tools** due to WMI limitations. However, it still detects whether Bitdefender is installed based on its service.

## Features

- Detects whether **Bitdefender Endpoint Security Tools** is installed.
- For other antivirus products, provides:
  - Antivirus name.
  - Update status (e.g., up-to-date or not).
  - Real-time protection status (e.g., enabled or disabled).
- Supports custom configurations to monitor different antivirus products.

## Limitations

- **Bitdefender Endpoint Security Tools**:  
  The script can detect if Bitdefender is installed but cannot provide information on its update status or real-time protection status. This is due to limitations in how Bitdefender interacts with WMI.

- For all other antivirus products, the script retrieves information via WMI as expected.

## How It Works

1. **WMI Query**:  
   The script uses `Get-WmiObject` with the `root\SecurityCenter2` namespace to retrieve antivirus information.  

2. **Bitdefender-Specific Handling**:  
   If WMI fails to provide information, the script checks for the presence of the Bitdefender service (`Bitdefender Endpoint*`) to confirm its installation.

3. **Product State Mapping**:  
   For other antivirus products, the script maps `productState` values retrieved from WMI to meaningful update and real-time protection statuses.

## Default Output

| Field                | Description                              |
|----------------------|------------------------------------------|
| **Antivirus Name**   | Name of the detected antivirus.          |
| **Update Status**    | Whether the antivirus definitions are up-to-date. (Unavailable for Bitdefender) |
| **Protection Status**| Whether real-time protection is enabled. (Unavailable for Bitdefender) |


## Adapting for Other Antivirus Products

To monitor a different antivirus:

1. Replace the `Bitdefender Endpoint*` service name in the `Get-Service` call with the appropriate service name for the target antivirus.

## Disclaimer
The script is provided as-is and has been tailored for specific use cases. It is especially effective for most antivirus solutions, but limitations exist for some products, such as Bitdefender. Always test in a controlled environment before deploying in production.

