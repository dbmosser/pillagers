$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  {v:'14.44',what:
'@ @'
  {v:'14.45',what:'a roll does not carry through a raid: arriving on the Undercroft floor with a roll part done places him at the lamp with the roll over, where it used to finish from there (floor audit finding 1)',
   run:function(){
     if(typeof showScreen!=='function') return 'SKIP: no screen switch in this build';
     if(typeof G!=='undefined'&&G) return 'SKIP: a raid is live, so the floor arrival cannot be driven cleanly';
     var bad=[];
     try{
       __topClear(); __cleanProfile();
       showScreen('hub'); __topClear();
       if(typeof HB==='undefined'||!HB||!HB.player) return 'SKIP: no Undercroft floor player in this build';
       HB.player.rollT=0.3; HB.eLock=false;
       showScreen('hub');
       // CONTROL: the arrival ran, because it set the E lock.
       if(HB.eLock!==true) return 'SKIP: showScreen did not run the floor arrival here';
       if(HB.player.rollT>0) bad.push('arriving on the floor left a roll with '+HB.player.rollT+' s to run, so he rolls out of the lamp he was placed in');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(HB&&HB.player) HB.player.rollT=0; }catch(_r){} try{ __topClear(); __cleanProfile(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'14.44',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
