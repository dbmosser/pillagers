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

if ($s.Contains("  {v:'21.42',what:")) { throw "check 21.42 is in the fixture already" }

SubRx @'
  {v:'21.41',what:
'@ @'
  {v:'21.42',what:'the Undercroft floor belt is centred on the screen like the key line above it, not pushed right by the raid corner blocks the floor never draws, and the belt under the open Undercroft backpack matches it',
   run:function(){
     if(!window.__hubEnter) return 'SKIP: this fixture cannot reach the Undercroft floor';
     if(typeof drawHubBelt!=='function'||typeof drawHubBag!=='function'||typeof hubBagState!=='function'||typeof HUBBELT!=='object'||!HUBBELT) return 'SKIP: no floor belt in this build';
     if(typeof ctx==='undefined'||!ctx) return 'SKIP: no HUD canvas here';
     if(typeof G!=='undefined'&&G&&G.sim) return 'SKIP: a sim is running';
     if(!(W>=640&&H>=480)) return 'SKIP: the canvas is '+W+'x'+H+' here, too small to lay out the floor belt';
     var bad=[], cells0=HUBBELT.cells, hadHB=Object.prototype.hasOwnProperty.call(CFG,'hubBelt'), hb0=CFG.hubBelt, bg0=hubBagG, bo0=hubBagOpen, m, hc;
     var curWas=(typeof _curNow!=='undefined')?_curNow:null, cursorWas=null;
     try{ cursorWas=cv.style.cursor; }catch(_cw){}
     function span(c){ var l=1e9, r=-1e9, i; for(i=0;i<c.length;i++){ if(!c[i]||!isFinite(c[i].x)||!isFinite(c[i].w)) continue; l=Math.min(l,c[i].x); r=Math.max(r,c[i].x+c[i].w); } return {l:l,r:r,m:(l+r)/2}; }
     try{
       __topClear(); __cleanProfile(); __hubEnter();
       if(typeof state==='undefined'||state!=='hub'||!HB) return 'SKIP: the Undercroft floor did not open';
       [].forEach.call(document.querySelectorAll('.modal.on'),function(x){ x.classList.remove('on'); });   // a fresh profile opens the welcome window
       if(typeof hubWinOn==='function'&&hubWinOn()) return 'SKIP: a window stayed open over the floor';
       CFG.hubBelt=1; HUBBELT.cells=[]; drawHubBelt();
       if(!HUBBELT.cells||HUBBELT.cells.length<2) return 'SKIP: the floor belt drew no keys here';
       m=span(HUBBELT.cells);
       if(Math.abs(m.m-W/2)>2) bad.push('the floor belt is centred at x '+Math.round(m.m)+', '+Math.round(m.m-W/2)+' px off the middle of a '+W+' wide screen, where the key line and the station prompt are centred');
       if(m.l<0||m.r>W) bad.push('the floor belt runs off the screen ('+Math.round(m.l)+' to '+Math.round(m.r)+')');
       hubBagG=hubBagState(); drawHubBag(); hc=(hubBagG&&hubBagG.hotCells)||[];
       if(hc.length>1){ m=span(hc); if(Math.abs(m.m-W/2)>2) bad.push('with the Undercroft backpack open the belt is centred at x '+Math.round(m.m)+', '+Math.round(m.m-W/2)+' px off the middle, under a backpack that is centred'); }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       hubBagG=bg0; hubBagOpen=bo0;
       try{ if(hadHB) CFG.hubBelt=hb0; else delete CFG.hubBelt; }catch(_c){}
       HUBBELT.cells=cells0;
       try{ ctx.clearRect(0,0,W,H); }catch(_x){}
       try{ if(curWas!==null) _curNow=curWas; if(cursorWas!==null) cv.style.cursor=cursorWas; }catch(_cu){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'21.41',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
