# party.ps1 : opens the PILLAGERS PARTY RIG with one click (2026-10-18, his order: "a one click shortcut that opens both windows full screen
# on the attract screen, with Career and the stash out of reach"). The desktop shortcut "Pillagers Party" runs tools\party\party.vbs, which runs this.
# ASCII only (PowerShell 5.1 reads .ps1 as ANSI). Settings: tools\party\party.cfg. Log: tools\party\party.log.
#
# WHAT IT DOES
#   1. Closes any old party Chrome (only the one that uses the party profile, never your normal Chrome).
#   2. Makes sure the game server answers (starts tools\serve.ps1 on that port if not).
#   3. Opens Chrome in its own PARTY PROFILE as an app window (no address bar, no tabs) on the game address, and puts that window
#      full screen on player 1's TV. The party profile has its own save and scoreboard, so a guest who somehow reaches Career or the
#      stash there meets an empty save, never yours.
#   4. URL_OPTIONS=0 (the game as it is today): stays running and watches for the player 2 window, which the game opens when someone clicks
#      "2 PLAYER ARCADE DEMO"; it puts that window full screen on player 2's TV by itself, and again if it is ever closed and reopened.
#      URL_OPTIONS=1 (only once the game supports ?party=1, task 05-party-launch-mode.md): opens BOTH windows itself, on the attract screen.
#   5. Keeps both windows full screen on their TVs (F11 is pressed again if a window leaves full screen) until the party windows are gone.
#
# RUN IT:   double click "Pillagers Party" on the desktop.            (to close the party windows:  ... -File tools\party\party.ps1 -Stop)
#           -ShowScreens   lists the screens Windows has and which one is which player's TV (changes nothing)
#           -DryRun        prints what it would do (changes nothing, does not touch the game server)
# It never touches your normal Chrome, your saves, or anything outside tools\party and the party profile folder.
param([switch]$DryRun,[switch]$ShowScreens,[switch]$Stop)
$ErrorActionPreference='Stop'
$R='C:\claudecode\dark raiders'; $PD=$R+'\tools\party'; $LogF=$PD+'\party.log'
function Log([string]$s){ try{ [IO.File]::AppendAllText($LogF,((Get-Date).ToString('MM-dd HH:mm:ss')+' '+$s+"`r`n")) }catch{} ; if($DryRun -or $ShowScreens){ Write-Output $s } }

# ---------------------------------------------------------------- settings
$cfg=@{ URL_BASE='http://localhost:8802/dark_raiders.html'; P1_DISPLAY='1'; P2_DISPLAY='2'; URL_OPTIONS='0'; FULLSCREEN='1';
        CHROME='C:\Program Files\Google\Chrome\Application\chrome.exe'; PROFILE=($env:LOCALAPPDATA+'\PillagersParty\chrome') }
try{
  foreach($l in (Get-Content -LiteralPath ($PD+'\party.cfg') -ErrorAction Stop)){
    if($l -match '^\s*([A-Z0-9_]+)\s*=\s*(.*?)\s*$'){ $cfg[$Matches[1]]=[Environment]::ExpandEnvironmentVariables($Matches[2]) }
  }
}catch{ Log ('party.cfg not read, defaults used: '+$_.Exception.Message) }
if($cfg.URL_BASE -notmatch '^http://(localhost|127\.0\.0\.1):\d+/[A-Za-z0-9._-]+\.html$'){ Log ('URL_BASE looks wrong, default used: '+$cfg.URL_BASE); $cfg.URL_BASE='http://localhost:8802/dark_raiders.html' }

