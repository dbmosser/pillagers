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

if ($s.Contains("  {v:'34.39',what:")) { throw "check 34.39 is in the fixture already" }

SubRx @'
  {v:'34.38',what:
'@ @'
  {v:'34.39',what:'cw-downedcard: no run info contract row wraps (it stays inside the panel), and the downed card is the shared raid panel with the timer as its biggest text',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame&&window.__loop)) return 'SKIP: this fixture cannot deploy and draw';
     var proto=CanvasRenderingContext2D.prototype, o=proto.fillText, hp0=hudPanel, bad=[], panels=[], seen=[], g, p, i, j, n, md=mouse.down, kc=null;
     function px(c){ var m=/([\d.]+)px/.exec(c.font); return m?parseFloat(m[1])*c.getTransform().a:0; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       kc=P.contracts;
       P.contracts=[{type:'district',d:0,n:3,prog:2,desc:'search 3 containers in the long dock or scrap yard line'},{type:'extract',n:1,prog:0,desc:'extract with a haul worth $12,000 or more'},{type:'kills',n:5,prog:1,desc:'kill five sentries before the second horn'}];
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       P.contracts=[{type:'district',d:0,n:3,prog:2,desc:'search 3 containers in the long dock or scrap yard line'},{type:'extract',n:1,prog:0,desc:'extract with a haul worth $12,000 or more'},{type:'kills',n:5,prog:1,desc:'kill five sentries before the second horn'}];
       g.bagOpen=false; g.mapOpen=false;
       hudPanel=function(x,y,w,h){ panels.push({x:x,y:y,w:w,h:h,a:arguments[4],plain:arguments[5]}); return hp0.apply(this,arguments); };
       proto.fillText=function(t,x,y){ if(this===ctx&&typeof t==='string'&&t.length&&/\S/.test(t)){ seen.push({t:String(t),x:x,y:y,px:px(this),w:this.measureText(String(t)).width}); } return o.apply(this,arguments); };
       __frame(0.001);
       n=0;
       for(i=0;i<seen.length;i++){
         if(!/search 3|haul over|haul worth|kill five/i.test(seen[i].t)) continue;
         n++;
         if(!/\d+\/\d+$/.test(seen[i].t)) bad.push('a contract row wraps: '+seen[i].t.slice(0,40));
         var inside=false;
         for(j=0;j<panels.length;j++){ var q=panels[j]; if(seen[i].x>=q.x-0.5&&seen[i].y>=q.y&&seen[i].y<=q.y+q.h){ inside=true; if(seen[i].x+seen[i].w>q.x+q.w+0.5) bad.push('a contract row is wider than the panel: '+seen[i].t.slice(0,30)); break; } }
         if(!inside) bad.push('no panel found for a row: '+seen[i].t.slice(0,30));
       }
       if(n<3) bad.push('the three staged contracts were not all drawn ('+n+')');
       // the downed card
       seen.length=0; panels.length=0;
       p=g.player; g.ents.length=0; p.hp=0; p.downed=true; p.downT=12.34; p.revived=0; p.iv=99; p.pendKiller=null; mouse.down=false;
       for(i=0;i<3;i++) __loop(performance.now()+i*17);
       var card=null;
       for(j=0;j<panels.length;j++) if(panels[j].w===480&&panels[j].h>=110){ card=panels[j]; }
       if(!card) bad.push('the downed card is not drawn with the shared raid panel (hudPanel)');
       else{
         if(!card.plain) bad.push('the downed card panel is not the plain raid panel');
         var tm=0, other=0, cnt=0;
         for(i=0;i<seen.length;i++){
           var s=seen[i];
           if(s.x<card.x||s.x>card.x+card.w||s.y<card.y||s.y>card.y+card.h) continue;
           cnt++;
           if(/^\d+\.\d\ds$/.test(s.t)) tm=Math.max(tm,s.px); else other=Math.max(other,s.px);
         }
         if(!tm) bad.push('no timer text on the card ('+cnt+' lines)');
         else if(!(tm>other+1)) bad.push('the timer is '+tm.toFixed(1)+' px, the biggest other text is '+other.toFixed(1));
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ proto.fillText=o; hudPanel=hp0; mouse.down=md; try{ if(kc) P.contracts=kc; var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'34.38',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
