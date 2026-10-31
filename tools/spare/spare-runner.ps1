# spare-runner.ps1 : THE SPARE PC RUNNER (2026-10-20). His spare PC (RTX 2080, AMD X3D, 16 GB; his words: "16gb ram, it can stay on and
# connected") becomes the TEST AND ROBOT machine, so the VM's memory goes to the helpers. It never ships, commits to the game or edits the
# game: its game copy (C:\claudecode\dark raiders, the same path as the VM so every test script works unchanged) refuses every push, and
# only the separate results copy (C:\PillagersSpare\results) pushes, and only to the spare-results branch on GitHub.
# What it does, every 5 minutes, with no Claude and no AI at all:
#   1. When no full test run is going: takes the newest game from GitHub master (a plain detached checkout of origin/master; this copy
#      has no work of its own), and when the game file changed since the last run it builds the test copy (tools\mkfixture.ps1) and
#      starts the full test run (tools\handoff\shipkit\corpq.sh, Chrome 9344), the same run the VM does, writing
#      C:\PillagersSpare\out\corpus\corpus-MMDD-HHMM.txt and a .head file naming the commit.
#   2. Keeps two crash robots going (tools\fuzz.ps1 on 9331 and 9332, 60 minute blocks, 3 of 4 raids the real 2-player demo) on the
#      full test run's copy of the game (tools\fxcorpus.html), so one exact version gets both, which is what the VM's stable picker needs.
#   3. Every 30 minutes, and at once when a full test run ends: copies the finished runs, the robot log and its problem records and a
#      status file into results\spare\HOSTNAME\ and pushes them to spare-results. The VM takes them in (tools\spare\spare-import.mjs).
# Its own test server (tools\spare\serve.mjs) listens on this PC only (127.0.0.1 and ::1, port 8806), so Windows asks no firewall
# question; this file never runs a firewall, Defender, UAC, power-plan or Windows Update command. While it runs it asks Windows to stay
# awake (the same request a video player makes); that ends when it stops.
# It refuses to run on the main PC (JUL26) or the VM, or without the marker file that spare-setup.ps1 writes.
# Start: wscript tools\spare\spare-start.vbs (the task made by spare-setup.ps1 does it at sign-in and every 15 minutes; a copy whose
# heartbeat is under 10 minutes old makes a new one exit). When master brings a new copy of this file, it restarts itself.
# Log: C:\PillagersSpare\runner.log. Status: C:\PillagersSpare\status.txt. ASCII only (PowerShell 5.1 reads .ps1 as ANSI).
# 10-22 IDLE MODE (his orders "When my main PC isn't being used, it should be used for testing too" and "its resources shouldn't be idle"):
# on the MAIN PC (JUL26) this runner works from its own copy, C:\PillagersIdle\game, never his old C:\claudecode\dark raiders there. It
# starts nothing until no key, mouse or game pad has been used for 15 minutes and 6 GB are free; it stops everything it started within
# seconds of a touch (or under 4 GB free); and a build another PC is testing or has tested stays that PC's: here it gets robots only.
# The VM's nights come first: from 22:40 to 23:10 it holds nothing, and until 06:45 it starts only with 10 GB free (see VMNight below).
# 10-28: while the VM's memory follows him it starts only after the VM stops growing and with 6 GB free, stops under 4 GB at two looks,
# waits 30 minutes after a memory stop, and runs one robot at 4K in both windows (see the idle loop, Watch and the robot lines). While he
# is at the PC but not playing, one robot runs at 1080p and below-normal priority; it stops within seconds once he plays (see Playing).
# 10-26 SPARE-PRESENCE-PAUSE (his "make it so that the JTPC pauses testing whenever someone is at the JTPC -- eg my son wants to use it
# for gaming"): the SPARE PC now stops all its test work (scripts and test Chromes) within seconds of someone being there, and starts
# again by itself once nobody has been there for 15 minutes. Someone is there when a key or the mouse was used, a game pad changed since
# the look before (a stick, pedal or trigger resting off centre is nobody), or another Windows account is signed in and unlocked at the
# screen (the sign-in and lock screens are nobody); and, for up to 2 hours after the last of those and only while this account is at the
# screen and unlocked, when a full-screen program runs (a game or a film), a program other than a test browser plays sound, or a program
# that is not a test browser works the graphics card (15% or more of its 3D engine at two looks in a row, a game). These are the signs
# of the stopgap pause-watch.ps1, which retires once this text is in the runner. A full test run stopped because someone is there gives
# its try back, so visits never use up a build's two tries. While paused its status says "paused: someone is using the PC" and when that
# began (paused_since=); the VM then runs the tests itself (tools/spare/spare-import.mjs, 64d6fec3). It stops only its own test parts,
# by the shape of the runner's own launches; one started by hand from a Windows program (Claude's PowerShell, a terminal window) and an
# editor or a search that only names a test script are left alone (one started from Git bash looks like the runner's and is stopped
# too). If the presence checks cannot load, it says PROBLEM in runner.log, adds presence=off to its status and tests as before. IDLE
# MODE on the main PC is unchanged by this: its check, what it stops and its tries are as before.
param([switch]$Once,[int]$FuzzMinutes=60,[int]$PublishMin=10)
$ErrorActionPreference='Continue'
$Idle=($env:COMPUTERNAME -eq 'JUL26')
if($Idle){ $R='C:\PillagersIdle\game'; $W='C:\PillagersIdle' } else { $R='C:\claudecode\dark raiders'; $W='C:\PillagersSpare' }
$T=$R+'\tools'
$Res=$W+'\results'; $Out=$W+'\out'; $FzOut=$Out+'\fuzz'; $CorpDir=$Out+'\corpus'
$Log=$W+'\runner.log'; $StateF=$W+'\state.txt'; $Hb=$W+'\runner.heartbeat'; $StatusF=$W+'\status.txt'
$Bash='C:\Program Files\Git\bin\bash.exe'; $Branch='spare-results'; $HostN=$env:COMPUTERNAME
$Enc=New-Object Text.UTF8Encoding $false