# ---------------------------------------------------------------- windows and screens (physical pixels: the process is made DPI aware first)
Add-Type -TypeDefinition @'
using System; using System.Runtime.InteropServices; using System.Text; using System.Collections.Generic;
public static class PW {
  [StructLayout(LayoutKind.Sequential)] public struct RECT { public int L, T, R, B; }
  public delegate bool EnumProc(IntPtr h, IntPtr l);
  [DllImport("user32.dll")] public static extern bool SetProcessDPIAware();
  [DllImport("user32.dll")] static extern bool EnumWindows(EnumProc p, IntPtr l);
  [DllImport("user32.dll", CharSet = CharSet.Unicode)] static extern int GetWindowText(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll", CharSet = CharSet.Unicode)] static extern int GetClassName(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll")] static extern bool IsWindowVisible(IntPtr h);
  [DllImport("user32.dll")] static extern bool GetWindowRect(IntPtr h, out RECT r);
  [DllImport("user32.dll")] static extern int GetWindowLong(IntPtr h, int i);
  [DllImport("user32.dll")] static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
  [DllImport("user32.dll")] public static extern bool MoveWindow(IntPtr h, int x, int y, int w, int hh, bool repaint);
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int cmd);
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
  [DllImport("user32.dll")] static extern bool PostMessage(IntPtr h, uint msg, IntPtr w, IntPtr l);
  public static void Close(IntPtr h) { PostMessage(h, 0x10, IntPtr.Zero, IntPtr.Zero); }   // WM_CLOSE: the page closes itself and runs its own cleanup
  [DllImport("user32.dll")] public static extern void keybd_event(byte vk, byte scan, uint flags, UIntPtr extra);
  // every visible Chrome window whose title starts with the prefix: "handle|title|style|left|top|right|bottom|pid"
  public static string[] Find(string prefix) {
    List<string> o = new List<string>();
    EnumWindows(delegate (IntPtr h, IntPtr l) {
      if (!IsWindowVisible(h)) return true;
      StringBuilder c = new StringBuilder(64); GetClassName(h, c, 64);
      if (c.ToString() != "Chrome_WidgetWin_1") return true;
      StringBuilder t = new StringBuilder(256); GetWindowText(h, t, 256);
      string ts = t.ToString();
      if (!ts.StartsWith(prefix)) return true;
      RECT r; GetWindowRect(h, out r);
      uint pid; GetWindowThreadProcessId(h, out pid);
      o.Add(h.ToInt64() + "|" + ts + "|" + GetWindowLong(h, -16) + "|" + r.L + "|" + r.T + "|" + r.R + "|" + r.B + "|" + pid);
      return true;
    }, IntPtr.Zero);
    return o.ToArray();
  }
  // bring a window to the front (the ALT tap is the usual way past the rule that stops a background program from taking the focus)
  public static void Front(IntPtr h) { keybd_event(0x12, 0, 0, UIntPtr.Zero); keybd_event(0x12, 0, 2, UIntPtr.Zero); SetForegroundWindow(h); }
  public static void F11() { keybd_event(0x7A, 0, 0, UIntPtr.Zero); keybd_event(0x7A, 0, 2, UIntPtr.Zero); }
}
'@
[void][PW]::SetProcessDPIAware()
Add-Type -AssemblyName System.Windows.Forms
function Get-Screens(){
  $out=@(); foreach($s in [System.Windows.Forms.Screen]::AllScreens){
    $n=0; if($s.DeviceName -match 'DISPLAY(\d+)$'){ $n=[int]$Matches[1] }
    $out+=[pscustomobject]@{ N=$n; Primary=$s.Primary; X=$s.Bounds.X; Y=$s.Bounds.Y; W=$s.Bounds.Width; H=$s.Bounds.Height }
  }
  return $out
}
# The screen for a Windows display number; if there is no such screen, the primary (player 1) or the nearest other screen (player 2).
function Pick-Screen([int]$want,[bool]$second){
  $all=@(Get-Screens); $m=$all | Where-Object { $_.N -eq $want } | Select-Object -First 1
  if($m){ return $m }
  $prim=$all | Where-Object { $_.Primary } | Select-Object -First 1
  if(-not $second){ return $prim }
  $other=$all | Where-Object { -not $_.Primary } | Sort-Object { [Math]::Abs($_.X-$prim.X) } | Select-Object -First 1
  if($other){ return $other }
  return $prim
}
function Parse-Win([string]$s){
  $p=$s.Split('|'); return [pscustomobject]@{ H=[IntPtr][int64]$p[0]; Title=$p[1]; Style=[int]$p[2]; L=[int]$p[3]; T=[int]$p[4]; R=[int]$p[5]; B=[int]$p[6]; Pid=[int]$p[7] }
}
function Is-Full($w,$sc){
  # full screen = no title bar (WS_CAPTION off) and the window covers exactly that screen
  return ((($w.Style -band 0xC00000) -ne 0xC00000) -and ([Math]::Abs($w.L-$sc.X) -le 3) -and ([Math]::Abs($w.T-$sc.Y) -le 3) -and ([Math]::Abs(($w.R-$w.L)-$sc.W) -le 3) -and ([Math]::Abs(($w.B-$w.T)-$sc.H) -le 3))
}
$script:lastTry=@{}
# Puts one window full screen on a screen. Returns what it did. At most one attempt every 15 seconds per window.
function Place-Window($w,$sc,[string]$who){
  if(Is-Full $w $sc){ return 'ok' }
  $k=[string]$w.H; $now=Get-Date
  if($script:lastTry.ContainsKey($k) -and (($now-$script:lastTry[$k]).TotalSeconds -lt 15)){ return 'wait' }
  $script:lastTry[$k]=$now
  if($DryRun){ Log ('would move the '+$who+' window to screen '+$sc.N+' ('+$sc.X+','+$sc.Y+' '+$sc.W+'x'+$sc.H+') and press F11'); return 'dry' }
  $capOn=(($w.Style -band 0xC00000) -eq 0xC00000)
  if(-not $capOn){ [PW]::Front($w.H); Start-Sleep -Milliseconds 400; if($cfg.FULLSCREEN -eq '1'){ [PW]::F11(); Start-Sleep -Milliseconds 1200 } }   # full screen on the wrong screen: leave it first
  $mw=[Math]::Min(1280,$sc.W-120); $mh=[Math]::Min(720,$sc.H-120)
  [void][PW]::ShowWindow($w.H,9)
  [void][PW]::MoveWindow($w.H,$sc.X+60,$sc.Y+60,$mw,$mh,$true)
  Start-Sleep -Milliseconds 400
  if($cfg.FULLSCREEN -eq '1'){ [PW]::Front($w.H); Start-Sleep -Milliseconds 500; [PW]::F11(); Start-Sleep -Milliseconds 1200 }
  Log ('moved the '+$who+' window to screen '+$sc.N+' and went full screen')
  return 'moved'
}

