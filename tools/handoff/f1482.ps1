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
  {v:'14.81',what:
'@ @'
  {v:'14.82',what:'a contract gun fills an empty hand: paid with no gun in hand it becomes gun 1, and paid with a gun in hand it goes to the armoury without taking the hand (gun audit finding 4)',
   run:function(){
     if(typeof payGear!=='function'||!window.__applyLoaded||!WEAPONS.smg||!WEAPONS.pistol) return 'SKIP: no contract gear payment in this build';
     var bad=[], snap=null;
     try{
       __topClear(); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       var q=__P();
       // CONTROL: with the pistol in hand, a paid SMG goes to the armoury and the hand keeps the pistol.
       q.weapons=['pistol']; q.equipped='pistol'; q.equippedSec='none';
       payGear({kind:'wep',k:'smg'});
       if(q.weapons.indexOf('smg')<0) return 'SKIP: a paid SMG did not reach the armoury here';
       if(q.equipped!=='pistol') bad.push('a paid SMG took the hand from the pistol he had equipped');
       q.weapons=[]; q.equipped='fists'; q.equippedSec='none';
       payGear({kind:'wep',k:'smg'});
       if(q.equipped!=='smg') bad.push('with no gun in hand a paid SMG went to the armoury and gun 1 stayed '+q.equipped);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(snap) __applyLoaded(snap); }catch(_r){} try{ __topClear(); __cleanProfile(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'14.81',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
