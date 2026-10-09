$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
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

if ($s.Contains("  {v:'21.67',what:")) { throw "check 21.67 is in the fixture already" }

SubRx @'
  {v:'21.66',what:
'@ @'
  {v:'21.67',what:'his note: a dead pillager drops better gear, one safe table roll on every body and two for a medium or heavy rig',
   run:function(){
     if(typeof bodyBonus!=='function') return 'control: a dead pillager drops nothing extra';
     var bad=[], a=bodyBonus({kind:'raider',rig:'none'}), b=bodyBonus({kind:'raider',rig:'heavy'}), c=bodyBonus({kind:'raider',rig:'none',merc:1});
     if(a.length!==1) bad.push('a pillager in no rig drops '+a.length+' extra, not 1');
     if(b.length!==2) bad.push('a pillager in a heavy rig drops '+b.length+' extra, not 2');
     if(c.length) bad.push('your hire drops extra gear');
     var safe=(LOOT.safe||[]).map(function(r){ return r[0]; });
     a.concat(b).forEach(function(k){ if(safe.indexOf(k)<0&&k!=='KEY'&&!/^key_/.test(k)) bad.push(k+' is not from the safe table'); });
     var src=[].slice.call(document.scripts).map(function(s){ return s.text||''; }).join(''), nd='_drop.concat(body'+'Bonus(e))';
     if(src.indexOf(nd)<0) bad.push('the body drop never adds the bonus');
     return bad.length?bad.join('; '):null; }},
  {v:'21.66',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
