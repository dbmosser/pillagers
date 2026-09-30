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

if ($s.Contains("  {v:'17.47',what:")) { throw "check 17.47 is in the fixture already" }

SubRx @'
  {v:'17.46',what:
'@ @'
  {v:'17.47',what:'richer animation: a body in its hit flash is drawn pushed away from the player who hit it and not once the flash is over, and a body that dies leaves a death animation where it fell that clears after 0.8 seconds',
   run:function(){
     if(typeof animHitShift!=='function'||typeof deathAnimAdd!=='function'||typeof drawDeathAnims!=='function') return 'this build has no hit or death animation';
     if(!window.__deploy||!window.__endRaid) return 'SKIP: no raid in this fixture';
     var bad=[], e=null, i, s, oSay=say, n0, x, y;
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over||!G.player) return 'SKIP: staging: no raid';
       say=function(){};
       s=animHitShift({x:G.player.x+100,y:G.player.y,hitT:0.16});
       if(!s||!(s.x>2)||Math.abs(s.y)>0.5) bad.push('a body in its hit flash was not pushed away from the player ('+JSON.stringify(s)+')');
       if(animHitShift({x:G.player.x+100,y:G.player.y,hitT:0})) bad.push('a body out of its hit flash was still pushed');
       for(i=0;i<G.ents.length;i++) if(G.ents[i]&&G.ents[i].kind==='crawler'){ e=G.ents[i]; break; }
       if(!e) return 'SKIP: staging: no crawler to kill';
       G.deathAnims=[]; x=e.x; y=e.y; e.hp=0; updateEnts(0.05);
       n0=(G.deathAnims||[]).length;
       if(!n0||Math.hypot(G.deathAnims[0].x-x,G.deathAnims[0].y-y)>1) bad.push('a crawler that died left no death animation where it fell');
       drawDeathAnims();
       G.t=(G.t||0)+1.0; drawDeathAnims();
       if((G.deathAnims||[]).length) bad.push('a death animation did not clear after 0.8 seconds');
     }catch(ex){ bad.push('threw: '+(ex&&ex.message||ex)); }
     finally{
       say=oSay;
       try{ if(G) G.deathAnims=[]; }catch(_d){}
       try{ __endRaid('abandon'); __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.46',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
