$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# HIRE AND PEDDLER AUDIT OF 2026-09-14, finding 1: THE HIRE'S ROUNDS WENT THROUGH EVERY PILLAGER
# AND COULD HIT YOU. mercEngage aims at hostile pillagers (v8.24) and fires on the enemy bullet
# path. That path tested the player first with no look at who fired, so a round crossing him
# hit him under the hire's name. And a pillager is only hit by another pillager's round when
# feudFoe says so, which it never does for a hire; every round passed through the man he was
# aiming at. Now his rounds pass through you, as yours pass through him (v6.72), and they hit a
# hostile pillager the way his target picker already calls one.
SubRx @'
          if(dist(b,p)<p.r+3){ damagePlayer(b.dmg,b.owner.kind,b.owner.name,b.x-b.vx*0.05,b.y-b.vy*0.05); spark(b.x,b.y,'#ff5a4a',10,200); hit=true; }
'@ @'
          // v13.68, hire audit: a round your hire fired passes through you, as yours pass
          // through him (v6.72), and it hits a hostile pillager, the man he was aiming at.
          var _mOwn=!!(b.owner&&b.owner.merc);
          if(!_mOwn&&dist(b,p)<p.r+3){ damagePlayer(b.dmg,b.owner.kind,b.owner.name,b.x-b.vx*0.05,b.y-b.vy*0.05); spark(b.x,b.y,'#ff5a4a',10,200); hit=true; }
'@
SubRx @'
            if(dist(b,en3)<en3.r+3&&(en3.kind!==b.owner.kind||feudFoe(b.owner,en3))){
'@ @'
            if(dist(b,en3)<en3.r+3&&(en3.kind!==b.owner.kind||feudFoe(b.owner,en3)||
               (_mOwn&&en3.kind==='raider'&&!en3.merc&&en3.hostile!==false&&!en3.friendlyPC))){
'@
SubRx @'
var VER='13.67';
'@ @'
var VER='13.68';
'@

$pat = "(?m)^  now:'v13\.67:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.68: YOUR HIRE SHOOTS THE PILLAGERS, NOT YOU. Hire and peddler audit of 2026-09-14, finding 1: mercEngage fires at hostile pillagers on the enemy bullet path, which tested the player with no look at who fired, so a round crossing you hit you under his name; and a pillager takes another pillager round only when feudFoe allows, which it never does for a hire, so every round passed through his target. His rounds now pass through you, as yours pass through him, and hit a hostile pillager. Check 13.68 stages the hire, a hostile pillager and you in a line and requires the pillager hit and you untouched, with the pillager firing at you as the control; it fails on v13.67',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
