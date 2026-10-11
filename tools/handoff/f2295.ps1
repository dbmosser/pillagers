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

if ($s.Contains("  {v:'22.95',what:")) { throw "check 22.95 is in the fixture already" }

SubRx @'
  {v:'22.94',what:
'@ @'
  {v:'22.95',what:'bare HUD text gets the ink outline: in a drawn HUD standing in the uncalled ring, the raid clock, the compass line and HOLD [E] TO CALL FOR EXTRACTION are each stroked, and a world prompt such as [E] CALL FOR EXTRACTION is stroked as well as plated',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)||typeof drawHUD!=='function'||typeof hudPrompt!=='function') return 'SKIP: no raid HUD or prompt here';
     var bad=[], g=null, p=null, OWN=Object.prototype.hasOwnProperty, oST=ctx.strokeText, oFT=ctx.fillText, ownS=OWN.call(ctx,'strokeText'), ownF=OWN.call(ctx,'fillText'), st=[], ft=[], z, i, clk=0, cmp=0, cal=0, pr=0, fclk=0, fcmp=0, fcal=0, s, CALL='TO CALL FOR '+'EXTRACTION', PR='] CALL FOR '+'EXTRACTION';
     function spy(){ st=[]; ft=[]; ctx.strokeText=function(t){ st.push(String(t)); return oST.apply(this,arguments); }; ctx.fillText=function(t){ ft.push(String(t)); return oFT.apply(this,arguments); }; }
     function unspy(){ if(ownS) ctx.strokeText=oST; else delete ctx.strokeText; if(ownF) ctx.fillText=oFT; else delete ctx.fillText; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player; keys={}; g.bagOpen=false; g.mapOpen=false; g.ents.length=0; p.downed=false;
       z=g.active; if(!z) return 'SKIP: staging: no ring';
       g.beaconT=null; z.beaconT=null; z.callT=0; p.x=z.x; p.y=z.y;
       spy();
       try{ drawHUD(); } finally { unspy(); }
       for(i=0;i<ft.length;i++){ s=ft[i]; if((/^\d+:\d\d$/).test(s)) fclk++; if((/^(EXTRACT|EXTRACTION|WAYPOINT) \d+m$/).test(s)) fcmp++; if(s.indexOf(CALL)>0&&s.indexOf('HOLD')===0) fcal++; }
       for(i=0;i<st.length;i++){ s=st[i]; if((/^\d+:\d\d$/).test(s)) clk++; if((/^(EXTRACT|EXTRACTION|WAYPOINT) \d+m$/).test(s)) cmp++; if(s.indexOf(CALL)>0&&s.indexOf('HOLD')===0) cal++; }
       if(!fclk) return 'SKIP: staging: the raid clock was not drawn';
       if(!fcmp) return 'SKIP: staging: the compass line was not drawn';
       if(!fcal) return 'SKIP: staging: HOLD [E] TO CALL FOR EXTRACTION was not drawn in the ring';
       if(!clk) bad.push('the raid clock is drawn with no outline');
       if(!cmp) bad.push('the compass line is drawn with no outline');
       if(!cal) bad.push('HOLD [E] TO CALL FOR EXTRACTION is drawn with no outline');
       spy();
       ctx.save();
       try{ hudPrompt('['+keyLabel('KeyE','E')+'] CALL FOR EXTRACTION',W/2,H/2,{col:HUDC.extract}); } finally { ctx.restore(); unspy(); }
       for(i=0;i<st.length;i++) if(st[i].indexOf(PR)>0) pr++;
       if(!pr) bad.push('the world prompt [E] CALL FOR EXTRACTION is drawn with no outline');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       unspy(); keys={};
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.94',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
