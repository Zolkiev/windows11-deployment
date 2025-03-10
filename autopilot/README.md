# Windows Autopilot

This folder contains configuration files and documentation for Windows Autopilot testing.

## Contents

- `profiles/`: Autopilot deployment profiles
- `test-plans/`: Test plans for Autopilot deployment
- `results/`: Test results and feedback
- `scripts/`: Autopilot-related scripts

## About Windows Autopilot

Windows Autopilot is a collection of technologies used to set up and pre-configure new devices, getting them ready for productive use. It's designed to simplify the IT administrative experience for deploying Windows devices.

## Testing Goals

While SCCM Task Sequences remain our primary deployment method, we are testing Windows Autopilot to evaluate:

1. Deployment efficiency and speed
2. User experience improvements
3. Reduced IT administrative overhead
4. Integration with cloud services
5. Zero-touch deployment scenarios

## Requirements for Testing

- Azure AD Premium licenses
- Microsoft Intune or other MDM service
- Windows 11 Pro, Enterprise, or Education
- Internet connectivity
- Modern devices that support TPM 2.0 and Secure Boot