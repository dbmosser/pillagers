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

if ($s.Contains("  {v:'22.00',what:")) { throw "check 22.00 is in the fixture already" }

SubRx @'
  {v:'21.99',what:
'@ @'
  {v:'22.00',what:'on a controller the sector map draws the right-stick marker cursor where the marker will land, and its header names R STICK and D-UP, not CLICK; the mouse header is unchanged',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof drawMapOverlay!=='function'||typeof mapProj!=='function'||typeof PAD!=='object'||!PAD) return 'SKIP: no raid or map here';
     var bad=[], g, arcs=[], txt=[], hadA=Object.prototype.hasOwnProperty.call(ctx,'arc'), oArc=ctx.arc, hadT=Object.prototype.hasOwnProperty.call(ctx,'fillText'), oTxt=ctx.fillText, pon=PAD.on, pbr=PAD.brand, M, cx, cy, ex, ey, hit, i;
     function at(){ var n=0, j; for(j=0;j<arcs.length;j++) if(Math.abs(arcs[j][0]-ex)<1.5&&Math.abs(arcs[j][1]-ey)<1.5) n++; return n; }
     try{
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       cx=g.player.x+((g.player.x+733.7<WORLD_W)?733.7:-733.7); cy=g.player.y+((g.player.y-419.3>0)?-419.3:419.3);
       g.mapOpen=true; g.mapCur={x:cx,y:cy};
       ctx.arc=function(x,y,r){ arcs.push([x,y,r]); return oArc.apply(this,arguments); };
       ctx.fillText=function(s){ txt.push(String(s)); return oTxt.apply(this,arguments); };
       PAD.on=true; PAD.brand='xbox';
       drawMapOverlay();
       M=mapProj(); ex=M.ox+cx*M.sc; ey=M.oy+cy*M.sc;
       if(!at()) bad.push('nothing was drawn at the controller map cursor ('+Math.round(ex)+','+Math.round(ey)+'); '+arcs.length+' rings on the map');
       if(txt.some(function(s){ return /CLICK/.test(s); })) bad.push('on a controller the map header still says CLICK');
       if(!txt.some(function(s){ return /R STICK/.test(s)&&/D-UP/.test(s); })) bad.push('on a controller the map header does not name R STICK and D-UP');
       txt=[]; arcs=[]; PAD.on=false; g.mapCur=null;
       drawMapOverlay();
       if(!txt.some(function(s){ return /CLICK/.test(s)&&/waypoint/.test(s); })) bad.push('with the mouse the map header lost its CLICK line');
       if(at()) bad.push('a cursor was drawn with no controller cursor set');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       if(hadA) ctx.arc=oArc; else delete ctx.arc;
       if(hadT) ctx.fillText=oTxt; else delete ctx.fillText;
       PAD.on=pon; PAD.brand=pbr;
       try{ var g2=__state(); if(g2){ g2.mapOpen=false; g2.mapCur=null; } }catch(_m){}
       try{ var g3=__state(); if(g3&&!g3.over){ g3.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'21.99',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
