# host-ollama-bridge.ps1 : lets the VM use the local AI (Ollama) that runs on THIS PC. HE runs it, in an ADMINISTRATOR PowerShell on the main PC.
# Why: the VM cannot use the AMD graphics card for Ollama, so the model audits (tools\ship-review.ps1, tools\llm-night.ps1) keep running on
# this PC's Ollama and the VM calls it over the Hyper-V "Default Switch" network (http://192.168.160.1:11434).
#
#   powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-ollama-bridge.ps1" -Status
#   powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-ollama-bridge.ps1" -Install -DryRun
#   powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-ollama-bridge.ps1" -Install
#   powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-ollama-bridge.ps1" -Undo
#
#   -Status      read only (works in a normal window): what Ollama listens on, the setting, the firewall rule, and a test request to
#                http://<host address on the Default Switch>:11434/api/tags
#   -Install     does three things (an administrator window is needed):
#                  1. adds the inbound Windows Firewall rule 'Pillagers Ollama for VM': TCP 11434, only from the Default Switch network
#                     (192.168.160.0/20 today, read from the live switch), only on the Default Switch network card, only for ollama.exe
#                  2. sets YOUR user variable OLLAMA_HOST=0.0.0.0:11434 (what was there before is remembered, -Undo puts it back)
#                  3. stops Ollama and starts it again AS YOU (not as administrator) so it picks the variable up
#   -Undo        removes the rule, puts OLLAMA_HOST back, restarts Ollama so it listens on this PC only again
#   -DryRun      prints what -Install / -Undo WOULD do and changes nothing
#   -NoRestart   do not stop / start Ollama; you quit it from the tray and start it from the Start menu yourself
#                There is no -Yes (if given it is ignored): the YES question must be typed by a person at the keyboard; a script that pipes YES in is
#                refused (exit 2). -DryRun asks nothing because it changes nothing.
#
# WHY 0.0.0.0 AND NOT "ONLY 127.0.0.1 AND 192.168.160.1": Ollama's OLLAMA_HOST takes ONE address (its code does not split a list, checked in
# the Ollama source and docs on 2026-10-19). Binding only 192.168.160.1 would cut off every tool on this PC that calls 127.0.0.1:11434
# (ship-review, llm-night, the Dev Console) and the Default Switch address does not exist yet at boot, so Ollama would fail to start.
# So Ollama listens on every card and the Windows Firewall rule is what limits who can connect (Windows blocks inbound by default).
#
# WHAT THIS EXPOSES: Ollama has no password. After -Install, anything inside a VM on this PC's Default Switch can ask your Ollama for its model list,
# send it prompts and use your graphics card. Computers on your Wi-Fi / LAN / VPN cannot, as long as no other firewall rule lets them in
# (-Status lists any other rule that mentions Ollama or port 11434). Windows Sandbox, if you use it, also lives on the Default Switch network.
# The whole protection is the Windows Firewall, so -Install first READS (changes nothing) whether the firewall is really doing that job, and REFUSES (exit 2,
# nothing changed, OLLAMA_HOST not set) when: the firewall is switched off or cannot be read for any of the three profiles (Domain, Private, Public); any
# profile allows inbound connections by default; or another enabled rule already lets other computers reach ollama.exe or port 11434. It also refuses
# when the Default Switch network card cannot be found, because a rule limited only by address could match a home network that picked the same range.
#
# If Windows shows "Allow Ollama on networks?": the rule this script makes comes first, so the question should not appear. If it does, do not tick Private or
# Public (that would let your Wi-Fi in). Close the window without allowing, then run -Status: pressing Cancel can make Windows add a BLOCK rule for Ollama
# (reported online, not confirmed by Microsoft), and a block rule beats the allow rule, so the bridge would silently not work. -Status lists such a rule
# and prints the exact command that removes it.
#
# Safety: no secret is read or printed. It changes only: the rule named above, your user variable OLLAMA_HOST, and the Ollama process.
# It never touches Defender, UAC, other firewall rules, Windows Update or any other setting.
# Exit codes: 0 done / status shown, 1 error, 2 refused because the firewall is not safe for this, or done but Ollama did not come back the way it should (see the text), 3 needs an administrator window.
# ASCII only. Works in Windows PowerShell 5.1 and PowerShell 7.
param(
  [switch]$Install,
  [switch]$Undo,
  [switch]$Status,
  [switch]$DryRun,
  [switch]$NoRestart
)
$ErrorActionPreference = 'Continue'
if (-not $PSScriptRoot) { Write-Host 'Please run this from its file, not pasted into a window.'; exit 1 }
$commonPath = Join-Path $PSScriptRoot 'host-common.ps1'
if (-not (Test-Path -LiteralPath $commonPath)) { Write-Host ('host-common.ps1 is missing next to this script: ' + $commonPath); exit 1 }
. $commonPath
Start-MigLog -Name 'host-ollama-bridge'

$script:RuleName    = 'Pillagers Ollama for VM'
$script:Port        = 11434
$script:EnvName     = 'OLLAMA_HOST'
$script:EnvValue    = '0.0.0.0:11434'
$script:SwitchAlias = 'vEthernet (Default Switch)'
$script:FallbackIp  = '192.168.160.1'
$script:FallbackCidr = '192.168.160.0/20'
$script:OllamaDir   = Join-Path $script:HostProfile 'AppData\Local\Programs\Ollama'
$script:OllamaExe   = Join-Path $script:OllamaDir 'ollama.exe'
$script:OllamaApp   = Join-Path $script:OllamaDir 'ollama app.exe'
$script:StateFile   = Join-Path $script:StateDir 'host-ollama-bridge-state.json'
$script:ExitCode    = 0
$isAdmin = Test-IsAdmin

# ------------------------------------------------------------------ pure helpers (unit-tested)
function Get-NetworkCidr {
  # '192.168.160.1', 20 -> '192.168.160.0/20'
  param([string]$Ip, [int]$Prefix)
  $a = [System.Net.IPAddress]::Parse($Ip).GetAddressBytes()
  $o = New-Object 'System.Collections.Generic.List[string]'
  for ($i = 0; $i -lt 4; $i++) {
    $bits = $Prefix - (8 * $i)
    if ($bits -lt 0) { $bits = 0 }
    if ($bits -gt 8) { $bits = 8 }
    $mask = (255 -shl (8 - $bits)) -band 255
    $o.Add([string]([int]$a[$i] -band $mask))
  }
  return (($o.ToArray() -join '.') + '/' + $Prefix)
}

