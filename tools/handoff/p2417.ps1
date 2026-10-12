$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# CASINGS PILE UP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      // entirely, so three hundred of them cost the same as none.
      for(i=G.shells.length-1;i>=0;i--){
var sl=G.shells[i];
        if(sl.mortar||sl.settled) continue;
        sl.t+=dt; sl.x+=sl.vx*dt; sl.y+=sl.vy*dt;
        var _dms=Math.pow(.88,dt*60); sl.vx*=_dms; sl.vy*=_dms;
        if(sl.t>sl.life) sl.settled=true;
      }
'@ @'
      // entirely, so three hundred of them cost the same as none.
      // v23.xx (gfx23), HIS ORDER (2026-10-12) on the graphics program: "add ALL of this stuff", item 7, shot detail. CASINGS PILE UP.
      // The settled casings were still drawn one by one every frame, all of them and off the screen too (five canvas calls each), and
      // the list kept only the last 300, so a long fight quietly lost its oldest brass. A casing that settles is now stamped into the
      // floor itself (scarStamp, gfx22) at the same colour, size and turn, and leaves the list: it stays for the whole raid, survives a
      // floor rebake, and costs nothing a frame however many there are. Only brass still in the air is drawn, and only on screen. If the
      // stamp is refused (graphics hooks bypassed, off the floor) the casing settles in the list exactly as before.
      for(i=G.shells.length-1;i>=0;i--){
var sl=G.shells[i];
        if(sl.mortar||sl.settled) continue;
        sl.t+=dt; sl.x+=sl.vx*dt; sl.y+=sl.vy*dt;
        var _dms=Math.pow(.88,dt*60); sl.vx*=_dms; sl.vy*=_dms;
        if(sl.t>sl.life){
          sl.settled=true;
          if(!G.sim&&sl.brass){ var _sbs=false; try{ _sbs=scarStamp('brass',sl.x,sl.y,{rot:sl.rot}); }catch(_gbs){} if(_sbs) G.shells.splice(i,1); }
        }
      }
'@

SubRx @'
    if(sl.mortar) continue;
    wc.globalAlpha=clamp(1-(sl.t-sl.life)/2.5,0,.9);
'@ @'
    if(sl.mortar) continue;
    if(sl.x<ox-20||sl.x>ox+VW+20||sl.y<oy-20||sl.y>oy+VH+20) continue;   // v23.xx (gfx23): brass off the screen is not drawn
    wc.globalAlpha=clamp(1-(sl.t-sl.life)/2.5,0,.9);
'@

SubRx @'
var VER='24.16';
'@ @'
var VER='24.17';
'@

$pat = "(?m)^  now:'v24\.16:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.17: Spent casings now stay on the floor for the whole raid, and cost nothing to draw. Check 24.17 fails on v24.16',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
