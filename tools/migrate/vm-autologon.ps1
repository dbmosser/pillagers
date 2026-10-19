<#
vm-autologon.ps1  -  make the Pillagers VM sign itself in after a restart (Sysinternals Autologon)

*** YOU RUN THIS, INSIDE THE VM. Claude never runs it. It never sees, asks for, stores or logs your password. ***

WHY IT EXISTS
  Everything that does the work in the VM lives in YOUR signed-in Windows session: the "Pillagers runner" task, the "Pillagers dev services" task
  (the game and dev servers), headless Chrome, Git bash, the Console lanes, and the coordinator Claude Code window. After ANY restart of the VM
  (a Windows Update, a power cut, the main PC rebooting) Windows stops at the sign-in screen and waits for a password. Until someone types it,
  nothing runs: no runner, no servers, no ships. That is the opposite of "always on". Autologon makes Windows type the password for you at boot.

WHAT IT DOES (and what it never does)
  1. Looks (read only): who you are, whether automatic sign-in is already on, whether Windows has a switch ON that blocks it.
  2. If the Autologon tool is missing, it gets it - ONLY after you type YES (or pass -AcceptLicences): first from Microsoft's winget source
     (package Microsoft.Sysinternals.Autologon, version 3.10), and if winget cannot do it, straight from https://download.sysinternals.com/files/AutoLogon.zip.
     Either way the program must carry a valid Microsoft digital signature or the script refuses to open it.
  3. Opens Sysinternals Autologon in ITS OWN WINDOW (Windows asks "Do you want to allow this app to make changes?": click Yes). YOU type the password
     into Autologon's Password box and click Enable. This script only waits for that window to close. It cannot see the box.
  4. Checks the result by reading three Winlogon registry values (AutoAdminLogon, DefaultUserName, DefaultDomainName) and the NAME of one more
     (DefaultPassword must NOT exist: that would be a plain-text password). It never reads a password value.
  It never changes Windows Update, Defender, the firewall, UAC, SmartScreen, BitLocker or any other security setting. It never turns the
  "Windows Hello only" switch off for you (see BLOCKERS). It never restarts the VM. It never touches the main PC.

HOW TO RUN (inside the VM, in a NORMAL Windows PowerShell window - no administrator window is needed; Autologon asks for its own permission)
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\PillagersMove\kit\vm-autologon.ps1 -DryRun     look first: prints everything, changes nothing
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\PillagersMove\kit\vm-autologon.ps1             turn automatic sign-in ON
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\PillagersMove\kit\vm-autologon.ps1 -Status     only report where things stand
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\PillagersMove\kit\vm-autologon.ps1 -Undo        turn it OFF again (you click Disable in Autologon)
  Run it as the same Windows user the helpers run as (the user you sign in with, normally User1). The script may also sit in
  C:\claudecode\dark raiders\tools\migrate\; it does not matter where it is run from.
  -Reconfigure    open Autologon even when it is already on (use this after you CHANGE the Windows password: type the new one)
  -ResumeClaude   also put a shortcut in your Startup folder that reopens the coordinator Claude Code after each sign-in (see CLAUDE below)
  -AcceptLicences same as typing YES when it asks to download Autologon (alias: -Yes). Needed only when nobody can answer a question.
  -RemoveTool     with -Undo: also uninstall the Autologon program (only after automatic sign-in is confirmed OFF)
  -DryRun         (alias -WhatIf) prints every step it would take, and changes nothing: no download, no window, no shortcut, no log file.
  Log: C:\PillagersMove\kit\logs\vm-autologon-<time>.log   (no password is ever in it)
  Exit codes: 0 done or nothing to do, 1 something is wrong (the line above says what), 2 refused or cancelled (the main PC, or you did not type YES).
  ASCII only. Windows PowerShell 5.1.

AFTER IT SAYS DONE: TEST IT ONCE, WATCHING
  Start menu, Power, Restart. Do not type anything at the sign-in screen. The desktop should appear on its own within about 5 minutes. Wait
  about 2 minutes more, then run vm-verify.ps1: the "signs in by itself" line must be PASS, the servers must answer (the dev services task
  starts them 30 seconds after sign-in), and the runner heartbeat is fresh again within about 25 minutes (the runner task fires every 15 minutes).

BLOCKERS (things that make Windows ignore automatic sign-in; the script checks and tells you, it changes none of them)
  - Settings > Accounts > Sign-in options > "For improved security, only allow Windows Hello sign-in for Microsoft accounts on this device".
    If it is ON, switch it OFF. (Registry: HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\PasswordLess\Device, DevicePasswordLessBuildVersion
    non-zero = ON.) Also: if you sign in with a PIN or face, Autologon still needs the account PASSWORD (for a Microsoft account, its
    password, not the PIN).
  - A "legal notice" shown before sign-in (a group policy): Windows waits for a click on it, so nothing signs in. The script warns if one is set.
  - Holding the Shift key while the VM boots turns automatic sign-in off for that one boot. That is Windows' own safety door.
  - If Windows asks for a new password at sign-in ("password must be changed"), automatic sign-in stops until you do it.

WHICH OPTION IS SAFEST? (researched 2026-10-19; this is why Autologon is the choice)
  A. Autologon + the tasks that are already there  <- CHOSEN.
       The password is kept by Windows in the LSA secrets area of the registry (encrypted; the plain-text Winlogon "DefaultPassword" value does
       NOT exist), and Autologon is a Microsoft/Sysinternals tool. Weak point, said plainly: an administrator inside the VM can still decrypt it
       (Sysinternals documents this), and after it is on, the VM's sign-in screen no longer stops anyone who reaches the VM's console. The VM's console
       is reachable only through Hyper-V Manager on the main PC (an administrator of the main PC), and the VM already holds your Claude, GitHub and
       Console sign-ins in your profile, so little is added. If that is not acceptable, run -Undo and sign in by hand after every restart.
       Everything else stays exactly as vm-setup.ps1 made it: the two tasks, the real desktop, Credential Manager, the coordinator window.
  B. Edit the tasks to "Run whether user is logged on or not" (instead of Autologon).  NOT chosen.
       Task Scheduler would ALSO keep your password in the same LSA store, so nothing is gained on safety. It also moves the runner and the servers to a
       background session with no desktop: the logon trigger of the dev services task no longer fires, Chrome and Git run without your desktop session, and
       the coordinator Claude Code window (an interactive terminal program) would still not come back. The "do not store password" variant cannot
       reach the network sign-ins (GitHub through Credential Manager) at all. It is more change for less result, and I could not test headless Chrome
       or Claude under it here.
  C. Do nothing, sign in by hand after every restart.  The safest for the password, and the VM is idle until you look. Not always-on.
  D. Windows' own "sign in and finish setting up my device automatically after an update" (Sign-in options). It is a different, narrower thing: it only
       helps right after an update restart and leaves the session behind the lock screen. Do not rely on it; Autologon covers every restart.

