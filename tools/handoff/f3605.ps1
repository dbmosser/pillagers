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

if ($s.Contains("  {v:'36.05',what:")) { throw "check 36.05 is in the fixture already" }

SubRx @'
  {v:'36.04',what:
'@ @'
  {v:'36.05',what:'pre-raid pack names stay whole beside buy slots and the career kills row keeps 600 SP; map labels retain his design A sizes',
   run:function(){
     if(!(window.__hubEnter&&window.__P&&window.__applyLoaded&&window.__deploy&&window.__state&&window.__endRaid)) return 'missing fixture staging';
     var bad=[], snap=null, c0=CAREER_ON, g=null, q, names, i, el, rows, label, val, kills='', sm=document.getElementById('sectormodal');
     function shut(){var ms=document.querySelectorAll('.modal.on');for(var j=0;j<ms.length;j++)ms[j].classList.remove('on');}
     try{
       snap=JSON.parse(JSON.stringify(__P()));
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();
       q=__P();q.freeKit=0;q.kitPick='mine';q.stash=Object.keys(ITEMS).filter(function(k){return ITEMS[k]&&ITEMS[k].use&&k!=='gun_scav';});q.kit=[];q.equipped='fists';q.credits=900;
       __hubEnter();shut();renderSector();openModal('sectormodal');
       names=sm.querySelectorAll('#sectorpack .srprow[data-pk] .nm');
       if(!names.length)bad.push('no pack names staged');
       for(i=0;i<names.length;i++){
         el=names[i];
         if(el.clientWidth<=0||el.scrollWidth>el.clientWidth+1)bad.push('pack name overflows: '+el.textContent);
         if(getComputedStyle(el).textOverflow==='ellipsis')bad.push('pack name can end in dots: '+el.textContent);
         if(el.scrollHeight>el.clientHeight+1)bad.push('pack name is clipped vertically: '+el.textContent);
       }
       shut();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();CAREER_ON=1;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});g=__state();
       if(!g||!g.cs||!g.career) return 'no career raid staged';
       g.player.iv=99;g.player.hp=100;g.player.downed=false;g.cs.s=750;g.cs.k=4;g.cs.b={kill:600,style:150};
       __endRaid('extract');
       el=document.querySelector('#oc_manifest .lg');
       if(!el)bad.push('no extraction ledger');
       else{
         lbCountEnd(el);rows=el.querySelectorAll('.lgr');
         for(i=0;i<rows.length;i++){
           label=rows[i].querySelector('.lgl');val=rows[i].querySelector('b');
           if(label&&/^kills(?:\s*\(\d+\))?$/i.test(label.textContent.trim()))kills=val?val.textContent.trim():'';
         }
         if(kills.toLowerCase()!=='600 sp')bad.push('kills row reads '+kills+', not 600 SP');
       }
       var src=String(sectorPreviewDraw);
       if(src.indexOf('fs=20,')<0||src.indexOf('fs>14&&')<0)bad.push('zone names lost the 20 px start or 14 px floor');
       if(src.indexOf("'600 18px '+FF; c.textAlign='center'")<0||src.indexOf("'600 18px '+FF; c.textAlign='right'")<0)bad.push('exit or keyed room names are not 18 px');
       return bad.length?bad.join('; '):null;
     }finally{
       try{shut();if(g&&!g.over)__endRaid('abandon');}catch(e){}
       CAREER_ON=c0;try{if(snap)__applyLoaded(snap);}catch(e){}__topClear();
     }
   }},
  {v:'36.04',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
