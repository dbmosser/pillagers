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

# NO SHINING CIRCLE ON LOOT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    var pu=.5+.35*Math.sin(G.t*3+ct.x*.05);
    wc.globalCompositeOperation='lighter';
    wc.fillStyle=ct.cache?RCOL[ct.best]:'#ffc04a';
    wc.globalAlpha=(ct.cache?.55:.28)*pu;
    wc.beginPath(); wc.arc(ct.x,ct.y-lift-d2-3,ct.cache?15:6,0,6.2832); wc.fill();
    if(ct.cache){
      wc.globalAlpha=.30*pu; wc.fillStyle='#e0a0ff';
      wc.beginPath(); wc.arc(ct.x,ct.y-lift-d2-3,30,0,6.2832); wc.fill();
    }
    wc.globalAlpha=1; wc.globalCompositeOperation='source-over';
'@ @'
    // v28.xx (lean6), HIS ORDER (2026-10-15): "get rid of the shining circle for items, don't highlight items like that any more". The pulsing amber dot over every
    // unopened container (and the cache rings) is gone, so every box is looted on its own look. The search bar, the ammunition tell and a cache name are unchanged.
'@

SubRx @'
    if(!G.sim&&needHolds(ct)) needGlow(wc,ct,lift,d2);   // v26.xx (career3): a box that holds an item a contract needs
'@ @'
    // v28.xx (lean6): no gold ring over a box that holds a contract item either (needGlow stays defined, the NEED edge in the backpack and the pickup stack is unchanged)
'@

SubRx @'
var VER='28.71';
'@ @'
var VER='28.72';
'@

$pat = "(?m)^  now:'v28\.71:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.72: Loot boxes no longer shine; every box looks the same until you open it. Check 28.72 fails on v28.71',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
