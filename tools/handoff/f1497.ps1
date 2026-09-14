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
  {v:'14.96',what:
'@ @'
  {v:'14.97',what:'the Undercroft backpack shows a packed gun the raid shows: with key 5 on the SMG and a field SMG packed, the backpack counts it when the SMG is in his hands, and hides it when the pistol is (copies audit finding 1)',
   run:function(){
     if(typeof renderHub!=='function'||!document.getElementById('kitn')||!window.__applyLoaded||!ITEMS.gun_smg||!WEAPONS.pistol||!WEAPONS.smg) return 'SKIP: no Undercroft backpack count in this build';
     var bad=[], snap=null;
     function packed(){ renderHub(); return +(document.getElementById('kitn').textContent||'NaN'); }
     try{
       __topClear(); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       var q=__P();
       q.weapons=['pistol','smg']; q.stash=['gun_smg']; q.kit=['gun_smg']; q.hotAssign={4:'gun_smg'}; q.freeKit=0;
       // CONTROL: with the pistol in hand the key on the SMG claims the packed SMG.
       q.equipped='pistol'; q.equippedSec='none';
       var c0=packed();
       if(c0!==0) return 'SKIP: with the pistol in hand the backpack counted '+c0+', so the key claim is not what it was here';
       q.equipped='smg';
       var c1=packed();
       if(c1!==1) bad.push('with the SMG in his hands and key 5 on it, the packed field SMG reads '+c1+' in the Undercroft backpack, while the raid backpack shows it');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(snap) __applyLoaded(snap); }catch(_r){} try{ __topClear(); __cleanProfile(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'14.96',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
