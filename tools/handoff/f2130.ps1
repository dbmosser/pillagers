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

if ($s.Contains("  {v:'21.30',what:")) { throw "check 21.30 is in the fixture already" }

SubRx @'
  {v:'21.29',what:
'@ @'
  {v:'21.30',what:'the Undercroft key line (WASD WALK, E USE STATION) is not painted under an open station window, where it showed in the strip below the frame, and is back when the window closes',
   run:function(){
     if(!window.__hubEnter||!window.__station) return 'SKIP: this fixture cannot open a station';
     if(typeof drawHubHUD!=='function'||typeof hubWinOn!=='function') return 'SKIP: no floor HUD in this build';
     if(typeof ctx==='undefined'||!ctx) return 'SKIP: no HUD canvas here';
     if(typeof G!=='undefined'&&G&&G.sim) return 'SKIP: a sim is running';
     var bad=[], got=[], realFill=null, ownFill=false, nd=['USE',' STA','TION'].join(''), keep=null, t, md, n0, n1, n2;
     var wn0=(typeof WNSEEN!=='undefined')?WNSEEN:null, curWas=(typeof _curNow!=='undefined')?_curNow:null, cursorWas=null;
     try{ cursorWas=cv.style.cursor; }catch(_cw){}
     function shut(){ var a=document.querySelectorAll('.modal.on'), k; for(k=0;k<a.length;k++) a[k].classList.remove('on'); }
     function count(){ var k, n=0; for(k=0;k<got.length;k++) if(got[k].indexOf(nd)>=0) n++; return n; }
     function frame(){ got=[]; drawHubHUD(0,0); return count(); }
     try{
       __topClear(); __runPrep(); __cleanProfile();
       t=document.getElementById('title'); if(t) t.classList.remove('on');
       __hubEnter(); shut();   // a fresh profile opens the welcome window
       if(typeof state==='undefined'||state!=='hub'||!HB) return 'SKIP: the Undercroft floor did not open';
       keep={near:HB.near,legend:HB.legend}; HB.near=null; HB.legend=false;
       if(wn0!==null) WNSEEN=1;
       ownFill=Object.prototype.hasOwnProperty.call(ctx,'fillText'); realFill=ctx.fillText;
       ctx.fillText=function(s){ got.push(String(s)); return realFill.apply(this,arguments); };
       n0=frame();
       if(!n0) return 'SKIP: the key line was not drawn on the open floor here';
       __station('trader','KeyE');
       md=document.getElementById('tradermodal');
       if(!md||!md.classList.contains('on')||!hubWinOn()) return 'SKIP: the shop window did not open';
       n1=frame();
       if(n1) bad.push('with the shop window open the floor still paints its key line ('+n1+' time'+(n1===1?'':'s')+'), which shows in the strip under the window frame');
       shut();
       n2=frame();
       if(!n2) bad.push('the key line did not come back when the window closed');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(realFill){ if(ownFill) ctx.fillText=realFill; else delete ctx.fillText; } }catch(_f){}
       try{ if(keep&&HB){ HB.near=keep.near; HB.legend=keep.legend; } }catch(_h){}
       try{ if(wn0!==null) WNSEEN=wn0; }catch(_w){}
       try{ if(curWas!==null) _curNow=curWas; if(cursorWas!==null) cv.style.cursor=cursorWas; }catch(_cu){}
       shut(); __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'21.29',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