function ConvertTo-CidrText {
  # Windows shows a rule's remote address as 192.168.160.0/255.255.240.0; this turns that into 192.168.160.0/20 so two spellings can be compared.
  param([string]$Text)
  $t = ([string]$Text).Trim()
  if ($t -match '^(\d{1,3}(?:\.\d{1,3}){3})/(\d{1,2})$') { return ($Matches[1] + '/' + $Matches[2]) }
  if ($t -match '^(\d{1,3}(?:\.\d{1,3}){3})/(\d{1,3}(?:\.\d{1,3}){3})$') {
    $ip = $Matches[1]
    $bits = 0
    foreach ($b in ([System.Net.IPAddress]::Parse($Matches[2]).GetAddressBytes())) {
      $v = [int]$b
      while ($v -gt 0) { if (($v -band 128) -ne 0) { $bits++ }; $v = ($v -shl 1) -band 255 }
    }
    return ($ip + '/' + $bits)
  }
  return $t
}

function Test-WideAddr { param([string]$Addr) return ($Addr -eq '0.0.0.0' -or $Addr -eq '::') }

function Test-RuleMatches {
  # $Info = what Get-BridgeRule read; $Want = what -Install would create. True when the rule already is what we want.
  param($Info, $Want)
  if (-not $Info.Exists) { return $false }
  if ($Info.Count -ne 1) { return $false }
  if ([string]$Info.Enabled -ne 'True') { return $false }
  if ([string]$Info.Direction -ne 'Inbound') { return $false }
  if ([string]$Info.Action -ne 'Allow') { return $false }
  if ([string]$Info.Profile -ne 'Any') { return $false }
  if ([string]$Info.Protocol -ne 'TCP') { return $false }
  if ([string]$Info.Port -ne [string]$Want.Port) { return $false }
  if ((ConvertTo-CidrText $Info.Remote) -ne (ConvertTo-CidrText $Want.Remote)) { return $false }
  if ($Want.Alias) { if (@($Info.Interface) -notcontains $Want.Alias) { return $false } }
  else { if ([string]$Info.Interface -and [string]$Info.Interface -ne 'Any') { return $false } }
  if ($Want.Program) { if (([string]$Info.Program).ToLowerInvariant() -ne ([string]$Want.Program).ToLowerInvariant()) { return $false } }
  return $true
}

# ------------------------------------------------------------------ small readers
function Get-SwitchInfo {
  $r = [ordered]@{ Found = $false; Alias = $script:SwitchAlias; Ip = $script:FallbackIp; Prefix = 20; Cidr = $script:FallbackCidr }
  try {
    $a = @(Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias $script:SwitchAlias -ErrorAction Stop | Where-Object { ([string]$_.IPAddress) -notlike '169.254.*' })
    if ($a.Count -gt 0) {
      $r.Found = $true
      $r.Ip = [string]$a[0].IPAddress
      $r.Prefix = [int]$a[0].PrefixLength
      $r.Cidr = Get-NetworkCidr -Ip $r.Ip -Prefix $r.Prefix
    }
  } catch { }
  return [pscustomobject]$r
}

function Get-OllamaListeners {
  $out = @()
  try {
    foreach ($c in @(Get-NetTCPConnection -State Listen -LocalPort $script:Port -ErrorAction Stop)) {
      $pn = ''
      try { $pn = (Get-Process -Id ([int]$c.OwningProcess) -ErrorAction Stop).ProcessName } catch { }
      $out += [pscustomobject]@{ Addr = [string]$c.LocalAddress; ProcId = [int]$c.OwningProcess; ProcName = $pn }
    }
  } catch { }
  return @($out)
}

function Get-ListenState {
  $l = @(Get-OllamaListeners)
  $wide = (@($l | Where-Object { Test-WideAddr $_.Addr }).Count -gt 0)
  $loop = (@($l | Where-Object { $_.Addr -eq '127.0.0.1' -or $_.Addr -eq '::1' }).Count -gt 0)
  return [pscustomobject]@{ Listeners = $l; Any = ($l.Count -gt 0); Wide = $wide; LoopbackOnly = ($loop -and -not $wide) }
}

function Get-OllamaProcs {
  $snap = Get-ProcSnap
  return @($snap | Where-Object {
      ($_.Name -in @('ollama.exe', 'ollama app.exe', 'ollama_llama_server.exe')) -and
      ((-not $_.ExecutablePath) -or ([string]$_.ExecutablePath -like '*\Ollama\*'))
    })
}

function Invoke-QuickGet {
  # One GET with a hard time limit and NO proxy (a system proxy would send a 192.168.x.x address somewhere else).
  param([string]$Url, [int]$TimeoutMs = 3000)
  $r = [ordered]@{ Ok = $false; Code = 0; Body = ''; Error = ''; Ms = 0 }
  $clock = [System.Diagnostics.Stopwatch]::StartNew()
  try {
    $req = [System.Net.HttpWebRequest]::Create($Url)
    $req.Method = 'GET'
    $req.Timeout = $TimeoutMs
    $req.ReadWriteTimeout = $TimeoutMs
    $req.Proxy = $null
    $req.KeepAlive = $false
    $resp = $req.GetResponse()
    try {
      $r.Code = [int]$resp.StatusCode
      $sr = New-Object System.IO.StreamReader($resp.GetResponseStream())
      try { $r.Body = $sr.ReadToEnd() } finally { $sr.Dispose() }
    } finally { $resp.Close() }
    $r.Ok = ($r.Code -eq 200)
  } catch [System.Net.WebException] {
    $st = [string]$_.Exception.Status
    if ($st -eq 'Timeout') { $r.Error = 'timed out (a firewall may be blocking it)' }
    elseif ($st -eq 'ConnectFailure') { $r.Error = 'connection refused (nothing listens on that address)' }
    else { $r.Error = $_.Exception.Message }
  } catch { $r.Error = $_.Exception.Message }
  $r.Ms = [int]$clock.ElapsedMilliseconds
  return [pscustomobject]$r
}

function Get-ModelNames {
  param([string]$Body)
  try { $j = $Body | ConvertFrom-Json; return @($j.models | ForEach-Object { [string]$_.name }) } catch { return @() }
}

