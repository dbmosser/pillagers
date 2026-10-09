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

if ($s.Contains("  {v:'21.69',what:")) { throw "check 21.69 is in the fixture already" }

SubRx @'
  {v:'21.68',what:
'@ @'
  {v:'21.69',what:'when the host leaves, a pillager last seen crouched at a box looks for a real box, and the raid runs on without a fault',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET||typeof netHostGone!=='function'||typeof netEntFlagsApply!=='function'||typeof netEntFlags!=='function'||typeof updateEnts!=='function') return 'SKIP: no raid or party in this fixture';
     var NK={}, k, bad=[], oSwf=sayWhenFree, oSay=say, g, e=null, bd=-1, i, q, d, f, thrown='';
     for(k in NET) NK[k]=NET[k];
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __topClear(); __runPrep(); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       sayWhenFree=function(){}; say=function(){};
       for(i=0;i<g.ents.length;i++){ q=g.ents[i]; if(!q||q.kind!=='raider'||q.merc||q.friendlyPC||q.downed||!(q.hp>0)) continue; d=dist(q,g.player); if(d>bd){ bd=d; e=q; } }
       if(!e) return 'SKIP: staging: no pillager on this map';
       NET.on=true; NET.role='join'; NET.seat=1; NET.max=4; NET.peers=[{seat:0,state:'in'}]; NET.upSeed=g.seed>>>0;
       f=netEntFlags(e)|2048|65536;
       netEntFlagsApply(e,f);
       if(e.goal!==e||e.state!=='loot') return 'SKIP: staging: the crouch row did not take';
       if(!netHostGone('lost')) return 'SKIP: staging: the takeover did not run';
       if(g.ents.indexOf(e)<0) return 'SKIP: staging: the pillager left the map at the takeover';
       if(e.goal===e) bad.push('after the takeover a pillager last seen crouched at a box still has himself as the box he searches');
       try{ for(i=0;i<50;i++) updateEnts(0.05); }catch(e2){ thrown=String(e2&&e2.message||e2); }
       if(thrown) bad.push('the raid threw after the takeover: '+thrown);
     }catch(e3){ bad.push('threw: '+(e3&&e3.message||e3)); }
     finally{
       sayWhenFree=oSwf; say=oSay;
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'21.68',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
