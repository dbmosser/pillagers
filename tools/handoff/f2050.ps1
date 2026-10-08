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

if ($s.Contains("  {v:'20.50',what:")) { throw "check 20.50 is in the fixture already" }

SubRx @'
  {v:'20.49',what:
'@ @'
  {v:'20.50',what:'the Undercroft station prompt and the TAKE prompt sit above the floor belt: with the belt on, the [E] station line, the line under it and [E] TAKE beside a dropped crate are drawn above the top of the belt keys and above the key footer, and with the belt off the station prompt still sits along the bottom of the screen',
   run:function(){
     if(!window.__hubEnter) return 'SKIP: this fixture cannot reach the Undercroft floor';
     if(typeof drawHubHUD!=='function'||typeof drawHubBelt!=='function'||typeof hubFootY!=='function'||typeof HUBBELT!=='object'||!HUBBELT||typeof keyLabel!=='function') return 'SKIP: no floor HUD or floor belt in this build';
     if(typeof ctx==='undefined'||!ctx) return 'SKIP: no HUD canvas here';
     if(typeof G!=='undefined'&&G&&G.sim) return 'SKIP: a sim is running';
     if(!(W>=640&&H>=480)) return 'SKIP: the canvas is '+W+'x'+H+' here, too small to lay out the floor belt';
     var bad=[], got=[], realFill=null, ownFill=false, keep=null, cells0=HUBBELT.cells, hadHB=Object.prototype.hasOwnProperty.call(CFG,'hubBelt'), hb0=CFG.hubBelt;
     var curWas=(typeof _curNow!=='undefined')?_curNow:null, cursorWas=null, st=null, ik=null, i, ks, E, top, fy, Lf, r=[], ix, tk;
     try{ cursorWas=cv.style.cursor; }catch(_cw){}
     function frame(){ got=[]; drawHubHUD(0,0); return got; }
     function find(list,t){ for(var j=0;j<list.length;j++) if(list[j].t===t) return j; return -1; }
     try{
       __topClear(); __cleanProfile(); __hubEnter();
       if(typeof state==='undefined'||state!=='hub'||!HB||!HB.player||!HB.stations||!HB.stations.length) return 'SKIP: the Undercroft floor did not open with its stations';
       [].forEach.call(document.querySelectorAll('.modal.on'),function(x){ x.classList.remove('on'); });   // a fresh profile opens the welcome window
       keep={near:HB.near,nearDrop:HB.nearDrop,legend:HB.legend};
       for(i=0;i<HB.stations.length;i++) if(HB.stations[i]&&HB.stations[i].label&&HB.stations[i].sub!==undefined){ st=HB.stations[i]; break; }
       if(!st) return 'SKIP: no station with a prompt here';
       ks=Object.keys(ITEMS); for(i=0;i<ks.length;i++) if(ITEMS[ks[i]]&&ITEMS[ks[i]].name){ ik=ks[i]; break; }
       if(!ik) return 'SKIP: no item to drop here';
       ownFill=Object.prototype.hasOwnProperty.call(ctx,'fillText');
       realFill=ctx.fillText;
       ctx.fillText=function(t,x,y){ got.push({t:String(t),y:y}); return realFill.apply(this,arguments); };
       E='['+keyLabel('KeyE','E')+']';
       HB.legend=false;
       // The belt on, as it is by default, drawn once so its keys are where the floor HUD reads them.
       CFG.hubBelt=1; drawHubBelt();
       if(!HUBBELT.cells||!HUBBELT.cells.length) return 'SKIP: the floor belt drew no keys here';
       top=H; for(i=0;i<HUBBELT.cells.length;i++) if(isFinite(HUBBELT.cells[i].y)) top=Math.min(top,HUBBELT.cells[i].y);
       fy=hubFootY();
       // A station in front of him.
       HB.near=st; HB.nearDrop=null;
       Lf=frame(); ix=find(Lf,E+'  '+st.label);
       if(ix<0) return 'SKIP: the station prompt was not drawn here';
       r.push({n:'the '+E+' '+st.label+' line',y:Lf[ix].y});
       r.push({n:'the station line under it',y:(Lf[ix+1]?Lf[ix+1].y:NaN)});
       // A dropped crate in front of him instead, as the floor picks one or the other.
       HB.near=null; HB.nearDrop={k:ik,x:HB.player.x,y:HB.player.y};
       Lf=frame(); tk=-1; for(i=0;i<Lf.length;i++) if(Lf[i].t.indexOf(E+' TAKE ')===0){ tk=i; break; }
       if(tk<0) bad.push('the TAKE prompt was not drawn beside a dropped crate');
       else r.push({n:'the '+E+' TAKE line',y:Lf[tk].y});
       for(i=0;i<r.length;i++){
         if(!(r[i].y<top-2)) bad.push(r[i].n+' is drawn at y '+Math.round(r[i].y)+', under the floor belt that starts at y '+Math.round(top)+' on a '+W+'x'+H+' screen');
         else if(!(r[i].y<fy)) bad.push(r[i].n+' is drawn at y '+Math.round(r[i].y)+', on the key footer at y '+Math.round(fy));
         if(!(r[i].y>H*0.5)) bad.push(r[i].n+' left the bottom of the screen (y '+Math.round(r[i].y)+')');
       }
       // CONTROL: with the belt off the station prompt still sits along the bottom of the screen.
       CFG.hubBelt=0; drawHubBelt();
       HB.near=st; HB.nearDrop=null;
       Lf=frame(); ix=find(Lf,E+'  '+st.label);
       if(ix<0||!(Lf[ix].y>H*0.85&&Lf[ix].y<H-16)) bad.push('with the floor belt off the station prompt is at y '+(ix<0?'nowhere':Math.round(Lf[ix].y))+' rather than along the bottom of the screen');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(realFill){ if(ownFill) ctx.fillText=realFill; else delete ctx.fillText; } }catch(_f){}
       try{ if(hadHB) CFG.hubBelt=hb0; else delete CFG.hubBelt; }catch(_c){}
       HUBBELT.cells=cells0;
       try{ if(keep&&HB){ HB.near=keep.near; HB.nearDrop=keep.nearDrop; HB.legend=keep.legend; } }catch(_h){}
       try{ if(curWas!==null) _curNow=curWas; if(cursorWas!==null) cv.style.cursor=cursorWas; }catch(_cu){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'20.49',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
