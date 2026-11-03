# Read only. Who uses the processor, from the kernel's own per-process totals (keyed by process, so Chrome starting and ending cannot shift the numbers, and it needs no rights). Waits for a slice with no gate job and no pause.
# Prints program names, Chrome's profile and type, and script file names only: no full command lines, no window titles.
param([int]$Sec=120,[int]$WaitMin=60,[switch]$NoWait)
Add-Type -IgnoreWarnings -TypeDefinition @'
using System; using System.Collections.Generic; using System.Runtime.InteropServices;
public class NtP { public int Id, Parent; public long Create, Base, Total, User, Kernel, User0, Kernel0; public string Name; public long Ready, Running, Polls; public bool Old; }
public static class Nt {
  [DllImport("ntdll.dll")] static extern int NtQuerySystemInformation(int c, IntPtr b, int n, out int r);
  [DllImport("kernel32.dll")] static extern bool GetSystemTimes(out long i, out long k, out long u);
  public static Dictionary<string,NtP> All = new Dictionary<string,NtP>();
  public static long I0, K0, U0, I1, K1, U1; public static long Polls = 0;
  static IntPtr buf = Marshal.AllocHGlobal(8 * 1024 * 1024);
  static void Snap(bool first){
    int r; if (NtQuerySystemInformation(5, buf, 8 * 1024 * 1024, out r) != 0) return;
    long off = 0; Polls++;
    while (true) {
      IntPtr p = new IntPtr(buf.ToInt64() + off);
      int next = Marshal.ReadInt32(p, 0), nth = Marshal.ReadInt32(p, 4);
      long create = Marshal.ReadInt64(p, 32), user = Marshal.ReadInt64(p, 40), kern = Marshal.ReadInt64(p, 48);
      int len = Marshal.ReadInt16(p, 56); IntPtr nm = Marshal.ReadIntPtr(p, 64);
      int id = (int)Marshal.ReadIntPtr(p, 80).ToInt64(), par = (int)Marshal.ReadIntPtr(p, 88).ToInt64();
      string name = (nm == IntPtr.Zero || len == 0) ? "Idle" : Marshal.PtrToStringUni(nm, len / 2);
      string key = id + ":" + create; NtP x;
      if (!All.TryGetValue(key, out x)) { x = new NtP { Id = id, Parent = par, Create = create, Name = name, Old = first, User0 = first ? user : 0, Kernel0 = first ? kern : 0 }; All[key] = x; }
      x.User = user; x.Kernel = kern; x.Polls++;
      for (int t = 0; t < nth; t++) { int st = Marshal.ReadInt32(p, 256 + t * 80 + 68); if (st == 1) x.Ready++; else if (st == 2) x.Running++; }
      if (next == 0) break; off += next;
    }
  }
  public static void Start(){ GetSystemTimes(out I0, out K0, out U0); Snap(true); }
  public static void Run(int ms){ long end = Environment.TickCount + ms; while (Environment.TickCount < end) { System.Threading.Thread.Sleep(1000); Snap(false); } GetSystemTimes(out I1, out K1, out U1); }
}
'@
$st='C:\PillagersSpare\state.txt'
function Has($re){ try{ return @(Get-Content $st -ErrorAction Stop | Where-Object { $_ -cmatch $re }).Count -gt 0 }catch{ return $false } }
function Slice(){ return @(Get-CimInstance Win32_Process -Filter "Name='bash.exe' or Name='sh.exe'" | Where-Object { $_.CommandLine -match 'corpus-slices\.sh' }).Count -gt 0 }
if(-not $NoWait){ $end=(Get-Date).AddMinutes($WaitMin); while((Get-Date) -lt $end){ if(-not (Has '^gate_id=.') -and -not (Has '^pause_why=.') -and (Slice)){ break }; Start-Sleep -Seconds 15 } }
$prof=@{}; $type=@{}; $tool=@{}
function Learn(){ foreach($p in (Get-CimInstance Win32_Process -Filter "Name='chrome.exe' or Name='powershell.exe' or Name='node.exe' or Name='bash.exe'")){ $c=[string]$p.CommandLine; $id=[int]$p.ProcessId
  if($p.Name -ceq 'chrome.exe'){ if($c -match 'user-data-dir="?([^"\s]+)'){ $prof[$id]=Split-Path $Matches[1] -Leaf }; $type[$id]=if($c -match '--type=([\w-]+)'){ $Matches[1] }else{ 'browser' } }
  else { $s=@([regex]::Matches($c,'[\w.-]+\.(?:ps1|mjs|js|sh)') | ForEach-Object { $_.Value } | Select-Object -Unique -First 2) -join ' '; if($s){ $tool[$id]=$s } } } }
