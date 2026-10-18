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

if ($s.Contains("  {v:'29.50',what:")) { throw "check 29.50 is in the fixture already" }

SubRx @'
  {v:'29.49',what:
'@ @'
  {v:'29.50',what:'the item wheel opens on the Undercroft floor on a held Q, draws its ring, picks nothing to use, and closes on release with one line (his order 2026-10-15)',
   run:function(){
     if(!window.__hubEnter) return 'SKIP: this fixture cannot reach the Undercroft floor';
     if(typeof ctx==='undefined'||!ctx) return 'SKIP: no HUD canvas here';
     if(!(W>=640&&H>=480)) return 'SKIP: the canvas is too small';
     if(typeof G!=='undefined'&&G&&G.sim) return 'SKIP: a sim is running';
     if(typeof hubWheelOpen!=='function'||typeof HUBWHEEL==='undefined') return 'no hubWheelOpen: the wheel is not on the Undercroft floor';
     var bad=[], kit0=null, cap=[], proto=CanvasRenderingContext2D.prototype, oF=proto.fillText, oT=hubToast, toasts=[], ok;
     try{
       __topClear(); __cleanProfile(); __hubEnter();
       if(typeof state==='undefined'||state!=='hub'||!HB) return 'SKIP: the Undercroft floor did not open';
       [].forEach.call(document.querySelectorAll('.modal.on'),function(x){ x.classList.remove('on'); });
       if(typeof hubWinOn==='function'&&hubWinOn()) return 'SKIP: a window stayed open over the floor';
       if(titleOn()) return 'SKIP: the title is up';
       kit0=P.kit; P.kit=['bandage','medkit','frag'];
       hubToast=function(t){ toasts.push(String(t)); };
       keys={}; HUBWHEEL=null;
       window.dispatchEvent(new KeyboardEvent('keydown',{code:'KeyQ',key:'q',bubbles:true}));
       if(!HUBWHEEL) bad.push('a held Q on the floor did not open the wheel');
       else {
         hubWheelStep(0.05);
         if(!HUBWHEEL||HUBWHEEL.list.length!==8) bad.push('the wheel has '+(HUBWHEEL?HUBWHEEL.list.length:0)+' slots (want his 8)');
         proto.fillText=function(t){ cap.push(String(t)); return oF.apply(this,arguments); };
         try{ ctx.clearRect(0,0,W,H); hubWheelDraw(); } finally { proto.fillText=oF; }
         if(cap.join('|').indexOf('ITEMS')<0) bad.push('the wheel drew no ITEMS hub');
         if(cap.join('|').indexOf('RELEASE TO CLOSE')<0) bad.push('the wheel hint does not say it closes');
         HUBWHEEL.armed=1; HUBWHEEL.sel=0;
         window.dispatchEvent(new KeyboardEvent('keyup',{code:'KeyQ',key:'q',bubbles:true}));
         hubWheelStep(0.016);
         if(HUBWHEEL) bad.push('the wheel stayed open after Q came up');
         if(toasts.length!==1) bad.push('letting go on a slot gave '+toasts.length+' lines (want one)');
       }
       HUBWHEEL=null; keys={};
       hubBagOpen=true; ok=hubWheelOpen(); hubBagOpen=false;
       if(ok||HUBWHEEL) bad.push('the wheel opened over the open backpack');
       return bad.length?bad.join('; '):null;
     } catch(e){ return 'threw: '+(e&&e.message||e); }
     finally {
       proto.fillText=oF; hubToast=oT; HUBWHEEL=null; keys={};
       try{ if(kit0!==null) P.kit=kit0; }catch(_k){}
       try{ ctx.clearRect(0,0,W,H); }catch(_x){}
       __topClear();
     } }},
  {v:'29.49',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
