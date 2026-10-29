# chrome-view.ps1 : runs ON THE MAIN PC for the host bridge job "chrome-view" (jobs.mjs adds his Chrome zoom for localhost). Read only.
# 10-27: what the main PC Claude read by hand when his 75% localhost zoom fooled fsFull() (v35.21), so the VM can ask with no Claude open
# there. Prints one JSON object: every monitor (name, bounds, primary, scale %) and his Chrome windows (bounds, maximized, minimized,
# covers its whole monitor, which monitor). A window title is given only when it names the game (pillagers, dark raiders, localhost,
# 8802); other Chrome windows are counted, never named. 10-29: each monitor also gives hz (what Windows runs it at) and maxHz (the fastest it
# offers at that resolution), for the frame cap questions. ASCII only.
$ErrorActionPreference = 'Stop'
Add-Type -TypeDefinition @'
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Text;
public static class PvWin {
  [StructLayout(LayoutKind.Sequential)] public struct RECT { public int L, T, R, B; }
  [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)] public struct MONITORINFOEX { public int cbSize; public RECT rcMonitor; public RECT rcWork; public uint dwFlags; [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)] public string szDevice; }
  delegate bool MonProc(IntPtr h, IntPtr dc, ref RECT r, IntPtr d);
  delegate bool WinProc(IntPtr h, IntPtr d);
  [DllImport("user32.dll")] static extern bool EnumDisplayMonitors(IntPtr dc, IntPtr clip, MonProc f, IntPtr d);
  [DllImport("user32.dll", CharSet = CharSet.Unicode)] static extern bool GetMonitorInfo(IntPtr m, ref MONITORINFOEX mi);
  [DllImport("shcore.dll")] static extern int GetDpiForMonitor(IntPtr m, int type, out uint x, out uint y);
  [DllImport("user32.dll")] static extern bool EnumWindows(WinProc f, IntPtr d);
  [DllImport("user32.dll")] static extern bool IsWindowVisible(IntPtr h);
  [DllImport("user32.dll")] static extern bool IsZoomed(IntPtr h);
  [DllImport("user32.dll")] static extern bool IsIconic(IntPtr h);
  [DllImport("user32.dll")] static extern bool GetWindowRect(IntPtr h, out RECT r);
  [DllImport("user32.dll", CharSet = CharSet.Unicode)] static extern int GetClassName(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll", CharSet = CharSet.Unicode)] static extern int GetWindowText(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll")] static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
  [DllImport("user32.dll")] static extern IntPtr MonitorFromWindow(IntPtr h, uint flags);
  [DllImport("user32.dll")] static extern IntPtr SetProcessDpiAwarenessContext(IntPtr v);
  [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)] public struct DEVMODE {
    [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)] public string dmDeviceName; public short dmSpecVersion, dmDriverVersion, dmSize, dmDriverExtra; public int dmFields;
    public int dmPositionX, dmPositionY, dmDisplayOrientation, dmDisplayFixedOutput; public short dmColor, dmDuplex, dmYResolution, dmTTOption, dmCollate;
    [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)] public string dmFormName; public short dmLogPixels; public int dmBitsPerPel, dmPelsWidth, dmPelsHeight, dmDisplayFlags, dmDisplayFrequency;
    public int dmICMMethod, dmICMIntent, dmMediaType, dmDitherType, dmReserved1, dmReserved2, dmPanningWidth, dmPanningHeight; }
  [DllImport("user32.dll", CharSet = CharSet.Unicode)] static extern bool EnumDisplaySettings(string dev, int mode, ref DEVMODE dm);
  public static void Aware() { try { SetProcessDpiAwarenessContext(new IntPtr(-4)); } catch { } }
  // 10-29 (FPS czar): the refresh rate Windows runs this screen at now, and the fastest it offers at the same resolution ("cur|max")
  public static string Hz(string dev) {
    var dm = new DEVMODE(); dm.dmSize = (short)Marshal.SizeOf(typeof(DEVMODE));
    if (!EnumDisplaySettings(dev, -1, ref dm)) return "0|0";
    int cur = dm.dmDisplayFrequency, w = dm.dmPelsWidth, h = dm.dmPelsHeight, max = cur;
    for (int i = 0; i < 4000; i++) {
      var m = new DEVMODE(); m.dmSize = dm.dmSize; if (!EnumDisplaySettings(dev, i, ref m)) break;
      if (m.dmPelsWidth == w && m.dmPelsHeight == h && m.dmDisplayFrequency > max) max = m.dmDisplayFrequency;
    }
    return cur + "|" + max;
  }
  public static List<string> Monitors() {
    var o = new List<string>();
    EnumDisplayMonitors(IntPtr.Zero, IntPtr.Zero, (IntPtr h, IntPtr dc, ref RECT r, IntPtr d) => {
      var mi = new MONITORINFOEX(); mi.cbSize = Marshal.SizeOf(typeof(MONITORINFOEX)); GetMonitorInfo(h, ref mi);
      uint x = 96, y = 96; try { GetDpiForMonitor(h, 0, out x, out y); } catch { }
      o.Add(string.Join("|", new string[] { h.ToInt64().ToString(), mi.szDevice, mi.rcMonitor.L.ToString(), mi.rcMonitor.T.ToString(), mi.rcMonitor.R.ToString(), mi.rcMonitor.B.ToString(), ((mi.dwFlags & 1) != 0) ? "1" : "0", ((int)Math.Round(x * 100.0 / 96)).ToString() }));
      return true; }, IntPtr.Zero);
    return o;
  }
  public static List<string> Windows() {
    var o = new List<string>();
    EnumWindows((IntPtr h, IntPtr d) => {
      if (!IsWindowVisible(h)) return true;
      var c = new StringBuilder(256); GetClassName(h, c, 256); if (c.ToString() != "Chrome_WidgetWin_1") return true;
      var t = new StringBuilder(512); GetWindowText(h, t, 512); if (t.Length == 0) return true;
      uint pid; GetWindowThreadProcessId(h, out pid); RECT r; GetWindowRect(h, out r);
      o.Add(string.Join("\u0001", new string[] { pid.ToString(), r.L.ToString(), r.T.ToString(), r.R.ToString(), r.B.ToString(), IsZoomed(h) ? "1" : "0", IsIconic(h) ? "1" : "0", MonitorFromWindow(h, 2).ToInt64().ToString(), t.ToString() }));
      return true; }, IntPtr.Zero);
    return o;
  }
}
'@
[PvWin]::Aware()
$mons = @(); $byH = @{}
foreach ($line in [PvWin]::Monitors()) {
  $f = $line.Split('|')
  $m = [ordered]@{ device = ($f[1] -replace '^\\\\\.\\', ''); left = [int]$f[2]; top = [int]$f[3]; width = [int]$f[4] - [int]$f[2]; height = [int]$f[5] - [int]$f[3]; primary = ($f[6] -eq '1'); scalePct = [int]$f[7] }
  $hz = '0|0'; try { $hz = [PvWin]::Hz($f[1]) } catch { }
  $m.hz = [int]$hz.Split('|')[0]; $m.maxHz = [int]$hz.Split('|')[1]
  $mons += $m; $byH[$f[0]] = $m
}
$chromePids = @{}; Get-Process chrome -ErrorAction SilentlyContinue | ForEach-Object { $chromePids[[string]$_.Id] = 1 }
$wins = @(); $others = 0
foreach ($line in [PvWin]::Windows()) {
  $f = $line.Split([char]1)
  if (-not $chromePids.ContainsKey($f[0])) { continue }
  $title = $f[8]
  if ($title -notmatch '(?i)pillagers|dark raiders|localhost|8802') { $others++; continue }
  $mon = $byH[$f[7]]
  $w = [ordered]@{ title = ($title -replace '[^\x20-\x7e]', '?'); left = [int]$f[1]; top = [int]$f[2]; width = [int]$f[3] - [int]$f[1]; height = [int]$f[4] - [int]$f[2]; maximized = ($f[5] -eq '1'); minimized = ($f[6] -eq '1') }
  if ($mon) { $w.monitor = $mon.device; $w.coversMonitor = ($w.left -eq $mon.left -and $w.top -eq $mon.top -and $w.width -eq $mon.width -and $w.height -eq $mon.height) }
  $wins += $w
}
[ordered]@{ ok = $true; host = $env:COMPUTERNAME; now = (Get-Date).ToString('s'); monitors = $mons; gameWindows = $wins; otherChromeWindows = $others; chromeRunning = ($chromePids.Count -gt 0) } | ConvertTo-Json -Depth 4 -Compress
