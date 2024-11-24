# Duplicate Asset Detection Script for N-Central

## 📄 Description

This script detects duplicate assets in the **N-Central RMM** console by leveraging the N-Central API and a regex-based naming convention. It is designed to identify devices that have been replaced or reinstalled during client interventions and flag them as duplicates.

---

## ⚙️ How It Works

1. **Asset Naming Convention**:
   - The script assumes assets are named using the following format:  
     `[CLIENT_TAG]-[ASSIGNED_NUMBER]-[INCREMENT_IF_REPLACED]`
   - Examples:
     - `CONTOSO-050`
     - `CONTOSO-050-02` (replaced version of the same asset)

2. **Duplicate Detection**:
   - The script identifies assets sharing the same base name (`[CLIENT_TAG]-[ASSIGNED_NUMBER]`) but with incremental suffixes.
   - For example:
     - Given the assets:
       - `CONTOSO-050`
       - `CONTOSO-050-02`
       - `CTS-055`
     - The script flags `CONTOSO-050` and `CONTOSO-050-02` as duplicates.

3. **Flagging Duplicates**:
   - The script updates a **custom property** on the flagged assets to indicate they are duplicates. This property can be used for filtering or reporting in the N-Central console.

---

## 🛠 Requirements

- **N-Central API**: Ensure API access is enabled and you have the required credentials.
- **Permissions**: The user accessing the API must have sufficient rights to modify custom properties on assets.
- **Custom Property**: Create a custom property in N-Central to store the duplicate flag (e.g., `DuplicateStatus`).

---

## 🚀 Usage Instructions

1. **Setup**:
   - Ensure the required custom property exists in your N-Central console.
   - Obtain API credentials (API key).
   - Configure the regex in the script to match your naming convention if needed.

2. **Script Output**:
   - The script logs its actions, including:
     - Detected duplicates.
     - Updated assets and their respective properties.

---

## 🔧 Configuration

### Parameters

| Parameter          | Description                           | Required | Example                        |
|--------------------|---------------------------------------|----------|--------------------------------|
| `$NcentralUri`    | N-Central API base URL                | Yes      | `https://n-central.example.com`|
| `$jwt`             | API key for authentication            | Yes      | `your-api-key`                 |
| `$customPropertyID`| Name of the custom property to update | Yes      | `id-of-the-custom-property`    |
| `$regex`           | Regex pattern for asset names         | Yes      | `^[A-Z]+-\d+(-\d+)?$`          |
| `$filterID`          | Filter ID to apply script on specific assets  | Yes      | `id-of-the-filter`  |
