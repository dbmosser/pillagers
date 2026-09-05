param([string]$Target='C:\claudecode\dark raiders\dark_raiders.html')
$ErrorActionPreference='Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$SP='C:\Users\User1\AppData\Local\Temp\claude\C--Users-User1-Desktop-dark-raiders\c6801b49-bb04-49e7-8681-639ade6b3be0\scratchpad'
$s=[IO.File]::ReadAllText($Target)
$json=[IO.File]::ReadAllText((Join-Path $SP 'textedits.norm.json'),[Text.Encoding]::UTF8).Trim()
$n=0
function SubRx([string]$old,[string]$new){
  $pat=($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c=([regex]::Matches($script:s,$pat)).Count
  if($c -ne 1){ throw "regex matched $c times: $($old.Substring(0,[Math]::Min(60,$old.Length)))" }
  $script:s=[regex]::Replace($script:s,$pat,{param($m) $new})
  $script:n++
}

$nl="`r`n"
$block = "// v11.42, HIS TEXT EDITS, baked permanently. The words he rewrote in the" + $nl +
"// in-game editor, shipped as a default the TX door consults when a profile has" + $nl +
"// no override of its own, so his wording is the game's wording for everyone. The" + $nl +
"// number-shaped lines become the same blanked patterns txSet builds, so a line" + $nl +
"// like the credit counter refills its numbers at draw time. His own P.txt wins." + $nl +
"var TXSHIP=" + $json + ";" + $nl +
"var TXPSHIP={}, TXPSHIPANY=0;" + $nl +
"(function(){" + $nl +
"  for(var _tk in TXSHIP){" + $nl +
"    if(!TXSHIP.hasOwnProperty(_tk)) continue;" + $nl +
"    var _tn=''+TXSHIP[_tk], _ts=txSplit(_tk);" + $nl +
"    if(_ts.nums.length&&txShapeOk(_ts.pat)){" + $nl +
"      var _ti=0;" + $nl +
"      var _tp=_tn.replace(/-?\d+(?:[.,]\d+)*/g,function(mm){" + $nl +
"        if(_ti<_ts.nums.length&&mm===_ts.nums[_ti]){ _ti++; return TXBLANK; }" + $nl +
"        return mm;" + $nl +
"      });" + $nl +
"      TXPSHIP[_ts.pat]=_tp; TXPSHIPANY=1;" + $nl +
"    }" + $nl +
"  }" + $nl +
"})();" + $nl

# INSERT the shipped map + derivation immediately before the TXPANY declaration.
SubRx 'var TXPANY=0;' ($block + "var TXPANY=0;")

# REPLACE the TX body to consult the shipped maps under the profile.
SubRx @'
function TX(s){
  if(typeof s!=='string'||!s) return s;
  var m=P&&P.txt; if(!m) return s;
  var v=m[s];
  if(typeof v==='string') return v;
  // Only now, and only if there is anything shaped to match against. A profile
  // with no edits pays one property read per drawn string, the same as v9.74.
  if(!TXPANY||!P.txp) return s;
  if(s.indexOf('0')<0&&!/\d/.test(s)) return s;
  var sp=txSplit(s);
  if(!sp.nums.length) return s;
  var pv=P.txp[sp.pat];
  return (typeof pv==='string')?txFill(pv,sp.nums):s;
}
'@ @'
function TX(s){
  if(typeof s!=='string'||!s) return s;
  var pm=P&&P.txt, v=pm?pm[s]:undefined;
  if(typeof v!=='string'&&TXSHIP) v=TXSHIP[s];   // v11.42: shipped default under his profile
  if(typeof v==='string') return v;
  var haveP=!!(TXPANY&&pm&&P.txp);
  if(!haveP&&!TXPSHIPANY) return s;
  if(s.indexOf('0')<0&&!/\d/.test(s)) return s;
  var sp=txSplit(s);
  if(!sp.nums.length) return s;
  var pv=haveP?P.txp[sp.pat]:undefined;
  if(typeof pv!=='string') pv=TXPSHIP[sp.pat];
  return (typeof pv==='string')?txFill(pv,sp.nums):s;
}
'@

# STAMPS.
SubRx "var VER='11.41';" "var VER='11.42';"
SubRx "var WHATSNEW_VER='11.41';" "var WHATSNEW_VER='11.42';"
SubRx @'
  'NO TWO CONTRACTS ON THE BOARD ARE THE SAME JOB. Finishing a contract used to be able to drop a copy of a job you already had back onto the board, wasting a slot. The freed slot now follows the same no-duplicate rule the board fills by.',
'@ @'
  'THE IN-GAME WORDING IS UPDATED. A batch of edits to shop copy, item descriptions, settings and menus is now built into the game.',
  'NO TWO CONTRACTS ON THE BOARD ARE THE SAME JOB. Finishing a contract used to be able to drop a copy of a job you already had back onto the board, wasting a slot. The freed slot now follows the same no-duplicate rule the board fills by.',
'@
SubRx @'
  now:'v11.41: a claimed contract refilled its slot with a bare genContract, skipping the no-duplicate rule (contractKey) the board is topped up by, so a claimed job could be replaced by one already on the board. Measured 182 of 400 finished-then-claimed boards ended with two identical rows. The render-time repair of a malformed card had the same gap. Both now go through freshContract, which dedups against every other slot the way ensureContracts does. From the contract agent.',
'@ @'
  now:'v11.42: his in-game text edits, baked permanently. 67 wording changes from the text editor (P.txt in his run export) are shipped as a default map TXSHIP that TX consults under the profile, so his words are the game words for everyone; number-shaped lines are derived into the same blanked patterns txSet builds, so lines like the credit counter refill their numbers at draw time. The export double-encoded the middot and it was normalized before baking. His own profile edits still win. From his instruction to pick the edits up permanently.',
'@

[IO.File]::WriteAllText($Target,$script:s,(New-Object Text.UTF8Encoding $false))
Write-Output ("OK, $n edits applied to " + $Target)
