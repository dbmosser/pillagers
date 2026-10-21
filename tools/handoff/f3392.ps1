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

if ($s.Contains("  {v:'33.92',what:")) { throw "check 33.92 is in the fixture already" }

SubRx @'
  {v:'33.91',what:
'@ @'
  {v:'33.92',what:'pixel fashion shows all four racks, worn set and pad focus, full-size pixel tiles and readable saved-look controls',
   run:function(){
     var cfg=CFG.xfPix,md,pk,oldP,bad=[],probe=null;
     function fail(s){bad.push(s);}
     function lime(s){return String(s).replace(/\s/g,'')==='rgb(230,255,61)';}
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();oldP=JSON.stringify(P);
       __hubEnter();CFG.xfPix=1;P.cosAll=1;P.cosOutfit='outskeleton';P.cosHat='none';P.cosCut='crop';
       __station('mirror','KeyE');renderAvatar('appavatar','appavatarpicker');
       md=document.getElementById('appearmodal');pk=document.getElementById('appavatarpicker');
       if(!md.classList.contains('pixfashion'))return 'pixel fashion has no dedicated presentation';
       // v28.xx (cw-cx-pixrackfit): Chrome quantizes line widths at the inherited menu zoom; compare with a real 2px reference in this same pane.
       probe=document.createElement('i');probe.style.cssText='position:fixed;left:-10000px;top:0;width:8px;height:8px';
       probe.style.setProperty('border','2px solid var(--acc)','important');probe.style.setProperty('outline','2px solid var(--acc)','important');pk.appendChild(probe);
       var ref=getComputedStyle(probe),borderMin=parseFloat(ref.borderLeftWidth),outlineMin=parseFloat(ref.outlineWidth);probe.remove();probe=null;
       if(!(borderMin>0&&outlineMin>0))return 'could not measure the menu-zoom line reference';
       var set=pk.querySelector('[data-pixkind="set"][data-pixid="skeleton"]'),cs=getComputedStyle(set);
       if(set.getAttribute('aria-pressed')!=='true'||!lime(cs.borderLeftColor)||cs.borderLeftStyle==='none'||parseFloat(cs.borderLeftWidth)+.02<borderMin)fail('worn skeleton lacks its lime selected border: '+cs.borderLeftColor+' '+cs.borderLeftStyle+' '+cs.borderLeftWidth+', reference '+borderMin);
       if(!lime(getComputedStyle(set.querySelector('.cosreq')).color))fail('worn label is not lime');
       var hood=pk.querySelector('[data-pixid="hood"]');padSetFocus(hood);cs=getComputedStyle(hood);
       if(!lime(cs.outlineColor)||parseFloat(cs.outlineWidth)+.02<outlineMin||cs.outlineStyle==='none')fail('pad cursor is invisible: '+cs.outlineColor+' '+cs.outlineStyle+' '+cs.outlineWidth+', reference '+outlineMin);
       var bounds=pk.getBoundingClientRect(),tiles=pk.querySelectorAll('[data-pixid]'),height=0;
       if(tiles.length!==13)fail('thirteen wardrobe controls are missing');
       for(var i=0;i<tiles.length;i++){
         var r=tiles[i].getBoundingClientRect();if(r.top<bounds.top-1||r.bottom>bounds.bottom+1)fail('rack tile outside visible picker: '+tiles[i].getAttribute('data-pixid'));
         if(!height)height=r.height;else if(Math.abs(r.height-height)>1)fail('unequal tile heights');
         if(parseFloat(getComputedStyle(tiles[i].querySelector('.cosreq')).fontSize)<16)fail('small tile status');
       }
       if(getComputedStyle(document.getElementById('apptabs')).display!=='none')fail('empty tab strip still takes space');
       if(getComputedStyle(md.querySelector('.msub')).display!=='none')fail('fashion explanation still visible');
       var zoom=parseFloat(getComputedStyle(md).zoom)||1,saves=md.querySelectorAll('[data-looksave]');for(i=0;i<saves.length;i++){cs=getComputedStyle(saves[i]);if(parseFloat(cs.fontSize)<16||saves[i].getBoundingClientRect().height<47*zoom)fail('saved look button too small');}
       var cv=document.getElementById('avcv');if(cv.width!==320||cv.height!==320)fail('pixel turntable backing size is not 320 square');
       for(i=0;i<16;i++){pixFrame();drawAvatarCanvas();}
       CFG.xfPix=0;renderAvatar('appavatar','appavatarpicker');if(md.classList.contains('pixfashion'))fail('pixel-only styling leaked into the legacy wardrobe');
       return bad.length?bad.join('; '):null;
     }finally{if(probe)probe.remove();try{padSetFocus(null);__endRaid('abandon');}catch(e){}__topClear();__resetCfg();__cleanProfile();if(oldP)P=JSON.parse(oldP);CFG.xfPix=cfg;}
   }},
  {v:'33.91',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
