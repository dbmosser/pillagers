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

# THE PAUSE BOX LISTS THE RAID CONDITIONS THAT PAY SP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  h='<div class="psph"><span>score</span><b>x'+diffMul().toFixed(2)+'</b></div>';
  for(i=0;i<R.length;i++) h+=rw(R[i][0],R[i][1],R[i][2]);
  h+=rw(gameOptLabel('superhot'),(CFG&&CFG.superhot)?'on':'off',sh);
'@ @'
  // v35.89 (cw-pausecond), his order of 2026-10-28 ("all the modifiers/settings that impact sp"): the raid conditions that pay sp since cw-cx-condition-sp
  // (night, hard weather, each signed term, x1.05 each, raidConditionRows) are rows too, under the settings, and the headline is the settings multiplier times
  // the conditions, which is what an sp is paid at (a career raid puts the conditions on at the settlement, a demo raid as it earns). No condition: one muted row.
  var C=[], cm=1;
  try{ C=raidConditionRows()||[]; cm=raidConditionMul(); }catch(_rc){ C=[]; cm=1; }
  h='<div class="psph"><span>score</span><b>x'+(Math.round(diffMul()*cm*100)/100).toFixed(2)+'</b></div>';
  for(i=0;i<R.length;i++) h+=rw(R[i][0],R[i][1],R[i][2]);
  h+=rw(gameOptLabel('superhot'),(CFG&&CFG.superhot)?'on':'off',sh);
  if(C.length) for(i=0;i<C.length;i++) h+=rw(C[i][0],'',DMUL_ON?C[i][1]:1).replace('class="psprow','class="psprow'+(i?'':' psc'));
  else h+=rw('conditions','none',1).replace('class="psprow','class="psprow psc');
'@

SubRx @'
#root #pausebox.asking #pausesp, #root #pausebox.padlost #pausesp{ display:none !important; }
'@ @'
#root #pausebox.asking #pausesp, #root #pausebox.padlost #pausesp{ display:none !important; }
#root #pausebox #pausesp .psc{ margin-top:var(--sp-1); }   /* v35.89 (cw-pausecond): the raid conditions sit a step under the settings rows */
'@

SubRx @'
var VER='35.88';
'@ @'
var VER='35.89';
'@

$pat = "(?m)^  now:'v35\.88:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.89: the pause box also lists night, weather and terms in the score panel Check 35.89 fails on v35.88',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
