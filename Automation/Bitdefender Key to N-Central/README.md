# Automating Bitdefender Agent Key Synchronization with N-Central

## Overview

This PowerShell script facilitates the synchronization of **Bitdefender agent keys** for clients managed through **N-Central**, a key step in automating the deployment of Bitdefender agents on endpoints. By leveraging both the **Bitdefender GravityZone API** and **N-Central API**, the script ensures that each client in N-Central has the correct Bitdefender agent key stored in their custom properties, enabling seamless installation of the agent on endpoints.

## Features

- **Integration with Bitdefender GravityZone API**:
  - Retrieves the installation key for each client based on their tag.
  - Verifies if a corresponding installation package exists in GravityZone.

- **Integration with N-Central API**:
  - Lists all clients in N-Central.
  - Verifies the synchronization of the `AV - Bitdefender Key` custom property for each client.
  - Updates the custom property in N-Central if it does not match the key from Bitdefender.

- **Automated Workflow**:
  - Ensures the correct key is always available in N-Central for Bitdefender agent installation.
  - Prepares the environment for automated deployment of the Bitdefender agent.

## Prerequisites

1. **API Keys**:
   - A valid **GravityZone API key** with permissions to retrieve package installation links.
   - A valid **N-Central JWT token** for API access.

2. **Environment Configuration**:
   - Ensure the script has network access to both the GravityZone and N-Central APIs.

3. **Custom Property in N-Central**:
   - Create a custom property named `AV - Bitdefender Key` for each customer in N-Central to store the installation key.

4. **GravityZone Installation Packages**:
   - Ensure that installation packages in GravityZone are named using the client tag (derived from the first word of the customer name in N-Central). The script will look for these tags to retrieve the corresponding installation key.

## How It Works

1. **Retrieve N-Central Customer List**:
   - The script connects to the N-Central server and fetches a list of all customers, excluding those starting with `0 -`.

2. **Fetch Bitdefender Installation Key**:
   - For each customer, the script retrieves the **Bitdefender installation key** using the GravityZone API.
   - The tag for each client is derived from the first word of the customer name in N-Central.
   - The script checks if a matching installation package exists in GravityZone for the client's tag. If no package exists, no key is returned.

3. **Synchronize Key in N-Central**:
   - The script compares the retrieved key with the value in the `AV - Bitdefender Key` custom property.
   - If the keys do not match:
     - The old key is removed.
     - The correct key is added.
   - If the keys match, no action is taken.

## Limitations

- The script assumes that the customer's tag can be derived from the first word of their name in N-Central.
- Installation packages in GravityZone must be correctly named to match the client's tag for this process to work.
- Requires administrative privileges on both the GravityZone and N-Central environments.

## Disclaimer

This script is provided as-is and should be tested in a development environment before use in production. Ensure you have backups of your N-Central custom properties before executing the script.


