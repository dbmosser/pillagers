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

# A CLAIMED CONTRACT'S REPLACEMENT SKIPPED THE NO-DUPLICATE RULE. The board is
# TOPPED UP by ensureContracts, which since v5.71 refuses two rows that are the
# same job (contractKey: the type plus what it is about, not the count). But the
# slot a CLAIMED contract vacates was refilled by a bare genContract, with no
# dedup, so a claimed job's replacement could be a job already on the board:
# measured 182 of 400 finished-then-claimed boards ended with two identical
# rows. The render-time repair of a malformed card had the same gap. Both now
# go through freshContract, which dedups against every OTHER slot exactly the
# way the top-up does. New helper, placed by contractKey so both sites see it.
SubRx @'
  if(c.type==='conduct')  return 'conduct:'+c.ck;
  return c.type;
}
'@ @'
  if(c.type==='conduct')  return 'conduct:'+c.ck;
  return c.type;
}
// v11.41: fill a FREED contract slot the way the board is topped up - no job
// already on the board, keyed on what it is about (contractKey). claimContractAt
// and the render-time repair both used a bare genContract, so a claimed job's
// replacement, or a repaired card, could duplicate a slot the no-duplicate rule
// (v5.71) keeps clear. Deduped against every OTHER slot; bounded retries then
// take what comes, exactly like ensureContracts, so a narrow pool cannot spin.
function freshContract(skipIx){
  for(var _ft=0;_ft<12;_ft++){
    var _fc=genContract(), _fk=contractKey(_fc), _fdup=false;
    for(var _fj=0;_fj<P.contracts.length;_fj++){
      if(_fj===skipIx) continue;
      if(contractKey(P.contracts[_fj])===_fk){ _fdup=true; break; }
    }
    if(!_fdup) return _fc;
  }
  return genContract();
}
'@

# THE CLAIM PATH: the reported, frequent site.
SubRx @'
  P.contracts[ci]=genContract();
  return {pay:c.reward, gear:got};
'@ @'
  P.contracts[ci]=freshContract(ci);
  return {pay:c.reward, gear:got};
'@

# THE RENDER-TIME REPAIR of a malformed card: the same gap, same helper.
SubRx @'
      try{ P.contracts[ci]=genContract(); }catch(_cg){ P.contracts[ci]=null; }
'@ @'
      try{ P.contracts[ci]=freshContract(ci); }catch(_cg){ P.contracts[ci]=null; }
'@

# STAMPS.
SubRx @'
var VER='11.40';
'@ @'
var VER='11.41';
'@
SubRx @'
var WHATSNEW_VER='11.40';
'@ @'
var WHATSNEW_VER='11.41';
'@
SubRx @'
  'A VENTED PILLBOX STAYS STUNNED AS LONG AS IT SHOULD. The stun from a vent shot on a Pillbox was draining almost twice as fast as the setting says, so it came back to life early. It now holds for the full lockout, like every other machine.',
'@ @'
  'NO TWO CONTRACTS ON THE BOARD ARE THE SAME JOB. Finishing a contract used to be able to drop a copy of a job you already had back onto the board, wasting a slot. The freed slot now follows the same no-duplicate rule the board fills by.',
  'A VENTED PILLBOX STAYS STUNNED AS LONG AS IT SHOULD. The stun from a vent shot on a Pillbox was draining almost twice as fast as the setting says, so it came back to life early. It now holds for the full lockout, like every other machine.',
'@
SubRx @'
  now:'v11.40: the Pillbox vent stun drained twice as fast. The general machine update decrements htImmune once for every machine and returns while overheating before it reaches the kind branches; the Choir branch decremented htImmune a second time, so once the overheat phase ended the vent lockout drained at double speed, 5.5 seconds of a 7-second stun. Measured against a sentry, which cleared at 7. The redundant lines are removed. From the combat agent.',
'@ @'
  now:'v11.41: a claimed contract refilled its slot with a bare genContract, skipping the no-duplicate rule (contractKey) the board is topped up by, so a claimed job could be replaced by one already on the board. Measured 182 of 400 finished-then-claimed boards ended with two identical rows. The render-time repair of a malformed card had the same gap. Both now go through freshContract, which dedups against every other slot the way ensureContracts does. From the contract agent.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
