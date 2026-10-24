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

if ($s.Contains("  {v:'34.20',what:")) { throw "check 34.20 is in the fixture already" }

SubRx @'
  {v:'34.19',what:
'@ @'
  {v:'34.20',what:'rewards rows carry a type cue and the next one reads first, claim all is lime under the list, no nothing-ready sentence, and the toast on rewards and racks sits above the card; racks are two columns with a lime build button',
   run:function(){
     var oldP=null,nt=null,bad=[],toast,i,rows,cs,a,b,list,btn,top;
     function fail(s){bad.push(s);}
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();oldP=JSON.stringify(P);
       nt=document.createElement('style');nt.textContent='#opmodal *,#hubtoast{transition:none !important;}';document.head.appendChild(nt);
       __hubEnter();P.xp=0;openOps('rew');
       if(!document.querySelector('#seasonlist .row.rw-credits')||!document.querySelector('#seasonlist .row.rw-wep'))fail('reward rows have no type cue class');
       a=document.querySelector('#seasonlist .row.rw-credits');b=document.querySelector('#seasonlist .row.rw-kit');
       if(a&&b&&getComputedStyle(a).borderLeftColor===getComputedStyle(b).borderLeftColor)fail('credits and kit rows share one cue colour');
       if(document.querySelectorAll('#seasonlist .row.rw-next').length!==1)fail('the next reward is not marked exactly once');
       btn=document.getElementById('seasonclaimall');list=document.getElementById('seasonlist');
       if(/nothing ready/i.test(btn.textContent))fail('claim all still says nothing ready to claim');
       if(btn.getBoundingClientRect().top<list.getBoundingClientRect().bottom-1)fail('claim all is not under the list: '+btn.getBoundingClientRect().top+' vs '+list.getBoundingClientRect().bottom);
       P.xp=20000;openOps('rew');btn=document.getElementById('seasonclaimall');
       if(btn.disabled||getComputedStyle(btn).backgroundColor!=='rgb(230, 255, 61)')fail('ready claim all is not lime: '+getComputedStyle(btn).backgroundColor);
       if(!document.querySelector('#seasonlist .row.rw-ready'))fail('a ready reward is not marked');
       toast=document.getElementById('hubtoast');top=innerHeight*.05;
       if(toast){toast.textContent='welcome pack in stash';toast.classList.add('on');if(toast.getBoundingClientRect().bottom>=top)fail('rewards toast covers the card: bottom '+toast.getBoundingClientRect().bottom);}
       P.xp=0;openOps('mf');
       a=document.getElementById('mfbuild').getBoundingClientRect();b=document.getElementById('mfghost').getBoundingClientRect();
       if(b.left<a.right)fail('racks are still one column: friend import left '+b.left+' build right '+a.right);
       if(a.height<56)fail('build button is '+a.height+'px high');
       cs=document.querySelector('#mfstatus > span');if(!cs||cs.getBoundingClientRect().height<35)fail('rack tiles are a thin strip');
       btn=document.getElementById('mfbuild');btn.disabled=false;
       if(getComputedStyle(btn).backgroundColor!=='rgb(230, 255, 61)')fail('build a rack is not lime when it can be built: '+getComputedStyle(btn).backgroundColor);
       if(toast&&toast.getBoundingClientRect().bottom>=top)fail('racks toast covers the card: bottom '+toast.getBoundingClientRect().bottom);
       return bad.length?bad.join('; '):null;
     }finally{
       if(nt)nt.remove();if(toast)toast.classList.remove('on');try{__endRaid('abandon');}catch(e){}__topClear();__resetCfg();__cleanProfile();if(oldP)P=JSON.parse(oldP);
     }
   }},
  {v:'34.19',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
