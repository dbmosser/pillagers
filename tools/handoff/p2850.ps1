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

# PLAYER 2 IS TOLD EVERY WAVE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(made){ WS.waveN=(WS.waveN|0)+1; say('WAVE '+WS.waveN,'warn',amb?{sub:'AMBUSH BEHIND YOU'}:undefined); try{ annCue('WAVE'); }catch(_vc){} try{ flowDirFired(D,amb,made); }catch(_fdf){} }   // v24.04 (his #45): WAVE INCOMING; v26.xx (flow1): and an ambush says where from
'@ @'
  if(made){ WS.waveN=(WS.waveN|0)+1; WS.waveAmb=amb; say('WAVE '+WS.waveN,'warn',amb?{sub:'AMBUSH BEHIND YOU'}:undefined); try{ annCue('WAVE'); }catch(_vc){} try{ flowDirFired(D,amb,made); }catch(_fdf){} }   // v24.04 (his #45): WAVE INCOMING; v26.xx (flow1): and an ambush says where from
  // v28.50 (cloud-coop-wave-said-to-p2), CLOUD HUNT 2026-10-15: the wave count and whether it was an ambush ride in the host raid flow, so player 2 is told the same WAVE n
'@

SubRx @'
  o.r=goalsNetOut();   // v27.27 (coop8): and the run goals
'@ @'
  o.r=goalsNetOut();   // v27.27 (coop8): and the run goals
  var WS=G.arcade?ARCADE:G.cs; if(WS) o.w=[WS.waveN|0,WS.waveAmb?1:0];   // v28.50 (cloud-coop-wave-said-to-p2), CLOUD HUNT 2026-10-15: and the wave count (player 2 is told WAVE n as the host is)
'@

SubRx @'
  if(fl.r) goalsNetTake(fl.r);   // v27.27 (coop8): the run goals
'@ @'
  if(fl.r) goalsNetTake(fl.r);   // v27.27 (coop8): the run goals
  if(fl.w&&typeof fl.w.length==='number') waveNetTake(fl.w);   // v28.50 (cloud-coop-wave-said-to-p2), CLOUD HUNT 2026-10-15: the wave count
'@

SubRx @'
function fireNetTake(rows){
'@ @'
function waveNetTake(w){   // v28.50 (cloud-coop-wave-said-to-p2), CLOUD HUNT 2026-10-15: the host made a wave: player 2 is told WAVE n (and AMBUSH BEHIND YOU) and hears the sting as the host does, and his count is the host count (a late joiner first word says nothing)
  var WS=G.arcade?ARCADE:G.cs, F=flowS(), n=w[0]|0;
  if(!WS||n<0) return 0;
  if(F.waveSeen&&n>(WS.waveN|0)){ say('WAVE '+n,'warn',w[1]?{sub:'AMBUSH BEHIND YOU'}:undefined); try{ annCue('WAVE'); }catch(_vc){} }
  F.waveSeen=1; WS.waveN=Math.max(WS.waveN|0,n);
  return 1;
}
function fireNetTake(rows){
'@

SubRx @'
var VER='28.49';
'@ @'
var VER='28.50';
'@

$pat = "(?m)^  now:'v28\.49:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.50: In co-op your teammate is now told WAVE and AMBUSH BEHIND YOU and hears the wave sting too. Check 28.50 fails on v28.49',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
