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

if ($s.Contains("  {v:'22.25',what:")) { throw "check 22.25 is in the fixture already" }

SubRx @'
  {v:'22.24',what:
'@ @'
  {v:'22.25',what:'a Crier pulled off patrol by a noise, a pack call or a blast walks that leg and then goes back on patrol, while one still walking to the noise keeps looking',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof mkSnitch!=='function'||typeof updateEnts!=='function') return 'SKIP: no raid or Crier here';
     var NK={}, k, bad=[], g=null, p, z=null, far=0, i, d, A, B, C, E0, oPr, oLt, cx;
     for(k in NET) NK[k]=NET[k];
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player||!g.zones) return 'SKIP: staging: no raid';
       p=g.player;
       for(i=0;i<g.zones.length;i++){ d=dist(g.zones[i],p); if(d>far){ far=d; z=g.zones[i]; } }
       if(!z||far<1400) return 'SKIP: staging: no ring far from the player';
       // it heard a noise and has reached it: its clock is out, so this step picks the next point
       A=mkSnitch(z.x+120.5,z.y-40.25); A.state='investigate'; A.cd=0; A.tx=A.x+5.5; A.ty=A.y; A.alert=0;
       // a pack call or a blast put it in chase; its clock is out too
       B=mkSnitch(z.x-150.5,z.y+60.75); B.state='chase'; B.cd=0; B.tx=B.x+4.5; B.ty=B.y; B.alert=0;
       // control: it is still walking to the noise it heard
       C=mkSnitch(z.x+40.5,z.y+150.25); C.state='investigate'; C.cd=2.5; C.tx=C.x+300.5; C.ty=C.y; C.alert=0; cx=C.tx;
       oPr=g.prints; oLt=g.lightning; E0=g.ents;
       g.prints=[]; g.lightning=0; g.ents=[A,B,C];
       try{ updateEnts(0.016); } finally { g.ents=E0; g.prints=oPr; g.lightning=oLt; }
       if(C.cd===2.5) return 'SKIP: staging: the Criers took no step';
       if(A.state==='alarm'||B.state==='alarm'||C.state==='alarm') return 'SKIP: staging: a Crier saw the player';
       if(A.state!=='patrol') bad.push('a Crier that heard a noise and reached it is still '+A.state+' on its next leg');
       if(B.state!=='patrol') bad.push('a Crier that a pack call or a blast put in chase is still '+B.state+' on its next leg');
       if(C.state!=='investigate'||C.tx!==cx) bad.push('control: a Crier still walking to the noise it heard stopped looking ('+C.state+')');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.24',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