WHAT NEEDS A SIGNED-IN INTERACTIVE DESKTOP (why a plain "service" is not enough)
  runner     the task "Pillagers runner" is an Interactive-token task (LogonType InteractiveToken) with a 15-minute timer: it starts tools\nightly.sh
             (through runner-guard.vbs) INSIDE your session. With nobody signed in the timer fires and does nothing. Once nightly.sh is running it
             keeps going if the screen locks or the Hyper-V window is closed or minimised; it stops when you SIGN OUT or the VM restarts.
  servers    the task "Pillagers dev services" has a "when this user signs in" trigger (30 s delay): no sign-in, no servers (8800/8799/8803/8820/8802).
  chrome     the headless Chrome used by cdp.ps1 / gate.ps1 shows no window but is started by the runner or a lane, so it lives in the same signed-in
             session and uses your profile. A locked screen does not stop it. No session, no Chrome.
  claude     Claude Code is a terminal program in a window of YOUR session. Its check-in timers (CronCreate) exist only while that process lives
             (they are saved with the conversation and restored by "claude --continue", for up to 7 days). It is NOT started by any task. See CLAUDE.
  Locked is fine, signed out is not. A Hyper-V window that you close, or an Enhanced Session that you disconnect from, leaves the session
  (and everything in it) running; do not choose "Sign out" in it. The VM never sleeps (vm-setup.ps1 stage perf sets sleep, display-off and
  hibernate to Never).

WHAT A WINDOWS UPDATE RESTART DOES IN THE VM, AND HOW THE LANES COME BACK  (documentation only; this script changes no Windows Update setting)
  Windows Update inside the VM can download and install by itself and then RESTART THE VM, normally outside the "active hours" Windows works
  out from how the VM is used, after a notice, and forced after a deadline. The VM's Windows is meant to match the main PC's build (guide Step 3), so
  updating it is expected from time to time. A restart ends every process in the VM at once:
     the runner (nightly.sh) and every lane job that was running; headless Chrome and the test servers; Git bash; the coordinator Claude Code window.
  The files are safe (they are on disk), and the main PC is not touched. What comes back by itself WITH Autologon, in this order:
     1. the VM boots (3-5 minutes) and signs you in with no typing;
     2. 30 s later the "Pillagers dev services" task starts the servers (vm-verify.ps1 section "servers");
     3. within 15 minutes the "Pillagers runner" task fires, runner-guard.vbs checks the marker host-stopped.txt, and starts nightly.sh. nightly.sh refuses to
        start while the old heartbeat is under 10 minutes old, so the first try may be skipped and the next one (15 minutes later) takes it: allow about 25 minutes;
     4. the runner starts the lanes again and they pick up from the job queue and the files on disk. A job that was running at the restart is lost and
        runs again. A ship that was in the middle of a push may leave the ship lock (the folder shipq.lock in the helper scratch folder) behind; it is cleared ONLY by
        tools/handoff/shipkit/clearstale.sh (a lock whose process is gone counts as stale after about 2 minutes), which the coordinator or the lane
        rules run - never delete the lock by hand. A killed git can also leave .git\index.lock; the same rule: check that no git is running, then delete only that file.
     5. the coordinator Claude Code window does NOT come back by itself (see CLAUDE). Until it does, nobody re-arms the 30-minute check-in; the runner
        and lanes keep working without it.
  WITHOUT Autologon the VM would stop at step 1 and wait for a password.
  vm-verify.ps1 shows "a restart is waiting" (WAIT) when Windows has one pending, so you can restart on your own time while you watch, instead of
  finding out at night. Windows Update is yours to manage; do not turn it off on my account.
  If the MAIN PC restarts (Windows Update there, a power cut): the VM is started by Hyper-V 60 seconds after the main PC boots (host-vm-boost.ps1 sets
  that, once), no one has to be signed in on the main PC for that, and Autologon then signs the VM in. The VM's own state (running or saved) is kept.

CLAUDE (the coordinator window) - optional: -ResumeClaude
  A restart ends the coordinator Claude Code session. To bring it back you open the desktop shortcut "Claude Code - Pillagers" (or run claude in the folder)
  and paste the message in VM-CLAUDE-FIRST-MESSAGE.md again (it is safe to repeat). With -ResumeClaude this script instead puts ONE shortcut in your
  own Startup folder:   "Pillagers Claude resume.lnk"   which, 60 seconds after sign-in, opens a PowerShell window in the Pillagers folder and runs
      claude --continue "<a short message: first read host-stopped.txt and do nothing if it is not valid; then run CronList, re-arm the check-in if missing,
                         run tools/health.sh, fix what it reports, continue>"
  so the last conversation is reopened and told to re-arm its check-in. -Undo removes that shortcut (only a shortcut made by this script).
  ONLY AFTER THE SWITCH-OVER: the script refuses to make the shortcut until host-stopped.txt is valid (the same strict check as vm-verify.ps1), and the
  message itself starts with that same check, so a restart of the VM before the main PC is stopped can never start helper lanes or a ship in the VM.
  Not verified here: whether "--continue" with a message works the same on every Claude Code version, and whether the check-in is restored by it. Test
  once while watching (restart the VM; the window should open by itself and the coordinator should say that the check-in is armed). If it does not, the
  shortcut is harmless: close the window and use the desktop shortcut and the first message instead.
