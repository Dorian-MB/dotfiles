# Windows preferences, counterpart of macos/defaults.sh. Idempotent, current user only (no admin).
#   powershell -ExecutionPolicy Bypass -File defaults.ps1          apply
#   powershell -ExecutionPolicy Bypass -File defaults.ps1 -Undo    back to the Windows defaults
# From WSL: powershell.exe -ExecutionPolicy Bypass -File "$(wslpath -w ~/dotfiles/windows/defaults.ps1)"
# Keyboard settings take effect after logging out.
param([switch]$Undo)

# path  name  type  value  windows-default
$settings = @(
    # Fast key repeat. The normal sliders stop at ~250 ms / ~33 ms; Filter Keys go lower,
    # same as macOS InitialKeyRepeat 15 (225 ms) and KeyRepeat 1 (15 ms).
    @('HKCU:\Control Panel\Keyboard', 'KeyboardDelay', 'String', '0', '1'),
    @('HKCU:\Control Panel\Keyboard', 'KeyboardSpeed', 'String', '31', '31'),
    @('HKCU:\Control Panel\Accessibility\Keyboard Response', 'AutoRepeatDelay', 'String', '225', '1000'),
    @('HKCU:\Control Panel\Accessibility\Keyboard Response', 'AutoRepeatRate', 'String', '15', '500'),
    # Must stay 0, otherwise a key has to be held before it registers.
    @('HKCU:\Control Panel\Accessibility\Keyboard Response', 'DelayBeforeAcceptance', 'String', '0', '1000'),
    @('HKCU:\Control Panel\Accessibility\Keyboard Response', 'BounceTime', 'String', '0', '0'),
    # 3 = on + available, without the hold-right-Shift-8s hotkey that toggles it.
    @('HKCU:\Control Panel\Accessibility\Keyboard Response', 'Flags', 'String', '3', '126'),
    # Explorer, like the Finder settings: hidden files, extensions, full path in the title.
    @('HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'Hidden', 'DWord', 1, 2),
    @('HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'HideFileExt', 'DWord', 0, 1),
    @('HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState', 'FullPath', 'DWord', 1, 0)
)

foreach ($s in $settings) {
    $path, $name, $type, $value, $default = $s
    if ($Undo) { $value = $default; $verb = 'reset ' } else { $verb = 'set   ' }
    if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
    Set-ItemProperty -Path $path -Name $name -Type $type -Value $value
    Write-Output "$verb $name = $value"
}

Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue  # restarts by itself
Write-Output 'done; log out and back in for the keyboard settings'
