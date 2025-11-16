# Strix Point OEM Display Driver Registry Fix

This repository contains a batch script (`oem_driver_fix.bat`) that is supposed to apply several registry settings for AMD "Strix Point" display drivers, based on what Asus provides with their Strix Point 32.0.13022.3006 display driver. These settings would normally be OEM-specific optimizations that might are typically missing from a generic driver installation.

## CAUTION!

This script modifies the Windows Registry. Use it at your own risk. Incorrectly modifying the registry can cause system instability.

I'm an enthusiast at best but I don't have professional experience with AMD graphics drivers. This script targets a few configuration options (taken from OEM driver definitions), that random web searches brought up in terms of instability on Laptops. I don't guarantee that this will help you, and you should always create a Restore Point before making changes to your registry. If you are on OEM drivers, odds are those are already set to values seen below.

## What does this script do?

The script adds five specific registry keys to your display driver's profile in the Windows Registry. These keys are related exclusively to either disabling PSR functionality partially, or disabling some type of VCN timeout. The rationale is that if the OEM decided that those changes need to be made, those are somewhat likely culprits if the keys are not defined in the mainline driver.

Specifically, it sets the following `REG_DWORD` values:

- `DalDisableReplayInAC` = `2`
- `DalFeatureEnablePsrSU` = `0`
- `DalPSRAllowSMUOptimizations` = `0`
- `DalReplayAllowSMUOptimizations` = `0`
- `KMD_EnableVcnIdleTimer` = `0`

The script iterates through profiles `0000` to `0004` under your graphics card's main registry key and applies these settings to all existing profiles.

## Why would I use this?

The reason why you would ever need this is if your system is not stable with generic / mainline AMD drivers + you want or need the mainline drivers for newest features or Vulkan extensions.
You might want to use this script if you are experiencing display issues on a laptop with an AMD "Strix Point" APU (Ryzen AI 7 Pro 360/Ryzen AI 9 365/Ryzen AI 370 with Radeon 880M/Radeon 890M), such as:

- Screen flickering, especially when on battery power.
- Instability when recovering from a long idle state
- Instability when recovering from Sleep / Hibernate

## How to Use

The script requires administrator privileges and must be run with a specific command-line argument: a path to your device's video identifier key.

### 1. Find Your Video Key

1.  Press `Win + R`, type `regedit`, and press Enter.
2.  Navigate to the following path:
   `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Video\`
3.  Under the `Video` key, you will see several keys with long, GUID-like names (e.g., `{XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX}`).
4.  Click through each of these keys and look at the subkeys. In one of them, you should simultaneously several folders called `0000`, `0001`..., `0004` and a `Video` key that has a value named `DeviceDesc`. Check its data and verify that the description matches your AMD graphics card (for example, AMD Radeon(TM) 880M).
5.  Once you've found the correct one, copy the full name of its parent GUID key (the one with the curly braces `{}`).

### 2. Run the Script

1.  Open a **Command Prompt** or **PowerShell** as an **Administrator**.
2.  Navigate to the directory where you saved the `oem_driver_fix.bat` script.
   ```shell
   cd "c:\path\to\the\script"
   ```
3.  Run the script, passing the video key you copied as an argument. **Make sure to include the curly braces and enclose the key in quotes.**
   ```shell
   oem_driver_fix.bat "{XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX}"
   ```

### 3. Reboot

After the script successfully adds the keys, you **must restart your computer** for the changes to take effect.

## How to revert the changes

If you want to be dramatic restore your system from a restore point. Otherwise just reinstall the graphics drivers, or manually delete keys that weren't there previously.
