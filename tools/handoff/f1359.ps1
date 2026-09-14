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
  {v:'13.58',what:
'@ @'
  {v:'13.59',what:'crafting with items packed in the backpack unpacks them properly: a Medkit crafted from two packed Bandages takes them off the loadout and clears their belt key, while spare unpacked Bandages are spent first and leave the packing and the key untouched (Undercroft audit 2026-09-14, finding 1)',
   run:function(){
     if(!window.__P||typeof renderWork!=='function'||typeof RECIPES==='undefined'||typeof stageKitLive!=='function') return 'SKIP: no crafting bench in this build';
     var ri=-1, i;
     for(i=0;i<RECIPES.length;i++) if(RECIPES[i].out&&RECIPES[i].out.medkit&&RECIPES[i].need&&RECIPES[i].need.bandage===2&&RECIPES[i].need.comp===1) ri=i;
     if(ri<0) return 'SKIP: no Medkit recipe of two Bandages and a Component Kit to stage';
     var P2=__P(), keep={st:(P2.stash||[]).slice(),kit:(P2.kit||[]).slice(),ha:JSON.stringify(P2.hotAssign||{})};
     var bad=[];
     function craft(){
       renderWork();
       var btn=document.querySelector('#worklist [data-w="recipe:'+ri+'"] button');
       if(!btn) return false;
       btn.disabled=false; btn.onclick();
       return true;
     }
     function packed(k){ var live=stageKitLive(), c=0; for(var j=0;j<live.length;j++) if(live[j]===k) c++; return c; }
     function kitHas(k){ var c=0; for(var j=0;j<P2.kit.length;j++) if(P2.kit[j]===k) c++; return c; }
     try{
       __topClear(); __cleanProfile();
       // THE FINDING: both Bandages packed and on key 3, nothing spare.
       P2.stash=['bandage','bandage','comp']; P2.kit=['bandage','bandage']; P2.hotAssign={2:'bandage'};
       if(!craft()) return 'SKIP: the crafting bench drew no Medkit row to press';
       if(P2.stash.indexOf('medkit')<0) bad.push('staging: the Medkit was not crafted');
       else {
         if(kitHas('bandage')>0) bad.push('crafting from two packed Bandages left '+kitHas('bandage')+' Bandage entries on the loadout, pointing at items that are gone');
         if(P2.hotAssign&&P2.hotAssign[2]==='bandage') bad.push('crafting from two packed Bandages left key 3 bound to Bandage, showing an item he no longer has');
       }
       // CONTROL: two spare unpacked Bandages are spent first; the packing and the key stay.
       P2.stash=['bandage','bandage','bandage','bandage','comp']; P2.kit=['bandage','bandage']; P2.hotAssign={2:'bandage'};
       if(craft()){
         if(packed('bandage')!==2) bad.push('control: with two spare Bandages the craft broke the packing (packed now '+packed('bandage')+')');
         if(!(P2.hotAssign&&P2.hotAssign[2]==='bandage')) bad.push('control: with two spare Bandages the craft cleared key 3');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ P2.stash=keep.st; P2.kit=keep.kit; P2.hotAssign=JSON.parse(keep.ha); saveProfile(); }catch(_r){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.58',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
