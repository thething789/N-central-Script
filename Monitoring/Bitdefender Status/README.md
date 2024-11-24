# Bitdefender Status Monitoring Script

## Overview

This PowerShell script is designed to monitor the presence and status of antivirus software on a Windows machine. By default, it checks if **Bitdefender Endpoint Security Tools**. The script can be adapted to monitor other antivirus solutions as needed.

## Features

- Detects whether **Bitdefender Endpoint Security Tools** is installed.
- Provides:
  - Antivirus name.
  - Update status (e.g., up-to-date or not).
  - Real-time protection status (e.g., enabled or disabled).
- Supports custom configurations to monitor other antivirus products.
- Includes a bypass mechanism for scenarios where WMI queries fail to retrieve antivirus information (specific to Bitdefender).

## How It Works

1. **WMI Query**:  
   The script uses `Get-WmiObject` with the `root\SecurityCenter2` namespace to retrieve antivirus information.  
   If the WMI query fails (common for Bitdefender), the script attempts to detect Bitdefender using the Windows service display name.

2. **Bitdefender-Specific Handling**:  
   Due to Bitdefender's limitations in providing details via WMI, the script bypasses normal detection and directly verifies the service status.

3. **Flexible Antivirus Detection**:  
   If monitoring other antivirus products, modify the service name and/or WMI query logic as needed.

4. **Product State Mapping**:  
   The script maps `productState` values retrieved from WMI to meaningful update and real-time protection statuses.

## Default Output

| Field                | Description                              |
|----------------------|------------------------------------------|
| **Antivirus Name**   | Name of the detected antivirus.          |
| **Update Status**    | Whether the antivirus definitions are up-to-date. |
| **Protection Status**| Whether real-time protection is enabled. |

## Adapting for Other Antivirus Products

To monitor a different antivirus:

1. Comment `$wmierror = "bypass"`
2. Replace the `Bitdefender Endpoint*` service name in the `Get-Service` call with the appropriate service name for the target antivirus.
3. Update the `switch` block to match the `productState` values for the new antivirus product if necessary.

## Notes

- **Bypass Mechanism**:  
A bypass is implemented for scenarios where WMI queries fail to retrieve antivirus details (common for Bitdefender). This mechanism defaults to using the service status.

- **Customizability**:  
The script is modular and can be customized for any antivirus by changing service detection parameters or adding logic for different `productState` mappings.

## Disclaimer
The script is provided as-is and has been tailored for specific use cases (e.g., monitoring Bitdefender). Always test in a controlled environment before deploying in production.