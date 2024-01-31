# Nl3WangLab PolarConnection
Connect multiple polar devices to measure health data in a single iOS app.

## Installation
- This repository should contain all the necessary files to run the app.
- Clone the repository and open the `PolarConnection.xcodeproj` file in Xcode.
- The main problem would be with `polar-ble-sdk`, It can be fixed by installing the older version of the `polar-ble-sdk` and upgrading to the latest version.
  - [Jan 31, 2024] Tested by installing `4.0` -> upgrade to `5.0` -> upgrade to `5.5.0`.
- Navigate to PolarConnection -> Signing and Capabilities. Add your desired Apple Development Team.
- In the event of a "Failed Registering Bundle Identifier" Error, simply add '.Name' to the end of the Bundle Identifier.
- Select Product -> Run. Do this while the iPad is connected to your Mac running XCode.

---
This work is derived from [polarBleSdk_example_app](https://github.com/polarofficial/polar-ble-sdk)
