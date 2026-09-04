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
  {v:'11.02',what:'changing save says why it leaves fullscreen
'@ @'
  {v:'11.03',what:'every run report ends with a restore code, and the code carries the character rather than a description of it',
   run:function(){
     if(typeof buildExport!=='function') return 'SKIP: this build writes no report';
     if(!window.__P) return 'SKIP: this fixture cannot reach the profile';
     if(typeof restoreCode!=='function'||typeof restoreRead!=='function')
       return 'the report carries no restore code, so a friend who loses a save cannot be given one back';
     var bad=[], prof=__P(), keep={}, k;
     var FIELDS=['pname','credits','xp','xpLevel','runs','ext','died','best','notoriety',
                 'pack','racks','arrays','cstand','stash','junk','mapIx','cond','wxPick',
                 'cosBought','spClaimed','kills'];
     for(k=0;k<FIELDS.length;k++) keep[FIELDS[k]]=prof[FIELDS[k]];
     var keepW={}, ck;
     for(ck in COSKEY) keepW[ck]=prof[COSKEY[ck]];
     try{
       // DISTINCTIVE ON PURPOSE. Every value here is one the fallback could never
       // produce, so a code that quietly rebuilt a default profile cannot pass.
       prof.pname='ZQXRESTORE'; prof.credits=918273; prof.xp=44551; prof.xpLevel=7;
       prof.runs=131; prof.ext=57; prof.died=29; prof.best=71234; prof.notoriety=3;
       prof.pack=2; prof.racks=4; prof.arrays=2; prof.cstand=11;
       prof.mapIx=1; prof.cond='night'; prof.wxPick='fog';
       prof.spClaimed=['t1','t3']; prof.kills={warden:4,crawler:99};
       prof.cosBought={ghostmask:1};
       prof.junk={scrap:1};
       // A bag the fallback could not roll: three of one thing, one of another.
       prof.stash=['titan','titan','titan','coil','core'];
       for(ck in COSKEY) prof[COSKEY[ck]]=null;
       prof.cosHat='spartan'; prof.cosBeard='fullbeard'; prof.cosEyes='eyeamber';
       var code=restoreCode();
       if(!code||code.length<20) bad.push('the restore code came out as '+(code?code.length+' characters':'nothing'));
       if(code&&code.slice(0,4)!=='PIL1') bad.push('the code does not name itself, so nothing can tell it from any other pasted line');
       // 1. IT IS IN THE REPORT, which is the only place a friend can reach it.
       var rep=buildExport();
       var txt=(rep&&rep.join)?rep.join('\n'):String(rep);
       if(txt.indexOf(code)<0) bad.push('the restore code is not in the run report, so nobody can send it');
       if(txt.toUpperCase().indexOf('RESTORE CODE')<0) bad.push('the report does not say what the code is');
       // 2. AND IT CARRIES THE CHARACTER, not a description of one. Read it back
       //    and compare every field that makes somebody who they are.
       var o=restoreRead(code);
       if(!o) bad.push('the code cannot be read back by the build that wrote it');
       else {
         function want(got,exp,what){ if(got!==exp) bad.push(what+' came back as '+got+' and not '+exp); }
         want(o.n,'ZQXRESTORE','the name'); want(o.c,918273,'the credits'); want(o.x,44551,'the XP');
         want(o.l,7,'the level'); want(o.r,131,'the runs'); want(o.e,57,'the extracts');
         want(o.d,29,'the deaths'); want(o.b,71234,'the best haul'); want(o.no,3,'the notoriety');
         want(o.pk,2,'the pack tier'); want(o.ra,4,'the racks'); want(o.ar,2,'the arrays');
         want(o.cs,11,'the contracts standing'); want(o.mi,1,'the chosen map');
         want(o.cd,'night','the chosen surface'); want(o.wq,'fog','the chosen weather');
         want((o.sc||[]).join(','),'t1,t3','the season tiers claimed');
         want((o.ki||{}).warden,4,'the warden kills, which unlock a rack');
         want((o.cb||{}).ghostmask,1,'a cosmetic bought outright');
         want((o.j||{}).scrap,1,'a junk tag');
         want((o.w||{}).hat,'spartan','the hat being worn');
         want((o.w||{}).beard,'fullbeard','the beard being worn');
         want((o.w||{}).eyes,'eyeamber','the eyes being worn');
         want((o.s||{}).titan,3,'three of the same thing in the stash');
         want((o.s||{}).coil,1,'a single thing in the stash');
         // 3. AND IT IS PASTEABLE. A code nobody can send is not a restore.
         if(code.length>4000) bad.push('the code is '+code.length+' characters, which is not something a person pastes into a chat window');
       }
       // 4. CONTROLS. The reader must refuse what it should refuse, or a
       //    mistyped line would be accepted as a character.
       if(restoreRead('')!==null) bad.push('control: an empty code reads as a character');
       if(restoreRead('hello there')!==null) bad.push('control: an ordinary sentence reads as a character');
       if(restoreRead('PIL1notbase64!!')!==null) bad.push('control: a corrupt code reads as a character');
       // AND THE READER MUST NOT SIMPLY ECHO. If it returned its argument or a
       // fixed object, every line above would pass on any build.
       prof.credits=112233;
       var o2=restoreRead(restoreCode());
       if(!o2||o2.c!==112233) bad.push('control: the code does not follow the profile, so it is not reading what it wrote');
       if(o2&&o2.c===918273) bad.push('control: the code is stale, the reader gave back the previous character');
     } finally {
       for(k=0;k<FIELDS.length;k++) prof[FIELDS[k]]=keep[FIELDS[k]];
       for(ck in COSKEY) prof[COSKEY[ck]]=keepW[ck];
       try{ saveProfile(); }catch(_sp){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'11.02',what:'changing save says why it leaves fullscreen
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
