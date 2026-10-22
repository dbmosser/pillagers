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

if ($s.Contains("  {v:'34.18',what:")) { throw "check 34.18 is in the fixture already" }

SubRx @'
  {v:'34.17',what:
'@ @'
  {v:'34.18',what:'pixel wardrobe focus stays inside four equal set tiles; worn marks differ from focus and redundant owned labels are absent',
   run:function(){
     var cfg=CFG.xfPix,oldP,bad=[];
     function fail(s){bad.push(s);}
     function colour(s){return String(s).replace(/\s/g,'');}
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();oldP=JSON.stringify(P);
       __hubEnter();CFG.xfPix=1;P.cosAll=1;P.cosOutfit='outskeleton';__station('mirror','KeyE');renderAvatar('appavatar','appavatarpicker');
       var md=document.getElementById('appearmodal'),pk=document.getElementById('appavatarpicker'),set=pk.querySelector('[data-pixrack="set"]'),tiles=set.querySelectorAll('[data-pixid]'),worn=tiles[1],cs;
       if(tiles.length!==4)return 'set rack lost one of its four controls';
       // v28.xx (cw-cx-pixrackfocus): exercise the actual focus motion, not just the unfocused CSS grid.
       for(var t=0;t<tiles.length;t++){
         padSetFocus(tiles[t]);for(var n=0;n<24;n++)UIM.step(16);
         cs=getComputedStyle(tiles[t]);
         if(cs.outlineStyle==='none'||parseFloat(cs.outlineWidth)<=0||parseFloat(cs.outlineOffset)>-2||colour(cs.outlineColor)!=='rgb(230,255,61)')fail('focus is not an inset lime ring');
         if(cs.boxShadow!=='none')fail('focus still has a halo');
         var ring=document.getElementById('uimring');if(ring&&getComputedStyle(ring).display!=='none')fail('the duplicate outer ring still shows');
         var first=tiles[0].getBoundingClientRect(),last=null;
         for(var i=0;i<tiles.length;i++){
           var r=tiles[i].getBoundingClientRect();
           if(Math.abs(r.width-first.width)>1||Math.abs(r.top-first.top)>1)fail('set tiles leave their equal four-column row');
           if(last&&r.left-last.right<5)fail('focused set overlaps its neighbour');last=r;
         }
       }
       padSetFocus(tiles[3]);cs=getComputedStyle(worn);
       if(worn.getAttribute('aria-pressed')!=='true'||colour(cs.borderLeftColor)!=='rgb(230,255,61)'||parseFloat(cs.borderLeftWidth)<=parseFloat(cs.borderRightWidth)||colour(cs.borderRightColor)==='rgb(230,255,61)')fail('worn set lacks a distinct left rail');
       var status=pk.querySelectorAll('.cosreq');for(i=0;i<status.length;i++)if(status[i].textContent.trim()==='owned')fail('redundant owned label remains');
       P.cosAll=0;P.runs=0;P.ext=0;P.xp=0;renderAvatar('appavatar','appavatarpicker');
       var locked=pk.querySelector('[data-pixid="android"]');if(!locked.classList.contains('lock')||!locked.querySelector('.cosreq').textContent.trim())fail('locked set lost its unlock requirement');
       var cv=document.getElementById('avcv');if(cv.width!==320||cv.height!==320)fail('the required 4x preview canvas changed');
       CFG.xfPix=0;renderAvatar('appavatar','appavatarpicker');if(md.classList.contains('pixfashion')||pk.querySelector('[data-pixid]'))fail('pixel focus styling leaked into the old wardrobe');
       return bad.length?bad.join('; '):null;
     }finally{try{padSetFocus(null);__endRaid('abandon');}catch(e){}__topClear();__resetCfg();__cleanProfile();if(oldP)P=JSON.parse(oldP);CFG.xfPix=cfg;}
   }},
  {v:'34.17',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
