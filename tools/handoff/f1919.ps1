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

if ($s.Contains("  {v:'19.19',what:")) { throw "check 19.19 is in the fixture already" }

SubRx @'
  {v:'19.18',what:
'@ @'
  {v:'19.19',what:'the status icons keep off a moved board and a grown controls list: with the list grown up past the column top, or the board dragged down into it, no status name is drawn inside either panel',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof drawStatusIcons!=='function'||typeof STATUSL==='undefined') return 'SKIP: no status icons here';
     var bad=[], g, p, oFT=ctx.fillText, names={}, pts=[], oR=HUDBOX.raiders, oL=HUDBOX.legend, oBd=HUDBOX.body, oB=P.buzz, i, d=(typeof DPR==='number'&&DPR>0)?DPR:1;
     function inside(b,q){ return b&&q.x>=b.x&&q.x<=b.x+b.w&&q.y>=b.y&&q.y<=b.y+b.h; }
     function run(lbl){ pts=[]; ctx.save(); try{ drawStatusIcons(); } finally { ctx.restore(); }
       if(!pts.length){ bad.push(lbl+': no status names were drawn'); return; }
       for(var k=0;k<pts.length;k++){ if(inside(HUDBOX.raiders,pts[k])) { bad.push(lbl+': a status name is drawn inside the board at '+Math.round(pts[k].x)+','+Math.round(pts[k].y)); break; } if(inside(HUDBOX.legend,pts[k])) { bad.push(lbl+': a status name is drawn inside the controls list at '+Math.round(pts[k].x)+','+Math.round(pts[k].y)); break; } if(inside(HUDBOX.body,pts[k])) { bad.push(lbl+': a status name is drawn inside the vitals at '+Math.round(pts[k].x)+','+Math.round(pts[k].y)); break; } } }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g.player; g.bagOpen=false; g.mapOpen=false;
       p.hp=50; p.healQ=25; p.healRate=4; p.healAmt0=30; p.stimT=6;
       P.buzz=[{tag:'drunk',dur:180,t:150,id:'liquor'},{tag:'lsd',dur:180,t:150,id:'lsd'}];
       statusLive(p); for(i=0;i<STATUSL.length;i++) if(STATUSL[i].on) names[STATUSL[i].nm]=1;
       if(Object.keys(names).length<3) return 'SKIP: fewer than three statuses came on';
       ctx.fillText=function(s,x,y){ if(names[String(s)]){ var m=ctx.getTransform(); pts.push({x:(m.a*x+m.c*y+m.e)/d,y:(m.b*x+m.d*y+m.f)/d}); } return oFT.apply(this,arguments); };
       HUDBOX.raiders={x:0,y:0,w:Math.round(W*0.2),h:Math.round(H*0.38)};
       HUDBOX.legend={x:0,y:Math.round(H*0.39),w:Math.round(W*0.25),h:Math.round(H*0.50)};
       HUDBOX.body={x:0,y:Math.round(H*0.92),w:Math.round(W*0.2),h:Math.round(H*0.07)};
       run('controls list grown up');
       HUDBOX.raiders={x:0,y:Math.round(H*0.51),w:Math.round(W*0.2),h:Math.round(H*0.10)};
       HUDBOX.legend={x:0,y:Math.round(H*0.80),w:Math.round(W*0.25),h:Math.round(H*0.11)};
       run('board dragged down');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; HUDBOX.raiders=oR; HUDBOX.legend=oL; HUDBOX.body=oBd; P.buzz=oB; try{ var g2=__state(); if(g2&&!g2.over){ g2.player.stimT=0; g2.player.healQ=0; g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.18',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
