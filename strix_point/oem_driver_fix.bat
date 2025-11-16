@echo off
SETLOCAL EnableDelayedExpansion

SET VIDEO_KEY=%~1
ECHO Video key: %1
ECHO This script tries to add 5 registry keys that are included in the Asus Strix Point driver profile to your registry.
ECHO It tries to run over several display profiles 0000 to 0004 and is supposed to skip missing profiles.
ECHO It also requires admin privileges, since we're editing registry and stuff
ECHO.

net session >nul 2>&1
IF %errorlevel% NEQ 0 (
    ECHO Error: This script needs to be ran with admin privileges.
    ECHO.
    PAUSE
    EXIT /B
) ELSE (
	ECHO Running as admin
	ECHO.
	)

IF "%1"=="" (
    ECHO Error: You must provide the video key name as an argument.
    ECHO It should be the key name from HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Video\ 
	ECHO under which you have a key that contains DeviceDesc matching your device
    ECHO Example: %~n0 "{XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX}"
    ECHO.
    PAUSE
    EXIT /B
) 

SET "SuccessFlag=0"

:: The specific path probably varies based on driver version and/or machine so it has to be parametrized
SET "BasePath=HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Video\%VIDEO_KEY%"

:: I'm not super sure how profiles work but it might be something like 1 for each display ever connected?
FOR %%i IN (0000, 0001, 0002, 0003, 0004) DO (
    SET "CurrentPath=%BasePath%\%%i"
    ECHO === Check if path exists: %%i ===
    
    REG QUERY "!CurrentPath!" >nul 2>&1
    
    IF !ERRORLEVEL! EQU 0 (
        ECHO Path "%%i" exists. Adding OEM config keys...
        REG ADD "!CurrentPath!" /v DalDisableReplayInAC /t REG_DWORD /d 2 /f
        REG ADD "!CurrentPath!" /v DalFeatureEnablePsrSU /t REG_DWORD /d 0 /f
        REG ADD "!CurrentPath!" /v DalPSRAllowSMUOptimizations /t REG_DWORD /d 0 /f
        REG ADD "!CurrentPath!" /v DalReplayAllowSMUOptimizations /t REG_DWORD /d 0 /f
        REG ADD "!CurrentPath!" /v KMD_EnableVcnIdleTimer /t REG_DWORD /d 0 /f
        ECHO Finished adding keys to path "%%i" 
        SET "SuccessFlag=1"
    ) ELSE (
        ECHO Failed to find path: "%%i", Aborting
    )
    ECHO.
)

IF "!SuccessFlag!"=="1" (
    ECHO ==================================================
    ECHO Finished adding OEM config keys for Strix Point driver optimizations.
    ECHO.
    ECHO Re-start the system manually now.
    ECHO ==================================================
) ELSE (
    ECHO ==================================================
    ECHO Failure: No changes were made to the registry.
    ECHO ==================================================
)
ECHO.
PAUSE