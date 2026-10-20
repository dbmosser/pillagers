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

if ($s.Contains("  {v:'32.83',what:")) { throw "check 32.83 is in the fixture already" }

SubRx @'
  {v:'32.82',what:
'@ @'
  {v:'32.83',what:'all six pad layouts keep the counter outside the focus ring and d-right clear of every controller line at 1080p and 4k',
   run:function(){
     var saved=P, oldSave=saveProfile, oldPad=KEYS.pad, km, oldStyle, bad=[];
     function hit(a,b){return a.left<b.right&&a.right>b.left&&a.top<b.bottom&&a.bottom>b.top;}
     function lineHit(label,el){
       var c=getComputedStyle(el), sw=parseFloat(c.strokeWidth)||0;
       if(c.stroke==='none'||!sw) return false;
       var len=el.getTotalLength(), m=el.getScreenCTM(), step=0.5, p=el.getPointAtLength(0);
       var x=m.a*p.x+m.c*p.y+m.e, y=m.b*p.x+m.d*p.y+m.f;
       var px=sw*0.5*(Math.abs(m.a)+Math.abs(m.c)), py=sw*0.5*(Math.abs(m.b)+Math.abs(m.d));
       for(var s=step;s<len+step;s+=step){
         p=el.getPointAtLength(Math.min(s,len));
         var nx=m.a*p.x+m.c*p.y+m.e, ny=m.b*p.x+m.d*p.y+m.f;
         if(hit(label,{left:Math.min(x,nx)-px,right:Math.max(x,nx)+px,top:Math.min(y,ny)-py,bottom:Math.max(y,ny)+py})) return true;
         x=nx;y=ny;
       }
       return false;
     }
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();
       P=JSON.parse(JSON.stringify(P));saveProfile=function(){};keysOpen(true);
       km=document.getElementById('keysmodal');oldStyle=km.getAttribute('style');
       // v28.xx (cw-cx-padcardgaps): exercise the card at both target sizes without resizing the shared gate browser.
       for(var size=0;size<2;size++){
         km.style.setProperty('width',(size?3840:1920)+'px','important');
         km.style.setProperty('height',(size?2160:1080)+'px','important');
         km.style.setProperty('box-sizing','border-box','important');
         km.style.setProperty('max-width','none','important');km.style.setProperty('max-height','none','important');
         for(var i=0;i<6;i++){
           padPresetApply(i);padListFit();var name=document.getElementById('padlayout');padSetFocus(name);
           var r=name.getBoundingClientRect(), c=km.querySelector('.padlayoutcount').getBoundingClientRect();
           var cs=getComputedStyle(name), outline=(parseFloat(cs.outlineWidth)||0)+(parseFloat(cs.outlineOffset)||0), spread=0;
           // v28.xx (cw-cx-padcardgaps): include the outer shadow and outline using the computed focus style.
           cs.boxShadow.split(/,(?![^()]*\))/).forEach(function(sh){
             if(/inset/.test(sh)) return;
             var n=sh.replace(/rgba?\([^)]*\)/g,'').match(/-?[\d.]+px/g)||[];
             if(n.length>=4) spread=Math.max(spread,parseFloat(n[3])+Math.max(Math.abs(parseFloat(n[0])),Math.abs(parseFloat(n[1]))));
           });
           var reach=Math.max(outline,spread)*(r.width/name.offsetWidth);
           var ring={left:r.left-reach,right:r.right+reach,top:r.top-reach,bottom:r.bottom+reach};
           var tag=(size?'4k ':'1080p ')+PAD_PRESETS[i].name;
           if(!c.width||!r.width) bad.push(tag+' hidden picker');
           else if(hit(c,ring)) bad.push(tag+' counter intersects focus ring');
           var text=km.querySelector('[data-pad-node="15"]'), label=text.getBoundingClientRect();
           var lines=km.querySelectorAll('.padpicture svg path,.padpicture svg rect,.padpicture svg circle');
           if(!label.width||!lines.length) bad.push(tag+' missing drawing');
           for(var j=0;j<lines.length;j++) if(lineHit(label,lines[j])){bad.push(tag+' d-right intersects controller line '+j);break;}
           var nodes=km.querySelectorAll('.padpicture svg text');
           for(j=0;j<nodes.length;j++) if(nodes[j]!==text&&hit(label,nodes[j].getBoundingClientRect())) bad.push(tag+' d-right touches another label');
         }
       }
       return bad.length?bad.join('; '):null;
     }finally{
       if(km){km.classList.remove('on');if(oldStyle===null) km.removeAttribute('style');else km.setAttribute('style',oldStyle);}
       PAD.focus=null;PAD.focusMd=null;KEYS.pad=oldPad;
       try{__endRaid('abandon');}catch(e){}__topClear();P=saved;saveProfile=oldSave;
     }
   }},
  {v:'32.82',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
