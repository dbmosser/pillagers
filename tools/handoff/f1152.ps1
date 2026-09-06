$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# v11.52 CHECK, inserted before the v11.51 entry. The pane is hidden while the
# corpus runs, so the frame loop does not fire; saveProfile is the path the
# check relies on, and it is the path every credit or XP change already takes.
SubRx @'
  {v:'11.51',what:'the two baked sector-facts lines are exact-only: the line with its own figures still maps to his wording, and a sector line with other figures is left as the game drew it instead of being rewritten by digit shape into the other map name',
'@ @'
  {v:'11.52',what:'credits and XP are shown at all times in the upper right corner, in the Undercroft and in a raid, above the screens and clear of the CONDITIONS box, and the readout follows the profile when a figure changes',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__frame&&window.__P&&window.__hubEnter)) return 'SKIP: this fixture cannot deploy and read the screen';
     var el=document.getElementById('topright');
     if(!el) return 'there is no credits and XP readout in the upper right corner';
     var bad=[], prof, keepC, keepX;
     function rect(){ var r=el.getBoundingClientRect(); return {l:r.left,t:r.top,r:r.right,b:r.bottom,w:r.width,h:r.height}; }
     function shown(where){
       var cs=getComputedStyle(el), r=rect();
       if(cs.display==='none'||cs.visibility==='hidden'||parseFloat(cs.opacity)===0) bad.push(where+': the readout is hidden');
       if(!(r.w>40&&r.h>10)) bad.push(where+': the readout has no size ('+Math.round(r.w)+'x'+Math.round(r.h)+')');
       if(!(r.r<=innerWidth+1&&r.r>=innerWidth-48)) bad.push(where+': the readout is not at the right edge (right '+Math.round(r.r)+' of '+innerWidth+')');
       if(!(r.t>=0&&r.t<=40)) bad.push(where+': the readout is not at the top (top '+Math.round(r.t)+')');
       var t=(el.textContent||'').replace(/\s+/g,' ');
       var c=(prof.credits||0).toLocaleString(), x=(prof.xp||0).toLocaleString();
       if(t.indexOf(c)<0) bad.push(where+': the readout does not show the credits '+c+' ("'+t+'")');
       if(t.indexOf(x)<0) bad.push(where+': the readout does not show the XP '+x+' ("'+t+'")');
       if(!/CREDITS/i.test(t)||!/\bXP\b/.test(t)) bad.push(where+': the readout does not say which figure is which ("'+t+'")');
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       prof=__P(); keepC=prof.credits; keepX=prof.xp;
       // DISTINCTIVE figures no fresh profile carries.
       prof.credits=4471337; prof.xp=98761; saveProfile();
       try{ __hubEnter(); }catch(_h){}
       shown('in the Undercroft');
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       __frame(); __frame();
       prof=__P(); prof.credits=4471337; prof.xp=98761; saveProfile();
       shown('in a raid');
       // CLEAR OF THE CONDITIONS BOX, in screen space: that box is drawn zoomed
       // about the top right corner, so its top in pixels is y times its zoom.
       var HB=(typeof HUDBOX!=='undefined')?HUDBOX.cond:null, r=rect();
       if(!HB) bad.push('control: the CONDITIONS box was not drawn, so the clearance cannot be measured');
       else {
         var cz=1; try{ cz=(HUDZ.cond||1)*hudRes()*hudUserZ('cond'); }catch(_z){ cz=1; }
         var condTop=HB.y*cz;
         if(r.b>condTop+1) bad.push('in a raid the readout reaches down to '+Math.round(r.b)+' while the CONDITIONS box starts at '+Math.round(condTop)+', so the two overlap');
       }
       // IT FOLLOWS A CHANGE.
       prof.credits=1234567; saveProfile();
       var t2=(el.textContent||'').replace(/\s+/g,' ');
       if(t2.indexOf((1234567).toLocaleString())<0) bad.push('after the credits changed the readout still says "'+t2+'"');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var pf=__P(); pf.credits=keepC; pf.xp=keepX; saveProfile(); }catch(_r){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'11.51',what:'the two baked sector-facts lines are exact-only: the line with its own figures still maps to his wording, and a sector line with other figures is left as the game drew it instead of being rewritten by digit shape into the other map name',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
