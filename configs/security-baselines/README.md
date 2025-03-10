# Security Baselines

This folder contains Windows 11 security baseline configurations and related files.

## Overview

Security baselines are pre-configured groups of Windows settings that help you apply security best practices recommended by Microsoft and various security agencies.

## Contents

- `windows-11-security-baseline/`: Microsoft's recommended security baseline for Windows 11
- `custom-baseline/`: Organization-specific security baseline modifications
- `baseline-comparison/`: Comparison between different baseline versions
- `baseline-deployment/`: Scripts and tools for deploying security baselines

## Implementation Instructions

### Using Group Policy

1. Download the [Microsoft Security Compliance Toolkit](https://www.microsoft.com/en-us/download/details.aspx?id=55319)
2. Import the baseline GPO backups into your Group Policy Management console
3. Link the GPOs to the appropriate OUs
4. Test on pilot systems before full deployment

### Using SCCM

1. Create Configuration Items based on baseline settings
2. Create a Configuration Baseline
3. Deploy to a collection
4. Monitor compliance

### Using Intune

1. Create a security baseline profile
2. Assign to groups
3. Monitor compliance

## Related Resources

- [Microsoft Security Baselines Blog](https://techcommunity.microsoft.com/t5/microsoft-security-baselines/bg-p/Microsoft-Security-Baselines)
- [Windows 11 Security Baseline Documentation](https://learn.microsoft.com/en-us/windows/security/threat-protection/windows-security-configuration-framework/windows-11-security-baseline)
- [Security Compliance Toolkit Documentation](https://learn.microsoft.com/en-us/windows/security/threat-protection/windows-security-configuration-framework/security-compliance-toolkit-10)

## Notes

- Always test security baselines in a controlled environment before deployment
- Document any deviations from Microsoft's recommended baselines
- Regularly review and update security baselines when new versions are released