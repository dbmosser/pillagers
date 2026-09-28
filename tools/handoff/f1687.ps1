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

if ($s.Contains("  {v:'16.87',what:")) { throw "check 16.87 is in the fixture already" }

SubRx @'
  {v:'16.86',what:
'@ @'
  {v:'16.87',what:'the kit question offers TOP GEAR and RANDOM FROM STASH: top gear equips the highest tier gun owned and packs grenades, ammo and heals from the stash, random equips an owned gun and packs up to six stash items, every packed item is in the stash, both go up as MY LOADOUT does, and the two buttons are gone once the card closes',
   run:function(){
     if(typeof askKit!=='function'||!window.__P) return 'SKIP: this build has no kit question';
     var top=document.getElementById('asktop'), rnd=document.getElementById('askrand'), md=document.getElementById('askmodal');
     if(!top||!rnd) return 'the kit question has no TOP GEAR or RANDOM FROM STASH answer';
     var P0=__P(), keep=JSON.stringify({w:P0.weapons,e:P0.equipped,es:P0.equippedSec,st:P0.stash,k:P0.kit,fk:P0.freeKit,ks:P0.kitSaved}), oSave=saveProfile, bad=[], went=0, i, st;
     function inStash(list){ var pool=P0.stash.slice(); for(var j=0;j<list.length;j++){ var x=pool.indexOf(list[j]); if(x<0) return false; pool.splice(x,1); } return true; }
     try{
       saveProfile=function(){};
       P0.weapons=['pistol','rifle','sniper']; P0.equipped='pistol'; P0.equippedSec='none'; P0.freeKit=0; P0.kitSaved=null; P0.kit=[];
       P0.stash=['frag','frag','frag','smoke','bandage','medkit','ammobox','bandage','scrap','scrap'];
       askKit(function(){ went++; });
       if(top.style.display==='none'||rnd.style.display==='none') bad.push('the kit question does not show TOP GEAR and RANDOM FROM STASH');
       top.click();
       if(went!==1) bad.push('TOP GEAR did not go up ('+went+')');
       if(P0.equipped!=='sniper') bad.push('TOP GEAR equipped '+P0.equipped+', not the highest tier gun owned');
       if(P0.kit.filter(function(k){ return k==='frag'; }).length!==2) bad.push('TOP GEAR did not pack two of each grenade ('+P0.kit.join(',')+')');
       if(P0.kit.indexOf('medkit')<0||P0.kit.indexOf('ammobox')<0) bad.push('TOP GEAR did not pack the biggest heal and ammo ('+P0.kit.join(',')+')');
       if(P0.kit.indexOf('scrap')>=0) bad.push('TOP GEAR packed scrap');
       if(!inStash(P0.kit)) bad.push('TOP GEAR packed something the stash does not hold');
       if(md&&md.classList.contains('on')) bad.push('TOP GEAR left the card open');
       if(top.style.display!=='none'||rnd.style.display!=='none') bad.push('the two answers stayed on the card after it closed');
       for(i=0;i<5;i++){
         P0.kit=[]; askKit(function(){ went++; }); rnd.click();
         if(P0.weapons.indexOf(P0.equipped)<0||P0.equipped==='fists') bad.push('RANDOM FROM STASH equipped '+P0.equipped);
         if(P0.kit.length>6||!inStash(P0.kit)) bad.push('RANDOM FROM STASH packed '+P0.kit.join(','));
         if(P0.kit.indexOf('scrap')>=0) bad.push('RANDOM FROM STASH packed scrap');
       }
       if(went!==6) bad.push('RANDOM FROM STASH did not go up every time ('+went+' of 6)');
     } finally {
       saveProfile=oSave;
       try{ st=JSON.parse(keep); P0.weapons=st.w; P0.equipped=st.e; P0.equippedSec=st.es; P0.stash=st.st; P0.kit=st.k; P0.freeKit=st.fk; P0.kitSaved=st.ks; }catch(e){}
       try{ if(md) md.classList.remove('on'); ASKYES=null; ASKALT=null; ASKBACK=null; if(typeof kitExtraHide==='function') kitExtraHide(); }catch(e){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'16.86',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