function Get-BridgeRule {
  $info = [ordered]@{ Exists = $false; Count = 0; Enabled = ''; Direction = ''; Action = ''; Profile = ''; Protocol = ''; Remote = ''; Port = ''; Interface = @(); Program = '' }
  $rules = @()
  try { $rules = @(Get-NetFirewallRule -DisplayName $script:RuleName -ErrorAction Stop) } catch { return [pscustomobject]$info }
  if ($rules.Count -eq 0) { return [pscustomobject]$info }
  $r = $rules[0]
  $info.Exists = $true
  $info.Count = $rules.Count
  $info.Enabled = [string]$r.Enabled
  $info.Direction = [string]$r.Direction
  $info.Action = [string]$r.Action
  $info.Profile = [string]$r.Profile
  try { $f = $r | Get-NetFirewallAddressFilter; $info.Remote = (@($f.RemoteAddress) -join ',') } catch { }
  try { $f = $r | Get-NetFirewallPortFilter; $info.Port = (@($f.LocalPort) -join ','); $info.Protocol = [string]$f.Protocol } catch { }
  try { $f = $r | Get-NetFirewallInterfaceFilter; $info.Interface = @($f.InterfaceAlias) } catch { }
  try { $f = $r | Get-NetFirewallApplicationFilter; $info.Program = [string]$f.Program } catch { }
  return [pscustomobject]$info
}

function Test-BroadRemote {
  # True when a rule's remote address lets OTHER computers in (Any, an empty list, the whole local subnet, or 0.0.0.0/0).
  param([string]$Remote)
  $r = ([string]$Remote).Trim()
  if ($r -eq '') { return $true }
  return [bool]($r -match '(?i)(^|,)\s*(Any|\*|LocalSubnet|0\.0\.0\.0/0|0\.0\.0\.0/0\.0\.0\.0\.0|0\.0\.0\.0-255\.255\.255\.255)\s*(,|$)')
}

function Get-OtherOpenRules {
  # Other ENABLED inbound rules that name ollama or open port 11434: Allow rules (Rules) and Block rules (Blocks). They are not ours; this only reports.
  # Needs a readable firewall store (an administrator window).
  $out = @()
  try {
    $apps = @(Get-NetFirewallApplicationFilter -ErrorAction Stop | Where-Object { ([string]$_.Program) -like '*ollama*' })
    $ports = @(Get-NetFirewallPortFilter -ErrorAction Stop | Where-Object { (@($_.LocalPort) -contains '11434') })
    $seen = @{}
    foreach ($f in @($apps) + @($ports)) {
      $rule = $null
      try { $rule = $f | Get-NetFirewallRule -ErrorAction Stop } catch { continue }
      if ($rule.DisplayName -eq $script:RuleName) { continue }
      $act = [string]$rule.Action
      if ([string]$rule.Enabled -ne 'True' -or [string]$rule.Direction -ne 'Inbound' -or ($act -ne 'Allow' -and $act -ne 'Block')) { continue }
      if ($seen.ContainsKey($rule.Name)) { continue }
      $seen[$rule.Name] = $true
      $remote = ''
      try { $remote = (@(($rule | Get-NetFirewallAddressFilter).RemoteAddress) -join ',') } catch { }
      $out += [pscustomobject]@{ Name = [string]$rule.DisplayName; Id = [string]$rule.Name; Profile = [string]$rule.Profile; Remote = $remote; Action = $act }
    }
    return [pscustomobject]@{ Readable = $true; Rules = @($out | Where-Object { $_.Action -eq 'Allow' }); Blocks = @($out | Where-Object { $_.Action -eq 'Block' }) }
  } catch {
    return [pscustomobject]@{ Readable = $false; Rules = @(); Blocks = @() }
  }
}

function Get-FirewallPosture {
  # READS (changes nothing) whether the Windows Firewall really does the job this bridge depends on: on for all three profiles, and blocking inbound by default.
  # Uses the ACTIVE policy (what Windows enforces right now, including Group Policy). Readable = $false when it could not be read at all.
  $o = [ordered]@{ Readable = $false; Problems = @(); Lines = @(); Error = '' }
  try {
    $p = @(Get-NetFirewallProfile -PolicyStore ActiveStore -ErrorAction Stop)
    $names = @($p | ForEach-Object { [string]$_.Name })
    foreach ($need in @('Domain', 'Private', 'Public')) { if ($names -notcontains $need) { $o.Problems += ('the ' + $need + ' profile could not be read') } }
    foreach ($x in $p) {
      $nm = [string]$x.Name
      $en = [string]$x.Enabled
      $inb = [string]$x.DefaultInboundAction
      $o.Lines += ($nm + ': firewall ' + $en + ', inbound by default ' + $inb)
      if ($en -ne 'True') { $o.Problems += ('the Windows Firewall is switched off (or not set) for the ' + $nm + ' profile') }
      if ($inb -eq 'Allow') { $o.Problems += ('the ' + $nm + ' profile allows inbound connections by default') }
    }
    $o.Readable = ($p.Count -gt 0)
    if (-not $o.Readable) { $o.Error = 'Windows returned no firewall profiles' }
  } catch { $o.Error = $_.Exception.Message }
  return [pscustomobject]$o
}

# ------------------------------------------------------------------ remembered change (so -Undo can reverse exactly what -Install did)
function Read-BridgeState {
  $s = [ordered]@{ time = ''; envSetByUs = $false; envHadPrevious = $false; envPrevious = ''; ruleCreated = $false; ruleRemote = '' }
  if (Test-Path -LiteralPath $script:StateFile) {
    try {
      $j = Get-Content -LiteralPath $script:StateFile -Raw | ConvertFrom-Json
      if ($j.envSetByUs) { $s['envSetByUs'] = [bool]$j.envSetByUs }
      if ($j.envHadPrevious) { $s['envHadPrevious'] = [bool]$j.envHadPrevious }
      if ($j.envPrevious) { $s['envPrevious'] = [string]$j.envPrevious }
      if ($j.ruleCreated) { $s['ruleCreated'] = [bool]$j.ruleCreated }
      if ($j.ruleRemote) { $s['ruleRemote'] = [string]$j.ruleRemote }
    } catch { Write-Mig 'The old state file could not be read; starting a fresh one.' 'WARN' }
  }
  return $s
}
function Save-BridgeState {
  if ($DryRun) { return }
  $st['time'] = (Get-Date).ToString('s')
  Write-AsciiFile -Path $script:StateFile -Text ($st | ConvertTo-Json -Depth 4)
}
$st = Read-BridgeState

