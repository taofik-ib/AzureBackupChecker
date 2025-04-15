# Azure App Services Backup Status Checker

This project contains a PowerShell script that checks the backup status of all Azure App Services across your Azure subscriptions. It provides a comprehensive inventory of App Services and their backup configurations.

## Features

- Scans all Azure subscriptions accessible to the user
- Checks backup configuration for each App Service
- Provides detailed information including:
  - App Service name and location
  - Resource group
  - Subscriptionk
  - Backup status (Enabled/Disabled)
  - Backup frequency (if enabled)
  - Retention period (if enabled)
  - App Service status (Enabled/Disabled)

## Prerequisites

- PowerShell 7.0 or later
- Azure PowerShell module installed
- Azure account with appropriate permissions to:
  - List subscriptions
  - Read App Service configurations
  - Read backup configurations

## Installation

1. Clone or download this repository
2. Install Azure PowerShell module if not already installed:
   ```powershell
   Install-Module -Name Az -AllowClobber -Scope CurrentUser
   ```

## Usage

1. Open PowerShell
2. Navigate to the project directory
3. Run the script:
   ```powershell
   ./custombackup-rest.ps1
   ```

## Output

The script provides:
- A detailed list of all App Services and their backup status
- Summary statistics including:
  - Total number of App Services
  - Number of App Services with backup enabled
  - Number of App Services without backup
- A formatted table view of all App Services
- CSV export of the inventory (commented out by default)

## Error Handling

The script includes error handling for:
- Missing backup configurations
- API errors
- Permission issues

## Notes

- The script requires Azure authentication. You will be prompted to log in if not already authenticated.
- The script checks all subscriptions accessible to your account.
- Backup status is determined by the presence of a backup configuration.
- The script uses Azure PowerShell cmdlets for reliable and efficient execution.

## Contributing

Feel free to submit issues and enhancement requests!

## License

This project is licensed under the MIT License - see the LICENSE file for details. 