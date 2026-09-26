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

if ($s.Contains("  {v:'16.03',what:")) { throw "check 16.03 is in the fixture already" }

SubRx @'
  {v:'16.02',what:
'@ @'
  {v:'16.03',what:'a lightning flash shows you to them from farther, not across the whole map: an enemy facing you at 1.6 times its sight on open ground sees you in the flash and not without it (control), one at 3 times its sight does not see you even in the flash, and a sim step counts the flash down',
   run:function(){
     if(!(window.__resetCfg&&window.__pinDefaults&&window.__startRaid&&window.__cleanProfile)||typeof updateEnts!=='function'||typeof roofAt!=='function') return 'SKIP: this fixture cannot stage a raid';
     var bad=[], keepE=null, keepV=null, e=null, p, i, a, r;
     function look(d,flash){
       e.x=p.x+d; e.y=p.y; e.face=Math.PI; e.state='patrol'; e.alert=0; e.seenYou=false; e.blind=0; e.cd=9; e.overheat=0;
       G.lightning=flash; G.pCrouch=false; G.pConceal=1;
       try{ updateEnts(0.001); }catch(x){ bad.push('updateEnts threw: '+x); }
       return !!(e.seenYou||e.state==='chase'||e.alert>0);
     }
     try{
       __resetCfg(); __pinDefaults(0); __startRaid({mapIx:0,seed:4242});
       if(!G||!G.player) return 'SKIP: no raid staged';
       p=G.player; p.downed=false;
       for(i=0;i<G.ents.length&&!e;i++) if(G.ents[i].kind==='sentry'&&G.ents[i].rng>0) e=G.ents[i];
       if(!e) return 'SKIP: no sentry on this map';
       keepE=G.ents; keepV=G.vseg; G.ents=[e]; G.vseg=[];
       r=e.rng;
       for(a=0;a<40;a++){ if(!roofAt(p.x,p.y)&&!roofAt(p.x+r*1.6,p.y)&&!roofAt(p.x+r*3,p.y)) break; p.x+=137; p.y+=91; }
       if(roofAt(p.x,p.y)||roofAt(p.x+r*1.6,p.y)) return 'SKIP: no open ground found';
       if(look(r*1.6,0)) return 'SKIP: the sentry sees him at 1.6 times its sight without a flash, so this staging cannot tell';
       if(!look(r*1.6,0.3)) bad.push('in a lightning flash a sentry facing him on open ground at '+Math.round(r*1.6)+' (1.6 times its sight of '+r+') did not see him');
       if(look(r*3,0.3)) bad.push('in a lightning flash a sentry at '+Math.round(r*3)+' (3 times its sight) saw him, so the flash shows him across the map');
       G.sim=1; G.lightning=0.34;
       try{ simStep(0.15); }catch(x2){}
       if(!(G.lightning<0.34)) bad.push('a sim step left the flash at '+G.lightning+', so the bot would be seen for the rest of the storm');
     }
     finally{
       try{ if(keepE) G.ents=keepE; if(keepV) G.vseg=keepV; }catch(_k){}
       try{ G=null; keys={}; }catch(_g){}
       try{ __resetCfg(); }catch(_rc){}
       try{ __cleanProfile(); }catch(_cp){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'16.02',what:
'@


$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
