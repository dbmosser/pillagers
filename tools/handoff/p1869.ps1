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

# ZONE NAMES ON THE SECTOR MAPS NEVER OVERLAP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    c.font='bold 11px Rubik, system-ui, sans-serif'; c.fillStyle='rgba(205,214,221,.85)'; c.textAlign='center'; c.fillText(z.name,ox+(z.x+z.w/2)*sc,oy+(z.y+z.h/2)*sc+3); }
'@ @'
    // v18.69, seen on the lift screenshot (2026-10-07): every zone name was 11 pixels whatever its zone, so on The Cold Mile
    // HOARFROST ROW, FROST YARD and BLAST LINE printed into each other. A name now shrinks to fit its zone (down to 8 pixels) and
    // breaks onto two lines at a space if it still does not fit.
    (function(){
      var zw=Math.max(10,z.w*sc-6), fs=11, cx=ox+(z.x+z.w/2)*sc, cy=oy+(z.y+z.h/2)*sc, nm=String(z.name), ws, k, a1, a2, best=-1, bw=1e9, w1, w2;
      c.fillStyle='rgba(205,214,221,.85)'; c.textAlign='center';
      c.font='bold '+fs+'px Rubik, system-ui, sans-serif';
      while(fs>8&&c.measureText(nm).width>zw){ fs--; c.font='bold '+fs+'px Rubik, system-ui, sans-serif'; }
      if(c.measureText(nm).width>zw&&nm.indexOf(' ')>0){
        ws=nm.split(' ');
        for(k=1;k<ws.length;k++){ w1=c.measureText(ws.slice(0,k).join(' ')).width; w2=c.measureText(ws.slice(k).join(' ')).width; if(Math.max(w1,w2)<bw){ bw=Math.max(w1,w2); best=k; } }
        a1=ws.slice(0,best).join(' '); a2=ws.slice(best).join(' ');
        c.fillText(a1,cx,cy-fs*0.5+3); c.fillText(a2,cx,cy+fs*0.5+4);
        return;
      }
      c.fillText(nm,cx,cy+3);
    })(); }
'@

SubRx @'
var VER='18.68';
'@ @'
var VER='18.69';
'@

$pat = "(?m)^  now:'v18\.68:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.69: The zone names on the sector maps are all readable. Check 18.69 fails on v18.68',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
