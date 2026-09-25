# Prints how many whole seconds since the last keyboard or mouse input on this PC (read-only; changes nothing).
# Used by the build loop to go light while he is at the PC and full rate when he is away.
Add-Type @'
using System;
using System.Runtime.InteropServices;
public static class IdleProbe {
  [StructLayout(LayoutKind.Sequential)] struct LASTINPUTINFO { public uint cbSize; public uint dwTime; }
  [DllImport("user32.dll")] static extern bool GetLastInputInfo(ref LASTINPUTINFO plii);
  public static uint Seconds() {
    LASTINPUTINFO i = new LASTINPUTINFO(); i.cbSize = (uint)Marshal.SizeOf(i);
    if (!GetLastInputInfo(ref i)) return 0;
    return ((uint)Environment.TickCount - i.dwTime) / 1000;
  }
}
'@
[IdleProbe]::Seconds()
