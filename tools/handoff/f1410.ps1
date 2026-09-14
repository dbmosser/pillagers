$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  {v:'14.09',what:
'@ @'
  {v:'14.10',what:'the give prompt shows only where E gives: a found survivor who wants a carried item draws no give prompt at 100 units, where E does nothing for him, while at 50 units the prompt is drawn (raid HUD and map screen audit 2026-09-15, finding 7)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__drawHUD)) return 'SKIP: this fixture cannot deploy or draw the HUD';
     if(typeof mkStray!=='function') return 'SKIP: no survivor in this build';
     var bad=[], realFill=null;
     var GIVE=['G','I','V','E'].join('');
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); __forceSize(1920,1080); }catch(_fs){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player;
       if(!g||!p||g.sim) return 'SKIP: no live raid';
       var e=mkStray(p.x+100,p.y); e.found=1; e.helped=0; e.hostile=false;
       g.ents.length=0; g.ents.push(e); g.containers.length=0;
       if(e.want==='ammobox'){ e.want='bandage'; }
       g.bag=[e.want];
       var seen=[];
       realFill=ctx.fillText;
       ctx.fillText=function(t){ seen.push(String(t)); return realFill.apply(ctx,arguments); };
       function drawn(dx){ e.x=p.x+dx; e.y=p.y; seen.length=0; __drawHUD(); return seen.some(function(t){ return t.indexOf(GIVE)>=0; }); }
       // CONTROL: at 50 units the prompt is drawn.
       if(!drawn(50)) return 'SKIP: the give prompt was not drawn at 50 units, so the trace cannot see it here';
       // THE FINDING: at 100 units, where E does nothing for him.
       if(drawn(100)) bad.push('the give prompt was drawn over a survivor 100 units away, where E does not hand anything over');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       try{ if(realFill) ctx.fillText=realFill; }catch(_r){}
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'14.09',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
