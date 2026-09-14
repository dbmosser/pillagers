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
  {v:'14.11',what:
'@ @'
  {v:'14.12',what:'the revive prompt shows the time he actually has: a downed pillager at 25 of 50 health with sixteen seconds of bleed reads about eight seconds, while one at full health reads sixteen (raid HUD and map screen audit 2026-09-15, finding 5)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__drawHUD)) return 'SKIP: this fixture cannot deploy or draw the HUD';
     if(typeof mkRaider!=='function'||typeof raiderDownHp!=='function'||typeof RAIDER_DOWN_T==='undefined') return 'SKIP: no downed pillagers in this build';
     var bad=[], realFill=null;
     var REV=['R','E','V','I','V','E'].join('');
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); __forceSize(1920,1080); }catch(_fs){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player;
       if(!g||!p||g.sim) return 'SKIP: no live raid';
       var R=mkRaider(p.x+30,p.y,null,false);
       g.ents.length=0; g.ents.push(R); g.containers.length=0;
       p.downed=false; p.iv=99;
       var seen=[];
       realFill=ctx.fillText;
       ctx.fillText=function(t){ seen.push(String(t)); return realFill.apply(ctx,arguments); };
       function secs(hp){
         R.downed=1; R.state='down'; R.downT=RAIDER_DOWN_T; R.hp=hp; R.x=p.x+30; R.y=p.y;
         g.nearDown=R; seen.length=0; __drawHUD();
         var line=null; for(var i=0;i<seen.length;i++) if(seen[i].indexOf(REV)>=0){ line=seen[i]; break; }
         if(!line) return null;
         var m=line.match(/(\d+)s\s*$/); return m?(+m[1]):null;
       }
       var full=raiderDownHp();
       // CONTROL: full health reads the whole bleed clock.
       var A=secs(full);
       if(A===null) return 'SKIP: the revive prompt was not drawn in the trace, so nothing here can be measured';
       if(A!==Math.round(RAIDER_DOWN_T)) return 'SKIP: at full health the prompt read '+A+'s, not the '+RAIDER_DOWN_T+'s bleed clock';
       // THE FINDING: half health reads the time his health allows.
       var want=Math.round((full/2)/(full/RAIDER_DOWN_T));
       var B=secs(full/2);
       if(B===null||Math.abs(B-want)>1) bad.push('a downed pillager at half health read '+B+'s on the revive prompt, when he is finished in about '+want+'s');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       try{ if(realFill) ctx.fillText=realFill; }catch(_r){}
       try{ var g2=__state(); if(g2){ g2.nearDown=null; if(g2.player) g2.player.iv=0; if(!g2.over) __endRaid('abandon'); } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'14.11',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
