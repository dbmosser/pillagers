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

if ($s.Contains("  {v:'35.99',what:")) { throw "check 35.99 is in the fixture already" }

SubRx @'
  {v:'35.98',what:
'@ @'
  {v:'35.99',what:'run over moments have readable labels, aligned four-stat rows, quiet scrim and equal death counts in both windows',
   run:function(){
     var a0, d, c, disp, oldPost, sent, r, rr, i, j, left, cs, col, bad=[];
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       a0=ARCADE; ARCADE=Object.assign({},a0,{on:1,solo:0,role:'host',run:{id:'overlook'},ini:null,scAt:0,scDirty:1,deaths:3,mine:1200});
       oldPost=netSamePost; netSamePost=function(m){sent=m;return true;};
       arcadeScFlush(Date.now()); if(!sent||sent.d!==3) bad.push('own deaths missing from score wire');
       arcadeScTake({run:'overlook',s:800,k:2,x:0,d:2});
       if(ARCADE.mateD!==2) bad.push('partner deaths not received');
       d=attEl(); disp=d.style.display; d.style.display='block'; attZ(d);
       ARCADE.over={at:Date.now()-3000,team:2000,p1:{s:1200,k:3,x:1,d:3},p2:{s:800,k:2,x:0,d:ARCADE.mateD},bm:{cr:{v:1200,who:'p1'},cc:{v:7,who:'p2'},dm:{v:300,who:'p2'},st:{v:4,who:'P1'},hl:{v:600,who:'P2'},ls:{v:70,who:'P2'}}};
       arcadeOverSync(); c=arcadeOverEl(); rr=c.querySelectorAll('.aosr');
       if(rr.length!==2) return 'not two stat rows';
       for(i=0;i<rr.length;i++){
         r=rr[i].querySelectorAll('.aosc'); if(r.length!==4) return 'player '+(i+1)+' has '+r.length+' stat cells';
         if(getComputedStyle(rr[i]).display!=='grid') bad.push('stat rows are not grids');
         for(j=0;j<r.length;j++){
           left=r[j].getBoundingClientRect().left;
           if(i===1&&Math.abs(left-rr[0].querySelectorAll('.aosc')[j].getBoundingClientRect().left)>1) bad.push('stat columns do not align');
           if(parseFloat(getComputedStyle(r[j].querySelector('i')).fontSize)<20) bad.push('stat labels below 20px');
         }
       }
       if(rr[1].querySelectorAll('.aosc')[3].querySelector('b').textContent!=='2') bad.push('partner deaths not drawn');
       r=c.querySelectorAll('.aobmt > div:first-child');
       if(r.length!==6) bad.push('not six moments');
       for(i=0;i<r.length;i++) if(parseFloat(getComputedStyle(r[i]).fontSize)<20) bad.push('moment labels below 20px');
       cs=getComputedStyle(d); if(cs.backgroundColor!=='rgba(6, 7, 8, 0.8)') bad.push('background is not the quiet 80 percent scrim: '+cs.backgroundColor);
       if(cs.backdropFilter!=='blur(6px)') bad.push('background blur is not 6px');
       if(parseFloat(getComputedStyle(c.querySelector('.aobm')).borderTopWidth)!==1) bad.push('no divider above moments');
       col=getComputedStyle(c.querySelector('.aocrown > div:last-child')).color;
       if(col!==getComputedStyle(c.querySelector('.aobmt:not(.aocrown) > div:last-child')).color) bad.push('crown value still uses a separate accent');
       return bad.length?bad.join('; '):null;
     }finally{
       if(oldPost) netSamePost=oldPost;
       if(a0) ARCADE=a0;
       if(c){c.style.display='none';c.removeAttribute('data-at');}
       if(d)d.style.display=disp;
       __topClear();
     }
   }},
  {v:'35.98',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
