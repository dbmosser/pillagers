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

if ($s.Contains("  {v:'22.30',what:")) { throw "check 22.30 is in the fixture already" }

SubRx @'
  {v:'22.29',what:
'@ @'
  {v:'22.30',what:'a kit question the party ascent closed unanswered leaves nothing on the Let them go card: RANDOM FROM STASH and TOP GEAR are hidden there, and pressing one rewrites no packing and sends no kit answer',
   run:function(){
     if(typeof askKit!=='function'||typeof kitExtraHide!=='function') return 'SKIP: no kit question here';
     var md=document.getElementById('askmodal'), mc=document.getElementById('mercclear'), kr=document.getElementById('askrand'), kt=document.getElementById('asktop'), tm=document.getElementById('tradermodal');
     if(!md||!mc||!kr||!kt||typeof mc.onclick!=='function') return 'SKIP: no Hire nobody card here';
     var bad=[], fired=0, oSave=saveProfile, keep={merc:P.merc,kit:P.kit,stash:P.stash,eq:P.equipped,eq2:P.equippedSec,fk:P.freeKit,ks:P.kitSaved,ha:P.hotAssign}, tmOn=tm?tm.classList.contains('on'):false;
     try{
       __topClear(); __runPrep();
       saveProfile=function(){};
       P.freeKit=0;
       askKit(function(){ fired++; },true);
       if(!md.classList.contains('on')||kr.style.display==='none'||kt.style.display==='none') return 'SKIP: staging: the kit card did not open with RANDOM FROM STASH and TOP GEAR';
       md.classList.remove('on');   // the party ascent: a screen change takes every open window down and runs no answer
       P.merc='zqk39hire';
       mc.onclick();
       if(!md.classList.contains('on')) return 'SKIP: staging: the Let them go card did not open';
       if(kr.style.display!=='none'||kt.style.display!=='none') bad.push('the Let them go card shows RANDOM FROM STASH and TOP GEAR, left over from a kit question the party ascent closed');
       if(ASKRAND||ASKTOP) bad.push('RANDOM FROM STASH and TOP GEAR are still armed under the Let them go card');
       P.kit=['zqk39a','zqk39b'];
       kr.click();
       if(fired) bad.push('RANDOM FROM STASH on the Let them go card sent a kit answer to the host');
       if(!(P.kit&&P.kit.length===2&&P.kit[0]==='zqk39a'&&P.kit[1]==='zqk39b')) bad.push('RANDOM FROM STASH on the Let them go card rewrote the packing to '+JSON.stringify(P.kit));
       if(P.merc!=='zqk39hire') bad.push('RANDOM FROM STASH on the Let them go card let the hire go');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       saveProfile=oSave;
       P.merc=keep.merc; P.kit=keep.kit; P.stash=keep.stash; P.equipped=keep.eq; P.equippedSec=keep.eq2; P.freeKit=keep.fk; P.kitSaved=keep.ks; P.hotAssign=keep.ha;
       md.classList.remove('on'); if(tm&&!tmOn) tm.classList.remove('on');
       ASKYES=null; ASKALT=null; ASKBACK=null; try{ kitExtraHide(); }catch(_k){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.29',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
