# host-vm-boost.ps1 : gives the Pillagers VM more CPU, RAM and (optionally) a share of the Radeon GPU, then sends the kit and the GPU driver into it.
#
# Run it in an ADMINISTRATOR PowerShell window on this PC (JUL26). Look first, then do it:
#   powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-vm-boost.ps1" -DryRun
#   powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-vm-boost.ps1"
#   -MemoryGB N           RAM for the VM, fixed (default 12; this PC keeps 6 GB free, so it may pick 10 or 8 if 12 does not fit)
#   -CPUs N               virtual processors (default 12 of the 16 this PC has)
#   -NoGpu                RAM and processors only, no GPU share (checkpoints are left alone; use this if the GPU share gives trouble)
#   -GpuPercent N         share of the GPU for the VM, 10 to 100 (default 80)
#   -HighMmioGB N         address space reserved for the GPU, 16 to 128 (default 32; try 48 if Device Manager in the VM says code 12)
#   -Undo                 take the GPU share away and put the VM back as it was before the first boost (8 GB and 4 processors if unknown)
#   -DryRun               only print what would change
#   -RemoveCheckpoints    allow this script to delete the VM's checkpoints (a GPU share does not work with checkpoints)
#   -BackupVhdx           copy the VM disk to a .vhdx next to it before changing things (a rollback point, since checkpoints are off)
#   -RebuildDriver        build the GPU driver pack again even if the host driver did not change
#   -ResendDriver         send the GPU driver pack to the VM again even if the same pack was sent before
#   -SkipSettingsExport   do not run host-settings-export.ps1 first
#   -NoPush               change the VM only; do not send the kit or the driver pack
#   -PushFiles            when finished, run host-push-files.ps1 (first pass of the Pillagers files)
#   -VMName NAME          the VM (default Pillagers_Oct26)
#
# Order: build the driver pack (the VM is not touched yet) -> read this PC look-and-feel settings -> shut the VM down cleanly ->
# set CPU/RAM/checkpoints/stop action -> GPU share -> start the VM and wait for it -> send the kit and the driver pack to C:\PillagersMove.
# It never changes Defender, firewall, UAC, BitLocker or other security settings. On this PC it changes only the VM's Hyper-V settings and
# its own files (the kit folder, the staging folder outside the repository, and one line in .git/info/exclude).
# Safe to repeat: when everything already matches, the VM is not shut down.
# Exit codes: 0 done, 2 stopped or something did not arrive (read the last FAIL line), 3 needs an administrator window, 1 error.
# ASCII only. Works in Windows PowerShell 5.1 and PowerShell 7.
param(
  [string]$VMName = 'Pillagers_Oct26',
  [int]$MemoryGB = 12,
  [int]$CPUs = 12,
  [switch]$NoGpu,
  [double]$GpuPercent = 80,
  [int]$HighMmioGB = 32,
  [switch]$Undo,
  [switch]$DryRun,
  [switch]$RemoveCheckpoints,
  [switch]$BackupVhdx,
  [switch]$RebuildDriver,
  [switch]$ResendDriver,
  [switch]$SkipSettingsExport,
  [switch]$NoPush,
  [switch]$PushFiles,
  [int]$ShutdownTimeoutSec = 240
)
$ErrorActionPreference = 'Continue'
if (-not $PSScriptRoot) { Write-Host 'Please run this from its file, not pasted into a window.'; exit 1 }
$commonPath = Join-Path $PSScriptRoot 'host-common.ps1'
if (-not (Test-Path -LiteralPath $commonPath)) { Write-Host ('host-common.ps1 is missing next to this script: ' + $commonPath); exit 1 }
. $commonPath
Start-MigLog -Name 'host-vm-boost'

$memoryGiven = $PSBoundParameters.ContainsKey('MemoryGB')
$beforePath = Join-Path $script:StateDir 'vm-before.json'
$lastPath = Join-Path $script:StateDir 'host-vm-boost-last.json'
$payloadDir = Join-Path $script:HostStage 'payload'
$zipPath = Join-Path $payloadDir 'gpu-driver.zip'
$guestZip = $script:GuestStage + '\payload\gpu-driver.zip'
$t0 = Get-Date

Write-MigBlank
if ($Undo) { Write-Mig '=== VM BOOST: UNDO (take the GPU share away, back to 8 GB and 4 processors) ===' 'STEP' } else { Write-Mig '=== VM BOOST: more CPU, RAM and GPU for the Pillagers VM ===' 'STEP' }
if ($DryRun) { Write-Mig '(dry run: nothing is changed, built or sent)' 'DRY' }

# ------------------------------------------------------------------ checks
if (-not (Test-IsAdmin)) {
  Write-Mig 'This changes Hyper-V settings, so it needs an administrator window.' 'FAIL'
  Write-Mig 'Right-click the PowerShell icon, choose "Run as administrator", and run the same command again.' 'FAIL'
  Exit-Mig 3
}
if (-not (Get-Command Get-VM -ErrorAction SilentlyContinue)) { Write-Mig 'The Hyper-V PowerShell module is not installed on this PC.' 'FAIL'; Exit-Mig 1 }
if (-not (Test-HostProfileOk)) { Exit-Mig 1 }
if (($GpuPercent -lt 10) -or ($GpuPercent -gt 100)) { Write-Mig '-GpuPercent must be between 10 and 100.' 'FAIL'; Exit-Mig 1 }
if (($MemoryGB -lt 4) -or ($MemoryGB -gt 64)) { Write-Mig '-MemoryGB must be between 4 and 64.' 'FAIL'; Exit-Mig 1 }
if ($CPUs -lt 1) { Write-Mig '-CPUs must be at least 1.' 'FAIL'; Exit-Mig 1 }
if (($HighMmioGB -lt 16) -or ($HighMmioGB -gt 128)) { Write-Mig '-HighMmioGB must be between 16 and 128.' 'FAIL'; Exit-Mig 1 }
$vm = $null
try { $vm = Get-VM -Name $VMName -ErrorAction Stop }
catch {
  Write-Mig ('The VM "' + $VMName + '" was not found on this PC.') 'FAIL'
  try { Write-Mig ('VMs here: ' + ((Get-VM | ForEach-Object { $_.Name }) -join ', ')) 'INFO' } catch { }
  Exit-Mig 1
}

# ------------------------------------------------------------------ helpers
function Get-HostAvailMB {
  try { return [int]((Get-Counter '\Memory\Available MBytes' -ErrorAction Stop).CounterSamples[0].CookedValue) } catch { }
  try { return [int]((Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop).FreePhysicalMemory / 1024) } catch { }
  return -1
}

