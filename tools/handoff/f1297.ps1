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

# v12.97 CHECK, inserted before the v12.96 entry.
#
# THE NUMBERS ARE DISTINCTIVE ON PURPOSE. A restored figure that happens to equal the
# restorer's own proves nothing, and neither does a zero that could be a default. The
# two profiles carry figures no arithmetic in this game would produce.
#
# THE OLD-CODE ARM MATTERS AS MUCH AS THE NEW ONE. Codes made before today are in the
# wild in his run reports, and the rule for them is the whole judgement call in this
# build: zero, not whatever the restorer happened to have.
#
# THE CONTROL IS EVERY COUNTER THE RESTORE ALREADY CARRIED. Adding a field to
# restoreMake changes the object every code is built from, so a build that carried the
# new one and dropped an old one would pass the arms above.
SubRx @'
  {v:'12.96',what:'the career card counts times he got back up
'@ @'
  {v:'12.97',what:'a restore code carries net lifetime earnings, so a character restored over a save no longer wears the restorer figure as its own, a code made before this build zeroes it rather than leaving the previous one standing, and every counter the restore already carried still arrives (audit finding 6, 2026-09-11)',
   run:function(){
     if(typeof restoreMake!=='function'||typeof restoreApply!=='function')
       return 'SKIP: this fixture cannot make or apply a restore code';
     if(!window.__P) return 'SKIP: this fixture cannot reach the profile';
     var bad=[], P2=__P();
     var KEEP={}, F=['pname','credits','xp','xpLevel','runs','ext','died','best','notoriety',
                     'pack','racks','arrays','cstand','netEarn','mapIx','cond','wxPick','stash','weapons','equipped'], fi;
     for(fi=0;fi<F.length;fi++) KEEP[F[fi]]=P2[F[fi]];
     try{
       // THE CHARACTER IN THE CODE. Figures no arithmetic here would land on.
       P2.pname='MAKER'; P2.credits=123457; P2.xp=8801; P2.xpLevel=7;
       P2.runs=77; P2.ext=41; P2.died=19; P2.best=52111; P2.notoriety=3;
       P2.pack=2; P2.racks=5; P2.arrays=1; P2.cstand=4;
       P2.netEarn=771122; P2.mapIx=1; P2.cond='night'; P2.wxPick='any';
       var code=restoreMake();
       if(!code) return 'SKIP: no restore code could be made from a staged profile';
       // THE CHARACTER BEING REPLACED, carrying a different lifetime figure.
       P2.pname='RESTORER'; P2.credits=1; P2.xp=1; P2.xpLevel=1;
       P2.runs=4; P2.ext=1; P2.died=3; P2.best=900; P2.notoriety=0;
       P2.netEarn=404404;
       if(restoreApply(code)!==true) return 'SKIP: the restore refused a code this check had just made';
       if(P2.netEarn===404404)
         bad.push('the restored character wears the lifetime earnings of the player who restored it: the panel says the code REPLACES the save he is playing, and every other counter was replaced, so the career card now states somebody else figure as a fact about this character');
       else if(P2.netEarn!==771122)
         bad.push('the restored character lifetime earnings came back as '+P2.netEarn+' rather than the 771122 the code was made from');
       // CONTROL: EVERY COUNTER THE RESTORE ALREADY CARRIED still arrives. Adding a
       // field changes the object every code is built from.
       var want={pname:'MAKER',credits:123457,xp:8801,xpLevel:7,runs:77,ext:41,died:19,best:52111,notoriety:3,pack:2,racks:5,arrays:1,cstand:4};
       for(var k in want) if(P2[k]!==want[k])
         bad.push('control: the restore no longer carries '+k+': it arrived as '+P2[k]+' rather than '+want[k]+', so adding a field has dropped one that was already there');
       // A CODE MADE BEFORE THIS BUILD has no key for it, and must ZERO the field
       // rather than leave the previous character figure standing. These codes are
       // in the wild in his run reports.
       var old=restoreMake();
       try{ delete old.ne; }catch(_d){ old.ne=undefined; }
       P2.netEarn=404404;
       if(restoreApply(old)!==true) return 'SKIP: the restore refused a code with the new key removed';
       if(P2.netEarn===404404)
         bad.push('a restore code made before this build leaves the previous character lifetime earnings in place, which is the same wrong number under a different name');
       else if(P2.netEarn!==0)
         bad.push('a restore code with no lifetime figure in it set the field to '+P2.netEarn+' rather than an honest zero');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ for(var fj=0;fj<F.length;fj++) P2[F[fj]]=KEEP[F[fj]]; saveProfile(); }catch(_p){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.96',what:'the career card counts times he got back up
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
