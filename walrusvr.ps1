<#PSScriptInfo

.VERSION 1.0.0

.GUID d4605a35-dc0a-437e-b118-94b423b3bf23

.AUTHOR walrusvr

.COMPANYNAME

.COPYRIGHT No rights reserved. Dedicated to the public domain under CC0 1.0 Universal.

.TAGS VR MetaQuest Quest Oculus HorizonOS VRC ADB Android QA Testing aapt2 apksigner OVRMetrics Windows

.LICENSEURI https://creativecommons.org/publicdomain/zero/1.0/

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
1.0.0 - First public release. 50 menu entries for Meta Quest VR application testing.
        Permission and feature checks match names exactly and report required and
        not-required features separately.

.PRIVATEDATA

#>

<#
.SYNOPSIS
Menu-driven ADB toolkit for Meta Quest VR application testing and Virtual Reality Check (VRC) validation.

.DESCRIPTION
walrusvr presents 50 numbered commands in a two-column menu for testing Meta Quest
applications before Meta Horizon Store submission. It covers ADB connection (USB and
wireless), installing and pulling base.apk and OBB folders, manifest and badging checks
with aapt2, APK signature verification with apksigner, categorized analysis of Android
permissions (prohibited / restricted / other) and non-VR features, OVR Metrics Tool
control, logs, screenshots and screen recording, temperature, resource profiling, Wi-Fi
toggling, low-battery simulation, and a custom command mode.

Not affiliated with, endorsed by, or sponsored by Meta Platforms, Inc.

.NOTES
Requirements:
- Windows (the script uses findstr and cmd).
- Android SDK platform-tools (adb) and build-tools (aapt2, apksigner) reachable from the
  folder the script is run in; run it from your platform-tools folder.
- A Java Development Kit for the "Verify APK signature" entry. That entry sets JAVA_HOME
  to C:\Program Files\Java\jdk-25.0.2; edit the path to match your installed JDK.
- The OVR Metrics Tool on the headset for the OVR entries. The "Install OVR Metrics Tool"
  entry expects OVRMetricsTool_v1.6.5.apk in the current folder; edit the filename if needed.
- A headset in Developer mode, connected and authorized for ADB.

Disabling Wi-Fi drops a wireless ADB session; use USB for the Wi-Fi entries.
To exit, enter the number one higher than the last menu entry (51).

.EXAMPLE
PS C:\Users\[USERNAME]\Desktop\platform-tools> .\walrusvr.ps1
Shows the menu. Enter a number to run that command.
#>

<#
CC0 1.0 Universal (public domain dedication)

To the extent possible under law, walrusvr has waived all copyright and related or
neighbouring rights to this script. You can copy, modify, distribute and use it,
even for commercial purposes, all without asking permission.

The script is provided "as is", without warranty of any kind. Use it at your own risk.

Full legal text: https://creativecommons.org/publicdomain/zero/1.0/legalcode
#>

# Set background color
$Host.UI.RawUI.BackgroundColor = "Black"

# Set text color
$Host.UI.RawUI.ForegroundColor = "Green"

# Add current directory to PATH
$env:PATH += ";$PWD"