# ---------------------------------------------------------------- the party Chrome
function Party-Chrome(){
  $pf=[string]$cfg.PROFILE
  if($pf.Length -lt 12 -or $pf -notmatch "Pillagers"){ return @() }   # never match every Chrome by accident
  return @(Get-CimInstance Win32_Process -Filter "Name='chrome.exe'" -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -and $_.CommandLine.Contains($pf) })
}
function Stop-Party(){
  $procs=@(Party-Chrome); if($procs.Count -eq 0){ return }
  $pids=@($procs | ForEach-Object { [int]$_.ProcessId })
  # ask each window to close first, so the game runs its own cleanup (a window killed mid raid leaves a mark that makes the game refuse a new 2 player pick for 75 s); kill what is left after 6 s
  foreach($s in [PW]::Find('')){ $w=Parse-Win $s; if($pids -contains $w.Pid){ [PW]::Close($w.H) } }
  for($i=0;$i -lt 12;$i++){ Start-Sleep -Milliseconds 500; if(@(Party-Chrome).Count -eq 0){ return } }
  foreach($p in (Party-Chrome)){ try{ Stop-Process -Id $p.ProcessId -Force -ErrorAction SilentlyContinue }catch{} }
}
if($ShowScreens){
  Log 'Screens Windows has (N is the number Settings > Display > Identify shows):'
  foreach($s in (Get-Screens)){ Log ('  screen '+$s.N+'  primary='+$s.Primary+'  at '+$s.X+','+$s.Y+'  '+$s.W+'x'+$s.H) }
  $a=Pick-Screen ([int]$cfg.P1_DISPLAY) $false; $b=Pick-Screen ([int]$cfg.P2_DISPLAY) $true
  Log ('player 1 window goes to screen '+$a.N+', player 2 window to screen '+$b.N+'   (party.cfg: P1_DISPLAY='+$cfg.P1_DISPLAY+' P2_DISPLAY='+$cfg.P2_DISPLAY+')')
  exit 0
}
if($Stop){ Stop-Party; Log 'party Chrome closed'; exit 0 }

$sc1=Pick-Screen ([int]$cfg.P1_DISPLAY) $false; $sc2=Pick-Screen ([int]$cfg.P2_DISPLAY) $true
$opt=($cfg.URL_OPTIONS -eq '1')
$pair='party'+(Get-Random -Minimum 1000 -Maximum 9999)
$u1=$cfg.URL_BASE; $u2=''
if($opt){ $u1=$cfg.URL_BASE+'?party=1&pair='+$pair; $u2=$cfg.URL_BASE+'?p2=1&mode=coop&arc=1&party=1&pair='+$pair }
$flags='--user-data-dir="'+$cfg.PROFILE+'" --no-first-run --no-default-browser-check --autoplay-policy=no-user-gesture-required --disable-session-crashed-bubble --disable-infobars --disable-features=Translate'
Log ('start: player 1 screen '+$sc1.N+', player 2 screen '+$sc2.N+', url '+$u1+', URL_OPTIONS='+$cfg.URL_OPTIONS+', dry='+$DryRun)
if($DryRun){
  Log ('would close any party Chrome (profile '+$cfg.PROFILE+')')
  Log ('would check that '+$cfg.URL_BASE+' answers and start tools\serve.ps1 on its port if not')
  Log ('would run: "'+$cfg.CHROME+'" '+$flags+' --app='+$u1)
  if($opt){ Log ('then run: "'+$cfg.CHROME+'" '+$flags+' --app='+$u2) }
  else { Log 'then watch for the window titled "Pillagers, player 2" (opened by the 2 PLAYER ARCADE DEMO row) and put it full screen on player 2''s screen' }
  Log 'would keep both windows full screen until the party windows are gone'
}