function Scale-U64 {
  param([uint64]$Base, [double]$Fraction)
  if ($Fraction -ge 1.0) { return $Base }
  return [uint64][math]::Floor([decimal]$Base * [decimal]$Fraction)
}

function Stop-VMClean {
  # Shuts the VM down through Windows (no power cut). Only if Windows does not answer in time is the power cut, and it says so.
  param([string]$Name, [int]$TimeoutSec)
  $v = Get-VM -Name $Name
  if ($v.State -eq 'Off') { Write-Mig 'The VM is already off.' 'SKIP'; return $true }
  if ($v.State -eq 'Paused') { try { Resume-VM -Name $Name -ErrorAction Stop } catch { } }
  if ($v.State -eq 'Saved') {
    Write-Mig 'The VM is in a saved state; starting it once so Windows inside can shut down cleanly.' 'INFO'
    try { Start-VM -Name $Name -ErrorAction Stop | Out-Null } catch { Write-Mig ('could not start it: ' + $_.Exception.Message) 'WARN' }
    Start-Sleep -Seconds 30
  }
  Write-Mig 'Asking Windows in the VM to shut down ...' 'INFO'
  try { Stop-VM -Name $Name -Force -ErrorAction Stop } catch { Write-Mig ('shutdown request: ' + $_.Exception.Message) 'WARN' }
  $t = Get-Date
  while (((Get-Date) - $t).TotalSeconds -lt $TimeoutSec) {
    $v = Get-VM -Name $Name
    if ($v.State -eq 'Off') { Write-Mig 'The VM is off.' 'OK'; return $true }
    Start-Sleep -Seconds 3
  }
  Write-Mig ('Windows in the VM did not shut down within ' + $TimeoutSec + ' seconds. Cutting the power now (like holding the power button). Unsaved work inside the VM is lost.') 'WARN'
  try { Stop-VM -Name $Name -TurnOff -Force -ErrorAction Stop } catch { Write-Mig ('power cut failed: ' + $_.Exception.Message) 'FAIL'; return $false }
  $t = Get-Date
  while (((Get-Date) - $t).TotalSeconds -lt 60) {
    if ((Get-VM -Name $Name).State -eq 'Off') { Write-Mig 'The VM is off.' 'OK'; return $true }
    Start-Sleep -Seconds 2
  }
  Write-Mig 'The VM did not turn off.' 'FAIL'
  return $false
}

