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

if ($s.Contains("  {v:'19.47',what:")) { throw "check 19.47 is in the fixture already" }

SubRx @'
  {v:'19.46',what:
'@ @'
  {v:'19.47',what:'the teammate rows stay on the left: with the pillager board dragged to the lower right, the teammate row is drawn high on the left, not pushed under the board',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof netTeamHud!=='function'||typeof netUpShown!=='function') return 'SKIP: no co-op HUD here';
     var bad=[], g, NK={}, k, oShown=netUpShown, oName=netSeatName, oFT=ctx.fillText, row=null, oR=HUDBOX.raiders, oL=HUDBOX.legend, oB=HUDBOX.body;
     for(k in NET) NK[k]=NET[k];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); g.bagOpen=false; g.mapOpen=false;
       NET.on=true; NET.up=[{seat:1,hp:70,mh:100,ar:0,ac:0,x:g.player.x+40,y:g.player.y,dn:0}];
       netUpShown=function(u){ return !!u; }; netSeatName=function(s){ return (s===1)?'ZQMATE':oName(s); };
       HUDBOX.raiders={x:Math.round(W*0.6),y:Math.round(H*0.55),w:300,h:Math.round(H*0.3)};
       HUDBOX.legend={x:0,y:Math.round(H*0.8),w:Math.round(W*0.3),h:Math.round(H*0.15)};
       delete HUDBOX.body;
       ctx.fillText=function(s,x,y){ var m=ctx.getTransform(), d=(typeof DPR==='number'&&DPR>0)?DPR:1; if(String(s)==='ZQMATE'&&!row) row={x:(m.a*x+m.c*y+m.e)/d,y:(m.b*x+m.d*y+m.f)/d}; return oFT.apply(this,arguments); };
       ctx.save(); try{ netTeamHud(H); } finally { ctx.restore(); }
       if(!row) return 'SKIP: the teammate row was not drawn';
       if(row.y>H*0.5) bad.push('the teammate row was pushed down to y '+Math.round(row.y)+' under a board on the other side of the screen');
       if(row.x>W*0.3) bad.push('the teammate row is not on the left');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; netUpShown=oShown; netSeatName=oName; HUDBOX.raiders=oR; HUDBOX.legend=oL; if(oB) HUDBOX.body=oB; for(k in NET) if(!(k in NK)) delete NET[k]; for(k in NK) NET[k]=NK[k]; try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.46',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