# Define permissions and features lists
$prohibited = @(
    "ACCEPT_HANDOVER","ACCESS_BACKGROUND_LOCATION","ACCESS_CHECKIN_PROPERTIES",
    "ACCESS_COARSE_LOCATION","ACCESS_FINE_LOCATION","ACCESS_LOCATION_EXTRA_COMMANDS",
    "ACCESS_NOTIFICATION_POLICY","ACCOUNT_MANAGER","ACTIVITY_RECOGNITION",
    "ADD_VOICEMAIL","ANSWER_PHONE_CALLS","BIND_ACCESSIBILITY_SERVICE",
    "BIND_APPWIDGET","BIND_AUTOFILL_SERVICE","BIND_CALL_REDIRECTION_SERVICE",
    "BIND_CARRIER_MESSAGING_CLIENT_SERVICE","BIND_CARRIER_MESSAGING_SERVICE",
    "BIND_CARRIER_SERVICES","BIND_CHOOSER_TARGET_SERVICE","BIND_CONDITION_PROVIDER_SERVICE",
    "BIND_CONTROLS","BIND_DEVICE_ADMIN","BIND_DREAM_SERVICE","BIND_INCALL_SERVICE",
    "BIND_INPUT_METHOD","BIND_MIDI_DEVICE_SERVICE","BIND_NFC_SERVICE",
    "BIND_NOTIFICATION_LISTENER_SERVICE","BIND_PRINT_SERVICE","BIND_QUICK_ACCESS_WALLET_SERVICE",
    "BIND_QUICK_SETTINGS_TILE","BIND_REMOTEVIEWS","BIND_SCREENING_SERVICE",
    "BIND_TELECOM_CONNECTION_SERVICE","BIND_TEXT_SERVICE","BIND_TV_INPUT",
    "BIND_VISUAL_VOICEMAIL_SERVICE","BIND_VOICE_INTERACTION","BIND_VR_LISTENER_SERVICE",
    "BIND_WALLPAPER","BLUETOOTH_PRIVILEGED","BODY_SENSORS","BROADCAST_PACKAGE_REMOVED",
    "BROADCAST_SMS","BROADCAST_WAP_PUSH","CALL_PHONE","CALL_PRIVILEGED",
    "CAMERA","CAPTURE_AUDIO_OUTPUT","CHANGE_COMPONENT_ENABLED_STATE",
    "CHANGE_CONFIGURATION","CLEAR_APP_CACHE","CONTROL_LOCATION_UPDATES",
    "DELETE_CACHE_FILES","DELETE_PACKAGES","DIAGNOSTIC","DUMP","FACTORY_TEST",
    "GET_ACCOUNTS","GET_ACCOUNTS_PRIVILEGED","INSTALL_LOCATION_PROVIDER",
    "INSTALL_PACKAGES","INSTANT_APP_FOREGROUND_SERVICE","LOADER_USAGE_STATS",
    "LOCATION_HARDWARE","MANAGE_DOCUMENTS","MANAGE_MEDIA","MANAGE_ONGOING_CALLS",
    "MASTER_CLEAR","MEDIA_CONTENT_CONTROL","MODIFY_PHONE_STATE","MOUNT_FORMAT_FILESYSTEMS",
    "MOUNT_UNMOUNT_FILESYSTEMS","PACKAGE_USAGE_STATS","PROCESS_OUTGOING_CALLS",
    "READ_CALENDAR","READ_CALL_LOG","READ_CONTACTS","READ_INPUT_STATE",
    "READ_LOGS","READ_PHONE_NUMBERS","READ_PHONE_STATE","READ_PRECISE_PHONE_STATE",
    "READ_SMS","READ_VOICEMAIL","REBOOT","RECEIVE_MMS","RECEIVE_SMS","RECEIVE_WAP_PUSH",
    "REQUEST_DELETE_PACKAGES","REQUEST_INSTALL_PACKAGES","SEND_RESPOND_VIA_MESSAGE",
    "SEND_SMS","SET_ALWAYS_FINISH","SET_ANIMATION_SCALE","SET_DEBUG_APP",
    "SET_PROCESS_LIMIT","SET_TIME","SET_TIME_ZONE","SIGNAL_PERSISTENT_PROCESSES",
    "SMS_FINANCIAL_TRANSACTIONS","START_FOREGROUND_SERVICES_FROM_BACKGROUND",
    "START_VIEW_PERMISSION_USAGE","STATUS_BAR","SYSTEM_ALERT_WINDOW","UNINSTALL_SHORTCUT",
    "UPDATE_DEVICE_STATS","USE_ICC_AUTH_WITH_DEVICE_IDENTIFIER","USE_SIP","WRITE_APN_SETTINGS",
    "WRITE_CALENDAR","WRITE_CALL_LOG","WRITE_CONTACTS","WRITE_GSERVICES",
    "WRITE_SECURE_SETTINGS","WRITE_SETTINGS","WRITE_VOICEMAIL" )

$restricted = @(
    "ACCESS_MEDIA_LOCATION","READ_EXTERNAL_STORAGE","BATTERY_STATS","BLUETOOTH_CONNECT",
    "BLUETOOTH_SCAN","BLUETOOTH_ADMIN","CHANGE_WIFI_STATE","FOREGROUND_SERVICE",
    "KILL_BACKGROUND_PROCESSES","MANAGE_EXTERNAL_STORAGE","MODIFY_AUDIO_SETTINGS",
    "QUERY_ALL_PACKAGES","RECORD_AUDIO","RECEIVE_BOOT_COMPLETED","SCHEDULE_EXACT_ALARM",
    "SET_ALARM","WAKE_LOCK","WRITE_EXTERNAL_STORAGE" )

