# Windows 11 Deployment Project

This repository contains all resources, scripts, and documentation for the Windows 11 deployment project.

## Overview

This repository is organized to support both SCCM Task Sequence deployment (primary method) and Windows Autopilot deployment (testing phase).

## Repository Structure

- `docs/`: Documentation for the deployment process
  - `deployment-guide.md`: Main deployment guide
  - `prerequisites.md`: Hardware and software requirements
  - `security-compliance.md`: Security configurations and compliance
  - `co-management-strategy.md`: SCCM and Intune co-management approach
  - `windows-patch-management.md`: Update and patch management
- `scripts/`: PowerShell and other scripts used in deployment
  - `pre-deployment/`: Scripts run before the main deployment
  - `deployment/`: Scripts used during OS deployment
  - `post-deployment/`: Scripts for post-deployment configuration
  - `utilities/`: Helper scripts and utilities
  - `autopilot/`: Scripts specific to Windows Autopilot testing
- `configs/`: Configuration files and templates
  - `unattend/`: Windows answer files for automated installation
  - `task-sequence/`: Configuration files for SCCM Task Sequences
  - `autopilot/`: Configuration profiles for Windows Autopilot
  - `group-policy/`: Group Policy settings and templates
  - `app-deployment/`: Application deployment configurations
  - `security-baselines/`: Windows security baseline configurations
- `task-sequences/`: SCCM Task Sequence exports and documentation
- `autopilot/`: Windows Autopilot configuration files and testing documentation
- `tools/`: Utilities and tools used in the deployment process
  - `hardware-inventory/`: Tools for hardware inventory and compatibility checking
  - `user-state-migration/`: Tools for migrating user state
  - `driver-management/`: Tools for driver extraction and management
  - `deployment-monitoring/`: Tools for monitoring deployment progress
- `images/`: Reference images and screenshots
- `logs/`: Sample logs and log analysis tools

## Project Goals

1. Standardize Windows 11 deployment process
2. Ensure security compliance from initial deployment
3. Minimize user disruption during deployment
4. Establish efficient update and patch management
5. Test modern deployment methods (Autopilot) for future use
6. Support both traditional and modern management approaches

## Getting Started

See the [Deployment Guide](docs/deployment-guide.md) for comprehensive instructions.

## Security Baselines

This project implements Microsoft recommended security baselines for Windows 11. See [Security and Compliance](docs/security-compliance.md) for details.

## Update Management

Windows 11 updates are managed through a combination of Windows Update for Business and SCCM. See [Patch Management Strategy](docs/windows-patch-management.md) for more information.

## Co-Management

This project includes a co-management approach with SCCM and Intune. See [Co-Management Strategy](docs/co-management-strategy.md) for implementation details.

## Contributing

1. Branch from main for each new feature or fix
2. Submit pull requests with detailed descriptions
3. Keep scripts and documentation updated
4. Test all changes before merging

## License

Internal use only - All rights reserved.