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

if ($s.Contains("  {v:'21.66',what:")) { throw "check 21.66 is in the fixture already" }

SubRx @'
  {v:'21.65',what:
'@ @'
  {v:'21.66',what:'his note: the single shot guns hit harder, so they keep up with the automatics',
   run:function(){
     var want={pistol:23,tacker:20,scuttle:12,magnum:62,dmr:64,sniper:170,lance:150,shotgun:16,whisper:24}, bad=[], k;
     for(k in want) if(!WEAPONS[k]||WEAPONS[k].dmg!==want[k]) bad.push(k+' does '+(WEAPONS[k]&&WEAPONS[k].dmg)+', not '+want[k]);
     if(WEAPONS.whisper&&WEAPONS.whisper.rof!==400) bad.push('the Whisper fires every '+WEAPONS.whisper.rof+' ms, not 400');
     function sus(w){ var per=w.dmg*(w.pellets||1)*(w.burst||1), shots=w.mag/(w.burst||1); return per*shots/(shots*w.rof/1000+w.reload/1000); }
     var ar=sus(WEAPONS.rifle);
     ['shotgun','lance','dmr','magnum','sniper'].forEach(function(k2){ var s=sus(WEAPONS[k2]); if(s<ar*0.6) bad.push(WEAPONS[k2].name+' sustains '+Math.round(s)+' a second against '+Math.round(ar)+' for the Auto Rifle'); });
     return bad.length?bad.join('; '):null; }},
  {v:'21.65',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
