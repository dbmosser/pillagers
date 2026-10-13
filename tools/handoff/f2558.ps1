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

if ($s.Contains("  {v:'25.58',what:")) { throw "check 25.58 is in the fixture already" }

SubRx @'
  {v:'25.57',what:
'@ @'
  {v:'25.58',what:'forge13: in the Undercroft a kept MK III cryo rifle shows UPGRADE MK III and ELEMENT CRYO with its upgraded numbers on the hover, reads Auto Rifle MK III on the belt, and its icon takes the cryo colour',
   run:function(){
     if(!window.__P||!window.__applyLoaded||typeof itemRows!=='function'||typeof hubBagState!=='function'||typeof gunIcon!=='function'||typeof forgeApply!=='function') return 'SKIP: no Undercroft rows, belt or forge model here';
     if(typeof forgeOf!=='function') return 'no forged rows in the Undercroft (forgeOf)';
     var bad=[], snap=null, q, R, i, up=null, el=null, dmg=null, st, oGA=null, seen=null, cv2;
     try{
       snap=JSON.parse(JSON.stringify(__P()));
       try{ var g0=__state(); if(g0&&!g0.over) __endRaid('abandon'); }catch(_a){}
       q=__P(); q.weapons=['pistol','rifle']; q.equipped='rifle'; q.equippedSec='none'; q.forged={rifle:{fk:2,el:'cryo'}};
       R=itemRows('gun_rifle');
       for(i=0;i<R.length;i++){ if(R[i][0]==='UPGRADE') up=R[i][1]; if(R[i][0]==='ELEMENT') el=R[i][1]; if(R[i][0]==='DAMAGE') dmg=R[i][1]; }
       if(up!=='MK III') bad.push('the rifle hover has no UPGRADE MK III row ('+up+')');
       if(!el||String(el).indexOf('CRYO')!==0) bad.push('the rifle hover has no ELEMENT CRYO row ('+el+')');
       if(!dmg||String(dmg).indexOf('29.9')!==0) bad.push('the rifle hover damage reads '+dmg+', not the MK III 29.9');
       if(R.length>8) bad.push('the hover has '+R.length+' rows');
       R=itemRows('gun_smg');
       if(R.some(function(r){ return r[0]==='UPGRADE'||r[0]==='ELEMENT'; })) bad.push('a plain gun shows an upgrade row');
       st=hubBagState();
       if(!st||!st.player||st.player.wep.name!=='Auto Rifle MK III') bad.push('the Undercroft belt names the rifle '+(st&&st.player&&st.player.wep.name));
       if(st&&st.player&&st.player.wep.tint!==ELEM.cryo.c) bad.push('the Undercroft belt rifle is not cryo tinted');
       if(typeof gunArt==='function'){
         oGA=gunArt; gunArt=function(c,fam,id,W,col,S){ seen=col; return true; };
         cv2=document.createElement('canvas'); cv2.width=64; cv2.height=64;
         gunIcon(cv2.getContext('2d'),'rifle',32,32,40);
         if(seen!==ELEM.cryo.c) bad.push('the rifle icon is drawn in '+seen+', not the cryo colour');
         seen=null; gunIcon(cv2.getContext('2d'),'smg',32,32,40);
         if(seen===ELEM.cryo.c||seen===FORGE_GOLD) bad.push('a plain gun icon took a forge colour');
         q.forged={rifle:{fk:1,el:''}}; seen=null; gunIcon(cv2.getContext('2d'),'rifle',32,32,40);
         if(seen!==FORGE_GOLD) bad.push('a MK II rifle icon is not gold ('+seen+')');
         q.weapons=['pistol']; seen=null; gunIcon(cv2.getContext('2d'),'rifle',32,32,40);
         if(seen===FORGE_GOLD) bad.push('a record for a gun no longer owned still colours its icon');
       }
     }catch(ex){ bad.push('threw: '+(ex&&ex.message||ex)); }
     finally{
       if(oGA) gunArt=oGA;
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'25.57',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
