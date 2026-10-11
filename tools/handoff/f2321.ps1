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

if ($s.Contains("  {v:'23.21',what:")) { throw "check 23.21 is in the fixture already" }

SubRx @'
  {v:'23.20',what:
'@ @'
  {v:'23.21',what:'his order: an arcade raid is endless (no clock, no ring closes), drops in with a random kit and no peddler, and a normal raid after it is unchanged',
   run:function(){
     var bad=[], n0=-1, c0=-1, L0=-1, rs0, xw0, g, p, i, f, nb, nm;
     try{
       __topClear(); __runPrep();
       if(typeof arcadeDeploy!=='function'||typeof ARCADE_GUNS1==='undefined'||typeof ARCADE!=='object') return 'no arcadeDeploy in this build';
       rs0=CFG.raidSec; xw0=CFG.extractWait;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!__state()) return 'SKIP: the plain deploy built no raid';
       n0=G.ents.length; c0=G.containers.length; L0=G.raidLen;
       __endRaid('abandon'); __topClear();
       if(!arcadeDeploy({mapIx:0,seed:4242})) bad.push('arcadeDeploy built no arcade raid');
       g=__state();
       if(!g) bad.push('no raid after arcadeDeploy');
       else {
         p=g.player;
         if(g.arcade!==1) bad.push('G.arcade is '+g.arcade);
         if(g.raidLen!==0) bad.push('raidLen is '+g.raidLen);
         if(raidClockOn()) bad.push('the raid clock is on');
         if(CFG.raidSec!==0||CFG.extractWait!==15) bad.push('the arcade dials are raidSec '+CFG.raidSec+', extractWait '+CFG.extractWait);
         for(i=0;i<g.zones.length;i++) if(g.zones[i].closeAt!==undefined) bad.push('ring '+i+' closes at '+g.zones[i].closeAt);
         if(!p.wep||ARCADE_GUNS1.indexOf(p.wep.id)<0) bad.push('the gun in hand is '+(p.wep&&p.wep.id));
         if(!p.sec||!WEAPONS[p.sec.id]||p.sec.id==='fists'||p.sec.id==='pistol'||(p.wep&&p.sec.id===p.wep.id)) bad.push('the stowed gun is '+(p.sec&&p.sec.id));
         if(p.wepIssued||p.wepFromArmory||p.secFromArmory) bad.push('an arcade gun is flagged issued or from the armoury');
         if(p.wep&&p.reserve!==6*p.wep.mag) bad.push('reserve is '+p.reserve+' for a magazine of '+p.wep.mag);
         nb=g.bag.filter(function(k){ return k==='bandage'; }).length; nm=g.bag.filter(function(k){ return k==='medkit'; }).length;
         if(nb!==3||nm!==1||g.bag.length!==4) bad.push('the backpack is '+JSON.stringify(g.bag));
         if(g.pouch.frag!==1||g.pouch.smoke!==1) bad.push('the pouch is '+JSON.stringify(g.pouch));
         if(g.ents.some(function(e){ return e&&(e.kind==='peddler'||e.kind==='stray'); })) bad.push('a peddler or a stray is in the arcade raid');
         for(f=0;f<600;f++){ __loop(performance.now()+f*16.7); if(__state()!==g) break; }
         if(__state()!==g) bad.push('the arcade raid was ended or replaced within 600 frames');
         if(g.over) bad.push('the arcade raid ended ('+g.over+')');
         if(g.nuking) bad.push('the arcade raid is nuking');
       }
       arcadeLeave();
       if(ARCADE.on) bad.push('ARCADE.on is still set after arcadeLeave');
       if(__state()) bad.push('arcadeLeave left a raid in hand');
       if(CFG.raidSec!==rs0||CFG.extractWait!==xw0) bad.push('the dials did not come back (raidSec '+CFG.raidSec+', extractWait '+CFG.extractWait+')');
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!__state()) bad.push('the plain deploy after the arcade built no raid');
       else {
         if(G.arcade) bad.push('the plain raid after the arcade is an arcade raid');
         if(G.ents.length!==n0) bad.push('the plain raid has '+G.ents.length+' ents, not '+n0);
         if(G.containers.length!==c0) bad.push('the plain raid has '+G.containers.length+' containers, not '+c0);
         if(G.raidLen!==L0||!(L0>0)) bad.push('the plain raid clock is '+G.raidLen+', not '+L0);
         __endRaid('abandon');
       }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.20',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
