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

if ($s.Contains("  {v:'19.11',what:")) { throw "check 19.11 is in the fixture already" }

SubRx @'
  {v:'19.10',what:
'@ @'
  {v:'19.11',what:'the status column stays at the left: squeezed into a short band with five statuses on, it uses at most two columns',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof drawStatusIcons!=='function'||typeof STATUSL==='undefined') return 'SKIP: no status icons here';
     var bad=[], g, p, oFT=ctx.fillText, names={}, xs={}, oR=HUDBOX.raiders, oL=HUDBOX.legend, oB=P.buzz, i, cols;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g.player; g.bagOpen=false; g.mapOpen=false;
       p.hp=50; p.healQ=25; p.healRate=4; p.healAmt0=30; p.stimT=6;
       P.buzz=[{tag:'drunk',dur:180,t:150,id:'liquor'},{tag:'lsd',dur:180,t:150,id:'lsd'}];
       statusLive(p); for(i=0;i<STATUSL.length;i++) if(STATUSL[i].on) names[STATUSL[i].nm]=1;
       if(Object.keys(names).length<4) return 'SKIP: fewer than four statuses came on ('+Object.keys(names).join(', ')+')';
       HUDBOX.raiders={x:0,y:0,w:Math.round(W*0.2),h:Math.round(H*0.64)};
       HUDBOX.legend={x:0,y:Math.round(H*0.70),w:Math.round(W*0.3),h:Math.round(H*0.2)};
       ctx.fillText=function(s,x,y){ if(names[String(s)]){ var m=ctx.getTransform(); xs[Math.round(m.a*x+m.e)]=1; } return oFT.apply(this,arguments); };
       ctx.save(); try{ drawStatusIcons(); } finally { ctx.restore(); delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; }
       cols=Object.keys(xs).length;
       if(cols>2) bad.push('the statuses spread over '+cols+' columns across the screen');
       if(!cols) return 'SKIP: no status names were drawn';
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; HUDBOX.raiders=oR; HUDBOX.legend=oL; P.buzz=oB; try{ var g2=__state(); if(g2&&!g2.over){ g2.player.stimT=0; g2.player.healQ=0; g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.10',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
