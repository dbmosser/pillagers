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
  {v:'15.95',what:
'@ @'
  {v:'15.96',what:'a restore code carries the imported friend: a code made by a character with a friend imported, restored over a character with none, brings that friend back with their name, gun and record and the Mainframe names them; a code made with no friend, restored over a character who imported one, leaves none; a code from before this build with no friend field leaves none; and the credits and the named pillager records still round-trip through each code (ghost audit finding)',
   run:function(){
     if(typeof restoreMake!=='function'||typeof restoreCode!=='function'||typeof restoreRead!=='function'||typeof restoreApply!=='function'||!window.__P||!window.__applyLoaded) return 'SKIP: no restore codes in this build';
     if(typeof applyGhost!=='function') return 'SKIP: this build has no imported friend';
     var bad=[], snap=null;
     function same(a,b){ return JSON.stringify(a||{})===JSON.stringify(b||{}); }
     function friend(tag){ return {tag:tag,wep:'pistol',wepName:(tag==='ZQXFRIEND')?'Scav Pistol':null,runs:(tag==='ZQXFRIEND')?4:1,ext:(tag==='ZQXFRIEND')?1:0,rate:(tag==='ZQXFRIEND')?25:0,avgHaul:0}; }
     try{
       __topClear(); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       var P2=__P();
       // Distinctive figures, so a code that quietly rebuilt a default profile cannot pass the controls.
       P2.credits=773311; P2.rivals={zqxfriendly:{kills:2,deaths:1,met:3,standing:-3}};
       // ARM A: a code made by a character who imported a friend, pasted over a character with none.
       P2.ghost=friend('ZQXFRIEND');
       var codeA=restoreCode();
       if(!codeA) return 'SKIP: no restore code could be made with a friend imported';
       var oA=restoreRead(codeA);
       if(!oA) return 'SKIP: the code made with a friend imported cannot be read back';
       if(codeA.length>4000) bad.push('with a friend imported the code is '+codeA.length+' characters, past what a person pastes into a chat window');
       P2.ghost=null; P2.credits=5; P2.rivals={};
       if(restoreApply(oA)!==true) return 'SKIP: restoreApply refused a code made a moment ago';
       // CONTROL: the code round-trips on its own: the credits and the named pillager records are the code own figures.
       if(P2.credits!==773311||!same(P2.rivals,oA.rv)||!(P2.rivals&&P2.rivals.zqxfriendly)) return 'SKIP: the first code did not round-trip its credits and named pillager records (credits '+P2.credits+'), so the restore cannot be read here';
       var gA=P2.ghost;
       if(!(gA&&typeof gA==='object'&&gA.tag==='ZQXFRIEND')) bad.push('a code made by a character with a friend imported, restored over a character with none, came up with '+(gA&&gA.tag?('a friend called '+gA.tag):'no friend')+', so the report file is needed again');
       else {
         if(gA.wep!=='pistol'||gA.rate!==25||gA.runs!==4||gA.wepName!=='Scav Pistol') bad.push('the friend came back as '+JSON.stringify(gA)+' rather than with the gun and record the code was made from');
         var hint=document.getElementById('mfghosthint');
         if(hint&&typeof renderMainframe==='function'){
           try{ renderMainframe(); var ht=String(hint.textContent||''); if(ht.indexOf('ZQXFRIEND walks your raids')<0) bad.push('after the restore the Mainframe does not name the friend the code carried: "'+ht.slice(0,80)+'"'); }catch(_rm){ bad.push('the Mainframe would not draw after the restore: '+(_rm&&_rm.message||_rm)); }
         }
       }
       // ARM B: a code made by a character with no friend, pasted over a character who has one.
       P2.ghost=null; P2.credits=664422;
       var codeB=restoreCode();
       var oB=restoreRead(codeB);
       if(!oB) return 'SKIP: the code made with no friend cannot be read back';
       P2.ghost=friend('OLDONE'); P2.credits=6;
       if(restoreApply(oB)!==true) return 'SKIP: restoreApply refused the second code';
       // CONTROL: the second code applied.
       if(P2.credits!==664422) return 'SKIP: the second code did not round-trip its credits ('+P2.credits+'), so the restore cannot be read here';
       if(P2.ghost) bad.push('a code made by a character with no friend, restored over a character who imported one, kept the friend of the replaced character ('+P2.ghost.tag+')');
       // ARM C: a code from before this build, with no friend field at all, over a character who has one.
       var oC=JSON.parse(JSON.stringify(oB)); try{ delete oC.gh; }catch(_d){ oC.gh=undefined; }
       P2.ghost=friend('OLDONE'); P2.credits=7;
       if(restoreApply(oC)!==true) return 'SKIP: restoreApply refused a code with the friend field removed';
       if(P2.credits!==664422) return 'SKIP: the older code did not round-trip its credits ('+P2.credits+'), so the restore cannot be read here';
       if(P2.ghost) bad.push('a code from before this build, with no friend field, kept the friend of the replaced character ('+P2.ghost.tag+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ if(typeof renderMainframe==='function'&&document.getElementById('mfghosthint')) renderMainframe(); }catch(_m){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.95',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