try{
  if(-not (Test-Path -LiteralPath $cfg.CHROME)){ Log ('Chrome not found at '+$cfg.CHROME); exit 1 }
  if(-not $DryRun){
    Stop-Party; Start-Sleep -Milliseconds 800
    New-Item -ItemType Directory -Force -Path (Split-Path $cfg.PROFILE) | Out-Null
    # the game server: it must answer, or the window would open on an error page
    $base=[uri]$cfg.URL_BASE; $up=$false
    for($i=0;$i -lt 2 -and -not $up;$i++){
      try{ $rq=[Net.WebRequest]::Create($cfg.URL_BASE); $rq.Method='HEAD'; $rq.Timeout=3000; $rs=$rq.GetResponse(); $rs.Close(); $up=$true }catch{ $up=$false }
      if(-not $up -and $i -eq 0){
        Log ('the server on port '+$base.Port+' did not answer, starting it')
        Start-Process -FilePath 'powershell.exe' -WindowStyle Hidden -ArgumentList ('-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "'+$R+'\tools\serve.ps1" -Root "'+$R+'" -Port '+$base.Port) | Out-Null
        for($j=0;$j -lt 20 -and -not $up;$j++){ Start-Sleep -Milliseconds 750; try{ $rq=[Net.WebRequest]::Create($cfg.URL_BASE); $rq.Method='HEAD'; $rq.Timeout=2000; $rs=$rq.GetResponse(); $rs.Close(); $up=$true }catch{ $up=$false } }
      }
    }
    if(-not $up){ Log ('the game server did not come up on '+$cfg.URL_BASE+'. Nothing opened.'); exit 1 }
    Start-Process -FilePath $cfg.CHROME -ArgumentList ($flags+' --app='+$u1) | Out-Null
    if($opt){ Start-Sleep -Seconds 4; Start-Process -FilePath $cfg.CHROME -ArgumentList ($flags+' --app='+$u2) | Out-Null }
  }

  # the watcher: player 1 is the window titled Pillagers, player 2 the one titled Pillagers, player 2
  $t0=Get-Date; $seen=$false; $goneAt=$null; $loop=0; $pids=@()
  while($true){
    if(($loop % 3) -eq 0){ $pids=@((Party-Chrome) | ForEach-Object { [int]$_.ProcessId }) }
    $loop++
    $ws=@(); foreach($s in [PW]::Find('Pillagers')){ $pw=Parse-Win $s; if(($pids -contains $pw.Pid) -or $DryRun){ $ws+=$pw } }
    $w2=@($ws | Where-Object { $_.Title -like 'Pillagers, player 2*' })
    $w1=@($ws | Where-Object { $_.Title -notlike 'Pillagers, player 2*' })
    if($w1.Count -gt 0 -or $w2.Count -gt 0){ $seen=$true; $goneAt=$null } elseif($seen -and -not $goneAt){ $goneAt=Get-Date }
    foreach($w in $w1){ [void](Place-Window $w $sc1 'player 1') }
    foreach($w in $w2){ $r2=Place-Window $w $sc2 'player 2'; if(($r2 -eq 'moved') -and ($w1.Count -gt 0) -and -not $DryRun){ Start-Sleep -Milliseconds 300; [PW]::Front($w1[0].H) } }   # the keyboard and mouse belong to player 1
    if($DryRun){ if(((Get-Date)-$t0).TotalSeconds -gt 6){ break } }
    elseif($seen -and $goneAt -and (((Get-Date)-$goneAt).TotalSeconds -gt 90)){ Log 'the party windows are gone, so this watcher ends'; break }
    elseif((-not $seen) -and (((Get-Date)-$t0).TotalSeconds -gt 90)){ Log 'no party window appeared in 90 s, giving up'; break }
    elseif(((Get-Date)-$t0).TotalHours -gt 14){ Log 'watched for 14 hours, stopping'; break }
    Start-Sleep -Seconds 2
  }
}catch{
  Log ('ERROR '+$_.Exception.Message+' at line '+$_.InvocationInfo.ScriptLineNumber)
  exit 1
}