$nonVR = @(
"android.hardware.telephony",
"android.hardware.camera.flash",
"android.hardware.nfc",
"android.hardware.location.gps",
"android.hardware.screen.portrait",
"android.hardware.screen.landscape",
"android.hardware.fingerprint",
"android.hardware.telephony.gsm",
"android.hardware.touchscreen",
"android.hardware.sensor.barometer",
"android.hardware.sensor.compass",
"android.hardware.sensor.stepcounter",
"android.hardware.sensor.stepdetector",
"android.hardware.usb.host",
"android.hardware.usb.accessory",
"android.hardware.biometrics.iris",
"android.hardware.biometrics.face",
"android.hardware.location",
"android.hardware.location.network",
"android.hardware.wifi.direct",
"android.software.midi",
"android.software.print",
"android.software.leanback",
"android.hardware.type.automotive",
"android.hardware.camera",
"android.hardware.camera.front",
"android.hardware.camera.any",
"android.hardware.camera.autofocus",
"android.hardware.consumerir",
"android.hardware.sensor.proximity",
"android.hardware.type.television",
"android.software.live_tv",
"android.hardware.type.watch",
"android.hardware.type.pc",
"android.hardware.keyboard",
"android.hardware.hardware_keystore",
"android.hardware.sensor.heartrate",
"android.hardware.sensor.heartrate.ecg",
"android.hardware.bluetooth_le",
"android.hardware.ethernet",
"android.software.secure_lock_screen",
"android.software.device_admin" )

