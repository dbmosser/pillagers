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

if ($s.Contains("  {v:'19.83',what:")) { throw "check 19.83 is in the fixture already" }

SubRx @'
  {v:'19.82',what:
'@ @'
  {v:'19.83',what:'a wrapped contract hangs its second line: in the CONDITIONS box the second line of a long contract starts to the right of its first',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame&&window.__forceSize)) return 'SKIP: this fixture cannot deploy and draw';
     var bad=[], g, oFT=ctx.fillText, c0=P.contracts, h0=P.hud?JSON.parse(JSON.stringify(P.hud)):undefined, seen=[], i, a=null, b=null, desc='Extract carrying 1x Zqhang Qqquartz Qqquartz Qqquartz Qqquartz Zqtail';
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __forceSize(1920,1080);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       g.bagOpen=false; g.mapOpen=false;
       P.contracts=[{type:'zqtest',desc:desc,n:1,prog:0}];
       if(!P.hud) P.hud={}; P.hud.cond=Object.assign({},P.hud.cond||{},{c:0});
       ctx.fillText=function(t,x,y){ var m=ctx.getTransform(); seen.push({t:String(t),x:m.a*x+m.c*y+m.e,w:ctx.measureText(String(t)).width*m.a}); return oFT.apply(this,arguments); };
       for(i=0;i<3;i++) __frame(0.05);
       for(i=0;i<seen.length;i++){ if(!a&&seen[i].t.indexOf('Extract carrying')===0&&seen[i].t.indexOf('Zqtail')<0) a=seen[i]; if(a&&!b&&seen[i]!==a&&seen[i].t.indexOf('Qqquartz')>=0&&seen[i].t.indexOf('Extract')<0) b=seen[i]; }
       if(!a||!b) return 'SKIP: the test contract did not wrap ('+(a?a.t:'none')+')';
       if(!(b.x>a.x+2)) bad.push('the second line starts at x '+Math.round(b.x)+', level with the first at '+Math.round(a.x));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; P.contracts=c0; if(h0===undefined) delete P.hud; else P.hud=h0; try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.82',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