$script:ConfirmRedirected = $false
function Confirm-Plain {
  param([string]$Question)
  if ($DryRun) { return $true }
  # the question must be answered by a person: a script that pipes "YES" into this window is refused (nothing is changed)
  $redirected = $false
  try { $redirected = [Console]::IsInputRedirected } catch { }
  if ($redirected) {
    Write-Mig 'This question must be answered by a person typing at the keyboard; the input here is redirected (piped or scripted), so it counts as NO.' 'FAIL'
    $script:ConfirmRedirected = $true
    return $false
  }
  $a = Read-Host ($Question + ' Type YES to go on, anything else to cancel')
  return ($a -ceq 'YES')
}

# ------------------------------------------------------------------ is a process running as administrator? (so Ollama is never left running elevated)
function Initialize-TokenHelper {
  if ('PillagersTok' -as [type]) { return }
  Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class PillagersTok {
  [DllImport("kernel32.dll", SetLastError=true)] static extern IntPtr OpenProcess(uint acc, bool inh, int pid);
  [DllImport("kernel32.dll")] static extern bool CloseHandle(IntPtr h);
  [DllImport("advapi32.dll", SetLastError=true)] static extern bool OpenProcessToken(IntPtr h, uint acc, out IntPtr tok);
  [DllImport("advapi32.dll", SetLastError=true)] static extern bool GetTokenInformation(IntPtr tok, int cls, out int val, int len, out int ret);
  public static int Elevated(int pid) {
    IntPtr p = OpenProcess(0x1000, false, pid);
    if (p == IntPtr.Zero) return -1;
    try {
      IntPtr t;
      if (!OpenProcessToken(p, 0x8, out t)) return -1;
      try {
        int v; int r;
        if (!GetTokenInformation(t, 20, out v, 4, out r)) return -1;
        return v != 0 ? 1 : 0;
      } finally { CloseHandle(t); }
    } finally { CloseHandle(p); }
  }
}
'@
}
function Get-ProcElevation {
  # 1 = elevated, 0 = normal, -1 = could not tell
  param([int]$ProcessId)
  try { Initialize-TokenHelper; return [int][PillagersTok]::Elevated($ProcessId) } catch { return -1 }
}

# ------------------------------------------------------------------ steps
function Show-Warning {
  param($Sw)
  Write-MigBlank
  Write-Mig '*** READ THIS FIRST ***' 'WARN'
  Write-Mig 'This makes Ollama (your local AI on the graphics card) listen on EVERY network card of this PC, not only on this PC itself.' 'WARN'
  Write-Mig 'Ollama has no password. What limits who can reach it is a Windows Firewall rule this script adds:' 'WARN'
  Write-Mig ('   only the network ' + $Sw.Cidr + ' (the VMs on the Hyper-V Default Switch of THIS PC), only on the card "' + $script:SwitchAlias + '", only for ollama.exe, only TCP 11434.') 'WARN'
  Write-Mig 'So after this, anything inside a VM on this PC (and Windows Sandbox, if you use it) can list your models, send prompts and use your graphics card. Computers on your Wi-Fi, LAN or VPN cannot, because the Windows Firewall stops them (this script checked that it is on).' 'WARN'
  Write-Mig 'If Windows ever pops up "Allow Ollama on networks?": do NOT tick Private or Public. Close the window without allowing, then run -Status (it finds and explains any block rule Windows added).' 'WARN'
  Write-Mig 'To go back: run this script with -Undo.' 'WARN'
  Write-MigBlank
}

