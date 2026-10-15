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

# PLAYER 2 SEES THE FULL SCAN CONES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var m={t:'ent',op:'new',id:e.nid,k:e.kind,x:Math.round(e.x),y:Math.round(e.y),n:netClean(e.name,24),r:e.r,mh:e.maxhp,hp:Math.ceil(clamp(e.hp/(e.maxhp||1),0,1)*20),el:e.elite?1:0,ho:e.hostile?1:0,af:e.affix?String(e.affix):''};
'@ @'
  // v28.61 (cloud-raid-p2reach), CLOUD HUNT 2026-10-15: sr, its sight reach, so the copy draws the scan cone and the laser as far as the host does
  var m={t:'ent',op:'new',id:e.nid,k:e.kind,x:Math.round(e.x),y:Math.round(e.y),n:netClean(e.name,24),r:e.r,mh:e.maxhp,hp:Math.ceil(clamp(e.hp/(e.maxhp||1),0,1)*20),el:e.elite?1:0,ho:e.hostile?1:0,af:e.affix?String(e.affix):'',sr:Math.round(+e.rng||0)};
'@

SubRx @'
  if(typeof m.r==='number'&&m.r>0&&m.r<80) e.r=m.r;
'@ @'
  if(typeof m.r==='number'&&m.r>0&&m.r<80) e.r=m.r;
  if(typeof m.sr==='number'&&m.sr>0&&m.sr<3000) e.rng=m.sr;   // v28.61 (cloud-raid-p2reach): the host sight reach (a copy started at 100)
'@

SubRx @'
var VER='28.60';
'@ @'
var VER='28.61';
'@

$pat = "(?m)^  now:'v28\.60:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.61: Player 2 now sees the searchers scan cones as long as player 1 does. Check 28.61 fails on v28.60',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