function Build-GpuPack {
  # Zips the AMD driver package and the System32/SysWOW64 files that belong to the GPU into gpu-driver.zip (nothing is installed on this PC).
  param($Facts, [string]$ZipFile)
  Add-Type -AssemblyName System.IO.Compression
  Add-Type -AssemblyName System.IO.Compression.FileSystem
  $res = [ordered]@{ Ok = $false; Note = ''; Files = 0; Extra = 0; Bytes = [int64]0; Sha256 = '' }
  $pkg = $Facts.PackagePath
  $pkgLeaf = Split-Path -Path $pkg -Leaf
  Write-Mig ('driver folder: ' + $pkg) 'INFO'
  Write-Mig 'asking Windows which extra driver files belong to the GPU (this takes about 30 seconds) ...' 'INFO'
  $extra = @()
  try {
    $extra = @(Get-CimInstance -ClassName Win32_PnPSignedDriverCIMDataFile -ErrorAction Stop |
        Where-Object { $_.Antecedent.DeviceID -eq $Facts.InstanceId } |
        ForEach-Object { $_.Dependent.Name } |
        Where-Object { $_ -and ($_ -notmatch '(?i)\\driverstore\\') -and ($_ -notmatch '(?i)\\windows\\inf\\') -and ($_ -match '(?i)\\windows\\(system32|syswow64)\\') } |
        Sort-Object -Unique)
  } catch { $res.Note = 'could not list the extra driver files: ' + $_.Exception.Message; Write-Mig $res.Note 'FAIL'; return [pscustomobject]$res }
  Write-Mig ('   ' + $extra.Count + ' extra files in System32 and SysWOW64') 'INFO'
  if ($extra.Count -eq 0) { Write-Mig 'Windows listed no extra driver files for this GPU. That is unusual for an AMD driver: the VM may fall back to software drawing. The pack is still built; check the Radeon in the VM.' 'WARN' }
  if (Test-Path -LiteralPath $ZipFile) { Remove-Item -LiteralPath $ZipFile -Force }
  $dir = Split-Path -Path $ZipFile -Parent
  if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
  $zip = [System.IO.Compression.ZipFile]::Open($ZipFile, [System.IO.Compression.ZipArchiveMode]::Create)
  $listed = New-Object System.Collections.Generic.List[string]
  $bad = 0
  $logsSkipped = 0
  $pkgBad = 0
  $badNames = New-Object System.Collections.Generic.List[string]
  try {
    $pkgFiles = @(Get-ChildItem -LiteralPath $pkg -Recurse -File -Force -ErrorAction SilentlyContinue)
    foreach ($f in $pkgFiles) {
      $rel = $f.FullName.Substring($pkg.TrimEnd('\').Length + 1).Replace('\', '/')
      $name = 'System32/HostDriverStore/FileRepository/' + $pkgLeaf + '/' + $rel
      if (Add-ZipFile -Zip $zip -Path $f.FullName -EntryName $name) { $res.Files++ }
      elseif ($f.Name -match '(?i)\.(log|tmp|etl)$') { $logsSkipped++ }   # the AMD driver keeps its own log open with no sharing; it is not needed
      else { $bad++; $badNames.Add($rel) }
    }
    $pkgBad = $bad
    if ($logsSkipped -gt 0) { Write-Mig ('   ' + $logsSkipped + ' log file(s) in the driver folder are locked by the running driver and were left out (not needed)') 'INFO' }
    foreach ($p in $extra) {
      $m = [regex]::Match($p, '(?i)\\windows\\(system32|syswow64)\\(.+)$')
      if (-not $m.Success) { continue }
      $top = 'System32'
      if ($m.Groups[1].Value -ieq 'syswow64') { $top = 'SysWOW64' }
      $name = $top + '/' + $m.Groups[2].Value.Replace('\', '/')
      if (Add-ZipFile -Zip $zip -Path $p -EntryName $name) { $res.Extra++; $listed.Add($name) } else { $bad++ }
    }
    # files.txt lets an undo delete exactly what was added: one path per line, relative to C:\Windows, forward slashes; a line ending in / is a folder to delete with everything in it
    $listed.Add('System32/HostDriverStore/FileRepository/' + $pkgLeaf + '/')
    $ent = $zip.CreateEntry('files.txt', [System.IO.Compression.CompressionLevel]::Fastest)
    $w = New-Object System.IO.StreamWriter($ent.Open(), [System.Text.Encoding]::ASCII)
    $w.Write((($listed.ToArray()) -join "`n") + "`n")
    $w.Dispose()
    $info = [ordered]@{ gpu = $Facts.Gpu; driver = $Facts.Driver; driverDate = $Facts.DriverDate; package = $Facts.Package; service = $Facts.Service; hostBuild = $Facts.HostBuild; dxgkrnl = $Facts.Dxgkrnl; built = (Get-Date).ToString('s'); packageFiles = $res.Files; extraFiles = $res.Extra }
    $ent2 = $zip.CreateEntry('pack-info.json', [System.IO.Compression.CompressionLevel]::Fastest)
    $w2 = New-Object System.IO.StreamWriter($ent2.Open(), [System.Text.Encoding]::ASCII)
    $w2.Write(($info | ConvertTo-Json -Depth 4))
    $w2.Dispose()
  } finally { $zip.Dispose() }
  if ($pkgBad -gt 0) { $res.Note = $pkgBad.ToString() + ' driver package file(s) could not be read: ' + ((@($badNames.ToArray()) | Select-Object -First 5) -join ', '); Write-Mig $res.Note 'FAIL'; return [pscustomobject]$res }
  if (($bad - $pkgBad) -gt 0) { Write-Mig (($bad - $pkgBad).ToString() + ' extra file(s) could not be read (in use?); the GPU may still work, check it in the VM') 'WARN' }
  $res.Bytes = (Get-Item -LiteralPath $ZipFile).Length
  $res.Sha256 = (Get-FileHash -LiteralPath $ZipFile -Algorithm SHA256).Hash.ToLowerInvariant()
  $res.Ok = $true
  return [pscustomobject]$res
}

function Add-ZipFile {
  param($Zip, [string]$Path, [string]$EntryName)
  $fs = $null
  try {
    $fs = [System.IO.File]::Open($Path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
    $entry = $Zip.CreateEntry($EntryName, [System.IO.Compression.CompressionLevel]::Fastest)
    $es = $entry.Open()
    try { $fs.CopyTo($es) } finally { $es.Dispose() }
    return $true
  } catch { return $false }
  finally { if ($null -ne $fs) { $fs.Dispose() } }
}

function Wait-ForMerge {
  param([string]$Name, [int]$TimeoutSec = 900)
  $t = Get-Date
  while (((Get-Date) - $t).TotalSeconds -lt $TimeoutSec) {
    $n = @(Get-VMSnapshot -VMName $Name -ErrorAction SilentlyContinue).Count
    $st = [string](Get-VM -Name $Name).Status
    if (($n -eq 0) -and ($st -notmatch '(?i)merg')) { return $true }
    Start-Sleep -Seconds 5
  }
  return $false
}

# ------------------------------------------------------------------ UNDO
if ($Undo) {
  $rMem = 8; $rCpu = 4; $rLow = 128MB; $rHigh = 512MB; $rCp = 'Production'; $rStop = 'ShutDown'; $rDyn = $false
  if (Test-Path -LiteralPath $beforePath) {
    try {
      $b = Get-Content -LiteralPath $beforePath -Raw | ConvertFrom-Json
      if ([int64]$b.MemoryStartup -ge 2GB) { $rMem = [math]::Round([int64]$b.MemoryStartup / 1GB, 2) }
      if ([int]$b.Cpu -ge 1) { $rCpu = [int]$b.Cpu }
      if ([int64]$b.LowMmio -gt 0) { $rLow = [uint32]$b.LowMmio }
      if ([int64]$b.HighMmio -gt 0) { $rHigh = [uint64]$b.HighMmio }
      if ($b.Checkpoint) { $rCp = [string]$b.Checkpoint }
      if ($b.Stop) { $rStop = [string]$b.Stop }
      if ($b.Dynamic) { $rDyn = $true }
      Write-Mig ('restoring the values recorded before the first boost (' + $b.time + ')') 'INFO'
    } catch { Write-Mig 'vm-before.json could not be read; using 8 GB and 4 processors' 'WARN' }
  } else { Write-Mig 'no earlier record; using the defaults 8 GB and 4 processors' 'INFO' }
  Write-Mig ('target: ' + $rMem + ' GB fixed RAM, ' + $rCpu + ' processors, no GPU share, checkpoints ' + $rCp + ', stop action ' + $rStop) 'INFO'
  $adapters = @(Get-VMGpuPartitionAdapter -VMName $VMName -ErrorAction SilentlyContinue)
  $wasRunning = ($vm.State -eq 'Running')
  if ($DryRun) {
    Write-Mig ('would shut the VM down, remove ' + $adapters.Count + ' GPU share(s), set RAM/CPU/MMIO/checkpoint values, and start it again: ' + $wasRunning) 'DRY'
    Exit-Mig 0
  }
  if (-not (Stop-VMClean -Name $VMName -TimeoutSec $ShutdownTimeoutSec)) { Exit-Mig 2 }
  $guard = 0
  while ((@(Get-VMGpuPartitionAdapter -VMName $VMName -ErrorAction SilentlyContinue).Count -gt 0) -and ($guard -lt 4)) {
    $guard++
    try { Remove-VMGpuPartitionAdapter -VMName $VMName -ErrorAction Stop; Write-Mig 'GPU share removed' 'OK' } catch { Write-Mig ('could not remove the GPU share: ' + $_.Exception.Message) 'FAIL'; break }
  }
  try {
    Set-VM -Name $VMName -GuestControlledCacheTypes $false -LowMemoryMappedIoSpace $rLow -HighMemoryMappedIoSpace $rHigh -CheckpointType $rCp -AutomaticStopAction $rStop -ErrorAction Stop
    Set-VMMemory -VMName $VMName -DynamicMemoryEnabled $rDyn -StartupBytes ([int64]($rMem * 1GB)) -ErrorAction Stop
    Set-VMProcessor -VMName $VMName -Count $rCpu -ErrorAction Stop
    Write-Mig ('VM settings restored: ' + $rMem + ' GB' + $(if ($rDyn) { ' (dynamic)' } else { '' }) + ', ' + $rCpu + ' processors') 'OK'
  } catch { Write-Mig ('could not restore a setting: ' + $_.Exception.Message) 'FAIL'; Exit-Mig 2 }
  if ($wasRunning) {
    try { Start-VM -Name $VMName -ErrorAction Stop | Out-Null; Write-Mig 'The VM is starting again.' 'OK' } catch { Write-Mig ('could not start the VM: ' + $_.Exception.Message) 'WARN' }
  }
  Write-MigBlank
  Write-Mig 'Undo finished on the host side.' 'DONE'
  Write-Mig 'Inside the VM (administrator PowerShell), clean up the copied driver files, then restart the VM:' 'INFO'
  Write-Mig '   delete the folders u0*.inf_amd64_* under C:\Windows\System32\HostDriverStore\FileRepository' 'INFO'
  Write-Mig '   and the files listed in files.txt inside gpu-driver.zip (the VM stage "gpu" has a clean-up for this)' 'INFO'
  Write-Mig 'The host AMD driver was not touched.' 'INFO'
  Exit-Mig 0
}

# ------------------------------------------------------------------ facts
Write-MigBlank
Write-Mig 'Step 1: what is there now' 'STEP'
$logical = 16
try { $logical = [int](Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction Stop).NumberOfLogicalProcessors } catch { }
$vmMem = Get-VMMemory -VMName $VMName
$adapters = @(Get-VMGpuPartitionAdapter -VMName $VMName -ErrorAction SilentlyContinue)
$snaps = @(Get-VMSnapshot -VMName $VMName -ErrorAction SilentlyContinue)
Write-Mig ('VM ' + $VMName + ': ' + $vm.State + ', RAM ' + [math]::Round($vm.MemoryStartup / 1GB, 1) + ' GB' + $(if ($vm.DynamicMemoryEnabled) { ' (dynamic)' } else { ' (fixed)' }) + ', ' + $vm.ProcessorCount + ' processors, checkpoints ' + $vm.CheckpointType + ', ' + $snaps.Count + ' existing checkpoint(s), ' + $adapters.Count + ' GPU share(s)') 'INFO'
Write-Mig ('this PC: ' + $logical + ' logical processors, Windows build ' + (Get-HostBuildString)) 'INFO'

# record the VM exactly as it was the first time, so -Undo can go back
if ((-not (Test-Path -LiteralPath $beforePath)) -and (-not $DryRun)) {
  $before = [ordered]@{
    time = (Get-Date).ToString('s'); Vm = $VMName; MemoryStartup = [int64]$vm.MemoryStartup; Dynamic = [bool]$vm.DynamicMemoryEnabled
    Cpu = [int]$vm.ProcessorCount; Checkpoint = [string]$vm.CheckpointType; Stop = [string]$vm.AutomaticStopAction
    GuestControlledCacheTypes = [bool]$vm.GuestControlledCacheTypes; LowMmio = [int64]$vm.LowMemoryMappedIoSpace; HighMmio = [int64]$vm.HighMemoryMappedIoSpace
  }
  Write-AsciiFile -Path $beforePath -Text ($before | ConvertTo-Json)
  Write-Mig 'saved the VM settings as they were (state\vm-before.json) for -Undo' 'OK'
}

# memory plan with the guard: this PC must keep 6 GB free (+0.5 GB overhead)
$availMB = Get-HostAvailMB
$heldMB = 0
if ($vm.State -eq 'Running') { $heldMB = [int]($vm.MemoryAssigned / 1MB) }
$ceilGB = -1
if ($availMB -ge 0) { $ceilGB = [int][math]::Floor(($availMB + $heldMB - 6144 - 512) / 1024) }
Write-Mig ('this PC has ' + [math]::Round($availMB / 1024, 1) + ' GB available (cache included) plus ' + [math]::Round($heldMB / 1024, 1) + ' GB the VM holds now; keeping 6 GB free leaves room for about ' + $ceilGB + ' GB for the VM') 'INFO'
$memGB = $MemoryGB
if ($MemoryGB -gt 12) { Write-Mig 'More than 12 GB for the VM is not recommended on this PC.' 'WARN' }
if ($ceilGB -ge 0 -and $memGB -gt $ceilGB) {
  if ($memoryGiven) {
    Write-Mig ('Only ' + $ceilGB + ' GB can go to the VM while this PC keeps 6 GB free; you asked for ' + $MemoryGB + ' GB. Stop other programs, or pass a smaller -MemoryGB.') 'FAIL'
    Exit-Mig 2
  }
  $memGB = 0
  foreach ($c in @(12, 10, 8)) { if ($c -le $ceilGB) { $memGB = $c; break } }
  if ($memGB -eq 0) {
    $memGB = [int][math]::Round($vm.MemoryStartup / 1GB)
    Write-Mig ('Even 8 GB does not fit right now; the VM keeps its ' + $memGB + ' GB.') 'WARN'
  } else { Write-Mig ('12 GB does not fit right now; using ' + $memGB + ' GB.') 'WARN' }
}
$cpu = $CPUs
if ($cpu -gt $logical) { $cpu = $logical; Write-Mig ('This PC has only ' + $logical + ' logical processors; using ' + $cpu) 'WARN' }
elseif ($cpu -gt ($logical - 4)) { Write-Mig ('Giving the VM ' + $cpu + ' of ' + $logical + ' processors can slow this PC while the VM is busy. 12 is the usual choice.') 'WARN' }
Write-Mig ('plan: ' + $memGB + ' GB fixed RAM, ' + $cpu + ' processors' + $(if ($NoGpu) { ', no GPU share' } else { ', GPU share ' + $GpuPercent + ' percent' })) 'INFO'
if ($memGB -lt 16) { Write-Mig 'Inside the VM the runner waits for 6 GB of free RAM before it starts a job, so with this much RAM only one or two jobs run at a time. Once Pillagers is stopped on this PC you can raise it with -MemoryGB 16 if the guard allows.' 'INFO' }

# ------------------------------------------------------------------ GPU facts and the driver pack
$facts = $null
$vramV = [uint64]0; $encV = [uint64]0; $decV = [uint64]0; $compV = [uint64]0
$hostGpus = @()
$packInfo = $null
$packReuse = $false
if (-not $NoGpu) {
  Write-MigBlank
  Write-Mig 'Step 2: the GPU' 'STEP'
  Write-Mig 'Sharing a Radeon with a VM (GPU partitioning) is NOT officially supported on Windows 11 PCs. It can fail: black screen, driver time-outs, no DX12/Vulkan. It is fully reversible (-Undo, or -NoGpu).' 'WARN'
  $facts = Get-GpuHostFacts
  if (-not $facts.Ok) { Write-Mig ('GPU not usable for sharing: ' + $facts.Error) 'FAIL'; Write-Mig 'Run again with -NoGpu to boost CPU and RAM only.' 'INFO'; Exit-Mig 2 }
  Write-Mig ('GPU: ' + $facts.Gpu + ', driver ' + $facts.Driver + ' (' + $facts.DriverDate + '), package folder ' + $facts.Package) 'INFO'
  try { $hostGpus = @(Get-VMHostPartitionableGpu -ErrorAction Stop) } catch { Write-Mig ('Get-VMHostPartitionableGpu failed: ' + $_.Exception.Message) 'FAIL'; Exit-Mig 2 }
  $amd = $hostGpus | Where-Object { $_.Name -match 'VEN_1002' } | Select-Object -First 1
  if (-not $amd) { Write-Mig 'The AMD GPU is not listed as shareable on this PC.' 'FAIL'; Write-Mig 'Run again with -NoGpu to boost CPU and RAM only.' 'INFO'; Exit-Mig 2 }
  $cim = Get-CimInstance -Namespace 'root\virtualization\v2' -ClassName Msvm_PartitionableGpu -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'VEN_1002' } | Select-Object -First 1
  if (-not $cim) { Write-Mig 'Could not read the GPU share limits (Msvm_PartitionableGpu).' 'FAIL'; Exit-Mig 2 }
  $fr = $GpuPercent / 100.0
  # whole-card values as Windows reports them; if one is missing, use the well-known whole-card numbers (1000000000, and the largest number for encode)
  $baseVram = [uint64]1000000000; $baseEnc = [uint64]::MaxValue; $baseDec = [uint64]1000000000; $baseComp = [uint64]1000000000
  try { if ([uint64]$cim.MaxPartitionVRAM -gt 0) { $baseVram = [uint64]$cim.MaxPartitionVRAM } } catch { }
  try { if ([uint64]$cim.MaxPartitionEncode -gt 0) { $baseEnc = [uint64]$cim.MaxPartitionEncode } } catch { }
  try { if ([uint64]$cim.MaxPartitionDecode -gt 0) { $baseDec = [uint64]$cim.MaxPartitionDecode } } catch { }
  try { if ([uint64]$cim.MaxPartitionCompute -gt 0) { $baseComp = [uint64]$cim.MaxPartitionCompute } } catch { }
  $vramV = Scale-U64 $baseVram $fr
  $encV = Scale-U64 $baseEnc $fr
  $decV = Scale-U64 $baseDec $fr
  $compV = Scale-U64 $baseComp $fr
  Write-Mig ('GPU share values (relative units, not bytes): VRAM ' + $vramV + ' of ' + $baseVram + ', compute ' + $compV + ' of ' + $baseComp + ', encode ' + $encV + ', decode ' + $decV + ' of ' + $baseDec) 'INFO'
  # the driver pack
  $mf = Get-GpuPackManifestPath
  $drift = Compare-GpuDrift $facts
  if ((-not $RebuildDriver) -and (Test-Path -LiteralPath $zipPath) -and (Test-Path -LiteralPath $mf) -and ($drift -eq '')) {
    try {
      $pm = Get-Content -LiteralPath $mf -Raw | ConvertFrom-Json
      if ($pm.zipSha256 -and ((Get-FileHash -LiteralPath $zipPath -Algorithm SHA256).Hash.ToLowerInvariant() -eq [string]$pm.zipSha256)) { $packReuse = $true; $packInfo = $pm }
    } catch { }
  }
  if ($packReuse) { Write-Mig ('driver pack is current (' + (Format-Bytes ((Get-Item -LiteralPath $zipPath).Length)) + ', built ' + $packInfo.built + '); reusing it') 'OK' }
  elseif ($DryRun) { Write-Mig ('would build the driver pack gpu-driver.zip (about 0.5 GB) from ' + $facts.PackagePath + '; reason: ' + $(if ($drift) { $drift } else { 'rebuild asked for or zip missing' })) 'DRY' }
  else {
    if ($drift) { Write-Mig $drift 'INFO' }
    $free = Get-DriveFreeBytes $script:HostStage
    if (($free -ge 0) -and ($free -lt 4GB)) { Write-Mig ('Not enough room to build the driver pack in ' + $script:HostStage) 'FAIL'; Exit-Mig 2 }
    Write-Mig 'building the driver pack ...' 'INFO'
    $bp = Build-GpuPack -Facts $facts -ZipFile $zipPath
    if (-not $bp.Ok) { Write-Mig ('driver pack failed: ' + $bp.Note) 'FAIL'; Exit-Mig 2 }
    $packInfo = [ordered]@{
      Gpu = $facts.Gpu; InstanceId = $facts.InstanceId; Driver = $facts.Driver; DriverDate = $facts.DriverDate; Service = $facts.Service
      Package = $facts.Package; HostBuild = $facts.HostBuild; Dxgkrnl = $facts.Dxgkrnl; built = (Get-Date).ToString('s')
      zipFile = 'gpu-driver.zip'; zipBytes = [int64]$bp.Bytes; zipSha256 = $bp.Sha256; packageFiles = $bp.Files; extraFiles = $bp.Extra
    }
    Write-AsciiFile -Path $mf -Text ($packInfo | ConvertTo-Json -Depth 4)
    Write-Mig ('driver pack ready: ' + (Format-Bytes $bp.Bytes) + ', ' + $bp.Files + ' package files + ' + $bp.Extra + ' extra files; recorded in gpu-pack-manifest.json') 'OK'
  }
}

# ------------------------------------------------------------------ what has to change
Write-MigBlank
Write-Mig 'Step 3: what has to change' 'STEP'
$changes = New-Object System.Collections.Generic.List[string]
$needOff = $false
if ($vm.DynamicMemoryEnabled -or ([int64]$vm.MemoryStartup -ne ([int64]$memGB * 1GB))) { $changes.Add('RAM: ' + [math]::Round($vm.MemoryStartup / 1GB, 1) + ' GB' + $(if ($vm.DynamicMemoryEnabled) { ' dynamic' } else { '' }) + ' -> ' + $memGB + ' GB fixed'); $needOff = $true }
if ([int]$vm.ProcessorCount -ne $cpu) { $changes.Add('processors: ' + $vm.ProcessorCount + ' -> ' + $cpu); $needOff = $true }
if ([string]$vm.AutomaticStopAction -ne 'ShutDown') { $changes.Add('when this PC shuts down: ' + $vm.AutomaticStopAction + ' -> ShutDown (the VM is shut down cleanly)') }
if ($vm.AutomaticCheckpointsEnabled) { $changes.Add('automatic checkpoints: on -> off') }
$gsi = Get-VMIntegrationService -VMName $VMName -Name 'Guest Service Interface' -ErrorAction SilentlyContinue
if ($gsi -and -not $gsi.Enabled) { $changes.Add('file-copy channel (Guest Service Interface): off -> on') }
if (-not $NoGpu) {
  if ([string]$vm.CheckpointType -ne 'Disabled') { $changes.Add('checkpoints: ' + $vm.CheckpointType + ' -> Disabled (needed for the GPU share)') }
  if (-not $vm.GuestControlledCacheTypes) { $changes.Add('guest-controlled cache types: off -> on'); $needOff = $true }
  if ([int64]$vm.LowMemoryMappedIoSpace -ne 3GB) { $changes.Add('low MMIO: ' + [math]::Round($vm.LowMemoryMappedIoSpace / 1MB) + ' MB -> 3072 MB'); $needOff = $true }
  if ([int64]$vm.HighMemoryMappedIoSpace -ne ([int64]$HighMmioGB * 1GB)) { $changes.Add('high MMIO: ' + [math]::Round($vm.HighMemoryMappedIoSpace / 1GB, 2) + ' GB -> ' + $HighMmioGB + ' GB'); $needOff = $true }
  $ad = $adapters | Select-Object -First 1
  if (-not $ad) { $changes.Add('GPU share: none -> ' + $GpuPercent + ' percent of the Radeon'); $needOff = $true }
  elseif (([uint64]$ad.MaxPartitionVRAM -ne $vramV) -or ([uint64]$ad.MinPartitionVRAM -ne $vramV) -or ([uint64]$ad.OptimalPartitionVRAM -ne $vramV) -or ([uint64]$ad.MaxPartitionCompute -ne $compV) -or ([uint64]$ad.MaxPartitionEncode -ne $encV) -or ([uint64]$ad.MaxPartitionDecode -ne $decV)) {
    $changes.Add('GPU share values -> ' + $GpuPercent + ' percent'); $needOff = $true
  }
  if ($snaps.Count -gt 0) { $needOff = $true }
}
if ($changes.Count -eq 0) { Write-Mig 'The VM already has all of these settings; it will not be shut down.' 'OK' }
else { foreach ($c in $changes) { Write-Mig ('   ' + $c) 'INFO' } }
if ($snaps.Count -gt 0) {
  Write-Mig ('The VM has ' + $snaps.Count + ' checkpoint(s): ' + (($snaps | ForEach-Object { $_.Name }) -join ', ')) 'INFO'
  if (-not $NoGpu) {
    if (-not $RemoveCheckpoints) {
      Write-Mig 'A GPU share does not work while the VM has checkpoints. Nothing was changed.' 'FAIL'
      Write-Mig 'Either add -RemoveCheckpoints (deletes them and merges their changes into the disk; you can no longer roll back to them), or use -NoGpu.' 'FAIL'
      Write-Mig 'Tip: add -BackupVhdx too, to keep a copy of the disk as the rollback point.' 'INFO'
      Exit-Mig 2
    }
    $changes.Add('delete ' + $snaps.Count + ' checkpoint(s)')
    Write-Mig ('   delete ' + $snaps.Count + ' checkpoint(s) (you asked with -RemoveCheckpoints)') 'WARN'
  }
}
if ($BackupVhdx) { Write-Mig '   copy the VM disk to a backup .vhdx before changing it' 'INFO' }

if ($DryRun) {
  Write-MigBlank
  if ($needOff -or $BackupVhdx) { Write-Mig 'would shut the VM down cleanly first, then apply the changes above and start it again.' 'DRY' }
  if (-not $SkipSettingsExport) { Write-Mig 'would run host-settings-export.ps1 (read-only) so the look-and-feel file is fresh.' 'DRY' }
  [void](Ensure-KitExcluded -DryRun)
  if (-not $NoPush) { Write-Mig ('would send the kit to ' + $script:GuestStage + '\kit' + $(if (-not $NoGpu) { ' and gpu-driver.zip to ' + $guestZip } else { '' })) 'DRY' }
  if ($PushFiles) { Write-Mig 'would then run host-push-files.ps1 (first pass).' 'DRY' }
  Write-MigBlank
  Write-Mig 'Dry run finished. Nothing was changed.' 'DONE'
  Exit-Mig 0
}

# ------------------------------------------------------------------ do it
[void](Ensure-KitExcluded)
if (-not $SkipSettingsExport) {
  Write-MigBlank
  Write-Mig 'Step 4: read this PC look-and-feel settings (read-only)' 'STEP'
  $ex = Join-Path $PSScriptRoot 'host-settings-export.ps1'
  if (Test-Path -LiteralPath $ex) {
    $out = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $ex 2>&1
    foreach ($l in @($out)) { Write-Mig ('   ' + [string]$l) 'INFO' }
  } else { Write-Mig 'host-settings-export.ps1 is missing, skipped' 'WARN' }
}

$applied = New-Object System.Collections.Generic.List[string]
if ($needOff -or $BackupVhdx -or ($snaps.Count -gt 0 -and -not $NoGpu)) {
  Write-MigBlank
  Write-Mig 'Step 5: shut the VM down and change it' 'STEP'
  if (-not (Stop-VMClean -Name $VMName -TimeoutSec $ShutdownTimeoutSec)) { Exit-Mig 2 }
  if (($snaps.Count -gt 0) -and -not $NoGpu) {
    Write-Mig 'deleting checkpoints and waiting for the merge (can take several minutes) ...' 'INFO'
    try {
      # remove each top-level checkpoint together with its children (removing a child first would make the later removal fail)
      $roots = @(Get-VMSnapshot -VMName $VMName -ErrorAction Stop | Where-Object { -not $_.ParentSnapshotName })
      if ($roots.Count -eq 0) { $roots = @(Get-VMSnapshot -VMName $VMName -ErrorAction Stop) }
      foreach ($rt in $roots) { Remove-VMSnapshot -VMName $VMName -Name $rt.Name -IncludeAllChildSnapshots -ErrorAction Stop }
    } catch { Write-Mig ('could not delete the checkpoints: ' + $_.Exception.Message) 'FAIL'; Exit-Mig 2 }
    if (-not (Wait-ForMerge -Name $VMName)) { Write-Mig 'The checkpoint merge did not finish in 15 minutes. Check Hyper-V Manager, then run this again.' 'FAIL'; Exit-Mig 2 }
    Write-Mig 'checkpoints deleted and merged' 'OK'
  }
  if ($BackupVhdx) {
    $di = Get-VmDiskInfo -VMName $VMName
    if (-not $di.Ok) { Write-Mig ('could not read the VM disk: ' + $di.Error) 'FAIL'; Exit-Mig 2 }
    $dest = [System.IO.Path]::ChangeExtension($di.Path, $null).TrimEnd('.') + '-backup-' + (Get-Date -Format 'yyyyMMdd-HHmm') + [System.IO.Path]::GetExtension($di.Path)
    $need = $di.FileBytes + 20GB
    if (($di.HostVolumeFree -ge 0) -and ($di.HostVolumeFree -lt $need)) { Write-Mig ('Not enough room for a disk backup: need ' + (Format-Bytes $need) + ', have ' + (Format-Bytes $di.HostVolumeFree)) 'FAIL'; Exit-Mig 2 }
    Write-Mig ('copying the VM disk (' + (Format-Bytes $di.FileBytes) + ') to ' + $dest + ' ...') 'INFO'
    try { Copy-Item -LiteralPath $di.Path -Destination $dest -ErrorAction Stop; Write-Mig 'disk backup done (delete it when you no longer need the rollback point)' 'OK'; $applied.Add('disk backup: ' + $dest) } catch { Write-Mig ('disk backup failed: ' + $_.Exception.Message) 'FAIL'; Exit-Mig 2 }
  }
}
$isOff = ((Get-VM -Name $VMName).State -eq 'Off')
try {
  # RAM, processors and address space can only change while the VM is off (it is, whenever one of them differs: it was shut down above)
  if ($isOff) {
    Set-VMMemory -VMName $VMName -DynamicMemoryEnabled $false -StartupBytes ([int64]$memGB * 1GB) -ErrorAction Stop
    Set-VMProcessor -VMName $VMName -Count $cpu -ErrorAction Stop
  }
  if ($NoGpu) { Set-VM -Name $VMName -AutomaticCheckpointsEnabled $false -AutomaticStopAction ShutDown -ErrorAction Stop }
  else { Set-VM -Name $VMName -CheckpointType Disabled -AutomaticCheckpointsEnabled $false -AutomaticStopAction ShutDown -ErrorAction Stop }
  if ($isOff -and -not $NoGpu) {
    Set-VM -Name $VMName -GuestControlledCacheTypes $true -LowMemoryMappedIoSpace 3GB -HighMemoryMappedIoSpace ([int64]$HighMmioGB * 1GB) -ErrorAction Stop
  }
  Write-Mig ('RAM ' + $memGB + ' GB fixed, ' + $cpu + ' processors, stop action ShutDown' + $(if (-not $NoGpu) { ', checkpoints off, MMIO 3 GB / ' + $HighMmioGB + ' GB' } else { '' })) 'OK'
  Enable-VMIntegrationService -VMName $VMName -Name 'Guest Service Interface' -ErrorAction Stop
  Write-Mig 'file-copy channel (Guest Service Interface) is on' 'OK'
} catch { Write-Mig ('a VM setting failed: ' + $_.Exception.Message) 'FAIL'; Exit-Mig 2 }

if ((-not $NoGpu) -and $isOff) {
  try {
    if (@(Get-VMGpuPartitionAdapter -VMName $VMName -ErrorAction SilentlyContinue).Count -eq 0) {
      if ($hostGpus.Count -gt 1) { Add-VMGpuPartitionAdapter -VMName $VMName -InstancePath $amd.Name -ErrorAction Stop }
      else { Add-VMGpuPartitionAdapter -VMName $VMName -ErrorAction Stop }
      Write-Mig 'GPU share added to the VM' 'OK'
    }
    $gp = @{
      MinPartitionVRAM = $vramV; OptimalPartitionVRAM = $vramV; MaxPartitionVRAM = $vramV
      MinPartitionEncode = $encV; OptimalPartitionEncode = $encV; MaxPartitionEncode = $encV
      MinPartitionDecode = $decV; OptimalPartitionDecode = $decV; MaxPartitionDecode = $decV
      MinPartitionCompute = $compV; OptimalPartitionCompute = $compV; MaxPartitionCompute = $compV
    }
    Set-VMGpuPartitionAdapter -VMName $VMName @gp -ErrorAction Stop
    Write-Mig ('GPU share set to ' + $GpuPercent + ' percent (VRAM, compute, encode, decode)') 'OK'
  } catch {
    Write-Mig ('the GPU share could not be set: ' + $_.Exception.Message) 'FAIL'
    Write-Mig 'The VM still has the new RAM and processors. Run again with -NoGpu, or -Undo.' 'INFO'
    Exit-Mig 2
  }
}
foreach ($c in $changes) { $applied.Add($c) }

# ------------------------------------------------------------------ start and push
Write-MigBlank
Write-Mig 'Step 6: start the VM and wait for it' 'STEP'
$vm = Get-VM -Name $VMName
if ($vm.State -ne 'Running') {
  try { Start-VM -Name $VMName -ErrorAction Stop | Out-Null; Write-Mig 'VM started' 'OK' } catch { Write-Mig ('could not start the VM: ' + $_.Exception.Message) 'FAIL'; Exit-Mig 2 }
}
$ready = $false
if ($NoPush) { Write-Mig '-NoPush: not waiting for Windows, nothing is sent' 'SKIP' }
else {
  $ready = Wait-GuestReady -VMName $VMName
  if (-not $ready) { Write-Mig 'Windows in the VM is not ready for file copies yet. The settings ARE applied. Sign in to the VM once, then run this script again (it will not restart the VM) to send the kit.' 'WARN' }
}
$kitOk = $false
$zipOk = $false
if ($ready) {
  Write-MigBlank
  Write-Mig 'Step 7: send the kit and the driver pack into the VM' 'STEP'
  [void](Export-RunnerTaskXml)
  $kitOk = Send-KitToGuest -VMName $VMName -StageDir (Join-Path $script:HostStage 'kitstage')
  if (-not $NoGpu) {
    $zipSha = ''
    if ($packInfo) { $zipSha = [string]$packInfo.zipSha256 }
    $already = $false
    if ((-not $ResendDriver) -and $zipSha -and (Test-Path -LiteralPath $lastPath)) {
      try {
        $lj = Get-Content -LiteralPath $lastPath -Raw | ConvertFrom-Json
        if (($lj.driverSent -eq $true) -and ([string]$lj.driverSha256 -eq $zipSha) -and ([string]$lj.vm -eq $VMName)) { $already = $true }
      } catch { }
    }
    if ($already) {
      Write-Mig 'This driver pack (same fingerprint) was already sent to this VM, so it is not sent again. Add -ResendDriver to send it anyway.' 'SKIP'
      $zipOk = $true
    } else {
      Write-Mig ('sending gpu-driver.zip (' + (Format-Bytes ((Get-Item -LiteralPath $zipPath).Length)) + ') to ' + $guestZip + ' (a few minutes) ...') 'INFO'
      $zipOk = Copy-ToGuest -VMName $VMName -Source $zipPath -GuestPath $guestZip
      if ($zipOk) { Write-Mig 'driver pack sent' 'OK' } else { Write-Mig 'the driver pack did not arrive; run this script again' 'FAIL' }
    }
    # list the pack (with its fingerprint) in payload\manifest.json so the VM can check the copy
    if ($zipOk) {
      $mfPath = Join-Path $payloadDir 'manifest.json'
      $skeleton = (-not (Test-Path -LiteralPath $mfPath))
      $pushedFully = $false
      $psPath = Join-Path $script:StateDir 'push-state.json'
      if ((-not $skeleton) -and (Test-Path -LiteralPath $psPath)) {
        try {
          $pj = Get-Content -LiteralPath $psPath -Raw | ConvertFrom-Json
          $mj0 = Get-Content -LiteralPath $mfPath -Raw | ConvertFrom-Json
          $a1 = (@($pj.archives | ForEach-Object { [string]$_.file + ':' + [string]$_.sha256 }) | Sort-Object) -join '|'
          $a2 = (@($mj0.archives | Where-Object { [string]$_.group -ne 'gpu' } | ForEach-Object { [string]$_.file + ':' + [string]$_.sha256 }) | Sort-Object) -join '|'
          $pushedFully = (($a1 -eq $a2) -and ([string]$pj.vm -eq $VMName))
        } catch { }
      }
      if (Add-GpuEntryToManifest -ManifestPath $mfPath -ZipPath $zipPath) {
        if ($skeleton -or $pushedFully) {
          if (Copy-ToGuest -VMName $VMName -Source $mfPath -GuestPath ($script:GuestStage + '\payload\manifest.json')) { Write-Mig 'sent payload\manifest.json (lists the driver pack fingerprint)' 'OK' }
          else { Write-Mig 'payload\manifest.json did not arrive; the VM will not be able to check the driver pack copy' 'WARN' }
        } else {
          Write-Mig 'A file push is only partly done, so the manifest on this PC was updated but not sent. host-push-files.ps1 -PushOnly will send it.' 'INFO'
        }
      }
    }
  }
}

# remember what was done
try {
  $last = [ordered]@{ time = (Get-Date).ToString('s'); vm = $VMName; memoryGB = $memGB; cpus = $cpu; gpu = (-not $NoGpu); gpuPercent = $GpuPercent; kitSent = $kitOk; driverSent = $zipOk; applied = @($applied.ToArray()) }
  if ($packInfo) { $last['driver'] = $packInfo.Driver; $last['hostBuild'] = $packInfo.HostBuild; $last['driverSha256'] = [string]$packInfo.zipSha256 }
  Write-AsciiFile -Path $lastPath -Text ($last | ConvertTo-Json -Depth 4)
} catch { }

if ($PushFiles -and $ready) {
  Write-MigBlank
  Write-Mig 'Step 8: first pass of the Pillagers files (host-push-files.ps1)' 'STEP'
  $pf = Join-Path $PSScriptRoot 'host-push-files.ps1'
  & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $pf -VMName $VMName -NoKit
  if ($LASTEXITCODE -ne 0) { Write-Mig ('host-push-files.ps1 ended with code ' + $LASTEXITCODE + ' (see its log)') 'WARN' } else { Write-Mig 'files sent' 'OK' }
}

# ------------------------------------------------------------------ summary
Write-MigBlank
Write-Mig ('SUMMARY (' + [int]((Get-Date) - $t0).TotalMinutes + ' min)') 'STEP'
foreach ($a in $applied) { Write-Mig ('   changed: ' + $a) 'INFO' }
if ($applied.Count -eq 0) { Write-Mig '   the VM settings already matched; nothing was changed' 'INFO' }
if (-not $NoGpu -and $packInfo) { Write-Mig ('   GPU driver pack: driver ' + $packInfo.Driver + ' for Windows build ' + $packInfo.HostBuild) 'INFO' }
Write-Mig ('   kit sent: ' + $kitOk + '   driver pack sent: ' + $(if ($NoGpu) { 'not needed' } else { [string]$zipOk }) + '   log: ' + $script:MigLog) 'INFO'
Write-MigBlank
Write-Mig 'NEXT, inside the VM:' 'STEP'
Write-Mig '   1. Sign in. If the screen stays black with the GPU share, use "Basic session" in the VM window (View menu) instead of Enhanced.' 'INFO'
Write-Mig ('   2. Update Windows in the VM until its build matches this PC (build ' + (Get-HostBuildString) + '); a GPU share needs matching builds.') 'INFO'
Write-Mig '   3. Open an administrator PowerShell in the VM and run:  powershell -ExecutionPolicy Bypass -File C:\PillagersMove\kit\vm-setup.ps1' 'INFO'
Write-Mig '   4. Check the Radeon: Device Manager shows it without a warning, and dxdiag lists it. If it fails here: host-vm-boost.ps1 -Undo (or -NoGpu).' 'INFO'
Write-Mig '   5. Then on this PC: host-push-files.ps1 (files), later host-stop.ps1 and host-push-files.ps1 -Final.' 'INFO'
Write-Mig 'Still unproven on this exact PC: the GPU share, Xbox pads inside the VM, and fast graphics in the VM window. Test them early; the party on 10/30 can play on this PC.' 'WARN'
if ((-not $NoPush) -and ((-not $kitOk) -or ((-not $NoGpu) -and (-not $zipOk)))) { Exit-Mig 2 }
Exit-Mig 0