function Step-Rule {
  param($Sw)
  Write-Mig 'Step 1: the Windows Firewall rule' 'STEP'
  $want = [pscustomobject]@{ Port = '11434'; Remote = $Sw.Cidr; Alias = $(if ($Sw.Found) { $script:SwitchAlias } else { '' }); Program = $(if (Test-Path -LiteralPath $script:OllamaExe) { $script:OllamaExe } else { '' }) }
  if (-not $Sw.Found) {
    # Fail closed: a rule limited only by address could match a home network or VPN that happens to use the same range, while Ollama is about to listen on every card.
    Write-Mig ('The network card "' + $script:SwitchAlias + '" was not found, so the rule cannot be limited to it. Nothing was changed (no rule, no setting, no restart).') 'FAIL'
    Write-Mig 'The Default Switch card exists once Hyper-V has created it (start the VM once, or open Hyper-V Manager), and its name must contain "Default Switch". Then run -Install again.' 'INFO'
    return $false
  }
  if (-not $want.Program) { Write-Mig ('ollama.exe was not found at ' + $script:OllamaExe + '. The rule will not be limited to that program.') 'WARN' }
  $ex = Get-BridgeRule
  if (Test-RuleMatches -Info $ex -Want $want) { Write-Mig ('rule "' + $script:RuleName + '" already exists and is correct') 'SKIP'; return $true }
  $cmd = 'New-NetFirewallRule -DisplayName ''' + $script:RuleName + ''' -Direction Inbound -Action Allow -Protocol TCP -LocalPort ' + $script:Port + ' -RemoteAddress ' + $want.Remote + ' -Profile Any'
  if ($want.Alias) { $cmd += ' -InterfaceAlias ''' + $want.Alias + '''' }
  if ($want.Program) { $cmd += ' -Program ''' + $want.Program + '''' }
  if ($ex.Exists) { Write-Mig ('rule "' + $script:RuleName + '" exists but is different (it will be replaced)') 'INFO' }
  if ($DryRun) {
    if ($ex.Exists) { Write-Mig ('would remove the old rule "' + $script:RuleName + '"') 'DRY' }
    Write-Mig ('would run: ' + $cmd) 'DRY'
    return $true
  }
  try {
    if ($ex.Exists) { Remove-NetFirewallRule -DisplayName $script:RuleName -ErrorAction Stop }
    $splat = @{ DisplayName = $script:RuleName; Description = 'Pillagers: lets VMs on the Hyper-V Default Switch reach Ollama. Remove with tools\migrate\host-ollama-bridge.ps1 -Undo'; Direction = 'Inbound'; Action = 'Allow'; Protocol = 'TCP'; LocalPort = $script:Port; RemoteAddress = $want.Remote; Profile = 'Any'; Enabled = 'True' }
    if ($want.Program) { $splat['Program'] = $want.Program }
    # The card limit is part of the safety, so there is no fallback to an address-only rule: if Windows refuses it, the whole step fails (and the catch below stops the install).
    $splat['InterfaceAlias'] = $want.Alias
    New-NetFirewallRule @splat -ErrorAction Stop | Out-Null
    $st['ruleCreated'] = $true
    $st['ruleRemote'] = $want.Remote
    Save-BridgeState
    $now = Get-BridgeRule
    Write-Mig ('rule created: inbound allow, TCP ' + $now.Port + ', from ' + $now.Remote + ', card ' + (@($now.Interface) -join ',') + ', program ' + $now.Program) 'OK'
    return $true
  } catch {
    Write-Mig ('could not create the firewall rule: ' + $_.Exception.Message) 'FAIL'
    return $false
  }
}

function Step-RemoveRule {
  Write-Mig 'Step 1: remove the Windows Firewall rule' 'STEP'
  $ex = Get-BridgeRule
  if (-not $ex.Exists) { Write-Mig ('rule "' + $script:RuleName + '" is not there') 'SKIP'; return $true }
  if ($DryRun) { Write-Mig ('would remove the rule "' + $script:RuleName + '"') 'DRY'; return $true }
  try {
    Remove-NetFirewallRule -DisplayName $script:RuleName -ErrorAction Stop
    $st['ruleCreated'] = $false
    Save-BridgeState
    Write-Mig ('rule "' + $script:RuleName + '" removed') 'OK'
    return $true
  } catch {
    Write-Mig ('could not remove the firewall rule: ' + $_.Exception.Message) 'FAIL'
    return $false
  }
}

function Step-SetEnv {
  Write-Mig ('Step 2: your user variable ' + $script:EnvName) 'STEP'
  $cur = [Environment]::GetEnvironmentVariable($script:EnvName, 'User')
  $mach = [Environment]::GetEnvironmentVariable($script:EnvName, 'Machine')
  if ($mach) { Write-Mig ('A computer-wide ' + $script:EnvName + ' is set to "' + $mach + '". The per-user value set here wins over it; this script leaves the computer-wide one alone.') 'INFO' }
  if ($cur -eq $script:EnvValue) { Write-Mig ($script:EnvName + ' is already ' + $script:EnvValue) 'SKIP'; return $true }
  if ($cur) { Write-Mig ('Your account already has ' + $script:EnvName + ' = "' + $cur + '". It is remembered and -Undo puts it back.') 'WARN' }
  if ($DryRun) { Write-Mig ('would set user variable ' + $script:EnvName + ' = ' + $script:EnvValue + ' (now: ' + $(if ($cur) { $cur } else { 'not set' }) + ')') 'DRY'; return $true }
  try {
    if (-not $st['envSetByUs']) { $st['envHadPrevious'] = [bool]$cur; $st['envPrevious'] = [string]$cur }
    [Environment]::SetEnvironmentVariable($script:EnvName, $script:EnvValue, 'User')
    $st['envSetByUs'] = $true
    Save-BridgeState
    Write-Mig ('user variable ' + $script:EnvName + ' set to ' + $script:EnvValue) 'OK'
    return $true
  } catch {
    Write-Mig ('could not set the variable: ' + $_.Exception.Message) 'FAIL'
    return $false
  }
}

function Step-RestoreEnv {
  Write-Mig ('Step 2: put your user variable ' + $script:EnvName + ' back') 'STEP'
  $cur = [Environment]::GetEnvironmentVariable($script:EnvName, 'User')
  $target = $null
  $do = $false
  if ($st['envSetByUs']) {
    if ($cur -eq $script:EnvValue) {
      $do = $true
      if ($st['envHadPrevious']) { $target = [string]$st['envPrevious'] }
    } elseif ($cur) { Write-Mig ($script:EnvName + ' is now "' + $cur + '" (not the value this script set), so it is left alone.') 'WARN' }
    else { Write-Mig ($script:EnvName + ' is already not set') 'SKIP' }
  } elseif ($cur -eq $script:EnvValue) { $do = $true }
  elseif ($cur) { Write-Mig ($script:EnvName + ' is "' + $cur + '" and was not set by this script, so it is left alone.') 'SKIP' }
  else { Write-Mig ($script:EnvName + ' is not set') 'SKIP' }
  if (-not $do) { return $true }
  if ($DryRun) { Write-Mig ('would ' + $(if ($target) { 'set ' + $script:EnvName + ' back to "' + $target + '"' } else { 'remove the user variable ' + $script:EnvName })) 'DRY'; return $true }
  try {
    [Environment]::SetEnvironmentVariable($script:EnvName, $target, 'User')
    $st['envSetByUs'] = $false
    Save-BridgeState
    Write-Mig ($(if ($target) { $script:EnvName + ' put back to "' + $target + '"' } else { 'user variable ' + $script:EnvName + ' removed' })) 'OK'
    return $true
  } catch {
    Write-Mig ('could not change the variable: ' + $_.Exception.Message) 'FAIL'
    return $false
  }
}

function Wait-Listener {
  # Waits until Ollama listens (any address) and, with -WantWide, on every address. Returns the final Get-ListenState.
  param([bool]$WantWide, [int]$Seconds)
  $end = (Get-Date).AddSeconds($Seconds)
  $ls = Get-ListenState
  while ((Get-Date) -lt $end) {
    $ls = Get-ListenState
    if ($ls.Any -and (($WantWide -and $ls.Wide) -or ((-not $WantWide) -and $ls.LoopbackOnly))) { break }
    Start-Sleep -Seconds 2
  }
  return $ls
}

function Step-RestartOllama {
  # $Want = 'wide' (after -Install) or 'loopback' (after -Undo)
  param([string]$Want)
  Write-Mig 'Step 3: restart Ollama so it reads the setting' 'STEP'
  $wantWide = ($Want -eq 'wide')
  $ls = Get-ListenState
  $procs = @(Get-OllamaProcs)
  if ($wantWide -and $ls.Wide) { Write-Mig 'Ollama already listens on every address, no restart needed' 'SKIP'; return 'ok' }
  if ((-not $wantWide) -and $ls.Any -and (-not $ls.Wide)) { Write-Mig 'Ollama already listens on this PC only, no restart needed' 'SKIP'; return 'ok' }
  if ((-not $ls.Any) -and $procs.Count -eq 0) { Write-Mig 'Ollama is not running right now. The next time it starts (Start menu, or tools\party-start.ps1) it reads the setting.' 'INFO'; return 'ok' }
  if ($NoRestart) {
    Write-Mig 'Not restarting Ollama (-NoRestart). Do this yourself: right-click the llama icon near the clock, choose Quit, then start Ollama from the Start menu.' 'INFO'
    return 'manual'
  }
  Write-Mig 'Ollama may update itself while it restarts (a newer version was already downloaded), which can take a minute.' 'INFO'
  $ps = Invoke-QuickGet -Url ('http://127.0.0.1:' + $script:Port + '/api/ps') -TimeoutMs 3000
  if ($ps.Ok) {
    $loaded = @(Get-ModelNames -Body $ps.Body)
    if ($loaded.Count -gt 0) {
      Write-Mig ('A model is in memory right now (' + ($loaded -join ', ') + '). A code review may be running on it; restarting cuts it off. tools\ship-review.ps1 simply asks again on its next round.') 'WARN'
      if (-not (Confirm-Plain 'Restart Ollama now?')) { Write-Mig 'Cancelled. Nothing was restarted. Run this again later (or with -NoRestart).' 'INFO'; return 'manual' }
    }
  }
  if (-not (Test-Path -LiteralPath $script:OllamaApp)) { Write-Mig ('Ollama is not installed where expected: ' + $script:OllamaApp) 'FAIL'; return 'failed' }
  if ($DryRun) {
    Write-Mig ('would stop ' + $procs.Count + ' Ollama process(es): ' + ((@($procs | ForEach-Object { $_.Name }) | Sort-Object -Unique) -join ', ')) 'DRY'
    Write-Mig ('would start "' + $script:OllamaApp + '" again as you (through Explorer, so it does NOT run as administrator)') 'DRY'
    return 'ok'
  }
  # stop the tray app first (it owns the server), then whatever is left
  $appProcs = @($procs | Where-Object { $_.Name -eq 'ollama app.exe' })
  if ($appProcs.Count -gt 0) { [void](Stop-ProcList -Procs $appProcs -What 'Ollama tray app') }
  Start-Sleep -Seconds 3
  $left = @(Get-OllamaProcs)
  if ($left.Count -gt 0) { [void](Stop-ProcList -Procs $left -What 'Ollama server') }
  $end = (Get-Date).AddSeconds(20)
  while ((Get-Date) -lt $end -and (Get-ListenState).Any) { Start-Sleep -Seconds 1 }
  if ((Get-ListenState).Any) { Write-Mig 'Something still listens on port 11434 after the stop. Not starting a second Ollama.' 'FAIL'; return 'failed' }
  Write-Mig 'Ollama stopped. Starting it again as you ...' 'INFO'
  try { Start-Process -FilePath 'explorer.exe' -ArgumentList ('"' + $script:OllamaApp + '"') } catch { Write-Mig ('could not start Ollama: ' + $_.Exception.Message) 'FAIL'; return 'failed' }
  $newApp = $null
  $end = (Get-Date).AddSeconds(30)
  while ((Get-Date) -lt $end -and -not $newApp) {
    Start-Sleep -Seconds 1
    $newApp = Get-Process -Name 'ollama app' -ErrorAction SilentlyContinue | Select-Object -First 1
  }
  if (-not $newApp) { Write-Mig 'Ollama did not appear after 30 seconds. Start it from the Start menu, then run -Status.' 'WARN'; return 'failed' }
  # never leave Ollama running as administrator: only a problem when your normal desktop is not elevated
  $e = Get-ProcElevation -ProcessId $newApp.Id
  $ex = -1
  $explorer = Get-Process -Name 'explorer' -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($explorer) { $ex = Get-ProcElevation -ProcessId $explorer.Id }
  if ($e -eq 1 -and $ex -eq 0) {
    Write-Mig 'Ollama came back running as administrator, which it should not. Stopping it. Please start Ollama from the Start menu yourself, then run -Status.' 'FAIL'
    [void](Stop-ProcList -Procs @(Get-OllamaProcs) -What 'elevated Ollama')
    return 'failed'
  }
  $ls = Wait-Listener -WantWide $wantWide -Seconds 90
  if ($wantWide -and $ls.Wide) { Write-Mig 'Ollama is back and listens on every address.' 'OK'; return 'ok' }
  if ((-not $wantWide) -and $ls.Any -and (-not $ls.Wide)) { Write-Mig 'Ollama is back and listens on this PC only.' 'OK'; return 'ok' }
  if (-not $ls.Any) { Write-Mig 'Ollama is not listening yet (it may be installing its update). Wait a minute, then run -Status.' 'WARN'; return 'failed' }
  if ($wantWide) {
    Write-Mig 'Ollama is back but still listens on this PC only. The new variable probably did not reach it. Fix: sign out of Windows and in again, or open Ollama Settings (llama icon, Settings) and switch on "Expose Ollama to the network". Then run -Status.' 'WARN'
  } else {
    Write-Mig 'Ollama is back but still listens on every address. Its own Settings may have "Expose Ollama to the network" switched on; switch it off there.' 'WARN'
  }
  return 'failed'
}

# ------------------------------------------------------------------ status
function Show-Status {
  param($Sw)
  Write-Mig 'Ollama bridge status (read only)' 'STEP'
  Write-Mig ('Hyper-V Default Switch card "' + $script:SwitchAlias + '": ' + $(if ($Sw.Found) { 'found, address ' + $Sw.Ip + '/' + $Sw.Prefix + ' (network ' + $Sw.Cidr + ')' } else { 'NOT found (is Hyper-V on? the fallback ' + $script:FallbackIp + ' is used below)' })) $(if ($Sw.Found) { 'OK' } else { 'WARN' })
  if ($Sw.Found -and $Sw.Cidr -ne $script:FallbackCidr) { Write-Mig ('The Default Switch network is not the usual ' + $script:FallbackCidr + ' any more. Run -Install again to move the firewall rule, and tell the VM (vm-user-settings.ps1 -HostIp ' + $Sw.Ip + ').') 'WARN' }

  $procs = @(Get-OllamaProcs)
  if ($procs.Count -eq 0) { Write-Mig 'Ollama is not running.' 'WARN' }
  else {
    foreach ($p in $procs) { Write-Mig ('process: ' + $p.Name + ' (id ' + $p.ProcessId + ')') 'INFO' }
  }
  $ls = Get-ListenState
  if (-not $ls.Any) { Write-Mig ('Nothing listens on port ' + $script:Port + '.') 'WARN' }
  foreach ($l in $ls.Listeners) {
    $what = $(if (Test-WideAddr $l.Addr) { 'every network card' } elseif ($l.Addr -eq '127.0.0.1' -or $l.Addr -eq '::1') { 'this PC only' } else { 'one card only' })
    Write-Mig ('listening on ' + $l.Addr + ':' + $script:Port + ' (' + $what + ') by ' + $l.ProcName) 'INFO'
  }

  $u = [Environment]::GetEnvironmentVariable($script:EnvName, 'User')
  $m = [Environment]::GetEnvironmentVariable($script:EnvName, 'Machine')
  Write-Mig ('user variable ' + $script:EnvName + ': ' + $(if ($u) { $u } else { 'not set' }) + $(if ($m) { '   (computer-wide: ' + $m + ')' } else { '' })) 'INFO'
  if ($st['envSetByUs']) { Write-Mig ('this script set it; before that it was ' + $(if ($st['envHadPrevious']) { '"' + $st['envPrevious'] + '"' } else { 'not set' })) 'INFO' }

  $rule = Get-BridgeRule
  $want = [pscustomobject]@{ Port = '11434'; Remote = $Sw.Cidr; Alias = $(if ($Sw.Found) { $script:SwitchAlias } else { '' }); Program = $(if (Test-Path -LiteralPath $script:OllamaExe) { $script:OllamaExe } else { '' }) }
  $ruleOk = $false
  if (-not $rule.Exists) { Write-Mig ('firewall rule "' + $script:RuleName + '": not there') 'WARN' }
  else {
    Write-Mig ('firewall rule "' + $script:RuleName + '": ' + $rule.Direction + ' ' + $rule.Action + ', enabled ' + $rule.Enabled + ', TCP ' + $rule.Port + ', from ' + $rule.Remote + ', card ' + (@($rule.Interface) -join ',') + ', profile ' + $rule.Profile) 'INFO'
    $ruleOk = Test-RuleMatches -Info $rule -Want $want
    if ($ruleOk) { Write-Mig 'the rule is correct for the current Default Switch network' 'OK' }
    else { Write-Mig 'the rule differs from what -Install would create now (run -Install to fix it)' 'WARN' }
  }
  $problems = @()
  $fw = Get-FirewallPosture
  if (-not $fw.Readable) { Write-Mig ('Could not read the Windows Firewall state (' + $fw.Error + ').') 'WARN'; $problems += 'the Windows Firewall state could not be read' }
  elseif ($fw.Problems.Count -gt 0) {
    foreach ($pr in $fw.Problems) { Write-Mig ('FIREWALL: ' + $pr + '. Ollama listens on every card, so the firewall is what keeps your network out; this is not safe.') 'FAIL'; $problems += $pr }
  } else { Write-Mig 'the Windows Firewall is on for Domain, Private and Public and blocks inbound by default (good)' 'OK' }
  $other = Get-OtherOpenRules
  if (-not $other.Readable) { Write-Mig 'Could not read all firewall rules from this window (open an administrator window to check for other rules that mention Ollama or port 11434, including a block rule Windows may have added).' 'INFO' }
  elseif ($other.Rules.Count -eq 0 -and $other.Blocks.Count -eq 0) { Write-Mig 'no other enabled inbound rule mentions Ollama or port 11434 (good)' 'OK' }
  else {
    foreach ($o in $other.Rules) {
      $broad = Test-BroadRemote $o.Remote
      if ($broad) {
        Write-Mig ('OTHER allow rule "' + $o.Name + '" (profile ' + $o.Profile + ', from ' + $(if ($o.Remote) { $o.Remote } else { 'anywhere' }) + ') lets OTHER computers on your network reach Ollama. This script does not touch it. If you did not make it on purpose, remove it in an administrator window: Remove-NetFirewallRule -Name ''' + $o.Id + '''') 'FAIL'
        $problems += ('another rule lets other computers reach Ollama: ' + $o.Name)
      } else { Write-Mig ('OTHER allow rule "' + $o.Name + '" (profile ' + $o.Profile + ', from ' + $o.Remote + ')') 'INFO' }
    }
    foreach ($b in $other.Blocks) {
      Write-Mig ('BLOCK rule "' + $b.Name + '" (profile ' + $b.Profile + ') for Ollama or port ' + $script:Port + '. A block rule beats the allow rule, so the VM cannot get through. Windows adds one when the "Allow Ollama on networks?" window is closed with Cancel. If you did not make it on purpose, remove it in an administrator window: Remove-NetFirewallRule -Name ''' + $b.Id + '''') 'FAIL'
      $problems += ('a block rule stops the bridge: ' + $b.Name)
    }
  }

  $t1 = Invoke-QuickGet -Url ('http://127.0.0.1:' + $script:Port + '/api/tags') -TimeoutMs 3000
  if ($t1.Ok) { Write-Mig ('test from this PC to http://127.0.0.1:' + $script:Port + '/api/tags: answers (' + @(Get-ModelNames -Body $t1.Body).Count + ' model(s), ' + $t1.Ms + ' ms)') 'OK' }
  else { Write-Mig ('test from this PC to http://127.0.0.1:' + $script:Port + '/api/tags: ' + $t1.Error) 'WARN' }
  $url = 'http://' + $Sw.Ip + ':' + $script:Port
  $t2 = Invoke-QuickGet -Url ($url + '/api/tags') -TimeoutMs 3000
  if ($t2.Ok) { Write-Mig ('test from this PC to ' + $url + '/api/tags: answers (' + $t2.Ms + ' ms) - Ollama listens on the Default Switch address') 'OK' }
  else { Write-Mig ('test from this PC to ' + $url + '/api/tags: ' + $t2.Error) 'WARN' }
  Write-Mig 'Note: a test from this PC to its own address goes around the Windows Firewall, so it proves the LISTENING part only. The real proof is vm-user-settings.ps1 run inside the VM.' 'INFO'

  Write-MigBlank
  if ($ls.Wide -and $rule.Exists -and $ruleOk -and $t2.Ok -and $problems.Count -eq 0) { Write-Mig ('READY for the VM: use ' + $url + ' (the VM sets PILLAGERS_OLLAMA_URL to it with vm-user-settings.ps1).') 'DONE' }
  else {
    $todo = @()
    foreach ($pr in $problems) { $todo += $pr }
    if (-not $ls.Wide) { $todo += 'Ollama does not listen on every address yet' }
    if (-not $rule.Exists) { $todo += 'the firewall rule is missing' } elseif (-not $ruleOk) { $todo += 'the firewall rule needs updating' }
    if (-not $t2.Ok -and $ls.Wide) { $todo += 'the test to the Default Switch address failed' }
    $tail = '. Run -Install (in an administrator window; add -DryRun first to look).'
    if ($problems.Count -gt 0) { $tail = '. Fix the FAIL / WARN lines above first (-Install refuses while the firewall is not safe), then run -Install in an administrator window (add -DryRun first to look).' }
    Write-Mig ('NOT ready: ' + ($todo -join '; ') + $tail) 'WARN'
  }
}

# ------------------------------------------------------------------ main
$modeCount = (@($Install.IsPresent, $Undo.IsPresent, $Status.IsPresent) | Where-Object { $_ }).Count
if ($modeCount -gt 1) { Write-Mig 'Use only one of -Install, -Undo, -Status.' 'FAIL'; Exit-Mig 1 }
$mode = 'Status'
if ($Install) { $mode = 'Install' } elseif ($Undo) { $mode = 'Undo' }
if ($modeCount -eq 0) {
  Write-Mig 'No mode given, so this only shows the status (read only). To change something use -Install or -Undo (add -DryRun to look first).' 'INFO'
}
Write-Mig ('host-ollama-bridge.ps1 - mode: ' + $mode + $(if ($DryRun) { ' (DRY RUN: nothing is changed)' } else { '' })) 'STEP'

$swi = Get-SwitchInfo

if ($mode -eq 'Status') {
  Show-Status -Sw $swi
  Exit-Mig 0
}

if (-not (Test-Path -LiteralPath $script:OllamaApp) -and $mode -eq 'Install') {
  Write-Mig ('Ollama is not installed where expected (' + $script:OllamaApp + '). Nothing was changed.') 'FAIL'
  Exit-Mig 1
}
if (-not $DryRun) {
  if (-not $isAdmin) {
    Write-Mig 'This needs an ADMINISTRATOR PowerShell window (the guide, Step 0A, shows how). Nothing was changed.' 'FAIL'
    Exit-Mig 3
  }
  if (-not (Test-HostProfileOk)) { Exit-Mig 1 }
} elseif (-not $isAdmin) {
  Write-Mig 'This is not an administrator window. The dry run still works; the real run needs one.' 'INFO'
}

if ($mode -eq 'Install') {
  # Safety gate, before anything is shown as a plan or changed: the Windows Firewall is the only thing that keeps the rest of the network out of an
  # Ollama that listens on every card. Read it (changes nothing) and REFUSE if it is not clearly doing that job.
  Write-Mig 'Safety check: is the Windows Firewall really protecting this PC? (reading only)' 'STEP'
  $fw = Get-FirewallPosture
  $refuse = @()
  if (-not $fw.Readable) { $refuse += ('the Windows Firewall state could not be read (' + $fw.Error + ')') }
  else {
    foreach ($ln in $fw.Lines) { Write-Mig ('  ' + $ln) 'INFO' }
    foreach ($pr in $fw.Problems) { $refuse += $pr }
  }
  $oth = Get-OtherOpenRules
  if (-not $oth.Readable) {
    if ($isAdmin) { $refuse += 'the firewall rules could not be read in full, so other rules that already open Ollama or port 11434 cannot be ruled out' }
    else { Write-Mig 'This (non-administrator) window cannot read all firewall rules, so the check for other rules that open Ollama is skipped in this dry run. The real run, in an administrator window, makes it and refuses if it cannot.' 'INFO' }
  }
  else {
    foreach ($o in $oth.Rules) {
      if (Test-BroadRemote $o.Remote) { $refuse += ('another enabled rule "' + $o.Name + '" (profile ' + $o.Profile + ', from ' + $(if ($o.Remote) { $o.Remote } else { 'anywhere' }) + ') already lets other computers reach Ollama or port ' + $script:Port + '. To remove it: Remove-NetFirewallRule -Name ''' + $o.Id + '''') }
    }
    foreach ($b in $oth.Blocks) { Write-Mig ('A BLOCK rule "' + $b.Name + '" for Ollama or port ' + $script:Port + ' exists. It would stop the bridge from working (a block beats an allow). To remove it: Remove-NetFirewallRule -Name ''' + $b.Id + '''') 'WARN' }
  }
  if ($refuse.Count -gt 0) {
    Write-MigBlank
    Write-Mig 'REFUSED. Nothing was changed (no rule, no OLLAMA_HOST, no restart). Why:' 'FAIL'
    foreach ($r in $refuse) { Write-Mig ('   - ' + $r) 'FAIL' }
    Write-Mig 'Ollama has no password; with an open firewall it would be reachable from your whole network. Fix the reason above (this script never changes the firewall settings of Windows itself), then run -Install again.' 'INFO'
    Exit-Mig 2
  }
  if ($oth.Readable) { Write-Mig 'The firewall is on for Domain, Private and Public, blocks inbound by default, and no other rule opens Ollama (good).' 'OK' }
  else { Write-Mig 'The firewall is on for Domain, Private and Public and blocks inbound by default (good).' 'OK' }
  Write-MigBlank
  Show-Warning -Sw $swi
  if (-not (Confirm-Plain 'Do you want to go on?')) { Write-Mig 'Cancelled. Nothing was changed.' 'INFO'; Exit-Mig $(if ($script:ConfirmRedirected) { 2 } else { 0 }) }
  $okRule = Step-Rule -Sw $swi
  if (-not $okRule) { Write-Mig 'Stopping here because the firewall rule could not be made (Ollama is not changed).' 'FAIL'; Exit-Mig 1 }
  $okEnv = Step-SetEnv
  if (-not $okEnv) { Exit-Mig 1 }
  $res = Step-RestartOllama -Want 'wide'
  Write-MigBlank
  if ($DryRun) { Write-Mig 'Dry run finished. Nothing was changed. Run again without -DryRun to do it.' 'DONE'; Exit-Mig 0 }
  Show-Status -Sw $swi
  if ($res -eq 'failed') { $script:ExitCode = 2 }
  Write-MigBlank
  Write-Mig 'Next: inside the VM run vm-user-settings.ps1. It prints PASS when the VM can reach Ollama through this bridge.' 'INFO'
  Exit-Mig $script:ExitCode
}

# Undo
$okRule = Step-RemoveRule
$okEnv = Step-RestoreEnv
$res = Step-RestartOllama -Want 'loopback'
Write-MigBlank
if ($DryRun) { Write-Mig 'Dry run finished. Nothing was changed.' 'DONE'; Exit-Mig 0 }
Show-Status -Sw $swi
if (-not ($okRule -and $okEnv)) { $script:ExitCode = 1 } elseif ($res -eq 'failed') { $script:ExitCode = 2 }
Exit-Mig $script:ExitCode
