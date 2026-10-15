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

if ($s.Contains("  {v:'27.39',what:")) { throw "check 27.39 is in the fixture already" }

SubRx @'
  {v:'27.38',what:
'@ @'
  {v:'27.39',what:'partyp2, his order (Halo style medals): each medal has its own note and its tier adds a voice on top, nothing for a plain medal, a high shimmer for a skilled one, a low thump and a rising run for a rare one, so the three tiers sound different',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep)) return 'SKIP: no raid here';
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object'||typeof styMedal!=='function') return 'SKIP: no arcade here';
     var bad=[], g=null, p, own=false, rs=say, oT=null, calls, c1, c2, c3, i, lo, hi, pay;
     function run(txt){ calls=[]; pay=styMedal(txt,10,p.x,p.y); return calls.slice(); }
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(typeof STY_TIER_SND==='undefined') return 'there are no tier sounds in this build';
       p=g.player; keys={}; say=function(){}; own=true; ARCADE.holdT=0;
       oT=styTone; styTone=function(n){ if(n&&n.length) calls.push(n); return true; };
       c1=run('MELEE'+' KILL'); if(!pay) return 'SKIP: the staged medal paid nothing';
       c2=run('LONG'+' SHOT'); c3=run('GRENADE'+' DOUBLE');
       if(c1.length!==1) bad.push('ONE: a plain medal made '+c1.length+' sounds, not its own note alone');
       if(c2.length!==2) bad.push('TWO: a skilled medal made '+c2.length+' sounds, not its note and the shimmer');
       else { lo=1e9; for(i=0;i<c2[1].length;i++) lo=Math.min(lo,c2[1][i][1]); if(!(lo>=2000)) bad.push('TWO: the skilled shimmer reaches down to '+lo+' Hz'); }
       if(c3.length!==2) bad.push('THREE: a rare medal made '+c3.length+' sounds, not its note and the run');
       else {
         lo=1e9; for(i=0;i<c3[1].length;i++) lo=Math.min(lo,c3[1][i][1]);
         if(!(c3[1].length>=5)) bad.push('THREE: the rare run is only '+c3[1].length+' notes');
         if(!(lo<=120)) bad.push('THREE: the rare medal has no low thump (lowest '+lo+' Hz)');
         if(c2.length===2&&JSON.stringify(c2[1])===JSON.stringify(c3[1])) bad.push('THREE: the rare medal sounds like the skilled one');
       }
       if(c1.length&&c2.length&&c3.length&&(JSON.stringify(c1[0])===JSON.stringify(c2[0])||JSON.stringify(c2[0])===JSON.stringify(c3[0]))) bad.push('FOUR: two medals share their own note');
       c1=run('TEAM'+' COMBO x2'); if(c1.length<1) bad.push('FIVE: a team combo medal made no sound of its own tier');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(own) say=rs;
       try{ if(oT) styTone=oT; }catch(_t){}
       keys={};
       try{ if(g) g.sty=null; }catch(_gs){}
       try{ if(typeof ARCADE==='object'){ ARCADE.streak=null; if(ARCADE.on) arcadeLeave(); } }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.waveT=0; ARCADE.holdT=0; } }catch(_h){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'27.38',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
