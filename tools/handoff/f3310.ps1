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

if ($s.Contains("  {v:'33.10',what:")) { throw "check 33.10 is in the fixture already" }

SubRx @'
  {v:'33.09',what:
'@ @'
  {v:'33.10',what:'pad selector has boxed centred arrows on each side of the name and a readable counter after the next arrow on all six layouts',
   run:function(){
     var saved=P,oldSave=saveProfile,oldPad=KEYS.pad,km,oldStyle,bad=[];
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();
       P=JSON.parse(JSON.stringify(P));saveProfile=function(){};keysOpen(true);km=document.getElementById('keysmodal');oldStyle=km.getAttribute('style');
       for(var size=0;size<2;size++){
         km.style.setProperty('width',(size?3840:1920)+'px','important');km.style.setProperty('height',(size?2160:1080)+'px','important');
         km.style.setProperty('box-sizing','border-box','important');km.style.setProperty('max-width','none','important');km.style.setProperty('max-height','none','important');
         for(var i=0;i<6;i++){
           padPresetApply(i);padListFit();padSetFocus(document.getElementById('padlayout'));UIM.step(1000);
           var tag=(size?'4k ':'1080p ')+PAD_PRESETS[i].name;
           var prev=document.getElementById('padlayoutprev'),next=document.getElementById('padlayoutnext'),name=document.getElementById('padlayout'),counter=km.querySelector('.padlayoutcount');
           var pr=prev.getBoundingClientRect(),nr=next.getBoundingClientRect(),lr=name.getBoundingClientRect(),cr=counter.getBoundingClientRect();
           if(pr.right>=lr.left||lr.right>=nr.left||nr.right>=cr.left)bad.push(tag+' incorrect stepper order or overlap');
           if(Math.abs((lr.left-pr.right)-(nr.left-lr.right))>2)bad.push(tag+' asymmetric arrow spacing');
           [prev,next].forEach(function(e){var cs=getComputedStyle(e),r=e.getBoundingClientRect();
             if(cs.borderTopStyle!=='solid'||!(parseFloat(cs.borderTopWidth)>0)||cs.borderTopColor==='transparent')bad.push(tag+' arrow has no box');
             if(e.offsetWidth<56||e.offsetHeight<48||cs.alignItems!=='center'||cs.justifyContent!=='center')bad.push(tag+' arrow target or alignment');
             if(Math.abs((r.top+r.bottom)-(lr.top+lr.bottom))>2)bad.push(tag+' arrow off centre');
           });
           var cc=getComputedStyle(counter),label=getComputedStyle(km.querySelector('.padlayoutrow > b'));
           if(parseFloat(cc.fontSize)<20||parseFloat(label.fontSize)<18)bad.push(tag+' small counter or label');
           if(Math.abs((cr.top+cr.bottom)-(lr.top+lr.bottom))>2)bad.push(tag+' counter off centre');
         }
       }
       return bad.length?bad.join('; '):null;
     }finally{
       UIM.unfocus();if(km){km.classList.remove('on');if(oldStyle===null)km.removeAttribute('style');else km.setAttribute('style',oldStyle);}
       PAD.focus=null;PAD.focusMd=null;KEYS.pad=oldPad;try{__endRaid('abandon');}catch(e){}__topClear();P=saved;saveProfile=oldSave;
     }
   }},
  {v:'33.09',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
