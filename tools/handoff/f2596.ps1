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

if ($s.Contains("  {v:'25.96',what:")) { throw "check 25.96 is in the fixture already" }

SubRx @'
  {v:'25.95',what:
'@ @'
  {v:'25.96',what:'his order (redo the bar at the bottom, guns, throwables, medical and armour their own groups): the nine keys are the same size, the gap between the groups (after keys 4, 6 and 8) is wider than the gap inside a group, a small caps label GUNS, THROW, MEDICAL and ARMOUR is drawn under its group, and it is amber for the group the highlight is in and dim for the others',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy and draw';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so the belt cannot be drawn';
     if(typeof G!=='undefined'&&G&&(G.sim||!G.over)) return 'SKIP: a raid or a sim is live';
     var bad=[], g=null, p=null, proto=CanvasRenderingContext2D.prototype, oFT=proto.fillText, rec=[], C, i, gi, gg, NM=['GUNS','THROW','MEDICAL','ARMOUR'], first={}, f0, f1;
     function draw(){
       rec=[];
       proto.fillText=function(s,x,y){ rec.push({s:String(s),x:x,y:y,st:String(this.fillStyle)}); return oFT.apply(this,arguments); };
       try{ __frame(0); __frame(0); } finally { proto.fillText=oFT; }
     }
     function lab(n){ var j; for(j=rec.length-1;j>=0;j--) if(rec[j].s===n) return rec[j]; return null; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: staging: no raid';
       p=g.player; p.iv=99; g.ents.length=0; g.bagOpen=false; g.mapOpen=false; g.paused=false; keys={};
       g.hot=0; draw(); C=g.hotCells;
       if(!C||C.length!==9) return 'the belt drew '+(C?C.length:0)+' keys, not 9';
       for(i=1;i<9;i++) if(Math.abs(C[i].w-C[0].w)>0.5) bad.push('key '+(i+1)+' is '+C[i].w+' wide, key 1 is '+C[0].w);
       function gap(a){ return C[a+1].x-(C[a].x+C[a].w); }
       for(gi=0;gi<8;gi++) if(gap(gi)<=0) bad.push('keys '+(gi+1)+' and '+(gi+2)+' touch or overlap');
       for(gi=0;gi<3;gi++){ gg=[3,5,7][gi]; if(!(gap(gg)>=gap(0)+4)) bad.push('the gap after key '+(gg+1)+' ('+gap(gg).toFixed(1)+') is not wider than the gap inside a group ('+gap(0).toFixed(1)+')'); }
       if(Math.abs(gap(1)-gap(0))>0.5||Math.abs(gap(2)-gap(0))>0.5||Math.abs(gap(4)-gap(0))>0.5||Math.abs(gap(6)-gap(0))>0.5) bad.push('the gaps inside the groups are not all the same ('+gap(0).toFixed(1)+', '+gap(1).toFixed(1)+', '+gap(2).toFixed(1)+', '+gap(4).toFixed(1)+', '+gap(6).toFixed(1)+')');
       // the labels: under their group, centred on it
       var ext=[[0,3],[4,5],[6,7],[8,8]];
       for(gi=0;gi<4;gi++){
         var L1=lab(NM[gi]);
         if(!L1){ bad.push('no label '+NM[gi]+' under the belt'); continue; }
         var x0=C[ext[gi][0]].x, x1=C[ext[gi][1]].x+C[ext[gi][1]].w;
         if(!(L1.y>C[0].y+C[0].h)) bad.push('the label '+NM[gi]+' is at y '+L1.y+', not under the keys (they end at '+(C[0].y+C[0].h)+')');
         if(Math.abs(L1.x-(x0+x1)/2)>2) bad.push('the label '+NM[gi]+' is centred at x '+L1.x+', not on its group ('+((x0+x1)/2)+')');
         first[NM[gi]]=L1.st;
       }
       if(first.GUNS===first.THROW) bad.push('with the highlight on key 1 the GUNS label is the same colour as the THROW label ('+first.GUNS+')');
       f0=first.GUNS;
       g.hot=4; draw();
       if(!lab('THROW')||!lab('GUNS')||lab('THROW').st===lab('GUNS').st) bad.push('with the highlight on key 5 the THROW and GUNS labels are the same colour');
       else if(lab('THROW').st!==f0) bad.push('the highlight group label is '+lab('THROW').st+' on key 5 and '+f0+' on key 1: the lit colour changed');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ proto.fillText=oFT; }catch(_f){}
       try{ var g2=__state(); if(g2){ g2.drag=null; g2.hot=0; if(g2.player){ g2.player.iv=0; g2.player.downed=false; } if(!g2.over) __endRaid('abandon'); } }catch(_e){}
       try{ keys={}; }catch(_m){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'25.95',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