# Define commands and their descriptions
$adbCommands = @(

@{ "Description" = "List all connected devices"; "Command" = "adb devices" }

@{ "Description" = "Get device IP address"; "Command" = "adb shell ip route | Select-String -Pattern 'src ([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})' | ForEach-Object { `$_.Matches.Groups[1].Value }" }

@{ "Description" = "Connect headset to wireless"; "Command" = "adb tcpip 5555; Start-Sleep -s 3; `$ips = @(adb shell ip route | Select-String -Pattern 'src ([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})' | ForEach-Object { `$_.Matches.Groups[1].Value }); Write-Output `$ips; if (`$ips.Count -gt 0) { adb connect ('{0}:5555' -f `$ips[0].Trim()) } else { Write-Output 'Could not determine device IP address.' }" }

@{ "Description" = "Disconnect headset from wireless"; "Command" = "adb tcpip 5555; Start-Sleep -s 3; `$ips = @(adb shell ip route | Select-String -Pattern 'src ([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})' | ForEach-Object { `$_.Matches.Groups[1].Value }); Write-Output `$ips; if (`$ips.Count -gt 0) { adb disconnect ('{0}:5555' -f `$ips[0].Trim()) } else { Write-Output 'Could not determine device IP address.' }" }

@{ "Description" = "Install base.apk"; "Command" = "adb install base.apk" }

@{ "Description" = "List all third party packages"; "Command" = "adb shell cmd package list packages -3" }

@{ "Description" = "Get app version number"; "Command" = "`$packageName = Read-Host 'Enter package name'; (adb shell dumpsys package `$packageName | findstr versionCode) -replace '.*versionCode=([0-9]+).*', '`$1'" }

@{ "Description" = "Find package path"; "Command" = "`$packageName = Read-Host 'Enter package name'; adb shell pm path `$packageName" }

@{ "Description" = "base.apk file size check"; "Command" = "`$packageName = Read-Host 'Enter package name'; `$packagePath = (adb shell pm path `$packageName).Trim().Replace('package:', ''); `$output = adb shell du -m `$packagePath; `$output | ForEach-Object { `$_ -replace '`t', ' ' } | ForEach-Object { `$(`$_ -split ' ')[0] + ' MB ' + `$(`$_ -split ' ')[1] }" }

@{ "Description" = "Pull base.apk"; "Command" = "`$packageName = Read-Host 'Enter package name'; `$packagePath = (adb shell pm path `$packageName).Trim().Replace('package:', ''); adb pull `$packagePath" }

@{ "Description" = "Uninstall program"; "Command" = "`$packageName = Read-Host 'Enter package name'; adb uninstall `$packageName" }

@{ "Description" = "List OBB folders"; "Command" = "adb shell ls /storage/emulated/0/Android/obb/" }

@{ "Description" = "List OBB file sizes"; "Command" = "`$obbFolder = Read-Host 'Enter OBB folder name'; adb shell du -m /storage/emulated/0/Android/obb/`$obbFolder/* | ForEach-Object { `$_ -replace '`t', ' ' } | ForEach-Object { `$(`$_ -split ' ')[0] + ' MB ' + `$(`$_ -split ' ')[1] }" }

@{ "Description" = "Pull OBB folder"; "Command" = "`$obbFolder = Read-Host 'Enter OBB folder name'; adb pull /storage/emulated/0/Android/obb/`$obbFolder" }

@{ "Description" = "Push OBB folder"; "Command" = "`$obbFolder = Read-Host 'Enter OBB folder name'; adb shell mkdir -p /storage/emulated/0/Android/obb/`$obbFolder; adb push `$obbFolder/. /storage/emulated/0/Android/obb/`$obbFolder/" }

@{ "Description" = "Take screenshot"; "Command" = "adb shell screencap -p /sdcard/screenshot.png; adb pull /sdcard/screenshot.png" }

@{ "Description" = "Start screen recording"; "Command" = "Start-Job -ScriptBlock { adb shell screenrecord /sdcard/video.mp4 }" }

@{ "Description" = "Stop screen recording & pull video"; "Command" = "adb shell pkill -2 screenrecord; sleep 3; adb pull /sdcard/video.mp4" }

@{ "Description" = "Clear log"; "Command" = "adb logcat -c" }

@{ "Description" = "Pull log"; "Command" = "adb shell setprop log.tag.Unity DEBUG; adb logcat -d > log.txt" }

@{ "Description" = "Pull Android Manifest"; "Command" = "aapt2 dump xmltree base.apk --file AndroidManifest.xml > AndroidManifest.txt" }

@{ "Description" = "Get package name"; "Command" = "`$output = (aapt2 dump badging base.apk | Select-String 'package: name=').Line.Split('''')[1]; if (`$output) { `$output } else { 'not applicable' }" }

@{ "Description" = "Get install location"; "Command" = "`$output = (aapt2 dump badging base.apk | Select-String 'install-location'); if (`$output) { `$output.Line } else { 'not applicable' }" }

@{ "Description" = "Check android.hardware.vr.headtracking"; "Command" = "`$output = (aapt2 dump badging base.apk | Select-String 'android.hardware.vr.headtracking'); if (`$output) { `$output.Line } else { 'not applicable' }" }

@{ "Description" = "Check Min and Target SDK versions"; "Command" = "`$output = aapt2 dump badging base.apk | Where-Object { `$_ -match 'sdkVersion:' -or `$_ -match 'targetSdkVersion:' }; if (`$output) { `$output -join ""`n"" } else { 'not applicable' }" }

@{ "Description" = "64-bit binary check"; "Command" = "`$output = (aapt2 dump badging base.apk | Select-String 'native-code'); if (`$output) { `$output.Line } else { 'not applicable' }" }

@{ "Description" = "Check debuggable status"; "Command" = "`$output = (aapt2 dump badging base.apk | Select-String 'android:debuggable', 'application-debuggable'); if (`$output) { `$output.Line } else { 'not applicable' }" }

@{ "Description" = "Verify APK signature"; "Command" = "`$env:JAVA_HOME = 'C:\Program Files\Java\jdk-25.0.2'; `$env:Path += ';C:\Program Files\Java\jdk-25.0.2\bin'; `$env:JDK_JAVA_OPTIONS = '--enable-native-access=ALL-UNNAMED'; apksigner verify --verbose base.apk" }

@{ "Description" = "List all permissions used (categorized)"
        "Command" = {
            # Includes uses-permission-sdk-23 entries. Each permission is matched on its exact
            # short name (the part after the last dot), so names that merely contain a listed
            # name - for example horizonos.permission.HEADSET_CAMERA or EXPAND_STATUS_BAR -
            # are not misreported as prohibited.
            $output = aapt2 dump permissions base.apk | Where-Object { $_ -match "^\s*uses-permission(-sdk-23)?: name='" } | ForEach-Object { $_.Split("'")[1] } | Sort-Object -Unique
            if ($output) {
                $prohibitedMatches = @(); $restrictedMatches = @(); $otherMatches = @()
                foreach ($permission in $output) {
                    $shortName = $permission.Split('.')[-1]
                    if ($prohibited -contains $shortName) { $prohibitedMatches += $permission }
                    elseif ($restricted -contains $shortName) { $restrictedMatches += $permission }
                    else { $otherMatches += $permission }
                }

                Write-Host "Prohibited: $($prohibitedMatches -join "`n")"
                Write-Host "Restricted: $($restrictedMatches -join "`n")"
                Write-Host "Other: $($otherMatches -join "`n")"
            } else {
                Write-Host "No permissions found." } } }

@{ "Description" = "List all features used (categorized)"
        "Command" = {
            # Reports required and not-required features separately. A feature counts as non-VR
            # when it equals a listed name or is a sub-feature of one (for example
            # android.hardware.touchscreen.multitouch), never on a partial-text match.
            # Features the build tools add automatically are marked (implied).
            $lines = aapt2 dump badging base.apk
            $required    = @($lines | Where-Object { $_ -match "^\s*uses-feature: name='" }              | ForEach-Object { $_.Split("'")[1] } | Sort-Object -Unique)
            $notRequired = @($lines | Where-Object { $_ -match "^\s*uses-feature-not-required: name='" } | ForEach-Object { $_.Split("'")[1] } | Sort-Object -Unique)
            $implied     = @($lines | Where-Object { $_ -match "^\s*uses-implied-feature: name='" }      | ForEach-Object { $_.Split("'")[1] })
            $isNonVR = { param ($feature) foreach ($name in $nonVR) { if ($feature -eq $name -or $feature.StartsWith("$name.")) { return $true } }; return $false }
            $label   = { param ($feature) if ($implied -contains $feature) { "$feature (implied)" } else { $feature } }

            if ($required.Count -gt 0 -or $notRequired.Count -gt 0) {
                $nonVRRequired    = $required    | Where-Object { & $isNonVR $_ }       | ForEach-Object { & $label $_ }
                $nonVRNotRequired = $notRequired | Where-Object { & $isNonVR $_ }       | ForEach-Object { & $label $_ }
                $otherRequired    = $required    | Where-Object { -not (& $isNonVR $_) } | ForEach-Object { & $label $_ }
                $otherNotRequired = $notRequired | Where-Object { -not (& $isNonVR $_) } | ForEach-Object { & $label $_ }

                Write-Host "Non-VR features (required): $($nonVRRequired -join "`n")"
                Write-Host "Non-VR features (not required): $($nonVRNotRequired -join "`n")"
                Write-Host "Other features (required): $($otherRequired -join "`n")"
                Write-Host "Other features (not required): $($otherNotRequired -join "`n")"
            } else {
                Write-Host "No features found." } } }

@{ "Description" = "Install OVR Metrics Tool"; "Command" = "adb install OVRMetricsTool_v1.6.5.apk" }

@{ "Description" = "Open OVR"; "Command" = "adb shell am start omms://app" }

@{ "Description" = "Start recording OVR metrics to CSV file"; "Command" = "adb shell am broadcast -n com.oculus.ovrmonitormetricsservice/.SettingsBroadcastReceiver -a com.oculus.ovrmonitormetricsservice.ENABLE_CSV" }

@{ "Description" = "Enable OVR overlay"; "Command" = "adb shell am broadcast -n com.oculus.ovrmonitormetricsservice/.SettingsBroadcastReceiver -a com.oculus.ovrmonitormetricsservice.ENABLE_OVERLAY" }

@{ "Description" = "Disable OVR overlay"; "Command" = "adb shell am broadcast -n com.oculus.ovrmonitormetricsservice/.SettingsBroadcastReceiver -a com.oculus.ovrmonitormetricsservice.DISABLE_OVERLAY" }

@{ "Description" = "Enable OVR Render Scale graph"; "Command" = "adb shell am broadcast -n com.oculus.ovrmonitormetricsservice/.SettingsBroadcastReceiver -a com.oculus.ovrmonitormetricsservice.ENABLE_GRAPH --es stat render_scale" }

@{ "Description" = "Disable OVR Render Scale graph"; "Command" = "adb shell am broadcast -n com.oculus.ovrmonitormetricsservice/.SettingsBroadcastReceiver -a com.oculus.ovrmonitormetricsservice.DISABLE_GRAPH --es stat render_scale" }

@{ "Description" = "Enable OVR Application SpaceWarp graph"; "Command" = "adb shell am broadcast -n com.oculus.ovrmonitormetricsservice/.SettingsBroadcastReceiver -a com.oculus.ovrmonitormetricsservice.ENABLE_GRAPH --es stat spacewarped_frames_per_second" }

@{ "Description" = "Disable OVR Application SpaceWarp graph"; "Command" = "adb shell am broadcast -n com.oculus.ovrmonitormetricsservice/.SettingsBroadcastReceiver -a com.oculus.ovrmonitormetricsservice.DISABLE_GRAPH --es stat spacewarped_frames_per_second" }

@{ "Description" = "Pull OVR performance logs"; "Command" = "adb pull sdcard/Android/data/com.oculus.ovrmonitormetricsservice/files/CapturedMetrics" }

@{ "Description" = "Pull Performance overview";
    "Command" = "`$packageName = Read-Host 'Enter package name'; `$output = adb shell `"dumpsys cpuinfo | grep `$packageName; dumpsys meminfo `$packageName; dumpsys gfxinfo `$packageName framestats; dumpsys netstats | grep `$packageName; dumpsys batterystats | grep `$packageName; dumpsys SurfaceFlinger | grep `$packageName; dumpsys activity `$packageName`" | Set-Content performance_metrics.txt" }

@{ "Description" = "Find the Oculus VR Shell version"; "Command" = "`$output = (adb shell dumpsys package com.oculus.vrshell | Select-String 'versionCode'); if (`$output) { `$output.Line } else { 'not applicable' }" }

@{ "Description" = "Get device serial number"; "Command" = "adb shell getprop ro.serialno" }

@{ "Description" = "Reboot device"; "Command" = "adb reboot" }

@{ "Description" = "Enable WiFi on device"; "Command" = "adb shell svc wifi enable" }

@{ "Description" = "Disable WiFi on device"; "Command" = "adb shell svc wifi disable" }

@{ "Description" = "Get headset temperature"; "Command" = "`$t = (adb shell dumpsys battery | findstr temperature | Select-Object -First 1) -replace '[^\d]', ''; if ([string]::IsNullOrWhiteSpace(`$t)) { Write-Output 'Temperature not found' } else { ([math]::Floor([int]`$t / 10)).ToString() + '.' + ([int]`$t % 10) + ' C' }" }

@{ "Description" = "Low battery state simulation"; "Command" = "adb shell dumpsys battery set ac 0; adb shell dumpsys battery set usb 0; adb shell dumpsys battery set wireless 0; adb shell dumpsys battery set level 1; adb shell dumpsys battery unplug" }

@{ "Description" = "Turn off low battery state simulation"; "Command" = "adb shell dumpsys battery reset; adb shell settings put global low_power 0" }

@{ "Description" = "Custom command mode"; "Command" = "while (`$true) { `$command = Read-Host 'Enter custom command (or press Enter to exit)'; if (`$command -eq '') { Write-Host 'Exiting custom command mode.'; break }; `$output = cmd /c `$command 2>&1; `$output }" }

)

# Show menu
function Show-Menu {
    Clear-Host
    Write-Host "walrusvr"
    Write-Host "-------------------"
    $half = [math]::Floor($adbCommands.Count / 2)
    for ($i = 0; $i -lt $half; $i++) {
        Write-Host "$($i + 1). $($adbCommands[$i].Description)" -NoNewline
        Write-Host (" " * (40 - $adbCommands[$i].Description.Length)) -NoNewline
        if ($i + $half -lt $adbCommands.Count) {
            Write-Host "$($i + $half + 1). $($adbCommands[$i + $half].Description)"
        } else {
            Write-Host ""
        }
    }
    if ($adbCommands.Count % 2 -eq 1) {
        Write-Host "$($adbCommands.Count). $($adbCommands[-1].Description)"
    }
    $choice = Read-Host "Enter your choice"
    return $choice
}

function Run-ADBCommand {
    param ($index)
    $command = $adbCommands[$index].Command
    if ($command -is [scriptblock]) {
        if ($adbCommands[$index].Params) {
            $params = @{}
            foreach ($paramName in $adbCommands[$index].Params) {
                $paramValue = Read-Host "Enter $paramName"
                $params[$paramName] = $paramValue
            }
            & $command @params
        } else {
            & $command
        }
    } else {
        if ($adbCommands[$index].Params) {
            $params = @()
            foreach ($paramName in $adbCommands[$index].Params) {
                $paramValue = Read-Host "Enter $paramName"
                $params += $paramValue
            }
            Invoke-Expression "$command $($params -join ' ')"
        } else {
            Invoke-Expression $command
        }
    }
    Write-Host "Command executed."
    Read-Host "Press Enter to continue..."
}

# Main loop
while ($true) {
    $choice = Show-Menu
    if ($choice -eq ($adbCommands.Count + 1).ToString()) {
        exit
    } elseif ($choice -match '^\d+$' -and [int]$choice -ge 1 -and [int]$choice -le $adbCommands.Count) {
        Run-ADBCommand -index ([int]$choice - 1)
    } else {
        Write-Host "Invalid choice. Please try again."
        Start-Sleep -s 2
    }
}
