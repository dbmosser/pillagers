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

# THE LOCKDOWN FENCES PLAYER 2 TOO (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var E=evS(), L=E.live, i, j, ev, pt, c, t=G.t||0;
'@ @'
  var E=evS(), L=E.live, i, j, ev, pt, c, t=G.t||0, p=G.player;
'@

SubRx @'
    if(ev.id==='debris'&&ev.ph==='live'&&ev.d.pts){
'@ @'
    if(ev.id==='lock'&&ev.ph==='live'){   // v27.09 (coop3): the district doors, felt by this player
      if(lockSealed(ev)&&p&&!p.specOut&&ev.d.pSide) lockKeep(p,p.r||11,ev,ev.d.pSide);
      else if(!lockSealed(ev)&&!ev.d.rel){ ev.d.rel=1; try{ say('DOORS OPEN','warn',{sub:'THEY ARE COMING OUT'}); }catch(_lo){} }
    }
    if(ev.id==='debris'&&ev.ph==='live'&&ev.d.pts){
'@

SubRx @'
    if(was==='warn'&&ph!=='warn') evPeerStart(ev);
'@ @'
    if(was==='warn'&&ph!=='warn') evPeerStart(ev);
    else if(was===null&&ph==='live') evPeerStart(ev);   // v27.09 (coop3): a word that finds the event already live (a lost word) still says it and picks the side
    else if(was==='live'&&ph==='end'&&id==='lock'){ try{ say('LOCKDOWN OVER','info'); }catch(_le){} }
'@

SubRx @'
var VER='27.08';
'@ @'
var VER='27.09';
'@

$pat = "(?m)^  now:'v27\.08:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.09: The lockdown alarm now seals player 2 in or out of the ring as well, then opens its doors. Check 27.09 fails on v27.08',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
