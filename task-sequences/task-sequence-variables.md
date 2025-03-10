# Task Sequence Variables for Windows 11 Deployment

This document outlines the key task sequence variables used in the Windows 11 deployment process.

## Common Variables

| Variable Name | Description | Example Value |
|---------------|-------------|---------------|
| `OSDComputerName` | Target computer name | `%SerialNumber%` |
| `_SMSTSPackageName` | Current running task sequence package name | `Windows 11 Deployment` |
| `_SMSTSMediaType` | Media type being used for deployment | `FullMedia` |
| `_SMSTSBootImageID` | Boot image ID | `ABC00001` |
| `_SMSTSMDataPath` | Path to task sequence data | `C:\_SMSTaskSequence\Data` |
| `_SMSTSLogPath` | Path to task sequence log files | `C:\_SMSTaskSequence\Logs` |

## Custom Deployment Variables

| Variable Name | Description | Example Value |
|---------------|-------------|---------------|
| `DeploymentType` | Type of deployment | `BareMetal`, `Refresh`, `Replace` |
| `OSDDepartment` | Department for the device | `IT`, `Finance`, `HR` |
| `OSDTimeZone` | Time zone for the device | `Eastern Standard Time` |
| `OSDDomainName` | Domain to join | `contoso.local` |
| `OSDDomainOUName` | OU path for computer account | `OU=Workstations,OU=Devices,DC=contoso,DC=local` |
| `OSDJoinAccount` | Account used for domain join | `CONTOSO\DomainJoin` |
| `OSDEncryptDrive` | Whether to encrypt the drive | `TRUE`, `FALSE` |
| `OSDBackupUserData` | Whether to backup user data | `TRUE`, `FALSE` |
| `OSDBackupLocation` | Network location for user data backup | `\\server\share\backups` |

## Hardware-Specific Variables

| Variable Name | Description | Example Value |
|---------------|-------------|---------------|
| `OSDComputerModel` | Model of the computer | `Surface Pro 7`, `Latitude 5420` |
| `OSDComputerManufacturer` | Manufacturer of the computer | `Microsoft`, `Dell`, `HP` |
| `OSDDriverPackage` | ID of the driver package to use | `DR100123` |
| `OSDTouchEnabled` | Whether the device has a touchscreen | `TRUE`, `FALSE` |
| `OSDRequireTPM` | Whether TPM is required | `TRUE`, `FALSE` |

## Application Installation Variables

| Variable Name | Description | Example Value |
|---------------|-------------|---------------|
| `OSDInstallOffice` | Whether to install Office | `TRUE`, `FALSE` |
| `OSDOfficeVersion` | Version of Office to install | `Microsoft 365 Apps`, `Office 2021` |
| `OSDInstallBaseApps` | Whether to install base applications | `TRUE`, `FALSE` |
| `OSDInstallDeptApps` | Whether to install department-specific apps | `TRUE`, `FALSE` |
| `OSDDepartmentApps` | List of department-specific apps to install | `App1,App2,App3` |

## Custom Configuration Variables

| Variable Name | Description | Example Value |
|---------------|-------------|---------------|
| `OSDApplyCustomSettings` | Whether to apply custom settings | `TRUE`, `FALSE` |
| `OSDCustomSettingsPackage` | ID of the custom settings package | `CS100123` |
| `OSDEnableLocalAdmin` | Whether to enable the local admin account | `TRUE`, `FALSE` |
| `OSDLocalAdminPassword` | Password for the local admin account | `*****` |
| `OSDEnableBitLocker` | Whether to enable BitLocker | `TRUE`, `FALSE` |
| `OSDRunCustomScript` | Whether to run a custom script | `TRUE`, `FALSE` |
| `OSDCustomScriptPath` | Path to the custom script | `%ScriptRoot%\CustomConfig.ps1` |

## Setting Variables in SCCM

Variables can be set at multiple levels:
1. Collection variables
2. Machine variables
3. Task sequence variables
4. Dynamic variables using scripts

Example PowerShell to set a task sequence variable during a running task sequence:

```powershell
$tsenv = New-Object -ComObject Microsoft.SMS.TSEnvironment
$tsenv.Value("OSDComputerName") = "PC-" + $tsenv.Value("SerialNumber")
```