# Windows Autopilot Test Plan

## Test Overview

This test plan outlines the process for evaluating Windows Autopilot as a potential deployment method alongside our existing SCCM Task Sequence-based deployment.

## Test Objectives

1. Evaluate the end-to-end Windows Autopilot deployment process
2. Compare deployment time against SCCM Task Sequence deployments
3. Assess user experience during the deployment process
4. Verify application installation and configuration
5. Test integration with existing management systems
6. Document advantages and limitations

## Test Environment

### Hardware

- **Test Devices**: 
  - 2x Dell Latitude 5420
  - 2x HP EliteBook 840 G8
  - 2x Lenovo ThinkPad X1 Carbon
  - 1x Microsoft Surface Pro 7

### Software/Services

- **Azure AD**: Production tenant
- **Intune**: Production tenant
- **Windows 11 Enterprise**: Version 22H2
- **Microsoft 365 Apps**: Current Channel

## Test Scenarios

### Scenario 1: Self-Deploying Mode

**Description**: Test fully automated deployment with no user interaction.

**Steps**:
1. Register device in Autopilot
2. Create self-deploying profile in Intune
3. Power on device and connect to network
4. Verify device automatically provisions

**Success Criteria**:
- Device completes deployment without user intervention
- Device is joined to Azure AD
- Required applications are installed
- Device appears in Intune management

### Scenario 2: User-Driven Mode with Azure AD Join

**Description**: Test user-driven deployment with Azure AD Join.

**Steps**:
1. Register device in Autopilot
2. Create user-driven profile in Intune
3. Power on device and connect to network
4. Sign in with test user credentials
5. Complete OOBE experience

**Success Criteria**:
- User can successfully sign in
- Personal settings are applied
- Required applications are installed
- Device appears in Intune management

### Scenario 3: User-Driven Mode with Hybrid Azure AD Join

**Description**: Test user-driven deployment with Hybrid Azure AD Join.

**Steps**:
1. Register device in Autopilot
2. Create user-driven profile with Hybrid Join in Intune
3. Power on device and connect to network
4. Sign in with domain credentials
5. Complete OOBE experience

**Success Criteria**:
- User can successfully sign in with domain credentials
- Device is joined to on-premises AD and Azure AD
- Group policies are applied
- Required applications are installed
- Device appears in both SCCM and Intune management

### Scenario 4: Pre-provisioning (White Glove)

**Description**: Test IT pre-provisioning capability.

**Steps**:
1. Register device in Autopilot
2. Configure profile for pre-provisioning
3. IT admin starts White Glove process
4. Complete IT admin phase
5. Ship to user and complete user phase

**Success Criteria**:
- IT admin can successfully pre-provision the device
- User experience is streamlined
- All applications are pre-installed
- User settings are applied at first login

## Test Metrics

For each scenario, record the following metrics:

1. **Time to Deploy**: Total time from power-on to ready-for-use
2. **User Interaction Time**: Amount of time requiring user input
3. **Success Rate**: Percentage of successful deployments
4. **Resource Utilization**: Network bandwidth used, CPU/RAM usage during deployment
5. **Application Installation Success**: Percentage of applications successfully installed

## Test Schedule

| Week | Activities |
|------|------------|
| Week 1 | Environment setup, device registration |
| Week 2 | Scenarios 1 and 2 testing |
| Week 3 | Scenarios 3 and 4 testing |
| Week 4 | Data analysis and report creation |

## Roles and Responsibilities

- **Test Lead**: [Name] - Overall test coordination
- **Intune Administrator**: [Name] - Configure Intune and Autopilot profiles
- **Azure AD Administrator**: [Name] - Configure Azure AD settings
- **Help Desk**: [Name] - User support during testing
- **Test Users**: [Names] - Perform user-driven testing

## Reporting

Test results will be documented in the `autopilot/results/` folder, including:

1. Deployment logs
2. Screenshots of key screens
3. Metric data in CSV format
4. Written observations
5. Final recommendation report