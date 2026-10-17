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

# TEAMMATE SEES RICOCHETS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  m={t:'fx',k:'b',s:NET.seat,b:[Math.round(b.x),Math.round(b.y),Math.round(b.vx),Math.round(b.vy),+(+b.life||0).toFixed(3),String(b.tint||'#ffd48a').slice(0,9),b.el?1:0]};   // v23.xx (forge8): 1 for an elemental round, drawn wider
'@ @'
  m={t:'fx',k:'b',s:NET.seat,b:[Math.round(b.x),Math.round(b.y),Math.round(b.vx),Math.round(b.vy),+(+b.life||0).toFixed(3),String(b.tint||'#ffd48a').slice(0,9),b.el?1:0,b._rico?1:0]};   // v23.xx (forge8): 1 for an elemental round, drawn wider   // v28.xx (cw-ricoseen), CLOUD HUNT 2026-10-15: the 8th field is 1 for a round sent again from a ricochet
'@

SubRx @'
  try{ spark(b.x,b.y,'#fff0c0',12,320); ricoPing(b.x,b.y); }catch(_r){}
'@ @'
  try{ spark(b.x,b.y,'#fff0c0',12,320); ricoPing(b.x,b.y); }catch(_r){}
  if(typeof NET==='object'&&NET&&NET.on) netFxShot(b);   // v28.xx (cw-ricoseen), CLOUD HUNT 2026-10-15: a ricochet was seen only in the window that fired it; the party gets the bounced round as a second tracer
'@

SubRx @'
    if(!G.sim){ try{ gfxShotFx(+a[0]||0,+a[1]||0,Math.atan2(+a[3]||0,+a[2]||0),a[5]); }catch(_gsx){} }   // v23.xx (gfx24): and its muzzle flash
'@ @'
    if(!G.sim&&a[7]){ try{ spark(+a[0]||0,+a[1]||0,'#fff0c0',12,320); ricoPing(+a[0]||0,+a[1]||0); }catch(_rc){} }   // v28.xx (cw-ricoseen), CLOUD HUNT 2026-10-15: a bounce word: the ricochet spark and ping, as the shooter sees and hears it, no muzzle flash
    else if(!G.sim){ try{ gfxShotFx(+a[0]||0,+a[1]||0,Math.atan2(+a[3]||0,+a[2]||0),a[5]); }catch(_gsx){} }   // v23.xx (gfx24): and its muzzle flash
'@

SubRx @'
var VER='28.96';
'@ @'
var VER='28.97';
'@

$pat = "(?m)^  now:'v28\.96:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.97: In co-op you now see and hear your teammates rounds ricochet off steel, and he sees yours. Check 28.97 fails on v28.96',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
