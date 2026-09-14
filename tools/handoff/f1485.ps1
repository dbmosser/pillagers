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
  {v:'14.84',what:
'@ @'
  {v:'14.85',what:'a belt key on a gun in his hands survives the dead key sweep: with the SMG equipped and in neither the stash nor the kit, its key stays, while a key on an item held nowhere goes (belt audit finding 2)',
   run:function(){
     if(typeof dropDeadKeys!=='function'||!window.__applyLoaded||!ITEMS.gun_smg||!ITEMS.stim) return 'SKIP: no dead key sweep in this build';
     var bad=[], snap=null;
     try{
       __topClear(); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       var q=__P();
       q.weapons=['smg']; q.equipped='smg'; q.equippedSec='none';
       q.stash=(q.stash||[]).filter(function(k){ return k!=='gun_smg'&&k!=='stim'; }); q.kit=[];
       q.hotAssign={4:'gun_smg',5:'stim'};
       dropDeadKeys();
       // CONTROL: the key on a Stim held nowhere is swept.
       if(q.hotAssign[5]!==undefined) return 'SKIP: the sweep kept a key on an item held nowhere here';
       if(q.hotAssign[4]!=='gun_smg') bad.push('the sweep deleted key 5 on the SMG in his hands');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(snap) __applyLoaded(snap); }catch(_r){} try{ __topClear(); __cleanProfile(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'14.84',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
