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

if ($s.Contains("  {v:'35.09',what:")) { throw "check 35.09 is in the fixture already" }

SubRx @'
  {v:'35.08',what:
'@ @'
  {v:'35.09',what:'cw-hotfix1 (items on the hotbar follow-up): the lift screen shows the belt plan and takes a drop, a kit pick keeps the item key, and an item key never takes the highlight',
   run:function(){
     var bad=[];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       P.kitPick='mine'; P.stash.push('medkit','medkit'); saveProfile();
       renderSector(); openModal('sectormodal');
       var cells=document.querySelectorAll('#sectorplan [data-plan]');
       if(cells.length!==9) bad.push('lift screen belt cells '+cells.length+' (want 9)');
       else {
         var ck=gunClassKey(gunClassOf('carbine')); if(ck<0||ck>=GUNKEYS) ck=4;
         if(typeof cells[ck].__grabDrop!=='function') bad.push('lift belt key '+(ck+1)+' takes no drop');
         else {
           cells[ck].__grabDrop('medkit','kit');
           if((P.hotAssign||{})[ck]!=='medkit') bad.push('drop on lift belt key '+(ck+1)+' left '+(P.hotAssign||{})[ck]);
           else {
             try{ kitPlaceGuns(['carbine']); }catch(_kp){ bad.push('kitPlaceGuns threw: '+(_kp&&_kp.message||_kp)); }
             if((P.hotAssign||{})[ck]!=='medkit') bad.push('kit pick put '+(P.hotAssign||{})[ck]+' over the medkit on key '+(ck+1));
           }
         }
       }
       try{ document.getElementById('sectormodal').classList.remove('on'); }catch(_m){}
       __cleanProfile();
       __deploy({kit:['gun_carbine','medkit','medkit'],safe:null,mapIx:0,seed:4242});
       if(state!=='raid'||!G||G.over) throw new Error('no live raid to test on');
       G.mapFirst=0; G.mapOpen=false; if(pauseOpen) togglePauseBox(false); syncPause();
       G.hotAssign=G.hotAssign||{}; G.hotAuto=G.hotAuto||{};
       var k2=(gunCell()===4)?5:4;
       G.hotAssign[k2]='medkit'; delete G.hotAuto[k2]; classKeysSettle();
       var sl=hotbarSlots();
       if(!sl[k2]||sl[k2].kind!=='heal') bad.push('raid key '+(k2+1)+' is '+(sl[k2]&&sl[k2].kind)+' not heal');
       else {
         var h0=G.hot; setHot(k2);
         if(G.hot!==h0) bad.push('setHot on the medkit key moved the highlight '+h0+' to '+G.hot);
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var sm=document.getElementById('sectormodal'); if(sm) sm.classList.remove('on'); }catch(_s){}
       try{ if(pauseOpen) togglePauseBox(false); }catch(_p){}
       try{ var K2=__keys(); for(var q2 in K2) delete K2[q2]; }catch(_k){}
       try{ if(state==='raid'&&G&&!G.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'35.08',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
