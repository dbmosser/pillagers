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
  {v:'11.03',what:'every run report ends with a restore code
'@ @'
  {v:'11.04',what:'a restore code can be pasted back in, it says whose character it is before anything is written, and it will not fire without the typed word',
   run:function(){
     if(typeof restoreCode!=='function'||typeof restoreRead!=='function')
       return 'SKIP: this build cannot make a restore code';
     if(!window.__P) return 'SKIP: this fixture cannot reach the profile';
     if(typeof restoreApply!=='function')
       return 'a restore code cannot be applied, so it is a note in a bottle';
     var ta=document.getElementById('rescode'), rd=document.getElementById('resread'),
         go=document.getElementById('resgo'), wd=document.getElementById('resword'),
         no=document.getElementById('resno'), cf=document.getElementById('resconfirm'),
         say=document.getElementById('reswhat');
     if(!(ta&&rd&&go&&wd&&cf)) return 'there is nowhere in the game to paste a restore code';
     if(!__vpAlive()) return 'SKIP: the pane has no layout, so no button can be pressed';
     var bad=[], prof=__P(), keep={}, k;
     var FIELDS=['pname','credits','xp','xpLevel','runs','ext','died','best','notoriety',
                 'pack','racks','arrays','cstand','stash','junk','mapIx','cond','wxPick',
                 'cosBought','spClaimed','kills','log'];
     for(k=0;k<FIELDS.length;k++) keep[FIELDS[k]]=prof[FIELDS[k]];
     var keepW={}, ck; for(ck in COSKEY) keepW[ck]=prof[COSKEY[ck]];
     var reloaded=0, realReload=null;
     try{
       // The apply reloads the tab on purpose, which would take the corpus with
       // it. The reload is counted instead of performed, and put back after.
       realReload=window.location.reload;
       try{ window.location.reload=function(){ reloaded++; }; }catch(_lr){ realReload=null; }
       // A CHARACTER THE FALLBACK COULD NOT PRODUCE, coded, then thrown away.
       prof.pname='ZQXLOST'; prof.credits=771122; prof.xp=8899; prof.xpLevel=6;
       prof.runs=77; prof.ext=41; prof.died=13; prof.best=52111; prof.notoriety=2;
       prof.pack=1; prof.racks=3; prof.arrays=1; prof.cstand=9;
       prof.mapIx=1; prof.cond='night'; prof.wxPick='storm';
       prof.spClaimed=['t2']; prof.kills={warden:5}; prof.cosBought={};
       prof.junk={wire:1}; prof.stash=['titan','titan','coil'];
       for(ck in COSKEY) prof[COSKEY[ck]]=null;
       prof.cosHat='beanie'; prof.cosEyes='eyegreen';
       var code=restoreCode();
       var logWas=(prof.log||[]).slice();
       // Now become somebody else entirely, the way a friend with a lost save is.
       prof.pname='SOMEONEELSE'; prof.credits=5; prof.xp=0; prof.xpLevel=1;
       prof.runs=0; prof.ext=0; prof.died=0; prof.best=0; prof.notoriety=0;
       prof.pack=0; prof.racks=0; prof.arrays=0; prof.cstand=0;
       prof.stash=['scrap']; prof.junk={}; prof.kills={}; prof.spClaimed=[];
       prof.cosHat='none'; prof.cosEyes='eyebrown';
       // 1. READING A CODE WRITES NOTHING. This is the whole safety of the door.
       ta.value=code; rd.click();
       if(prof.pname!=='SOMEONEELSE') bad.push('reading a code already replaced the save, before any confirmation');
       if(window.getComputedStyle(cf).display==='none') bad.push('reading a valid code did not open the confirmation');
       if(say&&String(say.textContent).indexOf('ZQXLOST')<0)
         bad.push('the game does not say whose character the code is, it says '+(say?say.textContent:'nothing'));
       // 2. AND NOR DOES PRESSING REPLACE WITHOUT THE WORD.
       wd.value=''; go.click();
       if(prof.pname!=='SOMEONEELSE') bad.push('REPLACE fired without the typed word, so a misclick costs a character');
       wd.value='RESTORE PLEASE'; go.click();
       if(prof.pname!=='SOMEONEELSE') bad.push('REPLACE fired on the wrong word');
       // 3. WITH THE WORD, THE CHARACTER COMES BACK, all of it.
       wd.value='restore'; go.click();
       function want(got,exp,what){ if(got!==exp) bad.push(what+' came back as '+got+' and not '+exp); }
       want(prof.pname,'ZQXLOST','the name'); want(prof.credits,771122,'the credits');
       want(prof.xp,8899,'the XP'); want(prof.xpLevel,6,'the level');
       want(prof.runs,77,'the runs'); want(prof.ext,41,'the extracts');
       want(prof.died,13,'the deaths'); want(prof.best,52111,'the best haul');
       want(prof.notoriety,2,'the notoriety'); want(prof.pack,1,'the pack tier');
       want(prof.racks,3,'the racks'); want(prof.arrays,1,'the arrays');
       want(prof.cstand,9,'the contracts standing'); want(prof.mapIx,1,'the chosen map');
       want(prof.cond,'night','the chosen surface'); want(prof.wxPick,'storm','the chosen weather');
       want((prof.spClaimed||[]).join(','),'t2','the season tier');
       want((prof.kills||{}).warden,5,'the warden kills');
       want((prof.junk||{}).wire,1,'the junk tag');
       want(prof.cosHat,'beanie','the hat'); want(prof.cosEyes,'eyegreen','the eyes');
       var st=prof.stash||[], nT=0, nC=0, nS=0, i;
       for(i=0;i<st.length;i++){ if(st[i]==='titan') nT++; if(st[i]==='coil') nC++; if(st[i]==='scrap') nS++; }
       want(nT,2,'two of the same thing in the stash'); want(nC,1,'the single thing in the stash');
       if(nS) bad.push('the old stash survived the restore, '+nS+' of it');
       // 4. AND IT RELOADS, because every panel on the floor was built from the
       //    profile that has just been replaced.
       if(!reloaded) bad.push('the restore did not reload, so the Undercroft is still showing the old character');
       // 5. IT DOES NOT PRETEND TO BRING BACK THE LOG, which is not in the code.
       if((prof.log||[]).length!==logWas.length)
         bad.push('the restore changed the run log, which it does not carry and must not touch');
       // 6. CONTROLS. Rubbish must be refused, and refused visibly.
       prof.pname='SOMEONEELSE';
       ta.value='not a code at all'; rd.click();
       if(window.getComputedStyle(cf).display!=='none') bad.push('control: rubbish opened the confirmation');
       if(say&&String(say.textContent).toLowerCase().indexOf('not a restore code')<0)
         bad.push('control: rubbish was not called rubbish, it said '+(say?say.textContent:'nothing'));
       wd.value='restore'; go.click();
       if(prof.pname!=='SOMEONEELSE') bad.push('control: the word alone replaced the save with nothing pasted');
       // AND KEEP MINE MUST ACTUALLY BACK OUT.
       ta.value=code; rd.click();
       if(no){ no.click();
         if(window.getComputedStyle(cf).display!=='none') bad.push('control: KEEP MINE left the confirmation open');
         wd.value='restore'; go.click();
         if(prof.pname!=='SOMEONEELSE') bad.push('control: after KEEP MINE the word still replaced the save');
       }
     } finally {
       if(realReload) try{ window.location.reload=realReload; }catch(_rr){}
       for(k=0;k<FIELDS.length;k++) prof[FIELDS[k]]=keep[FIELDS[k]];
       for(ck in COSKEY) prof[COSKEY[ck]]=keepW[ck];
       try{ if(ta) ta.value=''; if(wd) wd.value=''; if(cf) cf.style.display='none'; if(say) say.textContent=''; }catch(_cl){}
       try{ saveProfile(); }catch(_sp){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'11.03',what:'every run report ends with a restore code
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
