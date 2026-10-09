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

if ($s.Contains("  {v:'21.10',what:")) { throw "check 21.10 is in the fixture already" }

SubRx @'
  {v:'21.09',what:
'@ @'
  {v:'21.10',what:'the three names on the top row of the Undercroft sit on one line: the gambler name is drawn at the height of the lift and Mainframe names beside it',
   run:function(){
     if(!(window.__hubEnter&&window.__hubFrame&&window.__showScreen&&window.__wnseen)||typeof HB==='undefined') return 'SKIP: this fixture cannot draw the floor';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing renders';
     var bad=[], rec={}, proto=CanvasRenderingContext2D.prototype, oT=proto.fillText, ids=['lift','gamble','mf'], lab={}, ys=[], wn0=__wnseen(), i, st, yy;
     try{
       __topClear(); __runPrep();
       G=null; keys={}; __showScreen('hub'); __hubEnter();
       if(!HB||!HB.stations) return 'SKIP: the floor was not built';
       for(i=0;i<HB.stations.length;i++){ st=HB.stations[i]; if(st&&ids.indexOf(st.id)>=0) lab[st.id]=String(st.label); }
       for(i=0;i<ids.length;i++) if(!lab[ids[i]]) return 'SKIP: no '+ids[i]+' station on this floor';
       proto.fillText=function(t,x,y){ var m=this.getTransform(), k=String(t); if(!Object.prototype.hasOwnProperty.call(rec,k)) rec[k]=m.b*x+m.d*y+m.f; return oT.apply(this,arguments); };
       __wnseen(1); __hubFrame(0.016);
       proto.fillText=oT;
       for(i=0;i<ids.length;i++){ yy=rec[lab[ids[i]]]; if(typeof yy!=='number'||!isFinite(yy)) return 'SKIP: the name of the '+ids[i]+' station was not drawn'; ys.push(yy); }
       if(Math.abs(ys[1]-ys[0])>1||Math.abs(ys[1]-ys[2])>1) bad.push('the gambler name is drawn at y '+Math.round(ys[1])+' while the lift and Mainframe names beside it are at '+Math.round(ys[0])+' and '+Math.round(ys[2]));
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ proto.fillText=oT; __wnseen(wn0); __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'21.09',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