#>
[CmdletBinding()]
param(
  [Alias('WhatIf')][switch]$DryRun,
  [switch]$Undo,
  [switch]$Status,
  [switch]$Reconfigure,
  [switch]$RemoveTool,
  [switch]$ResumeClaude,
  [Alias('Yes', 'AcceptLicenses')][switch]$AcceptLicences
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

# ----------------------------------------------------------------------------------------------------------------------
# constants and settings (everything the main flow reads lives in $script: so a test can set it after dot-sourcing)
# ----------------------------------------------------------------------------------------------------------------------
$script:ScriptVersion = 'vm-autologon 1.0 (2026-10-19)'
$script:HostComputer = 'JUL26'
$script:LogDir = 'C:\PillagersMove\kit\logs'
$script:ToolDir = 'C:\PillagersMove\tools\autologon'
$script:WingetId = 'Microsoft.Sysinternals.Autologon'
$script:ZipUrl = 'https://download.sysinternals.com/files/AutoLogon.zip'
$script:ZipSha256 = '9a477624ea6488acfbd2cefcc392fac082383a3a8db1c6d867af1b410f4731b7'   # the hash winget's manifest lists for that file (shown for comparison only)
$script:LicenceUrl = 'https://learn.microsoft.com/en-us/sysinternals/license-terms'
$script:ShortcutName = 'Pillagers Claude resume.lnk'
$script:ShortcutDesc = 'PILLAGERS: reopens the coordinator Claude Code after each sign-in (made by vm-autologon.ps1 -ResumeClaude)'
$script:MirrorCoord = 'C:\Users\User1\Desktop\dark raiders'
$script:RepoRoot = 'C:\claudecode\dark raiders'
$script:Kit = 'C:\PillagersMove\kit'
# The prompt starts with the same gate as section 0 of VM-CLAUDE-FIRST-MESSAGE.md, so a resumed conversation can never start lanes or ship while the main PC may still be running Pillagers.
# It must contain no quote characters of any kind (Get-ResumeShortcutArgs puts it between single quotes inside a double-quoted command).
$script:ResumePrompt = 'The VM restarted. First read C:\PillagersMove\kit\host-stopped.txt. If it is missing, or its status line is not exactly stopped, or it names this computer, change nothing, start nothing (no runner, no helper, no lane, no ship) and tell me. Only if it is valid: run CronList and re-arm the check-in if it is missing, run bash tools/health.sh, fix what it reports, then continue the top job. End with Next.'
$script:ResumeDelaySec = 60
$script:DryRun = [bool]$DryRun
$script:Undo = [bool]$Undo
$script:Status = [bool]$Status
$script:Reconfigure = [bool]$Reconfigure
$script:RemoveTool = [bool]$RemoveTool
$script:ResumeClaude = [bool]$ResumeClaude
$script:AcceptLicences = [bool]$AcceptLicences
$script:Log = ''
$script:RC = 0

# ----------------------------------------------------------------------------------------------------------------------
# output and log (plain words; every line is also written to the log, never a password)
# ----------------------------------------------------------------------------------------------------------------------
function Clean-Ascii([string]$s) {
  if ($null -eq $s) { return '' }
  return [System.Text.RegularExpressions.Regex]::Replace($s, '[^\x20-\x7E]', '?')
}
function Start-Log {
  # no log (and no folder) on a dry run, or if this is run on the main PC by mistake
  if ($script:DryRun -or ([string]$env:COMPUTERNAME -ieq $script:HostComputer)) { $script:Log = ''; return }
  try {
    if (-not (Test-Path -LiteralPath $script:LogDir)) { New-Item -ItemType Directory -Force -Path $script:LogDir -ErrorAction Stop | Out-Null }
    $script:Log = Join-Path $script:LogDir ('vm-autologon-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '.log')
    [System.IO.File]::WriteAllText($script:Log, ('# ' + $script:ScriptVersion + ' started ' + (Get-Date -Format 's') + ' on ' + $env:COMPUTERNAME + ' as ' + $env:USERNAME + "`r`n"), [System.Text.Encoding]::ASCII)
  } catch { $script:Log = '' }
}
function Say([string]$Text, [string]$Color = '') {
  $t = Clean-Ascii $Text
  if ($Color) { Write-Host $t -ForegroundColor $Color } else { Write-Host $t }
  if ($script:Log) { try { [System.IO.File]::AppendAllText($script:Log, $t + "`r`n", [System.Text.Encoding]::ASCII) } catch { } }
}
function Ok([string]$t)   { Say ('OK    ' + $t) 'Green' }
function Info([string]$t) { Say ('      ' + $t) }
function Warn([string]$t) { Say ('WARN  ' + $t) 'Yellow' }
function Bad([string]$t)  { Say ('FAIL  ' + $t) 'Red' }
function Dry([string]$t)  { Say ('DRY   would ' + $t) 'Magenta' }
function Step([string]$t) { Say ''; Say ('== ' + $t) 'Cyan' }

# ----------------------------------------------------------------------------------------------------------------------
# small wrappers (a test replaces these)
# ----------------------------------------------------------------------------------------------------------------------
function Read-Answer([string]$Prompt) {
  # nobody to answer (input redirected, e.g. run from a task or a pipe): no answer, so nothing is downloaded
  try { if ([Console]::IsInputRedirected) { return $null } } catch { }
  try { return [string](Read-Host $Prompt) } catch { return $null }
}
function Test-IsAdmin {
  try {
    $p = New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())
    return $p.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
  } catch { return $false }
}
function Get-VmModel {
  try { return [string](Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction Stop).Model } catch { return '' }
}
function Get-AccountKind {
  # 'Local', 'MicrosoftAccount', 'Domain' or '' (unknown)
  $dom = [string]$env:USERDOMAIN
  if ($dom -and ($dom -ine [string]$env:COMPUTERNAME)) { return 'Domain' }
  try { return [string](Get-LocalUser -Name $env:USERNAME -ErrorAction Stop).PrincipalSource } catch { return '' }
}

# ----------------------------------------------------------------------------------------------------------------------
# what Windows says right now (read only; a password VALUE is never read - only whether a plain "DefaultPassword" value exists)
# ----------------------------------------------------------------------------------------------------------------------
function Get-WinlogonFacts {
  $o = [pscustomobject]@{ AutoAdminLogon = ''; DefaultUserName = ''; DefaultDomainName = ''; HasPlainPassword = $false; HelloBuild = $null; LegalNotice = $false }
  $k = $null
  try {
    $k = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey('SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon')
    if ($null -ne $k) {
      $o.AutoAdminLogon = [string]$k.GetValue('AutoAdminLogon')
      $o.DefaultUserName = [string]$k.GetValue('DefaultUserName')
      $o.DefaultDomainName = [string]$k.GetValue('DefaultDomainName')
      $o.HasPlainPassword = (@($k.GetValueNames()) -contains 'DefaultPassword')   # the NAME only; the value is never fetched
    }
  } catch { } finally { if ($null -ne $k) { try { $k.Close() } catch { } } }
  $h = $null
  try {
    $h = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey('SOFTWARE\Microsoft\Windows NT\CurrentVersion\PasswordLess\Device')
    if ($null -ne $h) { $o.HelloBuild = $h.GetValue('DevicePasswordLessBuildVersion') }
  } catch { } finally { if ($null -ne $h) { try { $h.Close() } catch { } } }
  $p = $null
  try {
    $p = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System')
    if ($null -ne $p) {
      if ([string]$p.GetValue('legalnoticecaption') -or [string]$p.GetValue('legalnoticetext')) { $o.LegalNotice = $true }
    }
  } catch { } finally { if ($null -ne $p) { try { $p.Close() } catch { } } }
  return $o
}

# pure: 'plain' (a plain-text password value exists), 'on' (for this user), 'other' (on, but for someone else), 'off'
function Get-AutoLogonState($Facts, [string]$User) {
  if ([bool]$Facts.HasPlainPassword) { return 'plain' }
  if ([string]$Facts.AutoAdminLogon -eq '1') {
    $n = ([string]$Facts.DefaultUserName) -replace '^.*\\', ''
    if ($n -ieq $User) { return 'on' }
    return 'other'
  }
  return 'off'
}

# pure: the things that make Windows ignore automatic sign-in. Each is @{ Key; Text; Fix }
function Get-Blockers($Facts) {
  $out = New-Object System.Collections.ArrayList
  if ($null -ne $Facts.HelloBuild) {
    $hb = 0
    if ([int]::TryParse([string]$Facts.HelloBuild, [ref]$hb) -and $hb -ne 0) {
      [void]$out.Add(@{ Key = 'hello'
        Text = 'Windows has "only allow Windows Hello sign-in for Microsoft accounts" switched ON; while it is on, Windows ignores automatic sign-in'
        Fix = 'Settings > Accounts > Sign-in options > switch OFF "For improved security, only allow Windows Hello sign-in for Microsoft accounts on this device". This script does not change it. Then restart the VM once.' })
    }
  }
  if ([bool]$Facts.LegalNotice) {
    [void]$out.Add(@{ Key = 'legal'
      Text = 'a sign-in "legal notice" is set (a policy); Windows shows it before sign-in and waits for a click, so nothing signs in by itself'
      Fix = 'Remove the legal notice policy (Local Security Policy > Local Policies > Security Options > "Interactive logon: Message text/title for users attempting to log on"). This script does not change it.' })
  }
  return $out.ToArray()   # callers wrap the call in @( ) so zero, one or many all count right
}

# ----------------------------------------------------------------------------------------------------------------------
# the Autologon program: find it, check its signature, get it, open it
# ----------------------------------------------------------------------------------------------------------------------
function Get-AutologonExeNames {
  $a = [string]$env:PROCESSOR_ARCHITECTURE
  if ($env:PROCESSOR_ARCHITEW6432) { $a = [string]$env:PROCESSOR_ARCHITEW6432 }
  if ($a -ieq 'ARM64') { return @('Autologon64a.exe', 'Autologon.exe') }
  if ($a -ieq 'AMD64') { return @('Autologon64.exe', 'Autologon.exe') }
  return @('Autologon.exe')
}
function Find-AutologonExe {
  $names = @(Get-AutologonExeNames)
  $dirs = New-Object System.Collections.ArrayList
  [void]$dirs.Add($script:ToolDir)
  if ($env:LOCALAPPDATA) {
    try {
      $pk = Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Packages'
      if (Test-Path -LiteralPath $pk) {
        foreach ($d in @(Get-ChildItem -LiteralPath $pk -Directory -Filter 'Microsoft.Sysinternals.Autologon_*' -ErrorAction SilentlyContinue)) { [void]$dirs.Add($d.FullName) }
      }
    } catch { }
    [void]$dirs.Add((Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Links'))
  }
  if ($env:ProgramFiles) { [void]$dirs.Add((Join-Path $env:ProgramFiles 'Sysinternals')) }
  [void]$dirs.Add('C:\Sysinternals')
  foreach ($d in $dirs) {
    foreach ($n in $names) {
      $p = Join-Path $d $n
      if (Test-Path -LiteralPath $p -PathType Leaf) { return $p }
    }
  }
  foreach ($n in $names) {
    try { $c = Get-Command $n -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1; if ($c -and $c.Source) { return [string]$c.Source } } catch { }
  }
  return ''
}
function Test-MicrosoftSigned([string]$Path) {
  # the password is typed into this program, so it must be signed by Microsoft. Returns Ok and Why.
  $r = [pscustomobject]@{ Ok = $false; Why = '' }
  try {
    $s = Get-AuthenticodeSignature -LiteralPath $Path -ErrorAction Stop
    if ([string]$s.Status -ne 'Valid') { $r.Why = 'its digital signature is "' + [string]$s.Status + '"'; return $r }
    $subj = ''
    if ($s.SignerCertificate) { $subj = [string]$s.SignerCertificate.Subject }
    if ($subj -notmatch '(^|,\s*)O=Microsoft Corporation(,|$)') { $r.Why = 'it is signed, but not by Microsoft Corporation (' + (Clean-Ascii $subj) + ')'; return $r }
    $r.Ok = $true
  } catch { $r.Why = 'its signature could not be read (' + $_.Exception.Message + ')' }
  return $r
}
function Get-WingetExe {
  try { $c = Get-Command winget.exe -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1; if ($c -and $c.Source) { return [string]$c.Source } } catch { }
  if ($env:LOCALAPPDATA) {
    $p = Join-Path $env:LOCALAPPDATA 'Microsoft\WindowsApps\winget.exe'
    if (Test-Path -LiteralPath $p) { return $p }
  }
  return ''
}
function Invoke-Tool {
  # one program with a time limit; no window; returns Lines, ExitCode, TimedOut, Started, Error
  param([string]$File, [string]$ArgLine = '', [int]$Seconds = 60)
  $o = [pscustomobject]@{ Started = $false; ExitCode = -1; TimedOut = $false; Lines = @(); Error = '' }
  $p = $null
  try {
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $File
    $psi.Arguments = $ArgLine
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.RedirectStandardInput = $true
    $psi.CreateNoWindow = $true
    $p = [System.Diagnostics.Process]::Start($psi)
    $o.Started = $true
    try { $p.StandardInput.Close() } catch { }
    $so = $p.StandardOutput.ReadToEndAsync()
    $se = $p.StandardError.ReadToEndAsync()
    if (-not $p.WaitForExit($Seconds * 1000)) {
      $o.TimedOut = $true
      try { & taskkill.exe /PID $p.Id /T /F 2>&1 | Out-Null } catch { }
    } else {
      $p.WaitForExit()
      $o.ExitCode = $p.ExitCode
    }
    $txt = ''
    try { if ($so.Wait(3000)) { $txt += $so.Result } } catch { }
    try { if ($se.Wait(3000)) { $txt += "`n" + $se.Result } } catch { }
    $o.Lines = @($txt -split "`r?`n" | Where-Object { $_ -ne '' })
  } catch { $o.Error = $_.Exception.Message }
  finally { if ($p) { try { $p.Dispose() } catch { } } }
  return $o
}
function Show-ToolOutput($Lines) {
  # winget draws spinners and bars; keep only lines that contain words
  $shown = 0
  foreach ($l in @($Lines)) {
    $t = (Clean-Ascii ([string]$l)).Trim()
    if ($t -match '[A-Za-z]{3}' -and $shown -lt 12) { Info $t; $shown++ }
  }
}
function Install-AutologonWinget {
  $wg = Get-WingetExe
  if (-not $wg) { Info 'winget is not available in this VM.'; return $false }
  Say ('getting Autologon with winget (' + $script:WingetId + ' from the "winget" source) ... this can take a minute')
  $argl = 'install --id ' + $script:WingetId + ' --exact --source winget --accept-package-agreements --accept-source-agreements --disable-interactivity'
  $r = Invoke-Tool -File $wg -ArgLine $argl -Seconds 300
  if ($r.TimedOut) { Warn 'winget took more than 5 minutes and was stopped'; return $false }
  if (-not $r.Started) { Warn ('winget could not be started - ' + $r.Error); return $false }
  Show-ToolOutput $r.Lines
  if ($r.ExitCode -ne 0) { Warn ('winget returned code ' + $r.ExitCode + ' (looking for the program anyway)') }
  return $true
}
function Install-AutologonZip {
  # straight from Microsoft's Sysinternals download site, into its own new folder; the program must be signed by Microsoft
  $tmp = Join-Path $env:TEMP ('autologon-' + (Get-Date -Format 'yyyyMMddHHmmss') + '.zip')
  try {
    Say ('downloading ' + $script:ZipUrl + ' ...')
    try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch { }
    Invoke-WebRequest -UseBasicParsing -Uri $script:ZipUrl -OutFile $tmp -TimeoutSec 120
    $hash = (Get-FileHash -LiteralPath $tmp -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($hash -eq $script:ZipSha256) { Ok 'the download is byte-for-byte the file winget lists (same SHA-256)' }
    else { Info 'the download differs from the file winget lists (Microsoft may have updated it); the signature check below decides' }
    if (-not (Test-Path -LiteralPath $script:ToolDir)) { New-Item -ItemType Directory -Force -Path $script:ToolDir | Out-Null }
    Expand-Archive -LiteralPath $tmp -DestinationPath $script:ToolDir -Force
    $exe = Find-AutologonExe
    if (-not $exe) { Warn 'the download did not contain an Autologon program for this PC'; return $false }
    $sig = Test-MicrosoftSigned $exe
    if (-not $sig.Ok) {
      Bad ('NOT using ' + $exe + ' because ' + $sig.Why)
      try { Remove-Item -LiteralPath $script:ToolDir -Recurse -Force -ErrorAction SilentlyContinue } catch { }
      return $false
    }
    Ok ('unpacked to ' + $script:ToolDir)
    return $true
  } catch {
    Warn ('the download did not work - ' + $_.Exception.Message)
    return $false
  } finally { try { if (Test-Path -LiteralPath $tmp) { Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue } } catch { } }
}
function Ensure-AutologonTool {
  # returns the path, or '' when it could not be got. Asks for YES first (unless -AcceptLicences).
  $exe = Find-AutologonExe
  if ($exe) { return $exe }
  Say 'The Autologon program (Sysinternals, Microsoft) is not in this VM yet.'
  Info ('It will be fetched from Microsoft: first with winget (' + $script:WingetId + '), and if that fails from ' + $script:ZipUrl + '.')
  Info ('Its licence terms: ' + $script:LicenceUrl + '  (installing it means you accept them).')
  if ($script:DryRun) {
    Dry ('ask you to type YES, then run: winget install --id ' + $script:WingetId + ' --exact --source winget --accept-package-agreements --accept-source-agreements')
    Dry ('fall back to downloading ' + $script:ZipUrl + ' into ' + $script:ToolDir + ' if winget cannot')
    Dry 'refuse to open the program unless its digital signature is valid and from Microsoft Corporation'
    return '(dry-run)'
  }
  if (-not $script:AcceptLicences) {
    $a = Read-Answer 'Type YES to get Autologon now (anything else cancels)'
    if ($null -eq $a) { Say 'Cancelled: there was no one to answer (no console input), so nothing was downloaded or changed. Run it in a PowerShell window you can type in, or add -AcceptLicences.' 'Yellow'; $script:RC = 2; return '' }
    if ($a.Trim() -cne 'YES') { Say 'Cancelled: nothing was downloaded or changed.' 'Yellow'; $script:RC = 2; return '' }
  }
  [void](Install-AutologonWinget)
  $exe = Find-AutologonExe
  if (-not $exe) {
    Say 'winget did not leave the program anywhere I can find; trying the direct download.'
    [void](Install-AutologonZip)
    $exe = Find-AutologonExe
  }
  if (-not $exe) { Bad 'could not get Autologon.'; Info ('Get it by hand from https://learn.microsoft.com/en-us/sysinternals/downloads/autologon , unpack it anywhere, and run this script again.'); $script:RC = 1; return '' }
  return $exe
}
function Start-AutologonWindow([string]$Exe) {
  # opens Autologon (asks Windows for permission when this window is not an administrator window) and waits until it is closed. Returns $true when it ran.
  try {
    if (Test-IsAdmin) { Start-Process -FilePath $Exe -Wait }
    else { Start-Process -FilePath $Exe -Verb RunAs -Wait }
    return $true
  } catch {
    Bad ('Autologon did not open - ' + $_.Exception.Message)
    Info 'If you clicked No on the Windows permission question, run this script again and click Yes.'
    return $false
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# host-stopped.txt : COPIED from vm-setup.ps1 (Get-MarkerCheck and Get-MarkerInfo), the same strict rules that vm-verify.ps1 and the runner guard use. Keep
# the three copies identical. -ResumeClaude refuses to make its Startup shortcut until this says the main PC is stopped, because the shortcut starts
# the coordinator, and the coordinator starts the helper lanes and can ship: before the switch-over that would be a SECOND shipper next to the main PC.
# ----------------------------------------------------------------------------------------------------------------------
function Get-MarkerCheck([string[]]$Lines) {
  # Same rule as Get-MarkerCheck in host-common.ps1 (this script cannot load that file; keep the two identical):
  # SHA-256 (lower-case hex) over every non-empty line except the check= line, each trimmed, joined with LF.
  $keep = New-Object System.Collections.ArrayList
  foreach ($l in $Lines) {
    $t = ([string]$l).Trim()
    if (-not $t) { continue }
    if ($t -match '^check\s*=') { continue }
    [void]$keep.Add($t)
  }
  $bytes = [System.Text.Encoding]::ASCII.GetBytes(($keep -join "`n"))
  $sha = [System.Security.Cryptography.SHA256]::Create()
  try { $h = $sha.ComputeHash($bytes) } finally { $sha.Dispose() }
  return (($h | ForEach-Object { $_.ToString('x2') }) -join '')
}

function Get-MarkerInfo {
  # host-stopped.txt is written by host-stop.ps1 as key=value lines (status, computer, time, gitHead, shipLockClear, unpushedCommits, ..., check).
  # STRICT: Stopped is $true only when ALL of these hold: status is exactly "stopped", computer is present and is not this VM,
  # gitHead is a full 40-character commit id, shipLockClear is yes, the check= line matches the other lines, and no key appears twice.
  # A marker that is missing, cut short, edited by hand, glued together from two runs, or in an older format is NOT stopped; Why says what is wrong.
  $o = [pscustomobject]@{ Exists = $false; Stopped = $false; Text = ''; Status = ''; Head = ''; ShipLockClear = $null; Computer = ''; Time = ''; Unpushed = ''; Changed = ''; GpuPack = ''; Why = @() }
  $f = Join-Path $script:Kit 'host-stopped.txt'
  if (-not (Test-Path -LiteralPath $f)) { $o.Why = @('host-stopped.txt does not exist in the kit folder'); return $o }
  $o.Exists = $true
  $t = ''
  try { $t = [System.IO.File]::ReadAllText($f) } catch { }
  $o.Text = $t
  $why = New-Object System.Collections.ArrayList
  if (-not $t.Trim()) { [void]$why.Add('host-stopped.txt is empty') }
  $kv = @{}
  $dupes = New-Object System.Collections.ArrayList
  $allLines = @($t -split "`r?`n")
  foreach ($l in $allLines) {
    if ($l -match '^\s*([A-Za-z][A-Za-z0-9]*)\s*=\s*(.*?)\s*$') {
      $k = $Matches[1].ToLowerInvariant()
      if ($kv.ContainsKey($k)) { if ($dupes -notcontains $k) { [void]$dupes.Add($k) } } else { $kv[$k] = $Matches[2] }
    }
  }
  if ($dupes.Count -gt 0) { [void]$why.Add('these lines appear twice (a file glued together from two runs?): ' + ($dupes -join ', ')) }
  if ($kv.ContainsKey('status')) { $o.Status = $kv['status'].ToLowerInvariant() } else { $o.Status = 'unknown' }
  if ($kv.ContainsKey('githead') -and $kv['githead'] -match '^[0-9a-fA-F]{40}$') { $o.Head = $kv['githead'].ToLowerInvariant() }
  if ($kv.ContainsKey('shiplockclear')) {
    $v = $kv['shiplockclear'].ToLowerInvariant()
    if ($v -eq 'yes') { $o.ShipLockClear = $true } elseif ($v -eq 'no') { $o.ShipLockClear = $false }
  }
  if ($kv.ContainsKey('computer')) { $o.Computer = $kv['computer'] }
  if ($kv.ContainsKey('time')) { $o.Time = $kv['time'] }
  if ($kv.ContainsKey('unpushedcommits')) { $o.Unpushed = $kv['unpushedcommits'] }
  if ($kv.ContainsKey('changedfiles')) { $o.Changed = $kv['changedfiles'] }
  if ($kv.ContainsKey('gpupack')) { $o.GpuPack = $kv['gpupack'] }
  if ($o.Status -ne 'stopped') { [void]$why.Add('the status line says "' + $o.Status + '" (it must say exactly stopped)') }
  if (-not $o.Computer) { [void]$why.Add('there is no computer= line') }
  elseif ($o.Computer -ieq $env:COMPUTERNAME) { [void]$why.Add('the marker names THIS computer (' + $o.Computer + '); it must come from the main PC') }
  if (-not $o.Head) { [void]$why.Add('there is no full 40-character gitHead= line') }
  if ($o.ShipLockClear -ne $true) { [void]$why.Add('the marker does not say shipLockClear=yes') }
  if (-not $kv.ContainsKey('check')) { [void]$why.Add('there is no check= line (older host-stop.ps1, or the file was cut short): run host-stop.ps1 again and push again') }
  elseif ($kv['check'].ToLowerInvariant() -ne (Get-MarkerCheck $allLines)) { [void]$why.Add('the check= line does not match the other lines (edited by hand, cut short, or copied half-written)') }
  $o.Why = $why.ToArray()
  $o.Stopped = ($why.Count -eq 0)
  return $o
}

# ----------------------------------------------------------------------------------------------------------------------
# the Startup shortcut for the coordinator Claude Code (-ResumeClaude)
# ----------------------------------------------------------------------------------------------------------------------
function Get-StartupFolder { try { return [Environment]::GetFolderPath('Startup') } catch { return '' } }
function Get-ResumeShortcutPath {
  $d = Get-StartupFolder
  if (-not $d) { return '' }
  return (Join-Path $d $script:ShortcutName)
}
function Get-ClaudeExe {
  if ($env:USERPROFILE) {
    $p = Join-Path $env:USERPROFILE '.local\bin\claude.exe'
    if (Test-Path -LiteralPath $p -PathType Leaf) { return $p }
  }
  try { $c = Get-Command claude.exe -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1; if ($c -and $c.Source) { return [string]$c.Source } } catch { }
  return ''
}
function Get-CoordFolder {
  if (Test-Path -LiteralPath $script:MirrorCoord) { return $script:MirrorCoord }
  return $script:RepoRoot
}
# pure: the argument text of the shortcut (outer double quotes for PowerShell -Command, single quotes inside; the prompt has neither kind of quote)
function Get-ResumeShortcutArgs([string]$Coord, [string]$ClaudeExe, [string]$Prompt, [int]$DelaySec) {
  $cmd = 'Start-Sleep -Seconds ' + $DelaySec + '; Set-Location -LiteralPath ' + [char]39 + $Coord + [char]39 + '; & ' + [char]39 + $ClaudeExe + [char]39 + ' --continue ' + [char]39 + $Prompt + [char]39
  return ('-NoExit -Command "' + $cmd + '"')
}
function Read-Shortcut([string]$Path) {
  try {
    $ws = New-Object -ComObject WScript.Shell
    $l = $ws.CreateShortcut($Path)
    return [pscustomobject]@{ Target = [string]$l.TargetPath; Args = [string]$l.Arguments; Desc = [string]$l.Description }
  } catch { return $null }
}
function Write-Shortcut([string]$Path, [string]$Target, [string]$ArgLine, [string]$WorkDir, [string]$Desc) {
  $ws = New-Object -ComObject WScript.Shell
  $l = $ws.CreateShortcut($Path)
  $l.TargetPath = $Target
  $l.Arguments = $ArgLine
  if ($WorkDir) { $l.WorkingDirectory = $WorkDir }
  $l.Description = $Desc
  $l.Save()
}
function Set-ResumeShortcut {
  $path = Get-ResumeShortcutPath
  if (-not $path) { Warn 'could not find your Startup folder; no shortcut made'; return }
  # Gate: only after the switch-over. Before it the main PC may still ship, and the coordinator started by this shortcut would be a second shipper.
  $mk = Get-MarkerInfo
  if (-not $mk.Stopped) {
    Warn 'no Startup shortcut made: the main PC has not been switched over yet (C:\PillagersMove\kit\host-stopped.txt is missing or not accepted).'
    foreach ($w in @($mk.Why)) { Info ('  - ' + $w) }
    Info 'Do the switch-over first (guide, switch-over day, up to step S5), then run this script again with -ResumeClaude. Automatic sign-in itself is not affected by this.'
    return
  }
  $claude = Get-ClaudeExe
  if (-not $claude) { Warn 'Claude Code is not installed for this user yet (no claude.exe); no Startup shortcut made. Install Claude Code, then run this script again with -ResumeClaude.'; return }
  $coord = Get-CoordFolder
  $psExe = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
  $argl = Get-ResumeShortcutArgs $coord $claude $script:ResumePrompt $script:ResumeDelaySec
  if (Test-Path -LiteralPath $path) {
    $cur = Read-Shortcut $path
    if ($cur -and $cur.Desc -eq $script:ShortcutDesc -and $cur.Args -eq $argl -and $cur.Target -ieq $psExe) { Ok ('Startup shortcut is already there: ' + $path); return }
    if ($cur -and $cur.Desc -ne $script:ShortcutDesc) { Warn ('a Startup shortcut with that name exists but was not made by this script; left alone: ' + $path); return }
  }
  if ($script:DryRun) { Dry ('make the Startup shortcut ' + $path + ' -> powershell.exe ' + $argl); return }
  try {
    $sd = Split-Path -Parent $path
    if (-not (Test-Path -LiteralPath $sd)) { New-Item -ItemType Directory -Force -Path $sd | Out-Null }
    Write-Shortcut $path $psExe $argl $coord $script:ShortcutDesc
    Ok ('made the Startup shortcut: ' + $path)
    Info ('after each sign-in, 60 seconds later, a window opens in ' + $coord + ' and runs: claude --continue "..."  (to remove it: run this script with -Undo)')
  } catch { Warn ('could not make the shortcut - ' + $_.Exception.Message) }
}
function Remove-ResumeShortcut {
  $path = Get-ResumeShortcutPath
  if (-not $path -or -not (Test-Path -LiteralPath $path)) { Info 'Startup shortcut "Pillagers Claude resume": not there'; return }
  $cur = Read-Shortcut $path
  if (-not $cur -or $cur.Desc -ne $script:ShortcutDesc) { Warn ('the Startup shortcut ' + $path + ' was not made by this script; left alone'); return }
  if ($script:DryRun) { Dry ('delete the Startup shortcut ' + $path); return }
  try { Remove-Item -LiteralPath $path -Force -ErrorAction Stop; Ok ('removed the Startup shortcut: ' + $path) } catch { Warn ('could not remove ' + $path + ' - ' + $_.Exception.Message) }
}

# ----------------------------------------------------------------------------------------------------------------------
# the report of where things stand
# ----------------------------------------------------------------------------------------------------------------------
function Show-Facts($Facts, [string]$User, [string]$Kind, [string]$Exe) {
  $state = Get-AutoLogonState $Facts $User
  Say ('this VM     : ' + $env:COMPUTERNAME)
  Say ('you         : ' + $env:USERDOMAIN + '\' + $User + $(if ($Kind) { '   (account type: ' + $Kind + ')' } else { '' }))
  switch ($state) {
    'on'    { Ok ('automatic sign-in is ON for ' + $User + ' (set by Autologon; the password is not in the registry)') }
    'other' { Warn ('automatic sign-in is ON, but for "' + $Facts.DefaultUserName + '", not for ' + $User) }
    'plain' { Bad 'a plain-text DefaultPassword value exists in the Winlogon registry key (its value was NOT read). That stores a password readable by anyone on the VM.' }
    default { Say 'automatic sign-in is OFF: after a restart the VM waits at the sign-in screen.' 'Yellow' }
  }
  if ($Exe) { Say ('Autologon   : found at ' + $Exe) }
  else { Say 'Autologon   : not in this VM yet (step 1 gets it, after you type YES)' }
  $sc = Get-ResumeShortcutPath
  if ($sc -and (Test-Path -LiteralPath $sc)) { Say ('Claude resume shortcut in Startup: yes (' + $sc + ')') }
  return $state
}
function Show-Blockers($Facts) {
  $bl = @(Get-Blockers $Facts)
  foreach ($b in $bl) { Warn $b.Text; Info ('fix: ' + $b.Fix) }
  return $bl.Count
}

# ----------------------------------------------------------------------------------------------------------------------
# the three runs
# ----------------------------------------------------------------------------------------------------------------------
function Invoke-Enable($Facts, [string]$User, [string]$Kind, [string]$Domain) {
  $state = Get-AutoLogonState $Facts $User
  if ($state -eq 'on' -and -not $script:Reconfigure) {
    Step 'automatic sign-in is already on'
    Ok 'nothing to do. (After you change the Windows password, run this again with -Reconfigure and type the new one.)'
    if (@(Get-Blockers $Facts).Count -gt 0) {
      Warn 'automatic sign-in is set, but the warning above can still stop it. Fix that, restart the VM once while you watch, then run vm-verify.ps1.'
      $script:RC = 1
    }
    if ($script:ResumeClaude) { Step 'Claude Code after a restart'; Set-ResumeShortcut }
    return
  }
  Step 'step 1 of 3: get the Autologon program'
  $exe = Ensure-AutologonTool
  if (-not $exe) { return }
  if ($exe -ne '(dry-run)') {
    $sig = Test-MicrosoftSigned $exe
    if (-not $sig.Ok) {
      Bad ('will not open ' + $exe + ' because ' + $sig.Why + '. Your password is typed into that program, so it must be Microsoft''s.')
      Info 'Delete that file and run this script again to get a fresh copy. (To check one by hand: right-click it, Properties, Digital Signatures tab: signer must be Microsoft Corporation.)'
      $script:RC = 1; return
    }
    Ok ('Autologon is here and signed by Microsoft: ' + $exe)
  }

  Step 'step 2 of 3: you type the password into Autologon (not into this window)'
  Info 'Autologon opens in its own window. Windows may first ask "Do you want to allow this app to make changes to your device?": click Yes.'
  Info ('1. Username should say: ' + $User)
  Info ('   Domain should say:   ' + $Domain + '   (for a local account that is this computer''s name; fix them in that window if they differ)')
  Info '2. Click in the PASSWORD box of that window and type the password you use to sign in to this VM.'
  if ($Kind -eq 'MicrosoftAccount') { Info '   This account is a Microsoft account: type the Microsoft account password, NOT the PIN.' }
  Info '3. Click ENABLE. It says that Autologon is configured. Click OK and close the Autologon window.'
  Info 'This script cannot see that window. It waits here until you close it, then checks the result.'
  if ($script:DryRun) {
    Dry ('open ' + $(if ($exe -eq '(dry-run)') { 'Autologon' } else { $exe }) + $(if (Test-IsAdmin) { ' (this window is already an administrator window)' } else { ' with the Windows permission question' }) + ' and wait until you close it')
  } else {
    if (-not (Start-AutologonWindow $exe)) { $script:RC = 1; return }
    Say 'Autologon window closed.'
  }

  Step 'step 3 of 3: check the result (reads the registry only)'
  if ($script:DryRun) {
    Dry 'read AutoAdminLogon, DefaultUserName and the NAME of DefaultPassword, and tell you whether automatic sign-in is on for you'
    Dry 'tell you if Windows Hello-only or a legal notice would still stop automatic sign-in'
  } else {
    $f2 = Get-WinlogonFacts
    $st = Get-AutoLogonState $f2 $User
    switch ($st) {
      'on'    { Ok ('automatic sign-in is ON for ' + $User + '. The password is kept by Autologon in Windows'' protected store; no plain-text password is in the registry.') }
      'other' { Bad ('automatic sign-in is on for "' + $f2.DefaultUserName + '", not for ' + $User + '. Run this again and fix the Username box.'); $script:RC = 1 }
      'plain' { Bad 'a plain-text DefaultPassword value still exists in the Winlogon key. Run this script with -Undo (click Disable), then run it again. If it is still there, delete only the value named DefaultPassword under HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon in regedit.'; $script:RC = 1 }
      default { Bad 'automatic sign-in is still OFF. Did you click Enable (and not just close the window)? Run this script again.'; $script:RC = 1 }
    }
    $nb = Show-Blockers $f2
    if ($st -eq 'on' -and $nb -eq 0) {
      Say ''
      Say 'DONE. Test it once, watching: Start menu, Power, Restart. Do not type at the sign-in screen. The desktop should appear on its own' 'Green'
      Say 'within about 5 minutes. Two minutes later run vm-verify.ps1: "the VM signs in by itself" must be PASS and the servers must answer.' 'Green'
    } elseif ($st -eq 'on') {
      Say ''
      Say 'Automatic sign-in is set, but the warning above can still stop it. Fix that, restart the VM once while you watch, then run vm-verify.ps1.' 'Yellow'
      $script:RC = 1
    }
  }
  if ($script:ResumeClaude) { Step 'Claude Code after a restart'; Set-ResumeShortcut }
  else { Say ''; Info 'Optional: run this again with -ResumeClaude to have the coordinator Claude Code reopen by itself after each sign-in (see the CLAUDE part of the notes at the top of this file).' }
}

function Invoke-Disable($Facts, [string]$User) {
  $state = Get-AutoLogonState $Facts $User
  Step 'turn automatic sign-in OFF'
  Info 'After this, a restart of the VM stops at the sign-in screen: the runner, the servers and Claude stay down until you sign in.'
  if ($state -eq 'off') {
    Ok 'automatic sign-in is already off; nothing to turn off'
  } else {
    $exe = Find-AutologonExe
    if (-not $exe) { $exe = Ensure-AutologonTool }
    if (-not $exe) { return }
    if ($exe -ne '(dry-run)') {
      $sig = Test-MicrosoftSigned $exe
      if (-not $sig.Ok) { Bad ('will not open ' + $exe + ' because ' + $sig.Why); $script:RC = 1; return }
    }
    Info 'Autologon opens in its own window (Windows may ask for permission first: click Yes). Click DISABLE, then close the window. No password is needed for that.'
    if ($script:DryRun) { Dry ('open ' + $(if ($exe -eq '(dry-run)') { 'Autologon' } else { $exe }) + ' and wait until you close it, then read the registry to confirm it is off') }
    else {
      if (-not (Start-AutologonWindow $exe)) { $script:RC = 1; return }
      Say 'Autologon window closed.'
      $f2 = Get-WinlogonFacts
      $st = Get-AutoLogonState $f2 $User
      if ($st -eq 'off') { Ok 'automatic sign-in is OFF now' }
      elseif ($st -eq 'plain') { Bad 'automatic sign-in is off, but a plain-text DefaultPassword value is still in the Winlogon key. Delete only that value in regedit (HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon).'; $script:RC = 1 }
      else { Bad 'automatic sign-in still looks ON. Run this again and click Disable.'; $script:RC = 1 }
      $state = $st
    }
  }
  Step 'Startup shortcut for Claude'
  Remove-ResumeShortcut
  if ($script:RemoveTool) {
    Step 'remove the Autologon program (-RemoveTool)'
    if ($state -ne 'off' -and -not $script:DryRun) { Warn 'kept: automatic sign-in is not confirmed off, and you need the program to turn it off'; return }
    if ($script:DryRun) { Dry ('run: winget uninstall --id ' + $script:WingetId + ' --exact   and delete ' + $script:ToolDir + ' if it exists'); return }
    $wg = Get-WingetExe
    if ($wg) {
      $r = Invoke-Tool -File $wg -ArgLine ('uninstall --id ' + $script:WingetId + ' --exact --disable-interactivity') -Seconds 180
      Show-ToolOutput $r.Lines
      if ($r.ExitCode -eq 0) { Ok 'uninstalled the winget package' } else { Info ('winget uninstall returned ' + $r.ExitCode + ' (it may not have been installed with winget)') }
    }
    if (Test-Path -LiteralPath $script:ToolDir) {
      try { Remove-Item -LiteralPath $script:ToolDir -Recurse -Force -ErrorAction Stop; Ok ('deleted ' + $script:ToolDir) } catch { Warn ('could not delete ' + $script:ToolDir + ' - ' + $_.Exception.Message) }
    }
  }
}

function Invoke-Main {
  $script:RC = 0
  Start-Log
  Say ('PILLAGERS VM : sign in by itself after a restart (Sysinternals Autologon)   ' + $script:ScriptVersion) 'Cyan'
  if ($script:DryRun) { Say 'DRY RUN: nothing will be downloaded, opened, made or changed (the log file is skipped too).' 'Magenta' }
  $comp = [string]$env:COMPUTERNAME
  if ($comp -ieq $script:HostComputer) {
    Bad ('this is the main PC (' + $comp + '). This script is only for the Pillagers VM. Nothing was changed.')
    $script:RC = 2
    return
  }
  $model = Get-VmModel
  if ($model -and $model -notmatch 'Virtual') { Warn ('this does not look like a Hyper-V virtual machine (model: ' + $model + '). It is meant for the Pillagers VM.') }
  $user = [string]$env:USERNAME
  $kind = Get-AccountKind
  $facts = Get-WinlogonFacts
  $exe = Find-AutologonExe
  Step 'where things stand now (read only)'
  $state = Show-Facts $facts $user $kind $exe
  $domain = [string]$env:USERDOMAIN
  if (-not $script:Undo) { [void](Show-Blockers $facts) }
  if ($script:Status) {
    Say ''
    Info 'Status only: nothing was changed.'
    return
  }
  if ($script:Undo) { Invoke-Disable $facts $user }
  else { Invoke-Enable $facts $user $kind $domain }
  Say ''
  if ($script:Log) { Say ('log file: ' + $script:Log) 'DarkGray' }
  if ($script:RC -eq 0) {
    if ($script:Undo) { Say 'NEXT: automatic sign-in is off. After any restart of the VM you must sign in by hand before the runner, servers and Claude come back. (To turn it on again, run this script without -Undo.)' }
    else { Say 'NEXT: restart the VM once while you watch (Start, Power, Restart), then run vm-verify.ps1.' }
  }
}

if ($MyInvocation.InvocationName -ne '.') {
  Invoke-Main | Out-Null
  exit $script:RC
}
