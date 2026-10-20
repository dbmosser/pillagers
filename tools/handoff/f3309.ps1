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

if ($s.Contains("  {v:'33.09',what:")) { throw "check 33.09 is in the fixture already" }

SubRx @'
  {v:'33.08',what:
'@ @'
  {v:'33.09',what:'all six pad selectors keep arrows, name and counter clear at 1080p and 4k, with one focus outline for pad and keys',
   run:function(){
     var saved=P,oldSave=saveProfile,oldPad=KEYS.pad,km,oldStyle,bad=[];
     function hit(a,b){return a.left<b.right-0.1&&a.right>b.left+0.1&&a.top<b.bottom-0.1&&a.bottom>b.top+0.1;}
     function visible(e){if(!e)return false;var c=getComputedStyle(e);return c.display!=='none'&&c.visibility!=='hidden'&&parseFloat(c.opacity)!==0;}
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();
       P=JSON.parse(JSON.stringify(P));saveProfile=function(){};keysOpen(true);
       km=document.getElementById('keysmodal');oldStyle=km.getAttribute('style');
       for(var size=0;size<2;size++){
         km.style.setProperty('width',(size?3840:1920)+'px','important');km.style.setProperty('height',(size?2160:1080)+'px','important');
         km.style.setProperty('box-sizing','border-box','important');km.style.setProperty('max-width','none','important');km.style.setProperty('max-height','none','important');
         for(var i=0;i<6;i++){
           padPresetApply(i);padListFit();
           var picker=km.querySelector('.padlayoutpick'),ids=['padlayoutprev','padlayout','padlayoutnext'];
           for(var mode=0;mode<2;mode++)for(var f=0;f<3;f++){
             var target=document.getElementById(ids[f]);
             if(mode===0){if(document.activeElement&&document.activeElement.blur)document.activeElement.blur();padSetFocus(target);}
             else{var pf=km.querySelector('.padfocus');if(pf)pf.classList.remove('padfocus');PAD.focus=null;UIM.unfocus();target.focus();}
             // v28.xx (cw-cx-padselector): settle real 1.05 focus growth and the moving ring before measuring.
             UIM.step(1000);
             var tag=(size?'4k ':'1080p ')+PAD_PRESETS[i].name+' '+(mode?'keys ':'pad ')+ids[f];
             var parts=ids.map(function(id){return document.getElementById(id);});parts.push(picker.querySelector('.padlayoutcount'));
             var r=parts.map(function(e){return e.getBoundingClientRect();}),pc=picker.getBoundingClientRect();
             for(var a=0;a<r.length;a++){
               if(!r[a].width||!r[a].height||r[a].left<pc.left-0.1||r[a].right>pc.right+0.1)bad.push(tag+' hidden or clipped part '+a);
               for(var b=a+1;b<r.length;b++)if(hit(r[a],r[b]))bad.push(tag+' overlapping parts '+a+'/'+b);
             }
             if(Math.abs(r[0].top-r[2].top)>4||Math.abs((r[1].top+r[1].bottom)-(r[0].top+r[0].bottom))>4)bad.push(tag+' picker is not one row');
             if(parts[1].scrollWidth>parts[1].clientWidth)bad.push(tag+' layout name clipped');
             if(parts[3].textContent!==(i+1)+' / 6')bad.push(tag+' wrong counter');
             var cs=getComputedStyle(target),rings=0;
             if(cs.outlineStyle!=='none'&&parseFloat(cs.outlineWidth)>0)rings++;
             if(cs.boxShadow!=='none')bad.push(tag+' extra focus shadow');
             // v28.xx (cw-cx-padselector): menu zoom rounds computed outline widths; require one visible ring, not exact CSS pixels.
             if(rings!==1||parseFloat(cs.outlineWidth)<2)bad.push(tag+' missing single focus outline: '+cs.outlineStyle+' '+cs.outlineWidth);
             var scale=r[f].width/target.offsetWidth,reach=(parseFloat(cs.outlineWidth)+parseFloat(cs.outlineOffset))*scale;
             var ring={left:r[f].left-reach,right:r[f].right+reach,top:r[f].top-reach,bottom:r[f].bottom+reach};
             for(a=0;a<r.length;a++)if(a!==f&&hit(ring,r[a]))bad.push(tag+' focus ring touches part '+a);
             var group=getComputedStyle(picker);
             if(group.boxShadow!=='none'||(parseFloat(group.borderTopWidth)>0&&group.borderTopColor!=='transparent'&&!/rgba\([^)]*,\s*0\)$/.test(group.borderTopColor)))bad.push(tag+' second group ring');
             if(visible(UIM.ring))bad.push(tag+' second moving ring');
           }
         }
       }
       return bad.length?bad.slice(0,16).join('; '):null;
     }finally{
       if(document.activeElement&&document.activeElement.blur)document.activeElement.blur();UIM.unfocus();
       if(km){km.classList.remove('on');if(oldStyle===null)km.removeAttribute('style');else km.setAttribute('style',oldStyle);}
       PAD.focus=null;PAD.focusMd=null;KEYS.pad=oldPad;
       try{__endRaid('abandon');}catch(e){}__topClear();P=saved;saveProfile=oldSave;
     }
   }},
  {v:'33.08',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