if($HostN -eq 'VM_Oct2026'){ Write-Output 'refusing: this is the VM, not a test PC'; exit 2 }
$Mark=$(if($Idle){ '.idle-pc' }else{ '.spare-pc' })
if(-not (Test-Path -LiteralPath ($R+'\'+$Mark))){ Write-Output ('refusing: no '+$Mark+' marker (run tools\spare\spare-setup.ps1 first)'); exit 2 }
# the test scripts (corpq.sh, corpus-slices.sh, fuzz.ps1) take their folders from these; unset, they use the spare PC's paths as before
if($Idle){ $env:PILLAGERS_ROOT=($R -replace '\\','/'); $env:PILLAGERS_SCRATCH=(($W+'\scratch') -replace '\\','/'); New-Item -ItemType Directory -Force -Path ($W+'\scratch') | Out-Null }
New-Item -ItemType Directory -Force -Path $W,$Out,$FzOut,$CorpDir | Out-Null
# 10-28 his "everything should restart automatically when I restart my pc": a heartbeat written before this boot is stale whatever its age.
# After his 23:12 restart the sign-in start found a heartbeat from before the restart, under 10 minutes old, and exited; the runner (and so
# 8802 and 8799) came back only with the 15-minute task at 23:24.
$Boot=$null; try{ $Boot=(Get-CimInstance Win32_OperatingSystem -ErrorAction Stop).LastBootUpTime }catch{}
function HbAgeSec(){ $t=(Get-Item -LiteralPath $Hb -ErrorAction Stop).LastWriteTime; if($Boot -and $t -lt $Boot){ return 1e9 }; return ((Get-Date)-$t).TotalSeconds }
if(-not $Once -and (Test-Path -LiteralPath $Hb)){
  if((HbAgeSec) -lt 600){ exit 0 }   # another copy is alive
}
# SPARE-PRESENCE-PAUSE: a heartbeat 10+ minutes old (or from before this boot) means this PC was off or the last copy died; a pause it was in
# is over (see below the functions). A copy that restarts itself for a new runner deletes the heartbeat first, so its pause and paused_since go on.
$HbOld=$false; if(-not $Idle){ try{ $HbOld=((HbAgeSec) -ge 600) }catch{} }
$Git=(Get-Command git -ErrorAction SilentlyContinue).Source; if(-not $Git){ $Git='C:\Program Files\Git\cmd\git.exe' }
$Node=(Get-Command node -ErrorAction SilentlyContinue).Source; if(-not $Node){ $Node='C:\Program Files\nodejs\node.exe' }

function Stamp(){ (Get-Date).ToString('MM-dd HH:mm') }
function Epoch(){ [DateTimeOffset]::UtcNow.ToUnixTimeSeconds() }
function Say([string]$s){ [IO.File]::AppendAllText($Log,(Stamp)+' '+($s -replace '[^\x20-\x7e]','?')+"`r`n",$Enc) }
function GetS([string]$k){
  if(Test-Path -LiteralPath $StateF){ foreach($l in [IO.File]::ReadAllLines($StateF)){ if($l.StartsWith($k+'=')){ return $l.Substring($k.Length+1) } } }
  return ''
}
function PutS([string]$k,[string]$v){
  $L=@(); if(Test-Path -LiteralPath $StateF){ $L=@([IO.File]::ReadAllLines($StateF) | Where-Object { -not $_.StartsWith($k+'=') }) }
  $L+=($k+'='+$v); [IO.File]::WriteAllLines($StateF,[string[]]$L,$Enc)
}
function G(){ $o = & $Git @args 2>&1; $script:gx=$LASTEXITCODE; return (($o | ForEach-Object { "$_" }) -join "`n").Trim() }
function Short([string]$s){ $s=($s -replace '\s+',' ').Trim(); if($s.Length -gt 160){ $s=$s.Substring(0,160) }; return $s }
function Running([string]$rx){
  @(Get-CimInstance Win32_Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessId -ne $PID -and $_.CommandLine -and ($_.CommandLine -match $rx) }).Count
}
function Up([int]$p,[string]$f){
  try{ $rq=[Net.WebRequest]::Create('http://127.0.0.1:'+$p+'/'+$f); $rq.Method='HEAD'; $rq.Timeout=4000; $rs=$rq.GetResponse(); $rs.Close(); return $true }catch{ return $false }
}
function GameVer(){
  try{ $m=[regex]::Match([IO.File]::ReadAllText($R+'\dark_raiders.html'),"var VER='([0-9]+\.[0-9]+)';"); if($m.Success){ return $m.Groups[1].Value } }catch{}
  return '?'
}

# keep the PC awake while this runs (ES_CONTINUOUS | ES_SYSTEM_REQUIRED); it ends with this process. Not on the main PC: that is his.
if(-not $Idle){ try{
  Add-Type -Namespace PillagersSpare -Name Power -MemberDefinition '[DllImport("kernel32.dll")] public static extern uint SetThreadExecutionState(uint f);' -ErrorAction Stop
  [void][PillagersSpare.Power]::SetThreadExecutionState([uint32]2147483649)
}catch{ Say ('could not ask Windows to stay awake: '+(Short "$_")) } }

# IDLE MODE: is he here? (his yes of 10-22: it may check how long since he last touched the keyboard, mouse or a pad, only to know whether
# he is away, and stop its own tests when he is back.) It reads the time since the last key or mouse input (GetLastInputInfo) and, for
# pads, whether a button, trigger or stick is past its rest zone at a check (XInput pads 1 to 4; a pad does not move the Windows idle clock
# and the party plays on pads). It records nothing of what was pressed.
# 10-26 SPARE-PRESENCE-PAUSE: the spare PC uses the same keyboard and mouse check; a pad counts only when it changed since the look before
# (PadMoved below, the stopgap's rule); it also counts another Windows account signed in and unlocked at the screen (fast user switching:
# this runner's own session is then in the background and sees no input; only whether the account at the screen is another one, and
# whether it is locked, is read, never its name), and the passive signs (a full-screen program, sound, a game on the graphics card) up to
# 2 hours ($PassCapSec) after the last key, mouse, pad or other sign-in. Its pad, account and game clocks start a day back; a copy that
# restarts itself during a pause first writes when someone was last there into state.txt (seen_t, human_t) and the new copy goes on from
# that, and every new copy looks for about 35 s before its first round (below the functions), so neither an update nor a restart starts
# the tests while someone is still there. If a check cannot load, it says PROBLEM and tests without it (as before this pause existed).
# The main PC keeps its own check exactly as before.
$script:padT=$(if($Idle){ Get-Date }else{ (Get-Date).AddDays(-1) }); $script:working=$false
$script:conT=(Get-Date).AddDays(-1); $script:conOn=$false; $script:gpuT=(Get-Date).AddDays(-1); $script:gpuChk=(Get-Date).AddDays(-1)
$script:gpuOn=$false; $script:gpuLast=''; $script:gpuPrev=@{}; $script:gpuPrevT=(Get-Date).AddDays(-1); $script:awayWhy=''; $script:pubTry=[long]0
$PassCapSec=7200; $script:pasT=(Get-Date).AddDays(-1); $script:pasWhy=''; $script:holdE=[long]0; $script:holdH=[long]0; $script:humanAgo=0.0
$script:capSaid=$false; $script:noIn=$false; $script:noPres=$false; $script:noSnd=$false; $script:sndSaid=$false; $script:sndCache=@{}
try{ Add-Type -Namespace PillagersIdle -Name Input -ErrorAction Stop -MemberDefinition @'
[StructLayout(LayoutKind.Sequential)] public struct LII { public uint cbSize; public uint dwTime; }
[DllImport("user32.dll")] static extern bool GetLastInputInfo(ref LII p);
[DllImport("xinput1_4.dll")] static extern uint XInputGetState(uint i, byte[] s);
public static double IdleSec(){ LII p = new LII(); p.cbSize = 8; if (!GetLastInputInfo(ref p)) return 0; return unchecked((uint)Environment.TickCount - p.dwTime) / 1000.0; }
public static bool PadInUse(){
  byte[] s = new byte[16];
  for (uint i = 0; i < 4; i++) {
    try { if (XInputGetState(i, s) != 0) continue; } catch { return false; }
    if (BitConverter.ToUInt16(s, 4) != 0 || s[6] > 30 || s[7] > 30) return true;
    for (int k = 8; k < 16; k += 2) { if (Math.Abs((int)BitConverter.ToInt16(s, k)) > 8000) return true; }
  }
  return false;
}
'@ }catch{
  if($Idle){ Say ('PROBLEM: cannot tell whether he is at the PC, so nothing runs: '+(Short "$_")); exit 1 }
  # SPARE PC: a runner that stops here publishes nothing and can never take a fixed copy from GitHub, so it tests as before this pause
  # existed (AwaySec says nobody) and says so
  $script:noIn=$true; Say ('PROBLEM: cannot tell whether someone is at the PC (the keyboard and mouse check did not load), so this runner tests without pausing for anyone: '+(Short "$_"))
}
# 10-28 (Main PC Correspondent), his "what about daytime testing when i'm at the pc?": the title of the window in front, so the runner can tell him working at the PC (one light robot may run) from him playing (nothing runs). If this does not load, nothing
# runs while he is at the PC, as before.
$script:noFg=$true
if($Idle){ try{ Add-Type -Namespace PillagersIdle -Name Fg -ErrorAction Stop -MemberDefinition @'
[DllImport("user32.dll")] static extern IntPtr GetForegroundWindow();
[DllImport("user32.dll", CharSet = CharSet.Unicode)] static extern int GetWindowText(IntPtr h, System.Text.StringBuilder s, int n);
public static string Title(){ try { System.Text.StringBuilder b = new System.Text.StringBuilder(512); GetWindowText(GetForegroundWindow(), b, 512); return b.ToString(); } catch { return ""; } }
'@; $script:noFg=$false }catch{ Say ('PROBLEM: the window-in-front check did not load, so nothing runs while he is at the PC (as before): '+(Short "$_")) } }
if(-not $Idle -and -not $script:noIn){
  $MySid=[uint32][Diagnostics.Process]::GetCurrentProcess().SessionId
  # another account at the screen: the console session is not this runner's, someone is signed in to it (the sign-in screen has no user
  # name), and it is not locked. WTSSessionInfoEx (25) gives WTSINFOEX: Level (1) at 0, then, 8-byte aligned, SessionId at 8, SessionState
  # at 12 and SessionFlags at 16 (0 locked, 1 unlocked on Windows 8 and later; checked on this PC 10-26: level 1, its own session id at 8,
  # flags 1 while in use). When that cannot be read, someone counts as there. MineAtScreen: this runner's own session is the one at the
  # screen and is not locked (the passive signs count only then; a lock state that cannot be read counts as unlocked). Quns: the shell's
  # notification state (SHQueryUserNotificationState): 2 busy (a full-screen program), 3 Direct3D full screen and 4 presentation mode
  # count; 1 (locked, screen saver), 5 normal, 6 quiet time and 7 (a Store app) do not. PadMoved: XInput pads 1 to 4, true when a pad
  # CHANGED since the last look (a button, a trigger by more than 30, a stick by more than 3000) or was switched on since then, never by
  # how far it rests from centre; the first look only records (pause-watch.ps1 PadPoll, the same thresholds).
  try{ Add-Type -Namespace PillagersSpare -Name Presence -ErrorAction Stop -MemberDefinition @'
[DllImport("kernel32.dll")] static extern uint WTSGetActiveConsoleSessionId();
[DllImport("wtsapi32.dll", CharSet = CharSet.Unicode, EntryPoint = "WTSQuerySessionInformationW")] static extern bool WTSQuerySessionInformation(IntPtr h, uint sid, int cls, out IntPtr buf, out uint n);
[DllImport("wtsapi32.dll")] static extern void WTSFreeMemory(IntPtr p);
public static bool OtherAtScreen(uint mine){
  uint s = WTSGetActiveConsoleSessionId(); if (s == 0xFFFFFFFF || s == mine) return false;
  IntPtr b; uint n; if (!WTSQuerySessionInformation(IntPtr.Zero, s, 5, out b, out n)) return false;
  try { if (String.IsNullOrEmpty(Marshal.PtrToStringUni(b))) return false; } finally { WTSFreeMemory(b); }
  if (!WTSQuerySessionInformation(IntPtr.Zero, s, 25, out b, out n)) return true;
  try { if (n < 20 || Marshal.ReadInt32(b, 0) != 1 || Marshal.ReadInt32(b, 8) != (int)s) return true; return Marshal.ReadInt32(b, 16) != 0; } finally { WTSFreeMemory(b); }
}
public static bool MineAtScreen(uint mine){
  if (WTSGetActiveConsoleSessionId() != mine) return false;
  IntPtr b; uint n; if (!WTSQuerySessionInformation(IntPtr.Zero, mine, 25, out b, out n)) return true;
  try { if (n < 20 || Marshal.ReadInt32(b, 0) != 1 || Marshal.ReadInt32(b, 8) != (int)mine) return true; return Marshal.ReadInt32(b, 16) != 0; } finally { WTSFreeMemory(b); }
}
[DllImport("shell32.dll")] static extern int SHQueryUserNotificationState(out int s);
public static int Quns(){ try { int s; if (SHQueryUserNotificationState(out s) != 0) return -1; return s; } catch { return -1; } }
[DllImport("xinput1_4.dll")] static extern uint XInputGetState(uint i, byte[] s);
static byte[][] padLast = new byte[4][];
static bool padFirst = true, padBroken = false;
public static bool PadMoved(){
  if (padBroken) return false;
  bool act = false;
  for (uint i = 0; i < 4; i++) {
    byte[] s = new byte[16]; uint rc;
    try { rc = XInputGetState(i, s); } catch { padBroken = true; return false; }
    if (rc != 0) { padLast[i] = null; continue; }
    byte[] p = padLast[i]; padLast[i] = s;
    if (p == null) { if (!padFirst) act = true; continue; }
    if (BitConverter.ToUInt16(s, 4) != BitConverter.ToUInt16(p, 4) || Math.Abs(s[6] - p[6]) > 30 || Math.Abs(s[7] - p[7]) > 30) act = true;
    for (int k = 8; k < 16; k += 2) { if (Math.Abs(BitConverter.ToInt16(s, k) - BitConverter.ToInt16(p, k)) > 3000) act = true; }
  }
  padFirst = false;
  return act;
}
'@ }catch{ $script:noPres=$true; Say ('PROBLEM: the pad, other-account and full-screen checks did not load, so only the keyboard, mouse, sound and graphics card say someone is at the PC: '+(Short "$_")) }
  # sound: the default output's loudness meter, and per program only when it is not quiet (Core Audio, read only; it says only how loud,
  # never what). The code of pause-watch.ps1, unchanged: every failure comes back as "ERR ...", the meter is made again every 5 minutes
  # (the default output can change) and not tried again for 60 s after a failure, and every COM object is released. In its own type,
  # so if it cannot load only the sound sign is lost.
  try{ Add-Type -Namespace PillagersSpare -Name Sound -ErrorAction Stop -MemberDefinition @'
[ComImport, Guid("BCDE0395-E52F-467C-8E3D-C4579291692E")] class MMDevEnumCo {}
[ComImport, Guid("A95664D2-9614-4F35-A746-DE8DB63617E6"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IMMDeviceEnumerator { int EnumAudioEndpoints(); [PreserveSig] int GetDefaultAudioEndpoint(int flow, int role, out IMMDevice dev); }
[ComImport, Guid("D666063F-1587-4E43-81F1-B948E807363F"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IMMDevice { [PreserveSig] int Activate(ref Guid iid, int ctx, IntPtr p, [MarshalAs(UnmanagedType.IUnknown)] out object o); }
[ComImport, Guid("77AA99A0-1BD6-484F-8BC7-2C654C9A9B6F"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IAudioSessionManager2 { int GetAudioSessionControl(); int GetSimpleAudioVolume(); [PreserveSig] int GetSessionEnumerator(out IAudioSessionEnumerator e); }
[ComImport, Guid("E2F5BB11-0570-40CA-ACDD-3AA01277DEE8"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IAudioSessionEnumerator { [PreserveSig] int GetCount(out int n); [PreserveSig] int GetSession(int i, out IAudioSessionControl2 s); }
[ComImport, Guid("bfb7ff88-7239-4fc9-8fa2-07c950be9c6d"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IAudioSessionControl2 {
  [PreserveSig] int GetState(out int st); int GetDisplayName(); int SetDisplayName(); int GetIconPath(); int SetIconPath(); int GetGroupingParam(); int SetGroupingParam();
  int RegisterAudioSessionNotification(); int UnregisterAudioSessionNotification(); int GetSessionIdentifier(); int GetSessionInstanceIdentifier();
  [PreserveSig] int GetProcessId(out uint pid); [PreserveSig] int IsSystemSoundsSession(); }
[ComImport, Guid("C02216F6-8C67-4B5B-9D00-D008E73E0064"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IAudioMeterInformation { [PreserveSig] int GetPeakValue(out float v); }
static object sndEnum; static IAudioSessionManager2 sndMgr; static IAudioMeterInformation sndMeter;
static DateTime sndInitT = DateTime.MinValue, sndFailT = DateTime.MinValue;
static void SoundFree(){
  object[] all = new object[] { sndMeter, sndMgr, sndEnum };
  sndMeter = null; sndMgr = null; sndEnum = null;
  foreach (object o in all) { try { if (o != null) Marshal.ReleaseComObject(o); } catch {} }
}
static void SoundInit(){
  SoundFree();
  sndEnum = new MMDevEnumCo();
  IMMDevice d = null;
  try {
    int hr = ((IMMDeviceEnumerator)sndEnum).GetDefaultAudioEndpoint(0, 1, out d);
    if (hr != 0 || d == null) throw new Exception("no sound output device (0x" + hr.ToString("X8") + ")");
    object o; Guid g = typeof(IAudioSessionManager2).GUID;
    hr = d.Activate(ref g, 23, IntPtr.Zero, out o); if (hr != 0) throw new Exception("no session list (0x" + hr.ToString("X8") + ")");
    sndMgr = (IAudioSessionManager2)o;
    g = typeof(IAudioMeterInformation).GUID;
    hr = d.Activate(ref g, 23, IntPtr.Zero, out o); if (hr != 0) throw new Exception("no loudness meter (0x" + hr.ToString("X8") + ")");
    sndMeter = (IAudioMeterInformation)o;
    sndInitT = DateTime.UtcNow;
  } finally { if (d != null) Marshal.ReleaseComObject(d); }
}
public static string SoundPids(float min){
  try {
    if (sndMeter == null || (DateTime.UtcNow - sndInitT).TotalMinutes >= 5) {
      if ((DateTime.UtcNow - sndFailT).TotalSeconds < 60) return "";
      try { SoundInit(); } catch { sndFailT = DateTime.UtcNow; SoundFree(); throw; }
    }
    float v;
    if (sndMeter.GetPeakValue(out v) != 0) { SoundFree(); return "ERR the loudness meter did not answer"; }
    if (v < min) return "";
    IAudioSessionEnumerator en;
    if (sndMgr.GetSessionEnumerator(out en) != 0 || en == null) { SoundFree(); return "ERR the session list did not answer"; }
    System.Text.StringBuilder sb = new System.Text.StringBuilder();
    try {
      int n; if (en.GetCount(out n) != 0) n = 0;
      for (int i = 0; i < n; i++) {
        IAudioSessionControl2 s = null;
        try {
          if (en.GetSession(i, out s) != 0 || s == null) continue;
          if (s.IsSystemSoundsSession() == 0) continue;
          float p; if (((IAudioMeterInformation)s).GetPeakValue(out p) != 0 || p < min) continue;
          uint pid; if (s.GetProcessId(out pid) < 0) continue;
          sb.Append(sb.Length > 0 ? "," : "").Append(pid);
        } finally { if (s != null) Marshal.ReleaseComObject(s); }
      }
    } finally { Marshal.ReleaseComObject(en); }
    return sb.ToString();
  } catch (Exception e) { SoundFree(); return "ERR " + e.Message; }
}
'@ }catch{ $script:noSnd=$true; Say ('PROBLEM: the sound check did not load, so the other signs count without it: '+(Short "$_")) }
}
# SPARE PC: a game on the graphics card: a program at 15% or more of the 3D engine over a one-second read, at two looks in a row (about
# 30 s apart, so a one-second spike of a launcher or a browser is not someone), not Windows' own drawing, not the Hyper-V VM and not a
# test browser (profile pillagers-cdp): the program rule of the main PC's game check (tools/migrate/host-night-memory.ps1 -GameCheck, which
# averages 5 one-second reads instead). One read takes about 1.5 s (measured on the spare PC 10-26), so at most every 30 s, and only when
# nothing else says someone is here.
function GpuGame(){
  if(((Get-Date)-$script:gpuChk).TotalSeconds -lt 30){ return }
  $script:gpuChk=Get-Date; $hit=''; $now=@{}
  if(((Get-Date)-$script:gpuPrevT).TotalSeconds -gt 90){ $script:gpuPrev=@{} }   # the look before is too old to count as "in a row"
  try{
    $set=Get-Counter -Counter '\GPU Engine(*engtype_3D)\Utilization Percentage' -MaxSamples 1 -ErrorAction SilentlyContinue
    $by=@{}
    if($set){ foreach($c in $set.CounterSamples){ if($c.Status -eq 0 -and $c.InstanceName -match 'pid_(\d+)_'){ $p=[int]$Matches[1]; $by[$p]=[double]$by[$p]+$c.CookedValue } } }
    foreach($p in @($by.Keys)){
      if($by[$p] -lt 15 -or $p -eq $PID){ continue }
      $n=''; try{ $n=(Get-Process -Id $p -ErrorAction Stop).ProcessName }catch{}
      if(-not $n -or $n -match '^(dwm|vmwp|vmmem|vmcompute|vmconnect|mstsc|msrdc|csrss|System|Idle|audiodg)$'){ continue }
      if($n -eq 'chrome'){ $cl=''; try{ $cl=[string](Get-CimInstance Win32_Process -Filter ('ProcessId='+$p) -ErrorAction Stop).CommandLine }catch{}; if($cl -match 'pillagers-cdp'){ continue } }
      $now[$p]=$n+' at '+[int]$by[$p]+'%'
      if(-not $hit -and $script:gpuPrev.ContainsKey($p)){ $hit=$now[$p] }
    }
  }catch{}
  $script:gpuPrev=$now; $script:gpuPrevT=Get-Date
  if($hit){ $script:gpuT=Get-Date; $script:gpuLast=$hit; if(-not $script:gpuOn){ Say ('a game on the graphics card: '+$hit) } }
  $script:gpuOn=[bool]$hit
}
# SPARE PC: a program other than a test Chrome playing sound now ('' when none; the name of a process id is looked up once and kept 10
# minutes). A sound check that does not work is said once in runner.log and counts as no sound.
function SoundWho(){
  if($script:noSnd){ return '' }
  $r=''; try{ $r=[string][PillagersSpare.Sound]::SoundPids([single]0.01) }catch{ $r='ERR '+(Short "$_") }
  if($r.StartsWith('ERR')){ if(-not $script:sndSaid){ $script:sndSaid=$true; Say ('PROBLEM: the sound check does not work, so the other signs count without it: '+(Short $r.Substring(3))) }; return '' }
  if($script:sndCache.Count -gt 200){ $script:sndCache=@{} }
  foreach($x in @($r.Split(',') | Where-Object { $_ -match '^\d+$' })){
    $q=[int]$x; $c=$null
    if($script:sndCache.ContainsKey($q)){ $c=$script:sndCache[$q]; if(((Get-Date)-$c.t).TotalMinutes -gt 10){ $c=$null } }
    if(-not $c){
      $pr=Get-CimInstance Win32_Process -Filter ('ProcessId='+$q) -ErrorAction SilentlyContinue
      $c=@{ n=$(if($pr){ [string]$pr.Name }else{ 'a program' }); test=[bool]($pr -and [string]$pr.Name -eq 'chrome.exe' -and ([string]$pr.CommandLine) -match 'pillagers-cdp'); t=(Get-Date) }
      $script:sndCache[$q]=$c
    }
    if(-not $c.test){ return ($c.n+' pid '+$q) }
  }
  return ''
}
# seconds since the last sign of someone at the PC. IDLE MODE: keyboard, mouse and pad, as before. SPARE PC: keyboard and mouse, a pad
# that changed, another account at the screen and, carried over a restart, the last of these the copy before saw (human_t): that is the
# last time a person certainly was here ($script:humanAgo). Then, under 2 hours after that and while this account is at the screen and
# unlocked, the passive signs, cheapest first: a full-screen program, sound, a game on the graphics card (the stopgap's order and cap).
# Last, the time someone was last there by any sign, carried over a restart (seen_t). $script:awayWhy says which sign it was (runner.log
# only). With no presence check loaded it says nobody, so the runner tests as before.
# 10-28 IDLE MODE: the party plays on pads, and a pad does not move the Windows idle clock that the main PC's "VM light while gaming" check
# goes by, so on a pads-only night the VM would start helpers, robots and the local AI on the party PC. While a pad is in use this writes
# pad-seen.txt (epoch=, seen=) into the bridge share at most once a minute; the VM's tools/nightly.sh counts one under 10 minutes old as
# gaming (nothing new starts). It records nothing of what was pressed.
$script:padNoteT=[long]0; $script:gcAtStart=$false; $script:lightRun=$false; $script:padUseT=(Get-Date).AddDays(-1)   # a real pad use only
function PadNote(){
  try{
    $e=Epoch; if(($e-$script:padNoteT) -lt 60){ return }; $script:padNoteT=$e
    $sh=Join-Path $env:LOCALAPPDATA 'PillagersBridge\share'; if(-not (Test-Path -LiteralPath $sh)){ return }
    $f=Join-Path $sh 'pad-seen.txt'
    [IO.File]::WriteAllText($f+'.tmp',('epoch='+$e+"`r`nseen="+(Get-Date).ToString('yyyy-MM-dd HH:mm:ss')+"`r`n"),$Enc)
    Move-Item -LiteralPath ($f+'.tmp') -Destination $f -Force
  }catch{}
}
function AwaySec(){
  if($Idle){ if([PillagersIdle.Input]::PadInUse()){ $script:padT=Get-Date; $script:padUseT=$script:padT; PadNote }; return [Math]::Min([PillagersIdle.Input]::IdleSec(),((Get-Date)-$script:padT).TotalSeconds) }
  if($script:noIn){ $script:awayWhy='nobody can be seen (the presence checks did not load)'; $script:humanAgo=1e9; return 1e9 }
  $now=Get-Date; $e=Epoch
  $o=$false
  if(-not $script:noPres){
    $pm=$false; try{ $pm=[PillagersSpare.Presence]::PadMoved() }catch{}
    if($pm){ $script:padT=$now }
    try{ $o=[PillagersSpare.Presence]::OtherAtScreen($MySid) }catch{}
  }
  if($o){ $script:conT=$now }
  if($o -ne $script:conOn){ $script:conOn=$o; Say $(if($o){ 'another Windows account is in use at the screen' }else{ 'no other Windows account in use at the screen now' }) }
  $a=[PillagersIdle.Input]::IdleSec(); $w='keyboard or mouse'
  $s=($now-$script:padT).TotalSeconds; if($s -lt $a){ $a=$s; $w='game pad' }
  $s=($now-$script:conT).TotalSeconds; if($s -lt $a){ $a=$s; $w='another account at the screen' }
  if($script:holdH -gt 0){ $s=[double]($e-$script:holdH); if($s -lt $a){ $a=$s; $w='someone used the PC before this runner restarted' } }
  $script:humanAgo=$a
  if($a -lt $PassCapSec){
    $script:capSaid=$false
    $mine=$true; if(-not $script:noPres){ try{ $mine=[PillagersSpare.Presence]::MineAtScreen($MySid) }catch{} }
    if($mine){
      if($a -ge 60){
        $q=-1; if(-not $script:noPres){ try{ $q=[int][PillagersSpare.Presence]::Quns() }catch{} }
        if($q -ge 2 -and $q -le 4){ $script:pasT=$now; $script:pasWhy='a full-screen program' }
        else{ $sw=SoundWho; if($sw){ $script:pasT=$now; $script:pasWhy='sound from '+$sw } else { GpuGame } }
      }
      $s=($now-$script:pasT).TotalSeconds; if($s -lt $a){ $a=$s; $w=$script:pasWhy }
      $s=((Get-Date)-$script:gpuT).TotalSeconds; if($s -lt $a){ $a=$s; $w='a game on the graphics card: '+$script:gpuLast }
    }
  } elseif(-not $script:capSaid){
    # the cap is what lets testing go on: say so once (a passive sign seen under 15 minutes ago would still hold it without the cap)
    $p=[Math]::Min(($now-$script:pasT).TotalSeconds,($now-$script:gpuT).TotalSeconds)
    if($p -lt 900){ $script:capSaid=$true; Say ('nobody has used the keyboard, mouse or a pad for '+[int]($a/60)+' minutes, so '+$(if(($now-$script:pasT).TotalSeconds -le ($now-$script:gpuT).TotalSeconds){ $script:pasWhy }else{ 'a game on the graphics card' })+' no longer counts as someone at the PC (that ends 2 hours after the last use)') }
  }
  if($script:holdE -gt 0){ $s=[double]($e-$script:holdE); if($s -lt $a){ $a=$s; $w='someone was at the PC before this runner restarted' } }
  $script:awayWhy=$w
  return $a
}
# SPARE PC: a copy that restarts itself while paused writes when someone was last there (seen_t) and when a person last used a key, the
# mouse, a pad or another sign-in (human_t), as epoch seconds; the new copy goes on from them (Load-Hold), so its 15 minutes and its
# 2-hour cap go on too. Cleared when testing starts again. A time ahead of this PC's clock counts as now.
function Save-Hold([double]$away){
  PutS 'seen_t' ([string]((Epoch)-[long][Math]::Min([Math]::Max($away,0),864000)))
  PutS 'human_t' ([string]((Epoch)-[long][Math]::Min([Math]::Max($script:humanAgo,0),864000)))
}
function Load-Hold(){
  $e=Epoch
  $v=GetS 'seen_t'; if($v -match '^\d{9,11}$'){ $script:holdE=[Math]::Min([long]$v,$e) }
  $v=GetS 'human_t'; if($v -match '^\d{9,11}$'){ $script:holdH=[Math]::Min([long]$v,$e) }
}
# 10-31 (CEO, his "consistent testing especially in low RAM/intermittent RAM scenarios"): a self-test can fake low RAM. fake-lowram.txt in
# the bridge share with until=EPOCH makes FreeGB read 1 GB until then (the VM puts it there with hostctl share-put). A fake stop starts no
# 30-minute wait, so the resume shows within minutes.
$script:fakeLow=$false
function FreeGB(){
  $script:fakeLow=$false
  try{ $t=[IO.File]::ReadAllText((Join-Path $env:LOCALAPPDATA 'PillagersBridge\share\fake-lowram.txt')); if($t -match 'until=(\d+)' -and [long]$Matches[1] -gt (Epoch)){ $script:fakeLow=$true; return 1.0 } }catch{}
  $os=Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue; if(-not $os){ return 0 }; return [Math]::Min($os.FreePhysicalMemory,$os.FreeVirtualMemory)/1MB }
# 10-22 the VM's nights: the main PC's "VM night memory up" task (tools/migrate/host-night-memory.ps1) lends the VM up to 6 GB more at 23:00,
# sized once from what is free right then, and takes it back from 06:00. Measured 10-20 and 10-21: 12.1 and 12.5 GB free at 23:00, VM 10 -> 16.
# So from 22:40 to 23:10 this runner frees what it holds and starts nothing, and until 06:45 it starts only with 10 GB free (the VM did not
# take its share). Once working it goes on down to 4 GB free, the margin that task keeps for this PC.
function HourMin(){ return [int](Get-Date).ToString('HHmm') }
# 10-24, his yes to "the VM gets the extra memory whenever you are away": once he runs the new night-memory setup, the main PC's minute check
# moves the VM's memory by whether he is here, not by the clock, and writes follow=away and awaymin=N into gaming.txt. Then the clock holds
# below are off, and this runner starts work only after he has been away awaymin + 2 minutes, so the VM has had its turn first.
function FollowAway(){
  try{ $f=Join-Path $env:LOCALAPPDATA 'PillagersBridge\share\gaming.txt'; $i=Get-Item -LiteralPath $f -ErrorAction Stop
       if(((Get-Date)-$i.LastWriteTime).TotalMinutes -gt 5){ return 0 }
       $t=[IO.File]::ReadAllText($f); if($t -match '(?m)^follow=away' -and $t -match '(?m)^awaymin=(\d+)'){ return [int]$Matches[1] } }catch{}
  return 0
}
# 10-28 (Main PC Correspondent): what the main PC's memory task wrote this minute (gaming.txt in the bridge share, under 5 minutes old).
# VmGrowing: it is still giving the VM memory while he is away ("mem=away, VM 12 -> 13 GB"); once it says "(its most)", "no more room" or
# "refused", the VM takes no more, so work started then keeps its memory. GameChrome: its game check names a Chrome this minute.
function ShareGaming(){ try{ $f=Join-Path $env:LOCALAPPDATA 'PillagersBridge\share\gaming.txt'; $i=Get-Item -LiteralPath $f -ErrorAction Stop
  if(((Get-Date)-$i.LastWriteTime).TotalMinutes -gt 5){ return '' }; return [IO.File]::ReadAllText($f) }catch{ return '' } }
function VmGrowing(){ return ((ShareGaming) -match '(?m)^mem=away, VM [0-9.]+ -> ') }
function GameChrome(){ return ((ShareGaming) -match '(?m)^what=chrome\b') }
# 10-28: is he playing, not just working at the PC? A pad used in the last 15 minutes, the main PC game check's gaming=1, the game's own
# window in front ("Pillagers", "Pillagers, player 2"), or a program working the graphics card like a game in the last 10 minutes (GpuGame;
# test Chromes are left out). No full-screen test: his "get rid of the whole fullscreen concept ... i fullscreen apps all the time".
# LightOK: he may be at the PC and one light robot may run.
$script:playWhy=''
# 10-28 22:20 (Main PC Correspondent): the game in front counts for 15 minutes, like a pad. Before, a light robot started each time he
# looked away from the game for a moment and was stopped a minute later (22:10 to 22:21: seven starts while he played, his game froze
# twice, at 22:12 and 22:20, the second at 30 fps).
$script:fgPlayT=(Get-Date).AddDays(-1)
$P2Want='1030a'   # 10-30: the online 2 player test this main PC hosts once (see the robot lines); a new value asks for one more run
# 10-29 (Main PC Correspondent, from the FPS chat): the main PC game check (host-night-memory.ps1 -GameCheck, as SYSTEM, no view of his
# screen) counts a game only at 15% of the graphics card; his 1440p game at 60 fps sits under that, so it had not seen him play since 10-28
# 14:36 and held the VM to 50% instead of 30% while he played. While the game is in front now, or a pad was used in the last minute, this
# writes playing.txt in the bridge share (at most every 30 s) and the game check counts it as a game. Pad and window only, never its
# own gaming=1, so the two never hold each other on.
$script:playNoteT=[long]0
function PlayNote([string]$w){
  if(((Epoch)-$script:playNoteT) -lt 30){ return }; $script:playNoteT=Epoch
  try{ [IO.File]::WriteAllText((Join-Path $env:LOCALAPPDATA 'PillagersBridge\share\playing.txt'),('epoch='+(Epoch)+"`r`nwhy="+$w+"`r`n"),$Enc) }catch{}
}
function Playing(){
  $script:playWhy=''
  $t=''; try{ $t=[PillagersIdle.Fg]::Title() }catch{}
  if($t -match '^(?i)pillagers(,| -|$)'){ $script:fgPlayT=Get-Date }
  if($Idle){ if(((Get-Date)-$script:fgPlayT).TotalSeconds -lt 60){ PlayNote 'the game in front' } elseif(((Get-Date)-$script:padUseT).TotalSeconds -lt 60){ PlayNote 'a game pad' } }
  if(((Get-Date)-$script:padUseT).TotalSeconds -lt 900){ $script:playWhy='a game pad'; return $true }
  if((ShareGaming) -match '(?m)^gaming=1'){ $script:playWhy='the main PC game check'; return $true }
  if(((Get-Date)-$script:fgPlayT).TotalSeconds -lt 900){ $script:playWhy='the game in front'; return $true }
  GpuGame
  if(((Get-Date)-$script:gpuT).TotalSeconds -lt 600){ $script:playWhy='a game on the graphics card'; return $true }
  return $false
}
function LightOK(){ if($script:noFg){ return $false }; return (-not (Playing)) }
function VMResizeSoon(){ if((FollowAway) -gt 0){ return $false }; $hm=HourMin; return ($hm -ge 2240 -and $hm -lt 2310) }
# 10-31 (CEO, his party night): no tests at all on this PC from Sat 10/31 17:00 to Sun 11/1 06:00, whatever the memory. 8802, the party
# copy and the bridge are looked after as always.
function PartyHold(){ $n=Get-Date; return ($n -ge [datetime]'2026-10-31 17:00' -and $n -lt [datetime]'2026-11-01 06:00') }
function VMNight(){ if((FollowAway) -gt 0){ return $false }; $hm=HourMin; return ($hm -ge 2240 -or $hm -lt 645) }
# ends only what this runner started: the test scripts run from C:\PillagersIdle, and the test Chromes (debug port and pillagers-cdp profile)
# 10-26 SPARE-PRESENCE-PAUSE, SPARE PC only (IDLE MODE keeps the match above, unchanged): a test part is one of the runner's own launch
# shapes, by program and by where the script stands in the command line (the rule of the stopgap pause-watch.ps1 Snap): a robot
# (powershell -File ...\tools\fuzz.ps1 ... -Port 9331/9332), the full run (Git bash with tools/handoff/shipkit/corpq.sh or
# tools/corpus-slices.sh right after the shell, then C:/PillagersSpare/out/corpus/corpus-MMDD-HHMM.txt), a cdp.ps1 or pause.ps1 call
# on 9344/9331/9332, and a test Chrome (debug port and pillagers-cdp profile, or a helper process of one by its profile). An editor, a
# viewer or a search that only names one of these scripts (notepad, Code, powershell_ise, grep, a Claude command) is never one. Then
# whose it is, by its parent chain (pause-watch.ps1 Owner): the runner's when the chain reaches a spare runner (this copy or another) or
# ends at a process that has exited (what a stopped or restarted runner leaves; every test Chrome, whose cdp.ps1 -Start has exited; and
# every process a Git bash script starts, whose Windows parent is a short-lived fork; so a test part started by hand from Git bash,
# Claude's Bash tool included, is stopped like the runner's). One whose chain reaches anything else (Claude's PowerShell, a terminal,
# explorer: started by hand) is left alone, and so is a test Chrome on a port such a test uses.
$RxRunner='-File\s+(?:"[^"]*[\\/]spare-runner\.ps1"|[^"\s]*[\\/]spare-runner\.ps1)(?=\s|$)'
$RxRobot='-File\s+(?:"[^"]*[\\/]tools[\\/]fuzz\.ps1"|[^"\s]*[\\/]tools[\\/]fuzz\.ps1)\s.*-Port\s+(9331|9332)(\s|$)'
$RxCdp='-File\s+(?:"[^"]*[\\/](?:cdp|pause)\.ps1"|[^"\s]*[\\/](?:cdp|pause)\.ps1)\s.*-Port\s+(9344|9331|9332)(\s|$)'
$RxRun='^\s*(?:"[^"]*[\\/](?:ba)?sh(?:\.exe)?"|(?:[^"\s]*[\\/])?(?:ba)?sh(?:\.exe)?)\s+"?(?:tools/handoff/shipkit/corpq\.sh|tools/corpus-slices\.sh)"?\s+"?C:/PillagersSpare/out/corpus/corpus-\d{4}-\d{4}\.txt(?:"|\s|$)'
function Spare-Role($p){
  $c=[string]$p.CommandLine; $n=[string]$p.Name
  if(-not $c){ return '' }
  if($n -eq 'powershell.exe' -or $n -eq 'pwsh.exe'){ if($c -match $RxRunner){ return 'runner' }; if($c -match $RxRobot){ return 'robot' }; if($c -match $RxCdp){ return 'cdp' }; return '' }
  if($n -eq 'bash.exe' -or $n -eq 'sh.exe'){ if($c -match $RxRun){ return 'run' }; return '' }
  if($n -eq 'chrome.exe' -and (($c -match 'remote-debugging-port=(9344|9331|9332)(\s|$)' -and $c -match 'pillagers-cdp') -or $c -match 'pillagers-cdp(9344|9331|9332)\b')){ return 'chrome' }
  return ''
}
# every process under $roots by parent id (a child is never older than its parent, so an older process with a reused parent id is not
# one); under a test Chrome only its own chrome.exe helpers
function Under($kids,$roots){
  $out=New-Object Collections.ArrayList; $seen=@{}; $q=New-Object Collections.Queue
  foreach($r in @($roots)){ if($r){ $seen[[int]$r.ProcessId]=1; $q.Enqueue($r) } }
  while($q.Count -gt 0){
    $p=$q.Dequeue(); $id0=[int]$p.ProcessId
    if(-not $kids.ContainsKey($id0)){ continue }
    foreach($c in $kids[$id0]){
      $id=[int]$c.ProcessId
      if($id -le 4 -or $id -eq $PID -or $seen.ContainsKey($id)){ continue }
      if($c.CreationDate -and $p.CreationDate -and $c.CreationDate -lt $p.CreationDate){ continue }
      if([string]$p.Name -eq 'chrome.exe' -and [string]$c.Name -ne 'chrome.exe'){ continue }
      $seen[$id]=1; [void]$out.Add($c); $q.Enqueue($c)
    }
  }
  return $out.ToArray()
}
# 'runner', 'orphan' or 'hand' (above); $cand holds every test part and every process under one, so the chain of a runner's test part
# never meets 'hand'
function Part-Owner($p,$byId,$cand,$rid){
  $cur=$p
  for($i=0;$i -lt 64;$i++){
    $pp=[int]$cur.ParentProcessId; $par=$null
    if($pp -gt 4 -and $byId.ContainsKey($pp)){ $par=$byId[$pp] }
    if($par -and $par.CreationDate -and $cur.CreationDate -and $par.CreationDate -gt $cur.CreationDate.AddSeconds(1)){ $par=$null }   # a reused id
    if(-not $par){ return 'orphan' }
    if($rid.ContainsKey($pp)){ return 'runner' }
    if(-not $cand.ContainsKey($pp)){ return 'hand' }
    $cur=$par
  }
  return 'orphan'
}
# stops one process from the list, checked against its start time right before: a process id that a new process has taken since the
# list was made is left alone. True when it was stopped.
function Kill-One($p){
  $g=$null; try{ $g=[Diagnostics.Process]::GetProcessById([int]$p.ProcessId) }catch{ return $false }
  try{
    try{ if($p.CreationDate -and [Math]::Abs(($g.StartTime-$p.CreationDate).TotalSeconds) -gt 2){ return $false } }catch{}
    $g.Kill(); return $true
  }catch{ return $false } finally{ $g.Dispose() }
}
# From each part of the runner's it also stops what that part started: each robot's hidden watchdog, the test server a robot starts for
# itself (serve.ps1 on 8811), which a killed robot never closes, the console hosts, and a test Chrome's own helpers; never this runner
# or another runner, nor node serve.mjs (the runner's 8806 server). The scripts go first, then what they started, then the browsers: a
# robot whose browser dies under it records a "cdp" problem (fuzz.ps1 Run-Raid) that keeps that build out of stable (tools/stable.mjs),
# and a hashtable gives its keys in any order. A second look 2 s later catches a browser that was being started at that moment.
# -Refund (someone is at the PC): the runner's full run (state.txt corpus_file), stopped before its end, gives its try back once, so it
# starts again from the beginning once the PC is free (while it is paused the VM runs the tests, so a day of short visits still gets
# full runs there).
function Stop-Work([string]$why,[switch]$Refund,[switch]$LowRam){
  if($Idle){
    # 10-31: a stop for low RAM is an abort, not a game failure: fuzz.log gets a FUZZ ABORT line (tools/stable.mjs leaves out the raids
    # that ended in the 3 minutes before it), and a stopped online 2 player test gets its try back
    if($LowRam){
      if((Running 'fuzz\.ps1.*-Port 9332(\s|$)') -gt 0){ try{ [IO.File]::AppendAllText($FzOut+'\fuzz.log',(Get-Date).ToString('yyyy-MM-dd HH:mm:ss')+' FUZZ ABORT reason=low ram ('+[Math]::Round((FreeGB),1)+' GB free'+$(if($script:fakeLow){ ', a self-test' }else{ '' })+'), not a game failure'+"`r`n",$Enc) }catch{} }
      if((Running 'p2\.mjs"?\s+host(\s|$)') -gt 0 -and (GetS 'p2_want') -eq $P2Want){ $tr=[int]('0'+(GetS 'p2_tries')); if($tr -gt 0){ PutS 'p2_tries' ([string]($tr-1)) } }
    }
    $n=0
    Get-CimInstance Win32_Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessId -ne $PID -and $_.CommandLine -and (
      ($_.CommandLine -match 'PillagersIdle' -and $_.CommandLine -match 'fuzz\.ps1|corpq\.sh|corpus-slices\.sh|p2\.mjs') -or
      ($_.Name -eq 'chrome.exe' -and $_.CommandLine -match 'pillagers-p2online') -or
      ($_.Name -eq 'chrome.exe' -and $_.CommandLine -match 'remote-debugging-port=(9344|9331|9332)(\s|$)' -and $_.CommandLine -match 'pillagers-cdp')) } |
      ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue; $n++ }
    $script:working=$false
    if($n){ Say ('stopped '+$n+' test parts ('+$why+')'); Tidy-Profiles }
    return
  }
  $n=0; $corp=@{}
  for($pass=0;$pass -lt 2;$pass++){
    $all=@(Get-CimInstance Win32_Process -ErrorAction SilentlyContinue)
    $byId=@{}; $kids=@{}; $role=@{}; $rid=@{}; $rid[[int]$PID]=1; $roots=@()
    foreach($p in $all){
      $id=[int]$p.ProcessId; $byId[$id]=$p
      $pp=[int]$p.ParentProcessId; if(-not $kids.ContainsKey($pp)){ $kids[$pp]=New-Object Collections.ArrayList }; [void]$kids[$pp].Add($p)
      if($id -eq $PID){ continue }
      $r=Spare-Role $p
      if($r -eq 'runner'){ $rid[$id]=1 } elseif($r){ $role[$id]=$r; $roots+=$p }
    }
    $cand=@{}; foreach($p in $roots){ $cand[[int]$p.ProcessId]=1 }; foreach($p in (Under $kids $roots)){ $cand[[int]$p.ProcessId]=1 }
    $own=@{}; foreach($p in $roots){ $own[[int]$p.ProcessId]=Part-Owner $p $byId $cand $rid }
    # the ports that tests started by hand use: a test Chrome there is theirs
    $hand=@{}
    foreach($p in $roots){
      $id=[int]$p.ProcessId; if($own[$id] -ne 'hand'){ continue }; $c=[string]$p.CommandLine
      if($role[$id] -eq 'run'){ $hand['9344']=1 } elseif($c -match '-Port\s+(\d+)' -or $c -match 'remote-debugging-port=(\d+)' -or $c -match 'pillagers-cdp(\d{4})'){ $hand[$Matches[1]]=1 }
    }
    $kill=@{}
    foreach($p in $roots){
      $id=[int]$p.ProcessId; if($own[$id] -eq 'hand'){ continue }; $c=[string]$p.CommandLine
      if($role[$id] -eq 'chrome' -and ($c -match 'remote-debugging-port=(\d+)' -or $c -match 'pillagers-cdp(\d{4})') -and $hand.ContainsKey($Matches[1])){ continue }
      $kill[$id]=$p; if($role[$id] -eq 'run'){ $corp[$c]=1 }
    }
    foreach($p in (Under $kids @($kill.Values))){
      $id=[int]$p.ProcessId
      if(-not $kill.ContainsKey($id) -and -not $rid.ContainsKey($id) -and [string]$p.CommandLine -notmatch 'serve\.mjs'){ $kill[$id]=$p }
    }
    if($kill.Count -eq 0){ break }
    # the order: 0 the test scripts (robots, full run), 1 what they started (watchdogs, 8811 server, cdp.ps1 calls, bash children), 2 the
    # test browsers; oldest first within each (a parent before its children)
    $ord=@($kill.Values | Sort-Object @{Expression={ $r=$role[[int]$_.ProcessId]; if($_.Name -eq 'chrome.exe'){ 2 }elseif($r -eq 'robot' -or $r -eq 'run'){ 0 }else{ 1 } }},@{Expression={ $_.CreationDate }})
    $first=@($ord | Where-Object { $_.Name -ne 'chrome.exe' -and ($role[[int]$_.ProcessId] -eq 'robot' -or $role[[int]$_.ProcessId] -eq 'run') } | ForEach-Object { [int]$_.ProcessId })
    foreach($id in $first){ if(Kill-One $kill[$id]){ $n++ } }
    if($first.Count){ Start-Sleep -Milliseconds 300 }   # the scripts are gone before their browsers close
    foreach($p in $ord){ if($first -notcontains [int]$p.ProcessId){ if(Kill-One $p){ $n++ } } }
    Start-Sleep -Seconds 2
  }
  $script:working=$false
  if($n){ Say ('stopped '+$n+' test parts ('+$why+')') }
  $cf=GetS 'corpus_file'
  # only the run state.txt names (its output file is in the stopped bash's command line), only once per run, and not a run that ended
  if($corp.Count -and $Refund -and $cf -and (GetS 'corpus_done') -ne $cf -and @($corp.Keys | Where-Object { $_.IndexOf((Split-Path $cf -Leaf),[StringComparison]::OrdinalIgnoreCase) -ge 0 }).Count -and
     -not ((Test-Path -LiteralPath $cf) -and ([IO.File]::ReadAllText($cf) -match 'ALL DONE'))){
    $cb=GetS 'corpus_blob'; $t=[int]('0'+(GetS 'tries'))
    if($cb -and (GetS 'try_blob') -eq $cb -and $t -gt 0){ PutS 'tries' ([string]($t-1)) }
    PutS 'corpus_done' $cf   # so the main loop does not report it as "ended without finishing"; the next start writes a new file
    Say ('full test run '+(Split-Path $cf -Leaf)+' stopped before its end because someone is at the PC: its try is given back')
  }
}
# the test scripts this runner's copies started (the same match Stop-Work uses)
function IdleWork(){
  @(Get-CimInstance Win32_Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessId -ne $PID -and $_.CommandLine -and
    $_.CommandLine -match 'PillagersIdle' -and $_.CommandLine -match 'fuzz\.ps1|corpq\.sh|corpus-slices\.sh' }).Count
}
# SPARE-PRESENCE-PAUSE: someone came to the spare PC during this round (a fetch, a test copy build or a push can take a minute), so it
# starts nothing more; the next round pauses. Always false in IDLE MODE.
function Arrived(){ if($Idle){ return $false }; return ((AwaySec) -lt 30) }
# the wait between rounds, looking for him every 5 seconds (10-26 SPARE-PRESENCE-PAUSE: on the spare PC too, for anyone)
function Watch([int]$sec){
  $end=(Get-Date).AddSeconds($sec); $k=0; $lo=0
  while((Get-Date) -lt $end){
    Start-Sleep -Seconds 5; $k++
    if((AwaySec) -lt 30){ if($Idle){ if((-not $script:lightRun) -or -not (LightOK)){ Stop-Work $(if($script:playWhy){ 'he is playing ('+$script:playWhy+')' }else{ 'he is back at the PC' }); return } }else{ Stop-Work ('someone is at the PC: '+$script:awayWhy) -Refund; return } }
    if($Idle -and ($k % 6) -eq 0){
      if((FreeGB) -lt 4){ $lo++ }else{ $lo=0 }
      if($lo -ge 2){ if(-not $script:fakeLow){ PutS 'lowstop_t' ([string](Epoch)) }; Stop-Work 'paused: low ram, under 4 GB free at two looks' -LowRam; return }
      if(PartyHold){ Stop-Work 'party night: no tests until Sun 06:00'; return }
      if(VMResizeSoon){ Stop-Work 'the VM takes its night memory at 23:00'; return }
      # 10-28: if the main PC's game check reads the 4K robot as him playing (it skips pillagers-cdp Chromes since 10-24), the VM would be
      # held to 30% of its processors: the robot goes back to 1080p for the rest of the day
      if((-not $script:gcAtStart) -and (GameChrome) -and ((Running 'corpq\.sh|corpus-slices\.sh') -eq 0) -and (Running 'fuzz\.ps1.*-Port 9332\s.*3840x2160') -gt 0){ PutS 'no4k' ((Get-Date).ToString('yyyy-MM-dd')); Stop-Work 'the 4K robot reads as a game to the main PC game check: 1080p for the rest of today'; return }
    }
    # 10-28: his 8802, the party copy and the bridge are looked after every minute while the runner works too (once per 5-minute round
    # before: v35.38 took 319 s to reach his PC while robots ran); each throttles itself to 60 s
    if($Idle -and ($k % 12) -eq 0){ Refresh-Party; Ensure-Bridge; Ensure-Play }
  }
}

$SelfHash=(Get-FileHash -LiteralPath $PSCommandPath -Algorithm SHA256).Hash
# 10-28: a new runner from GitHub is restarted into only when this Windows PowerShell can read it and it is ASCII. Otherwise this copy goes
# on (it keeps 8802, the party copy and the bridge up), says PROBLEM once, and takes the next good copy from master.
$script:badHash=''
function NewRunnerOK(){
  $h=(Get-FileHash -LiteralPath $PSCommandPath -Algorithm SHA256).Hash
  if($h -eq $SelfHash -or $h -eq $script:badHash){ return $false }
  $msg=''
  try{ $tk=$null; $er=$null; [void][Management.Automation.Language.Parser]::ParseFile($PSCommandPath,[ref]$tk,[ref]$er)
    if($er -and $er.Count -gt 0){ $msg=([string]$er[0].Message)+' (line '+$er[0].Extent.StartLineNumber+')' } elseif([IO.File]::ReadAllText($PSCommandPath,[Text.Encoding]::GetEncoding(28591)) -match '[^\x00-\x7F]'){ $msg='it is not ASCII' } }catch{ return $true }
  if($msg){ $script:badHash=$h; Say ('PROBLEM: the new runner from GitHub ('+$h.Substring(0,8)+') cannot be read, so this copy goes on: '+(Short $msg)); return $false }
  return $true
}
Say ('spare runner started (pid '+$PID+', game v'+(GameVer)+')')

function Ensure-Server(){
  if(Up 8806 'cdp.ps1'){ return }
  if(-not (Test-Path -LiteralPath $Node)){ Say 'PROBLEM: Node is not installed, so the test server cannot start'; return }
  Start-Process -FilePath $Node -ArgumentList @(('"'+$T+'\spare\serve.mjs"'),'--root',('"'+$T+'"'),'--port','8806') -WindowStyle Hidden | Out-Null
  for($i=0;$i -lt 10;$i++){ Start-Sleep 1; if(Up 8806 'cdp.ps1'){ Say 'test server 8806 started'; return } }
  Say 'PROBLEM: the test server on 8806 did not start'
}

function Update-Game(){
  $o=G -C $R fetch -q origin master
  if($script:gx -ne 0){ Say ('GitHub fetch failed: '+(Short $o)); return $false }
  $want=G -C $R rev-parse origin/master; $have=G -C $R rev-parse HEAD
  if($want -and $want -ne $have){
    $o=G -C $R -c advice.detachedHead=false checkout -q -f --detach $want
    if($script:gx -ne 0){ Say ('could not take the new game: '+(Short $o)); return $false }
    Say ('game copy now at '+$want.Substring(0,8)+' (v'+(GameVer)+')')
  }
  return $true
}
# 10-27 his "I want the main PC to always have the latest build!": in idle mode, every minute (10-27 evening "still not getting the latest
# build": 5 minutes was too slow), whether he is at the PC or away,
# the party copy his 8802 server plays (C:\claudecode\pillagers-party) is brought to GitHub master when master moved. Only -Prepare
# (git fetch and reset in that copy, stable.html copied); never -Stop, no request to 8802. He reloads the page to play it. (Ensure-Play
# below is the one -Start: only when nothing has served 8802 for 2 minutes.)
function PartyVer([string]$d){ try{ $m=[regex]::Match([IO.File]::ReadAllText($d+'\dark_raiders.html'),"var VER='([0-9]+\.[0-9]+)';"); if($m.Success){ return $m.Groups[1].Value } }catch{}; return '?' }
# what his 8802 really serves, from the process list only (no request to 8802): the -Root of the serve.ps1 on port 8802 and its game version
function Play8802(){
  try{
    $c=@(Get-CimInstance Win32_Process -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -and ($_.CommandLine -match 'serve\.ps1') -and (($_.CommandLine -match '-Port\s+"?8802\b') -or ($_.CommandLine -notmatch '-Port\b')) })
    if($c.Count -eq 0){ if((Running 'play-relay\.mjs') -gt 0){ return 'relay to the VM' }; return 'nothing' }
    $m=[regex]::Match([string]$c[0].CommandLine,'-Root\s+(?:"([^"]+)"|(\S+))')
    $rt=$(if($m.Success){ ($m.Groups[1].Value+$m.Groups[2].Value).TrimEnd('\') }else{ 'C:\claudecode\dark raiders' })
    return ($rt+' v'+(PartyVer $rt))
  }catch{ return '?' }
}
$script:partyT=0; $script:partyP=$null; $script:partyS=0; $script:partyW=''
# 10-30 (CEO, his "update the game to play through all the captures during the party if the game is afk"): every 15 minutes his
# Downloads\pillagers-attract*.webm are copied into the party copy's attract folder (what 8802 serves; untracked, and -Prepare never
# cleans), only the new or changed ones, and attract\list.json names every clip there. Files only: 8802 itself is never touched.
$script:attractT=[long]0
function Sync-Attract(){
  if(-not $Idle -or ((Epoch)-$script:attractT) -lt 900){ return }
  $script:attractT=Epoch
  try{
    $PD='C:\claudecode\pillagers-party'; if(-not (Test-Path -LiteralPath ($PD+'\dark_raiders.html'))){ return }
    # where his Chrome saves: the Windows Downloads folder (it can be moved, e.g. to OneDrive), each Chrome profile's own download folder,
    # the plain Downloads and the Desktop; the newest copy of a name wins
    $dirs=@()
    try{ $dirs+=[string](Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders' -ErrorAction Stop).'{374DE290-123F-4565-9164-39C4925E467B}' }catch{}
    try{ Get-ChildItem -LiteralPath (Join-Path $env:LOCALAPPDATA 'Google\Chrome\User Data') -Directory -ErrorAction Stop | ForEach-Object {
      $pf=Join-Path $_.FullName 'Preferences'; if(Test-Path -LiteralPath $pf){ $m=[regex]::Match([IO.File]::ReadAllText($pf),'"default_directory"\s*:\s*"((?:[^"\\]|\\.)*)"'); if($m.Success){ $dirs+=($m.Groups[1].Value -replace '\\\\','\') } } } }catch{}
    $dirs+=@((Join-Path $env:USERPROFILE 'Downloads'),(Join-Path $env:USERPROFILE 'Desktop'),(Join-Path $env:USERPROFILE 'OneDrive\Downloads'))
    $dirs=@($dirs | Where-Object { $_ -and (Test-Path -LiteralPath $_) } | Select-Object -Unique); $src=($dirs -join '; '); $dst=$PD+'\attract'
    $by=@{}; foreach($dd in $dirs){ foreach($f in @(Get-ChildItem -LiteralPath $dd -Filter 'pillagers-attract*.webm' -File -ErrorAction SilentlyContinue)){ if(-not $by.ContainsKey($f.Name) -or $by[$f.Name].LastWriteTime -lt $f.LastWriteTime){ $by[$f.Name]=$f } } }
    $fs=@($by.Values)
    if($fs.Count -eq 0 -and -not (Test-Path -LiteralPath $dst)){ if((GetS 'attract') -ne ('none '+$src)){ PutS 'attract' ('none '+$src); Say ('attract clips: no pillagers-attract*.webm in '+$src) }; return }
    New-Item -ItemType Directory -Force -Path $dst | Out-Null
    $nw=0
    foreach($f in $fs){ $d=Join-Path $dst $f.Name; $o=Get-Item -LiteralPath $d -ErrorAction SilentlyContinue
      if(-not $o -or $o.Length -ne $f.Length -or $o.LastWriteTime -lt $f.LastWriteTime){ Copy-Item -LiteralPath $f.FullName -Destination $d -Force -ErrorAction Stop; $nw++ } }
    $names=@(Get-ChildItem -LiteralPath $dst -Filter 'pillagers-attract*.webm' -File -ErrorAction SilentlyContinue | Sort-Object Name | ForEach-Object { $_.Name })
    $js='['+(($names | ForEach-Object { '"'+($_ -replace '\\','\\' -replace '"','\"')+'"' }) -join ',')+']'
    $lf=$dst+'\list.json'; $old=''; try{ $old=[IO.File]::ReadAllText($lf) }catch{}
    if($old -ne $js){ [IO.File]::WriteAllText($lf,$js,$Enc) }
    if($nw -gt 0 -or $old -ne $js){ Say ('attract clips: '+$names.Count+' in the party copy ('+$nw+' new)') }
    PutS 'attract' ([string]$names.Count)
  }catch{ Say ('PROBLEM: attract clips: '+(Short $_.Exception.Message)) }
}
function Refresh-Party(){
  if(-not $Idle){ return }
  Sync-Attract
  try{
    $PD='C:\claudecode\pillagers-party'
    if($script:partyP){   # a refresh started earlier: look at it, never wait for it
      if(-not $script:partyP.HasExited){
        if(((Epoch)-$script:partyS) -lt 300){ return }
        & taskkill.exe /T /F /PID $script:partyP.Id 2>&1 | Out-Null; $script:partyP=$null; $script:partyT=(Epoch)+1740
        Say 'PROBLEM: the party copy update took over 5 minutes and was stopped'; return
      }
      $rc=$script:partyP.ExitCode; $script:partyP=$null
      $now=G -C $PD rev-parse HEAD; $ok=($rc -eq 0 -and $script:gx -eq 0 -and $now.Length -ge 8); $ver=PartyVer $PD
      if($ok){
        PutS 'party_head' ($now.Substring(0,8)); PutS 'party_ver' $ver
        Say ('party copy now at '+$now.Substring(0,8)+' (v'+$ver+'): he reloads the page to play it')
        PutS 'pub_t' '0'   # the status note goes out at the next round, so the VM sees the new party= within a minute
        if($now -ne $script:partyW){ $script:partyT=(Epoch)+1740; Say ('party copy is not at the GitHub master it was sent to ('+$script:partyW.Substring(0,8)+'); next try in 30 minutes') }
      } else { $script:partyT=(Epoch)+1740; Say ('PROBLEM: the party copy did not update (code '+$rc+'), next try in 30 minutes: '+(Short ((Get-Content -LiteralPath ($W+'\party-refresh.out') -Tail 3 -ErrorAction SilentlyContinue) -join ' '))) }
      return
    }
    if(-not (Test-Path -LiteralPath ($PD+'\.git'))){ if(-not (GetS 'party_none')){ PutS 'party_none' '1'; Say 'no party copy on this PC: nothing to keep current' }; return }
    if(((Epoch)-$script:partyT) -lt 60){ return }
    $script:partyT=Epoch
    if((Running 'party-host-copy\.ps1') -gt 0){ return }
    $ls=G -C $R ls-remote origin refs/heads/master
    $m=[regex]::Match($ls,'(?m)^([0-9a-f]{40})\s'); if($script:gx -ne 0 -or -not $m.Success){ return }
    $want=$m.Groups[1].Value; $script:lastMaster=$want; $have=G -C $PD rev-parse HEAD
    if($script:gx -ne 0 -or $have.Length -lt 8){ return }
    if($want -eq $have){ if((GetS 'party_head') -ne $have.Substring(0,8)){ PutS 'party_head' $have.Substring(0,8); PutS 'party_ver' (PartyVer $PD) }; return }
    if($script:playMiss -gt 0){ return }   # 10-28: 8802 is down; Ensure-Play starts it first and the copy update follows (see Ensure-Play)
    $S=$T+'\migrate\party-host-copy.ps1'; if(-not (Test-Path -LiteralPath $S)){ return }
    $p=Start-Process powershell.exe -NoNewWindow -PassThru -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-File',('"'+$S+'"'),'-Prepare','-Force') -RedirectStandardOutput ($W+'\party-refresh.out') -RedirectStandardError ($W+'\party-refresh.err')
    [void]$p.Handle   # PS 5.1: hold the handle so ExitCode is filled in later
    $script:partyP=$p; $script:partyS=Epoch; $script:partyW=$want
    Say ('GitHub master is at '+$want.Substring(0,8)+': updating the party copy')
  } catch { Say ('PROBLEM: party copy check failed: '+(Short $_.Exception.Message)) }
}
# 10-27 his "you can't seem to communicate effectively with the main PC from the VM": the bridge agent (tools\bridge\host-agent.mjs, the
# VM's direct line to this PC) runs from this runner's copy, which follows GitHub master, so a new bridge job reaches the main PC by itself.
# Once a minute in idle mode: when the agent runs from another folder (his Startup shortcut starts the 10-19 copy in C:\claudecode\dark
# raiders) or the bridge files changed since it started, it is restarted from here. If the new one does not listen on 8830 within 10 s,
# the old one is started again and the next try is in 30 minutes.
$script:brT=0; $script:lastMaster=''; $script:tookMaster=''
function Ensure-Bridge(){
  if(-not $Idle){ return }
  try{
    if(((Epoch)-$script:brT) -lt 60){ return }
    $script:brT=Epoch
    $want=$T+'\bridge\host-agent.mjs'
    if(-not (Test-Path -LiteralPath $want) -or -not (Test-Path -LiteralPath ($env:LOCALAPPDATA+'\PillagersBridge\key.txt'))){ return }
    $h=(@('host-agent.mjs','jobs.mjs','bridge-common.mjs','gate-test.mjs','main-status.ps1') | ForEach-Object { $f=$T+'\bridge\'+$_; if(Test-Path -LiteralPath $f){ (Get-FileHash -LiteralPath $f -Algorithm SHA256).Hash.Substring(0,8) } }) -join '-'
    $ag=@(Get-CimInstance Win32_Process -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -and ($_.CommandLine -match 'host-agent\.mjs') -and ($_.CommandLine -notmatch '--status|--once') })
    $here=@($ag | Where-Object { ([string]$_.CommandLine).IndexOf($want,[StringComparison]::OrdinalIgnoreCase) -ge 0 })
    if($ag.Count -eq 1 -and $here.Count -eq 1 -and (GetS 'bridge_hash') -eq $h){ return }
    $script:brT=(Epoch)+1740   # a failure below waits 30 minutes; success sets it back
    $exe=$(if($ag.Count -gt 0 -and $ag[0].ExecutablePath){ [string]$ag[0].ExecutablePath }else{ $Node })
    foreach($p in $ag){ Stop-Process -Id ([int]$p.ProcessId) -Force -ErrorAction SilentlyContinue }
    Start-Sleep -Milliseconds 800
    $np=Start-Process -FilePath $exe -ArgumentList @(('"'+$want+'"'),'--port','8830') -WindowStyle Hidden -PassThru
    $up=$false; for($i=0;$i -lt 20;$i++){ Start-Sleep -Milliseconds 500; if(@(Get-NetTCPConnection -LocalPort 8830 -State Listen -ErrorAction SilentlyContinue | Where-Object { $_.OwningProcess -eq $np.Id }).Count -gt 0){ $up=$true; break } }
    if($up){ PutS 'bridge_hash' $h; $script:brT=Epoch; Say ('bridge agent now runs from the runner copy ('+$h+')'); return }
    try{ Stop-Process -Id $np.Id -Force -ErrorAction SilentlyContinue }catch{}
    $vbs='C:\claudecode\dark raiders\tools\bridge\start-agent-hidden.vbs'
    if(Test-Path -LiteralPath $vbs){ Start-Process -FilePath wscript.exe -ArgumentList ('"'+$vbs+'"') | Out-Null }
    Say 'PROBLEM: the bridge agent from the runner copy did not listen on 8830; the old one was started again, next try in 30 minutes'
  } catch { $script:brT=(Epoch)+1740; Say ('PROBLEM: bridge check failed: '+(Short $_.Exception.Message)) }
}
# 10-27 his "the main pc is not always going to have claude code open": nothing served his 8802 again after a restart or a crash (the
# server from a -Start lived until the next reboot). Once a minute in idle mode it knocks on 127.0.0.1:8802 (a connect, no request). When
# nothing answered at 3 looks in a row (2+ minutes, so a server starting at sign-in gets there first), or a play relay holds 8802 but
# has not delivered the game at 3 looks (the main PC Claude found 10-27 that its Startup shortcut takes 8802 and 8799 at every sign-in
# and forwards to a VM port nobody answers, so the page hangs), no party-host-copy runs, and the party copy's last running/stopped record
# is not "stopped" (a deliberate -Stop, from either copy of the script), it runs party-host-copy -Start (which stops such a relay first;
# the game on 8802 and the run-report collector on 8799; -NoCollector when something else holds 8799) as a child it never waits on.
# Never a -Stop; a relay that delivers the game is left alone. A failure tries again in 10 minutes.
$script:playT=0; $script:playMiss=0; $script:playP=$null; $script:playS=0
function PortOpen([int]$p){
  $c=New-Object Net.Sockets.TcpClient
  try{ $a=$c.BeginConnect('127.0.0.1',$p,$null,$null); return [bool]($a.AsyncWaitHandle.WaitOne(700) -and $c.Connected) }catch{ return $false }finally{ try{ $c.Close() }catch{} }
}
# something serves the port: the knock above, else (a server bound to ::1 only) any HTTP answer to a HEAD on localhost, even an error
function Answers([int]$p){
  if(PortOpen $p){ return $true }
  try{ $rq=[Net.WebRequest]::Create('http://localhost:'+$p+'/dark_raiders.html'); $rq.Method='HEAD'; $rq.Timeout=4000; $rs=$rq.GetResponse(); $rs.Close(); return $true }
  catch [Net.WebException]{ return ($null -ne $_.Exception.Response) }catch{ return $false }
}
# the play relay (10-19 route to the VM) delivers the game: a HEAD through it gets the page (over 1 MB) within 5 s. Asked only while a
# relay runs: its Startup shortcut starts it at sign-in while host-stopped.txt says switched over, and its VM side has not answered since.
function RelayGame(){
  try{ $rq=[Net.WebRequest]::Create('http://127.0.0.1:8802/dark_raiders.html'); $rq.Method='HEAD'; $rq.Timeout=5000; $rs=$rq.GetResponse(); $n=[long]$rs.ContentLength; $rs.Close(); return ($n -gt 1000000) }catch{ return $false }
}
# the newest "running" or "stopped" record of the party copy (its state file sits next to whichever party-host-copy.ps1 wrote it)
function PartyIntent(){
  $best=''; $bt=''
  foreach($f in @(($T+'\migrate\state\party-copy.json'),'C:\claudecode\dark raiders\tools\migrate\state\party-copy.json')){
    try{ $s=Get-Content -LiteralPath $f -Raw -ErrorAction Stop | ConvertFrom-Json; if(($s.state -eq 'running' -or $s.state -eq 'stopped') -and [string]$s.time -gt $bt){ $best=[string]$s.state; $bt=[string]$s.time } }catch{}
  }
  return $best
}
# 10-27 his order (via the main PC Claude): "make sure we are always getting game telemetry back from the main pc when we play on chrome on
# the main pc". The 8799 report receiver (the party copy's tools\collector.ps1, which writes its exports folder: run reports, notes, snips)
# was never started again after it died while 8802 still answered: party-host-copy -Start refuses a busy 8802, and the look below stopped
# at 8802. Now, when 8802 answers (not a relay), nothing has answered on 8799 at 3 looks in a row (2+ minutes) and the party copy was not
# stopped on purpose, the copy's own collector is started alone, hidden and detached (the runner never waits on it beyond 8 s). It never
# stops anything: not 8802, not his play server, not a collector that answers. A new collector that does not answer within 8 s is stopped
# (only that new process) and the next try is in 10 minutes. One runner.log line either way.
$script:collMiss=0; $script:collT=0; $script:collDown=''
function Ensure-Collector([string]$PD,[int]$port=8799){
  if((Epoch) -lt $script:collT){ return }
  $coll=$PD+'\tools\collector.ps1'; if(-not (Test-Path -LiteralPath $coll)){ return }
  if(Answers $port){ $script:collMiss=0; $script:collDown=''; return }
  if((PartyIntent) -eq 'stopped'){ $script:collMiss=0; return }
  if(-not $script:collDown){ $script:collDown=(Get-Date).ToString('HH:mm') }
  $script:collMiss++
  if($script:collMiss -lt 3){ return }
  $script:collMiss=0
  $ps=Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
  $np=Start-Process -FilePath $ps -WindowStyle Hidden -PassThru -ArgumentList ('-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "'+$coll+'" -Root "'+$PD.TrimEnd('\')+'" -Port '+$port)
  $up=$false; for($i=0;$i -lt 16;$i++){ Start-Sleep -Milliseconds 500; if(PortOpen $port){ $up=$true; break } }
  if($up){ Say ('report receiver '+$port+' had not answered since '+$script:collDown+' while 8802 serves: started the party copy''s own collector (pid '+$np.Id+'); run reports and notes reach exports again'); $script:collDown=''; PutS 'pub_t' '0'; return }
  try{ Stop-Process -Id $np.Id -Force -ErrorAction SilentlyContinue }catch{}
  $script:collT=(Epoch)+600
  Say ('PROBLEM: report receiver '+$port+' down since '+$script:collDown+' and the party copy''s collector did not answer within 8 s; next try in 10 minutes')
}
# 10-27 (same order): the report receiver in the status note (and main-status): up or down by a knock on 8799 (a connect, no request), and
# when the newest run report and note landed in the party copy's exports folder (HH:MM today, else MM-dd HH:MM)
function NewestExport([string]$PD,[string]$filter){
  try{ $f=Get-ChildItem -LiteralPath ($PD+'\exports') -Filter $filter -File -ErrorAction Stop | Sort-Object LastWriteTime | Select-Object -Last 1
       if($f){ $t=$f.LastWriteTime; if($t.Date -eq (Get-Date).Date){ return $t.ToString('HH:mm') }; return $t.ToString('MM-dd HH:mm') } }catch{}
  return 'none'
}
function Receiver8799(){
  $PD='C:\claudecode\pillagers-party'
  return ($(if(PortOpen 8799){ 'up' }else{ 'down' })+', last report '+(NewestExport $PD 'run-*.txt')+', last note '+(NewestExport $PD 'feedback-*.txt'))
}
function Ensure-Play(){
  if(-not $Idle){ return }
  try{
    $PD='C:\claudecode\pillagers-party'
    if($script:playP){   # a start begun earlier: look at it, never wait for it
      if(-not $script:playP.HasExited){
        if(((Epoch)-$script:playS) -lt 120){ return }
        Stop-Process -Id $script:playP.Id -Force -ErrorAction SilentlyContinue   # only the script: a server it already started keeps serving
        $script:playP=$null; $script:playT=(Epoch)+540; Say 'PROBLEM: starting the 8802 server took over 2 minutes and was stopped; next try in 10 minutes'; return
      }
      $rc=$script:playP.ExitCode; $script:playP=$null; $script:playMiss=0
      if($rc -eq 0 -and (Answers 8802)){ Say ('8802 serves the party copy again (v'+(PartyVer $PD)+'): he reloads the page'); PutS 'pub_t' '0' }
      else { $script:playT=(Epoch)+540; Say ('PROBLEM: the 8802 server did not start (code '+$rc+'), next try in 10 minutes: '+(Short ((Get-Content -LiteralPath ($W+'\play-start.out') -Tail 3 -ErrorAction SilentlyContinue) -join ' '))) }
      return
    }
    if(((Epoch)-$script:playT) -lt 60){ return }
    $script:playT=Epoch
    if(-not (Test-Path -LiteralPath ($PD+'\.git')) -or -not (Test-Path -LiteralPath ($PD+'\tools\serve.ps1'))){ return }
    $relay=((Running 'play-relay\.mjs') -gt 0)
    if($relay){ if(RelayGame){ $script:playMiss=0; return } } elseif(Answers 8802){ $script:playMiss=0; Ensure-Collector $PD; return }
    if((PartyIntent) -eq 'stopped'){ if($script:playMiss -ge 0){ Say '8802 has no server: the party copy was stopped on purpose, so it stays off'; $script:playMiss=-1 }; return }
    if($script:playMiss -lt 0){ $script:playMiss=0 }
    $script:playMiss++
    if($script:playMiss -lt 3){ return }
    # 10-28: a running party-host-copy (the copy update Refresh-Party starts on every new master, or a -Start) used to set the misses back
    # to 0 before they were counted; with master moving every 1 to 3 minutes 8802 stayed down 18+ minutes after his 23:12 restart. Now the
    # misses count, a start waits only for the one that is running, and Refresh-Party starts no new update while 8802 is down.
    if((Running 'party-host-copy\.ps1') -gt 0){ return }
    $S=$T+'\migrate\party-host-copy.ps1'; if(-not (Test-Path -LiteralPath $S)){ return }
    $a=@('-NoProfile','-ExecutionPolicy','Bypass','-File',('"'+$S+'"'),'-Start')
    if(-not $relay -and (PortOpen 8799) -and (Running 'pillagers-party[\\/]+tools[\\/]+collector\.ps1') -eq 0){ $a+='-NoCollector' }
    $p=Start-Process powershell.exe -NoNewWindow -PassThru -ArgumentList $a -RedirectStandardOutput ($W+'\play-start.out') -RedirectStandardError ($W+'\play-start.err')
    [void]$p.Handle   # PS 5.1: hold the handle so ExitCode is filled in later
    $script:playP=$p; $script:playS=Epoch
    $w8=$(if($relay){ 'the play relay on 8802 has not delivered the game for 2 minutes (its VM side does not answer)' }else{ 'nothing has answered on 8802 for 2 minutes' })
    Say ($w8+': serving the party copy again (party-host-copy -Start'+$(if($a -contains '-NoCollector'){ ' -NoCollector' }else{ '' })+')')
  } catch { $script:playT=(Epoch)+540; Say ('PROBLEM: 8802 check failed: '+(Short $_.Exception.Message)) }
}

function Build-Fixture(){
  $t0=Get-Date
  $fx=& powershell.exe -NoProfile -ExecutionPolicy Bypass -File ($T+'\mkfixture.ps1') -Root $R 2>&1 | Select-Object -Last 2
  $fi=Get-Item -LiteralPath ($T+'\fixture.html') -ErrorAction SilentlyContinue
  if(-not $fi -or $fi.LastWriteTime -lt $t0 -or $fi.Length -lt 5000000){ Say ('PROBLEM: the test copy did not build: '+(Short ($fx -join ' '))); return $false }
  return $true
}

# IDLE MODE: is this commit already another PC's? Its status says it is testing it now (seen under 3 hours ago), or it sent a finished run of it.
function OtherPC([string]$head){
  [void](G -C $Res fetch -q origin $Branch); if($script:gx -ne 0){ return '' }
  foreach($f in ((G -C $Res ls-tree -r --name-only FETCH_HEAD -- spare) -split "`n")){
    if($f -notmatch '^spare/([A-Za-z0-9_.-]+)/(.+)$' -or $Matches[1] -eq $HostN){ continue }
    $h=$Matches[1]; $p=$Matches[2]
    if($p -eq 'status.txt'){
      $t=G -C $Res show ('FETCH_HEAD:'+$f)
      if($t -match ('(?m)^game='+$head.Substring(0,8)) -and $t -match '(?m)^test_run=running' -and $t -match '(?m)^epoch=(\d+)' -and ((Epoch)-[long]$Matches[1]) -lt 10800){ return ('being tested on '+$h) }
    } elseif($p -match '^corpus/corpus-\d{4}-\d{4}\.txt\.head$'){
      if((G -C $Res show ('FETCH_HEAD:'+$f)).StartsWith($head)){ return ('already tested on '+$h) }
    }
  }
  return ''
}

function Start-Corpus(){
  $blob=G -C $R rev-parse 'HEAD:dark_raiders.html'; $head=G -C $R rev-parse HEAD
  if(-not $blob -or $blob -eq (GetS 'tested_blob')){ return }
  if($Idle){
    if((GetS 'skip_blob') -eq $blob){ return }
    $who=OtherPC $head
    if($who){
      PutS 'skip_blob' $blob; Say ('build '+$head.Substring(0,8)+' (v'+(GameVer)+') is '+$who+': robots only here')
      if((GetS 'fx_blob') -ne $blob -and (Build-Fixture)){ Copy-Item -LiteralPath ($T+'\fixture.html') -Destination ($T+'\fxcorpus.html') -Force; PutS 'fx_blob' $blob }
      return
    }
    # 10-22 review: a full run takes 2.5 to 3.5 hours (corpq.sh), so one started after 19:10 is stopped at 22:40 and spends one of the
    # build's two tries. The robots get the build now; the full run waits for the morning (tries untouched).
    $hm=HourMin
    if($hm -ge 1910 -and $hm -lt 2240 -and (FollowAway) -eq 0){
      if((GetS 'fx_blob') -ne $blob -and (Build-Fixture)){ Copy-Item -LiteralPath ($T+'\fixture.html') -Destination ($T+'\fxcorpus.html') -Force; PutS 'fx_blob' $blob; Say ('build '+$head.Substring(0,8)+' (v'+(GameVer)+'): robots only until the morning, a full run would not end before 22:40') }
      return
    }
    # 10-22 12:03: the first full run here (with two robots) took this PC from 8.4 GB free to under 4 within a minute and was stopped,
    # spending a try. By day this PC has about 8 to 9 GB free while he is away (the VM holds 10), so a full run starts only with 10 GB free;
    # otherwise the robots get the build and no try is spent.
    if((FreeGB) -lt 10){
      if((GetS 'fx_blob') -ne $blob -and (Build-Fixture)){ Copy-Item -LiteralPath ($T+'\fixture.html') -Destination ($T+'\fxcorpus.html') -Force; PutS 'fx_blob' $blob; Say ('build '+$head.Substring(0,8)+' (v'+(GameVer)+'): robots only, a full run needs 10 GB free here') }
      return
    }
  }
  # SPARE-PRESENCE-PAUSE: a run stopped because someone came to the PC has already given its try back (Stop-Work -Refund)
  $tries=0; if((GetS 'try_blob') -eq $blob){ $tries=[int]('0'+(GetS 'tries')) }
  if($tries -ge 2){ return }   # this build failed twice to give a full run; wait for the next one
  PutS 'try_blob' $blob; PutS 'tries' ([string]($tries+1))
  if(-not (Build-Fixture)){ return }
  # SPARE-PRESENCE-PAUSE: someone came to the spare PC while the test copy was built (a minute or so): the run is not started and its try
  # is given back; the next round pauses
  if(Arrived){ PutS 'tries' ([string]$tries); Say ('someone came to the PC while the test copy was built ('+$script:awayWhy+'): the full run waits, its try is given back'); return }
  PutS 'fx_blob' $blob   # corpq.sh copies this test copy to fxcorpus.html, which the robots play
  $name='corpus-'+(Get-Date -Format 'MMdd-HHmm')+'.txt'; $outF=$CorpDir+'\'+$name
  [IO.File]::WriteAllText($outF+'.head',$head+"`n",$Enc)
  Start-Process -FilePath $Bash -ArgumentList @('tools/handoff/shipkit/corpq.sh',('"'+($outF -replace '\\','/')+'"')) -WorkingDirectory $R -WindowStyle Hidden | Out-Null
  PutS 'corpus_file' $outF; PutS 'corpus_blob' $blob; PutS 'corpus_t' ([string](Epoch))
  Say ('full test run started on '+$head.Substring(0,8)+' (v'+(GameVer)+') -> '+$name)
}

# 10-31: before a test Chrome starts, test Chromes whose script is gone are ended and the test profiles lose their stale lock files,
# so one Chrome per test at most and no "profile in use" start
function Tidy-Profiles(){
  if(-not $Idle){ return }
  try{
    $own=@{ '9331'=((Running 'fuzz\.ps1.*-Port 9331(\s|$)') -gt 0); '9332'=((Running 'fuzz\.ps1.*-Port 9332(\s|$)') -gt 0); 'p2'=((Running 'p2\.mjs"?\s+host(\s|$)') -gt 0) }
    $k=0
    Get-CimInstance Win32_Process -Filter "Name='chrome.exe'" -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine } | ForEach-Object {
      $c=$_.CommandLine; $o=$null
      if($c -match 'pillagers-p2online'){ $o='p2' } elseif($c -match 'pillagers-cdp' -and $c -match 'remote-debugging-port=(9331|9332)(\s|$)'){ $o=$Matches[1] }
      if($o -and -not $own[$o]){ Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue; $k++ } }
    if($k){ Say ('ended '+$k+' left-over test Chrome parts') }
    if(-not ($own['9331'] -or $own['9332'] -or $own['p2'])){
      Get-ChildItem -LiteralPath $env:TEMP -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -like 'pillagers-cdp*' -or $_.Name -like 'pillagers-p2online*' } | ForEach-Object {
        foreach($lf in 'SingletonLock','SingletonCookie','SingletonSocket','lockfile'){ Remove-Item -LiteralPath (Join-Path $_.FullName $lf) -Force -ErrorAction SilentlyContinue } } }
  }catch{}
}
function Start-Robot([int]$port,[string]$copy,[string]$size='',[switch]$Low){
  Tidy-Profiles
  if(-not (Test-Path -LiteralPath ($T+'\fxcorpus.html'))){ return }
  $env:FUZZ_OUT_DIR=$FzOut; $env:FUZZ_COPY_NAME=$copy
  $pr=Start-Process -FilePath powershell.exe -WindowStyle Hidden -PassThru -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-WindowStyle','Hidden',
    '-File',('"'+$T+'\fuzz.ps1"'),'-Minutes',[string]$FuzzMinutes,'-IgnoreFlag','-Port',[string]$port,'-MinFreeGB',$(if($Idle){ '3' }else{ '2' }),'-Fixture','fxcorpus.html',$(if($size){ '-Size' }else{ '-P2Share' }),$(if($size){ $size }else{ '75' }))
  # 10-28: below normal at once; the robot's Chrome and its other children take the class it has when they start
  if($Low -and $pr){ try{ $pr.PriorityClass=[Diagnostics.ProcessPriorityClass]::BelowNormal }catch{} }
  $script:lightRun=[bool]$Low   # Watch lets only a light robot go on while he is at the PC
  Remove-Item Env:FUZZ_OUT_DIR,Env:FUZZ_COPY_NAME -ErrorAction SilentlyContinue
  Say ('robot started on '+$port+$(if($size){ ' at '+$size }else{ '' })+$(if($Low){ ', below normal (he is at the PC)' }else{ '' }))
}

# 10-22 his "All this work and you can't tell what it's doing?!": the spare PC went quiet at 09:27 and the VM (behind the main PC's private
# switch) cannot see the home network. The main PC can, so in idle mode its status also says whether the spare PC is on: its name, then a
# ping, then two ports, then whether it answered the network's address lookup (ARP, which its firewall cannot block). At most every 10 minutes.
function SparePC([string]$n='DESKTOP-82BKOP4'){
  if($script:spT -and ((Get-Date)-$script:spT).TotalSeconds -lt 600){ return $script:spV }
  $script:spT=Get-Date; $ip=''
  try { $ip=@([Net.Dns]::GetHostAddresses($n) | Where-Object { $_.AddressFamily -eq 'InterNetwork' })[0].IPAddressToString } catch { }
  if(-not $ip){ $script:spV='off or offline (its name is not on the network), '+(Get-Date).ToString('HH:mm'); return $script:spV }
  $v=''
  if(Test-Connection -ComputerName $ip -Count 1 -Quiet -ErrorAction SilentlyContinue){ $v='on ('+$ip+' answers a ping)' }
  if(-not $v){ foreach($port in 445,135){ $c=New-Object Net.Sockets.TcpClient; try { if($c.ConnectAsync($ip,$port).Wait(1500) -and $c.Connected){ $v='on ('+$ip+' port '+$port+')'; break } } catch { } finally { $c.Dispose() } } }
  if(-not $v -and @(Get-NetNeighbor -IPAddress $ip -ErrorAction SilentlyContinue | Where-Object { [string]$_.State -eq 'Reachable' }).Count){ $v='on ('+$ip+' is on the network but answers nothing else)' }
  if(-not $v){ $v='not answering ('+$ip+')' }
  $script:spV=$v+', '+(Get-Date).ToString('HH:mm'); return $script:spV
}
function Write-Status([string]$corpus,[int]$robots){
  $os=Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
  $free=if($os){ [math]::Round($os.FreePhysicalMemory/1MB,1) }else{ '?' }
  # 10-28: the machine's real size and load, read only, so what it runs at once is sized from its numbers. The notes say 16 GB and
  # 4 threads, but it has read 22 to 25 GB free all week, and every AMD X3D chip has 12 threads or more.
  $tot=if($os){ [math]::Round($os.TotalVisibleMemorySize/1MB,1) }else{ '?' }
  $cpu=@(Get-CimInstance Win32_Processor -ErrorAction SilentlyContinue); $thr='?'; $pct='?'; $cpuN='?'
  if($cpu.Count){ $thr=($cpu | Measure-Object NumberOfLogicalProcessors -Sum).Sum; $lp=($cpu | Measure-Object LoadPercentage -Average).Average; if($null -ne $lp){ $pct=[math]::Round([double]$lp) }
    $cpuN=(([string]$cpu[0].Name) -replace '[^\x20-\x7E]','' -replace '\w+=','' -replace '\s+',' ').Trim() }
  # 10-21: each pair in its own brackets. PowerShell's comma binds before +, so the old list was ONE string joined with spaces and the
  # VM's import never found epoch= (it read the spare PC as never seen).
  $L=@(('host='+$HostN),('seen='+(Get-Date).ToString('yyyy-MM-dd HH:mm')),('epoch='+(Epoch)),('game='+(G -C $R rev-parse --short=8 HEAD)+' v'+(GameVer)),
    ('test_run='+$corpus),('robots='+$robots),('ram_free_gb='+$free),('push_ok='+(GetS 'push_ok')),('runner='+$SelfHash.Substring(0,8)),('mode='+$(if($Idle){ 'idle' }else{ 'full' })),
    ('ram_total_gb='+$tot),('cpu_threads='+$thr),('cpu_pct='+$pct),('cpu='+$cpuN))
  # SPARE-PRESENCE-PAUSE: on the spare PC, when its pause began (epoch), for whoever reads the status; the VM goes by test_run=paused alone
  if($Idle){ $L+=('spare_pc='+(SparePC)); $L+=('party='+(GetS 'party_ver')+' '+(GetS 'party_head')); $L+=('play8802='+(Play8802)); $L+=('receiver8799='+(Receiver8799)) } else {
    if($corpus -like 'paused*' -and (GetS 'pause_t')){ $L+=('paused_since='+(GetS 'pause_t')) }
    if($script:noIn){ $L+='presence=off' }   # the presence checks did not load: it tests without pausing for anyone (see runner.log)
  }
  [IO.File]::WriteAllLines($StatusF,[string[]]$L,$Enc)
}

function Publish([string]$why){
  if(-not (Test-Path -LiteralPath ($Res+'\.git'))){ Say 'PROBLEM: the results copy is missing (run tools\spare\spare-setup.ps1 again)'; return }
  $dst=$Res+'\spare\'+$HostN; New-Item -ItemType Directory -Force -Path ($dst+'\corpus'),($dst+'\fuzz') | Out-Null
  Get-ChildItem -LiteralPath $CorpDir -Filter 'corpus-*.txt' | Sort-Object Name | Select-Object -Last 12 | ForEach-Object {
    if([IO.File]::ReadAllText($_.FullName) -match 'ALL DONE'){
      Copy-Item -LiteralPath $_.FullName -Destination ($dst+'\corpus\'+$_.Name) -Force
      if(Test-Path -LiteralPath ($_.FullName+'.head')){ Copy-Item -LiteralPath ($_.FullName+'.head') -Destination ($dst+'\corpus\'+$_.Name+'.head') -Force }
    }
  }
  if(Test-Path -LiteralPath ($FzOut+'\fuzz.log')){ Copy-Item -LiteralPath ($FzOut+'\fuzz.log') -Destination ($dst+'\fuzz\fuzz.log') -Force }
  Get-ChildItem -LiteralPath $FzOut -Filter 'fuzz-*.jsonl' | Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-7) } |
    ForEach-Object { Copy-Item -LiteralPath $_.FullName -Destination ($dst+'\fuzz\'+$_.Name) -Force }
  Copy-Item -LiteralPath $StatusF -Destination ($dst+'\status.txt') -Force
  [void](G -C $Res add -A -f -- spare)
  [void](G -C $Res diff --cached --quiet)
  if($script:gx -eq 0){ return }
  [void](G -C $Res commit -q -m ('spare: '+$HostN+' '+$why+' '+(Stamp)))
  # 10-22: two PCs push here now (the spare PC and the main PC's idle runs), each into its own folder, so a refused push is usually the
  # other PC's newer note: take it in with a plain merge (never a rebase or a force) and push once more.
  for($k=0;$k -lt 2;$k++){
    $o=G -C $Res push -q origin ('HEAD:refs/heads/'+$Branch)
    if($script:gx -eq 0 -or $k -eq 1){ break }
    [void](G -C $Res fetch -q origin $Branch)
    $m=G -C $Res merge -q --no-edit FETCH_HEAD
    if($script:gx -ne 0){ [void](G -C $Res merge --abort); $o=$o+' / merge: '+$m; break }
  }
  if($script:gx -ne 0){ PutS 'push_ok' '0'; Say ('PROBLEM: results push failed: '+(Short $o)) } else { PutS 'push_ok' '1'; PutS 'pub_t' ([string](Epoch)) }
}

# 10-22 review: a copy that restarted itself for a new runner from GitHub left its robots (or a test run) going; this copy looks after them,
# so his return, the 4 GB floor and the 22:40 hold still stop them
if($Idle -and (IdleWork) -gt 0){ $script:working=$true; Say 'an earlier copy left test work running: this copy looks after it now' }
# SPARE-PRESENCE-PAUSE: on the spare PC an earlier copy's work (or the full run's Chrome, which stays open after a finished run) is this
# copy's to stop too: while someone is at the PC every look stops whatever is there. A pause this PC was switched off in (or whose runner
# died) is over: the next one is a new pause with its own start time, and the status goes out at the first round.
# A copy that restarted itself during a pause left when someone was last there (Save-Hold): this copy goes on from it. Then, before its
# first round, every new copy looks for about 35 s (8 looks 5 s apart, writing the heartbeat so the task's copies exit): a pad needs two
# looks to show a change and a game two graphics-card looks 30 s apart, so neither a restart for a new runner, nor the 15-minute task
# reviving a stopped runner, nor the stopgap handing over, starts the tests under someone who is playing on a pad or watching.
if(-not $Idle){
  $script:working=$true
  if($HbOld -and (GetS 'pause_why')){ PutS 'pause_why' ''; PutS 'pause_t' ''; PutS 'pub_t' '0'; Say 'the last pause ended with this PC off or its runner stopped' }
  Load-Hold
  if(-not $script:noIn){ for($i=0;$i -lt 8;$i++){ [IO.File]::WriteAllText($Hb,[string](Epoch),$Enc); if((AwaySec) -lt 900){ break }; if($i -lt 7){ Start-Sleep -Seconds 5 } } }
}
while($true){
  [IO.File]::WriteAllText($Hb,[string](Epoch),$Enc)
  if($Idle){
    # IDLE MODE: while he is at the PC (or memory is short) nothing runs; a look every 20 seconds, a status note when that changes
    $away=AwaySec; $fg=FreeGB; $vmn=VMNight
    # 10-28 (Main PC Correspondent): no more start-and-stop. 116 stints on 10-25 to 10-27 lasted a median 4 minutes: work started at 6 GB
    # free while the VM was still growing into the same memory, and stopped at 4. Now, while the VM's memory follows him, nothing starts
    # until the VM has stopped growing, a start needs 6 GB free (the 4 GB he keeps free plus the robot), work stops under 4 GB at two looks
    # (Watch; under 3 at one look here), and after a memory stop nothing starts for 30 minutes. His rulings: the VM takes its memory first;
    # 4 GB stay free (his 10-28 afternoon "can we knock it down to only leave 4gb free?"; it was 6).
    $fw=FollowAway
    # 10-30: while the online 2 player test is still wanted, a start needs 5 GB free (his 4 GB floor plus its one Chrome), not 6
    $ng=$(if(VMResizeSoon -or (PartyHold)){ 999 }elseif($script:working){ 3 }elseif($vmn){ 10 }elseif((GetS 'p2_done') -ne $P2Want){ 5 }else{ 6 })
    $na=$(if($script:working -or $fw -le 0){ 900 }else{ [Math]::Max(900,($fw+2)*60) })
    $grow=(-not $script:working) -and ($fw -gt 0) -and (VmGrowing)
    $lowW=(-not $script:working) -and (((Epoch)-[long]('0'+(GetS 'lowstop_t'))) -lt 1800)
    # 10-28: at the PC but not playing (his "what about daytime testing when i'm at the pc?"): one light robot may run (1080p, below normal)
    $light=($away -lt 900) -and (LightOK)
    $busy=(($away -lt $na) -and -not $light)
    if($busy -or $fg -lt $ng -or $grow -or $lowW){
      $pw=$(if(PartyHold){ 'paused: party night, no tests until Sun 06:00' }elseif($away -lt 900 -and -not $light){ 'paused: he is using the PC'+$(if($script:playWhy){ ' ('+$script:playWhy+')' }else{ '' }) }elseif($busy -or $grow){ 'paused: the VM takes its memory first' }elseif($lowW){ 'paused: 30 minutes after a memory stop' }elseif($vmn){ 'paused: the VM has the memory at night' }else{ 'paused: low ram, under '+$ng+' GB free' })
      if($script:working){ $lr=((-not $busy) -and $ng -lt 999 -and $fg -lt $ng); if($lr -and -not $script:fakeLow){ PutS 'lowstop_t' ([string](Epoch)) }; Stop-Work $pw -LowRam:$lr }
      Refresh-Party
      Ensure-Bridge
      Ensure-Play
      # a new runner is taken as soon as master moves (Refresh-Party asks GitHub every minute), not only at the 10-minute note
      if($script:lastMaster -and $script:lastMaster -ne $script:tookMaster -and ((Running 'corpq\.sh|corpus-slices\.sh') -eq 0)){
        $script:tookMaster=$script:lastMaster
        if((Update-Game) -and (NewRunnerOK)){
          Say 'a new copy of this runner came from GitHub: restarting'
          Remove-Item -LiteralPath $Hb -Force -ErrorAction SilentlyContinue
          Start-Process -FilePath wscript.exe -ArgumentList ('"'+$T+'\spare\spare-start.vbs"') | Out-Null
          exit 0
        }
      }
      $pt=[long]('0'+(GetS 'pub_t'))
      if((GetS 'pause_why') -ne $pw -or ((Epoch)-$pt) -ge ($PublishMin*60)){
        if((GetS 'pause_why') -ne $pw){ PutS 'pause_why' $pw; Say $pw }
        Write-Status $pw 0; Publish 'paused'
        if(((Running 'corpq\.sh|corpus-slices\.sh') -eq 0) -and (Update-Game) -and (NewRunnerOK)){
          Say 'a new copy of this runner came from GitHub: restarting'
          Remove-Item -LiteralPath $Hb -Force -ErrorAction SilentlyContinue
          Start-Process -FilePath wscript.exe -ArgumentList ('"'+$T+'\spare\spare-start.vbs"') | Out-Null
          exit 0
        }
      }
      if($Once){ break }
      Start-Sleep -Seconds 20; continue
    }
    if((GetS 'pause_why')){ PutS 'pause_why' ''; Say ('he has been away '+[int]($away/60)+' minutes and '+[Math]::Round($fg,1)+' GB are free: testing') }
    $script:working=$true
  } else {
    # SPARE-PRESENCE-PAUSE: while someone is at the spare PC nothing runs; a look every 20 seconds (so the heartbeat stays fresh), each
    # one also stopping any test part that survived or started since (with nothing to stop that is one process list), a status note for
    # the VM when the pause begins and every PublishMin minutes (a failed push is tried again at the next note, not every look), and at
    # those notes a new runner from GitHub is still taken (not while a full run is still there: the checkout would swap its files), so a
    # fix from the VM reaches a spare PC that is paused for hours; the new copy goes on from when someone was last there (Save-Hold)
    $away=AwaySec
    if($away -lt 900){
      $pw='paused: someone is using the PC'
      Stop-Work ($pw+', '+$script:awayWhy) -Refund
      $chg=((GetS 'pause_why') -ne $pw)
      if($chg){ PutS 'pause_why' $pw; PutS 'pause_t' ([string](Epoch)); Say ($pw+' ('+$script:awayWhy+')') }
      $pt=[Math]::Max([long]('0'+(GetS 'pub_t')),$script:pubTry)
      if($chg -or ((Epoch)-$pt) -ge ($PublishMin*60)){
        $script:pubTry=[long](Epoch); Write-Status $pw 0; Publish 'paused'
        if(((Running 'corpq\.sh|corpus-slices\.sh') -eq 0) -and (Update-Game) -and (NewRunnerOK)){
          Say 'a new copy of this runner came from GitHub: restarting'
          Save-Hold $away
          Remove-Item -LiteralPath $Hb -Force -ErrorAction SilentlyContinue
          Start-Process -FilePath wscript.exe -ArgumentList ('"'+$T+'\spare\spare-start.vbs"') | Out-Null
          exit 0
        }
      }
      if($Once){ break }
      Start-Sleep -Seconds 20; continue
    }
    # testing again: pub_t 0 makes this round publish its status at once, so the VM does not go on reading "paused" for up to PublishMin
    if((GetS 'pause_why')){ PutS 'pause_why' ''; PutS 'pause_t' ''; PutS 'pub_t' '0'; Say ('nobody has been at the PC for '+[int]($away/60)+' minutes: testing again') }
    if((GetS 'seen_t') -or (GetS 'human_t')){ PutS 'seen_t' ''; PutS 'human_t' '' }
    $script:working=$true
  }
  Ensure-Server
  Refresh-Party
  Ensure-Bridge
  Ensure-Play
  $cr=Running 'corpq\.sh|corpus-slices\.sh'
  $why=''
  if($cr -eq 0){
    $cf=GetS 'corpus_file'
    if($cf -and (GetS 'corpus_done') -ne $cf -and (Test-Path -LiteralPath $cf)){
      PutS 'corpus_done' $cf
      if([IO.File]::ReadAllText($cf) -match 'ALL DONE'){ PutS 'tested_blob' (GetS 'corpus_blob'); Say ('full test run finished: '+(Split-Path $cf -Leaf)); $why='test run done' }
      else { Say ('full test run ended without finishing: '+(Split-Path $cf -Leaf)) }
    }
    if(Update-Game){
      if((NewRunnerOK)){
        if($why){ Write-Status 'idle' (Running 'fuzz\.ps1'); Publish $why }
        Say 'a new copy of this runner came from GitHub: restarting'
        Remove-Item -LiteralPath $Hb -Force -ErrorAction SilentlyContinue
        Start-Process -FilePath wscript.exe -ArgumentList ('"'+$T+'\spare\spare-start.vbs"') | Out-Null
        exit 0
      }
      if(Arrived){ continue }   # SPARE-PRESENCE-PAUSE (never in IDLE MODE)
      if(-not $Idle -or (AwaySec) -ge 900){ Start-Corpus }   # 10-28: never a full run while he is at the main PC (only the light robot)
    }
  }
  if(Arrived){ continue }
  if($Idle){
    # 10-28 (Main PC Correspondent), his "i don't think the party is any reason to not use the gpu": the main PC runs ONE robot, playing the
    # 2-player raid at 4K in both windows on his RX 7900 XTX, the only frame numbers at party size on a real card (the VM has no graphics
    # card). One, not two: its two 1080p robots found 0 problems in 960 raids, raid lines carry no port (two robots mix their numbers in one
    # fuzz.log), and the memory goes further. The 10-22 reason for 1080p is gone: the main PC game check skips pillagers-cdp Chromes since
    # 10-24; if it still reads the robot as a game, Watch puts it back to 1080p for the day (no4k).
    # (a Chrome game he left drawing already shows in the game check: then this start plays 1080p and nothing is blamed on the robot)
    # 10-28: while he is at the PC (working, not playing) the robot plays 1080p at below-normal priority, so his programs come first
    # 10-28 23:50: the robot plays the newest build. Start-Corpus (which builds the robots' copy) is skipped while he is at the PC, so the
    # light robot played v36.17 from 21:23 to past 23:43 while v36.18 to v36.27 shipped (the freeze fixes among them). A build that fails
    # once is not tried again until master moves.
    if((Running 'fuzz\.ps1.*-Port 9332(\s|$)') -eq 0 -and ((Running 'corpq\.sh|corpus-slices\.sh') -eq 0)){
      $fb=G -C $R rev-parse 'HEAD:dark_raiders.html'
      if($fb -and (GetS 'fx_blob') -ne $fb -and (GetS 'fx_fail') -ne $fb){
        if(Build-Fixture){ Copy-Item -LiteralPath ($T+'\fixture.html') -Destination ($T+'\fxcorpus.html') -Force; PutS 'fx_blob' $fb; Say ('build v'+(GameVer)+': the robot plays it') } else { PutS 'fx_fail' $fb }
      }
    }
    # 10-28 23:55: a new robot block needs the START memory (6 GB free; 4K needs 7). Before, the next hour's robot started on the 3 GB
    # keep-going bar because the runner was still working: the 4K robot started at 4.3 GB free (17:44 and 21:23) and was stopped for memory
    # within a minute, 0 raids. Under 6 GB the runner stops working, so the next start waits for 6 GB like any other start.
    # 10-30 (CEO, his "yes i want the auto test", then "can you run it while I'm here?"): the main PC hosts the online 2 player test ONCE,
    # ahead of the robot, also while he works at the PC (tools\p2online\p2.mjs host: test port 8817, Chrome 9361, never 8802; about 15
    # minutes; no AI). The spare PC's runner joins as player 2. It starts with 5 GB free; Watch ends it like a light robot once he plays or
    # under 4 GB at two looks; 3 tries at most. Its result goes out with the next status (spare\JUL26\p2-online-test.txt on spare-results).
    # A new $P2Want asks for one more run.
    $p2Run=(Running 'p2\.mjs"?\s+host(\s|$)')
    if($p2Run -eq 0 -and (GetS 'p2_done') -ne $P2Want -and (GetS 'p2_t') -and (GetS 'p2_want') -eq $P2Want){
      $pf=$T+'\handoff\spare\p2-online-test.txt'; $pi=Get-Item -LiteralPath $pf -ErrorAction SilentlyContinue
      if($pi -and ([DateTimeOffset]$pi.LastWriteTime).ToUnixTimeSeconds() -gt [long](GetS 'p2_t')){
        Copy-Item -LiteralPath $pf -Destination ($Res+'\spare\'+$HostN+'\p2-online-test.txt') -Force -ErrorAction SilentlyContinue
        PutS 'p2_done' $P2Want; Say ('online 2 player test: '+(Short ([IO.File]::ReadAllLines($pf)[0]))); Publish 'p2 online test'
      }
    }
    if($p2Run -eq 0 -and (GetS 'p2_done') -ne $P2Want -and (FreeGB) -ge 5 -and (Test-Path -LiteralPath ($T+'\p2online\p2.mjs'))){
      $n=$(if((GetS 'p2_want') -eq $P2Want){ [int]('0'+(GetS 'p2_tries')) }else{ 0 })
      if($n -ge 3){ PutS 'p2_done' $P2Want; Say 'the online 2 player test did not finish in 3 tries' }
      else {
        if((Running 'fuzz\.ps1.*-Port 9332(\s|$)') -gt 0){ Stop-Work 'the online 2 player test goes first' }
        Tidy-Profiles; PutS 'p2_want' $P2Want; PutS 'p2_tries' ([string]($n+1)); PutS 'p2_t' ([string](Epoch))
        Start-Process -FilePath $Node -WindowStyle Hidden -ArgumentList @(('"'+$T+'\p2online\p2.mjs"'),'host','--port','8817','--cdp','9361','--root',('"'+$R+'"')) | Out-Null
        $p2Run=1; $script:working=$true; $script:lightRun=$true; Say ('online 2 player test started as the host (try '+($n+1)+', test port 8817)')
      }
    }
    if($p2Run -eq 0 -and (Running 'fuzz\.ps1.*-Port 9332(\s|$)') -eq 0){
      $sf=FreeGB
      if($sf -lt 6){ Stop-Work 'under 6 GB free for a new robot' }
      else { $atPc=((AwaySec) -lt 900); $script:gcAtStart=(GameChrome); Start-Robot 9332 'fixture-soak-spare2.html' $(if($atPc -or $script:gcAtStart -or $sf -lt 7 -or (GetS 'no4k') -eq (Get-Date).ToString('yyyy-MM-dd')){ '' }else{ '3840x2160' }) -Low:$atPc }
    }
  } else {
    if((Running 'fuzz\.ps1.*-Port 9331(\s|$)') -eq 0){ Start-Robot 9331 'fixture-soak-spare1.html' }
    # 10-30, his "yes i want the auto test": the online 2 player test joins from here. tools\p2online\p2.mjs guest-daemon looks in the
    # p2-mailbox branch every 20 s for an invite from the VM and plays player 2 in a headless Chrome on 9362 (it calls no AI).
    if((Test-Path -LiteralPath ($T+'\p2online\p2.mjs')) -and (Running 'p2\.mjs.*guest-daemon') -eq 0){ Start-Process -FilePath $Node -ArgumentList @(('"'+$T+'\p2online\p2.mjs"'),'guest-daemon','--root',('"'+$R+'"')) -WindowStyle Hidden | Out-Null }
    # 10-22: Start-Robot takes a screen size (fuzz.ps1 -Size), but both robots here stay at 1080p. A 4K robot on the main PC reads as "he is gaming"
    # to its game check (a program at 15% of the graphics card, 22:38 that night), which holds the VM to 30% of its processors; the VM plays the 4K robot.
    # 10-26: on the spare (4 threads) a full run plus two robots choked the robots. 10-28 (CEO): two robots alone choke it too: 4 game windows at
    # 94-100% CPU, player 2 joins in 93-168 s instead of 4-8, and 23 false problems (16 hangs, CDP send timeouts) on v35.65 06:07-07:38, which
    # alone blocked stable; 4-32 an hour on 10-26 and 9-28 on 10-27, while one robot was clean. So the spare runs ONE robot, like the main PC.
  }
  $cs='idle'; if((Running 'corpq\.sh|corpus-slices\.sh') -gt 0){ $cs='running '+(Split-Path (GetS 'corpus_file') -Leaf) }
  Write-Status $cs (Running 'fuzz\.ps1')
  $pt=[long]('0'+(GetS 'pub_t'))
  if($why -or ((Epoch)-$pt) -ge ($PublishMin*60)){ if(-not $why){ $why='update' }; Publish $why }
  if($Once){ break }
  Watch 300   # SPARE-PRESENCE-PAUSE: the spare PC also looks for someone every 5 seconds (it used to sleep the 5 minutes)
}
