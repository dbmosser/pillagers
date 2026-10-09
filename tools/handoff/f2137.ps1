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

if ($s.Contains("  {v:'21.37',what:")) { throw "check 21.37 is in the fixture already" }

SubRx @'
  {v:'21.36',what:
'@ @'
  {v:'21.37',what:'the run card headings are readable: HOW DID THAT RUN FEEL, and HOW IT WENT on a death card, are no more than a point under the feel tags',
   run:function(){
     var tw=document.getElementById('tagwrap'), lb=tw&&tw.previousElementSibling, oc=document.getElementById('outcome'), was=oc&&oc.classList.contains('on'), bad=[], fl, ft, tg, ds, i, hw=null, nd='HOW IT'+' WENT', staged=false;
     if(!tw||!lb||!oc||typeof buildTags!=='function') return 'SKIP: no run card here';
     if(String(lb.textContent).replace(/\s+/g,'').length<5) return 'SKIP: the heading above the tags is blank here';
     try{
       if(!tw.querySelector('.tag')) buildTags();
       oc.classList.add('on');
       tg=tw.querySelector('.tag');
       if(!tg) return 'SKIP: no feel tags here';
       ft=parseFloat(getComputedStyle(tg).fontSize); fl=parseFloat(getComputedStyle(lb).fontSize);
       if(!(fl>0&&ft>0)) return 'SKIP: no font sizes here';
       if(fl<ft*0.9) bad.push('the heading above the feel tags is '+fl+' px over tags of '+ft+' px, the smallest text on the card');
       if(!was) oc.classList.remove('on');
       if(window.__deploy&&window.__endRaid&&window.__topClear){
         __topClear(); __runPrep(); __cleanProfile();
         __deploy({kit:[],safe:null,mapIx:0,seed:4242});
         staged=true;
         if(G&&!G.over&&G.player&&G.tel){
           G.tel.hitLog=[{n:'QZ TEST HAMMER',a:37,t:61,hp:63}];
           G.player.downed=false; __endRaid('dead');
           ds=document.querySelectorAll('#oc_manifest div');
           for(i=0;i<ds.length;i++) if(!ds[i].children.length&&String(ds[i].textContent).replace(/\s+/g,' ').trim()===nd){ hw=ds[i]; break; }
           if(hw){ fl=parseFloat(getComputedStyle(hw).fontSize); if(fl<ft*0.9) bad.push('the '+nd+' heading on a death card is '+fl+' px over tags of '+ft+' px'); }
         }
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       if(staged){
         try{ if(G&&!G.over){ G.player.downed=false; __endRaid('abandon'); } }catch(_e){}
         __topClear(); __cleanProfile();
       } else if(!was) oc.classList.remove('on');
     }
     return bad.length?bad.join('; '):null; }},
  {v:'21.36',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
