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

if ($s.Contains("  {v:'20.37',what:")) { throw "check 20.37 is in the fixture already" }

SubRx @'
  {v:'20.36',what:
'@ @'
  {v:'20.37',what:'the raid a host keeps for his party after his run is live for the pillagers: a crew still answers a shout, the arrival clock still runs, and a raid that is simply over calls nobody',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET||typeof crewShout!=='function'||typeof tickRaiderWaves!=='function'||typeof netSpecTick!=='function') return 'SKIP: no raid or party here';
     var NK={}, k, bad=[], g, i, a=null, b=null, n, w0, nd;
     for(k in NET) NK[k]=NET[k];
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       for(i=0;i<g.ents.length;i++){ var e=g.ents[i]; if(e.kind==='raider'&&!e.merc&&!e.friendlyPC&&!e.downed){ if(!a) a=e; else { b=e; break; } } }
       if(!a||!b) return 'SKIP: staging: no two pillagers';
       b.crew=a.crew; b.hostile=true; b.state='patrol'; b.x=a.x+30; b.y=a.y;
       NET.on=true; NET.role='host'; NET.upSeed=g.seed>>>0;
       g.over='dead'; NET.specG=null;
       if(crewShout(a,a.x,a.y)!==0) bad.push('a raid that is over still called a crew');
       b.state='patrol';
       NET.specG=g;
       n=crewShout(a,a.x,a.y);
       if(n!==1) bad.push('on the raid kept for the party a shout brought '+n+' men, not 1');
       g.frameN=(g.frameN||0)+7; w0=g.waveT||0;
       tickRaiderWaves(1);
       if(!((g.waveT||0)>w0+0.5)) bad.push('on the raid kept for the party the arrival clock stood still ('+w0+' to '+g.waveT+')');
       nd='tickRaider'+'Waves(';
       if(String(netSpecTick).indexOf(nd)<0) bad.push('the kept raid stepper never runs the arrivals');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var g2=__state(); if(g2){ g2.over=false; NET.specG=null; } }catch(_o){}
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ var g3=__state(); if(g3&&!g3.over){ g3.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'20.36',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
