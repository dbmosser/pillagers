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

if ($s.Contains("  {v:'33.11',what:")) { throw "check 33.11 is in the fixture already" }

SubRx @'
  {v:'33.10',what:
'@ @'
  {v:'33.11',what:'all six layout selectors use matching idle button edges, neutral focused name text and a bright counter 16px after the arrow',
   run:function(){
     var saved=P,oldSave=saveProfile,oldPad=KEYS.pad,km,oldStyle,bad=[];
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();
       P=JSON.parse(JSON.stringify(P));saveProfile=function(){};keysOpen(true);km=document.getElementById('keysmodal');oldStyle=km.getAttribute('style');
       for(var size=0;size<2;size++){
         km.style.setProperty('width',(size?3840:1920)+'px','important');km.style.setProperty('height',(size?2160:1080)+'px','important');
         km.style.setProperty('box-sizing','border-box','important');km.style.setProperty('max-width','none','important');km.style.setProperty('max-height','none','important');
         for(var i=0;i<6;i++){
           padPresetApply(i);padListFit();var name=document.getElementById('padlayout');padSetFocus(name);UIM.step(1000);
           var prev=document.getElementById('padlayoutprev'),next=document.getElementById('padlayoutnext'),counter=km.querySelector('.padlayoutcount');
           var n=getComputedStyle(name),a=getComputedStyle(prev),b=getComputedStyle(next),c=getComputedStyle(counter),tag=(size?'4k ':'1080p ')+PAD_PRESETS[i].name;
           if(n.borderTopStyle!=='solid'||!(parseFloat(n.borderTopWidth)>0)||n.borderTopColor!==a.borderTopColor||n.borderTopColor!==b.borderTopColor)bad.push(tag+' mismatched name/arrow edges');
           if(n.borderRadius!==a.borderRadius||a.borderRadius!==b.borderRadius)bad.push(tag+' mismatched corners');
           if(name.offsetHeight!==prev.offsetHeight||name.offsetHeight!==next.offsetHeight)bad.push(tag+' mismatched button heights');
           // v28.xx (cw-cx-padselectorstyle): resolve the shared text token in the actual page cascade, then compare the real controls.
           var sample=document.createElement('span');sample.style.color='var(--tx-1)';km.appendChild(sample);var ink=getComputedStyle(sample).color;sample.remove();
           if(n.color!==ink||c.color!==ink)bad.push(tag+' dim counter or lime name text');
           var cr=counter.getBoundingClientRect(),nr=next.getBoundingClientRect(),z=nr.width/next.offsetWidth;
           if(Math.abs((cr.left-nr.right)/z-16)>1)bad.push(tag+' counter gap is not 16px');
         }
       }
       return bad.length?bad.join('; '):null;
     }finally{
       UIM.unfocus();if(km){km.classList.remove('on');if(oldStyle===null)km.removeAttribute('style');else km.setAttribute('style',oldStyle);}
       PAD.focus=null;PAD.focusMd=null;KEYS.pad=oldPad;try{__endRaid('abandon');}catch(e){}__topClear();P=saved;saveProfile=oldSave;
     }
   }},
  {v:'33.10',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