"start $(Get-Date -Format 'HH:mm:ss'); $((Get-Content $st | Where-Object { $_ -cmatch '^(gate_id|pause_why)=' }) -join ' '); slice running: $(Slice); this reading is pid $PID"
Learn; [Nt]::Start(); $t0=Get-Date; $n=[Math]::Ceiling($Sec/10)
for($i=0;$i -lt $n;$i++){ [Nt]::Run(10000); Learn }
$dt=((Get-Date)-$t0).TotalSeconds; $w=[double]([Nt]::K1-[Nt]::K0+[Nt]::U1-[Nt]::U0); $idle=[double]([Nt]::I1-[Nt]::I0); $user=[double]([Nt]::U1-[Nt]::U0)
'{0:N0} s, {1} looks. Machine busy {2:N1} percent of 4 threads, of which user {3:N1}, kernel {4:N1}; idle {5:N1}' -f $dt,[Nt]::Polls,(100*($w-$idle)/$w),(100*$user/$w),(100*($w-$idle-$user)/$w),(100*$idle/$w)
$rows=@(); foreach($x in [Nt]::All.Values){ if($x.Name -ceq 'Idle'){ continue }; $du=[double]($x.User-$x.User0); $dk=[double]($x.Kernel-$x.Kernel0); $g=$x.Name
  if($x.Name -ceq 'chrome.exe'){ $pf=if($prof.ContainsKey($x.Id)){ $prof[$x.Id] }elseif($prof.ContainsKey($x.Parent)){ $prof[$x.Parent] }else{ '(profile not seen)' }; $g='chrome '+$pf }
  $rows+=[pscustomobject]@{Group=$g;Id=$x.Id;Name=$x.Name;Cpu=100*($du+$dk)/$w;Kern=100*$dk/$w;New=-not $x.Old;Ready=[double]$x.Ready/[Nt]::Polls;Running=[double]$x.Running/[Nt]::Polls} }
'all programs add up to {0:N1}; what is not listed ended between looks or ran under a second' -f (($rows | Measure-Object Cpu -Sum).Sum)
'by program, percent of all 4 threads (kernel part), processes, of them new, threads waiting for a core on average, threads on a core on average:'
$rows | Group-Object Group | ForEach-Object { [pscustomobject]@{G=$_.Name;C=($_.Group | Measure-Object Cpu -Sum).Sum;K=($_.Group | Measure-Object Kern -Sum).Sum;N=$_.Count;W=@($_.Group | Where-Object { $_.New }).Count;R=($_.Group | Measure-Object Ready -Sum).Sum;U=($_.Group | Measure-Object Running -Sum).Sum} } | Sort-Object C -Descending | Select-Object -First 22 | ForEach-Object { '{0,-36} {1,6:N1} ({2,5:N1})  {3,4} {4,4}  {5,6:N2} {6,6:N2}' -f $_.G,$_.C,$_.K,$_.N,$_.W,$_.R,$_.U }
'top single processes:'
$rows | Sort-Object Cpu -Descending | Select-Object -First 16 | ForEach-Object { $l=if($type.ContainsKey($_.Id)){ $type[$_.Id] }elseif($tool.ContainsKey($_.Id)){ $tool[$_.Id] }else{ '' }; '{0,6} {1,-34} {2,6:N1} ({3,5:N1})  {4}{5}' -f $_.Id,$_.Group,$_.Cpu,$_.Kern,$l,$(if($_.New){ ' [new]' }else{ '' }) }
'scripts seen: '+((@($tool.Values) | Group-Object | ForEach-Object { $_.Name+' x'+$_.Count }) -join '; ')
"end $(Get-Date -Format 'HH:mm:ss'); $((Get-Content $st | Where-Object { $_ -cmatch '^(gate_id|pause_why)=' }) -join ' '); slice running: $(Slice)"
