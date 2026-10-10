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

if ($s.Contains("  {v:'22.23',what:")) { throw "check 22.23 is in the fixture already" }

SubRx @'
  {v:'22.22',what:
'@ @'
  {v:'22.23',what:'a pillbox, a Warden and THE OVERSEER put in a hunt or a search by a round, a blast or a noise while unaware drop the mark on their next step, while a Warden that has seen you keeps hunting',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof mkChoir!=='function'||typeof mkWarden!=='function'||typeof updateEnts!=='function') return 'SKIP: no raid or machines here';
     var NK={}, k, bad=[], g=null, p, z=null, far=0, i, d, C, W, B, H, E0, oPr, oLt, f0;
     for(k in NET) NK[k]=NET[k];
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player||!g.zones) return 'SKIP: staging: no raid';
       p=g.player;
       for(i=0;i<g.zones.length;i++){ d=dist(g.zones[i],p); if(d>far){ far=d; z=g.zones[i]; } }
       if(!z||far<1600) return 'SKIP: staging: no ring far from the player';
       C=mkChoir(z.x,z.y+260.5); C.state='chase'; C.alert=0; C.tx=p.x; C.ty=p.y; f0=C.face;
       W=mkWarden(z.x+300.25,z.y); W.state='chase'; W.seenYou=false; W.tx=W.x+90.5; W.ty=W.y;
       B=mkWarden(z.x-300.25,z.y); B.boss=1; B.lairX=B.x; B.lairY=B.y; B.state='investigate'; B.seenYou=false; B.tx=B.x+70.5; B.ty=B.y;
       H=mkWarden(z.x,z.y-280.75); H.state='chase'; H.seenYou=true; H.tx=H.x+50.5; H.ty=H.y;
       oPr=g.prints; oLt=g.lightning; E0=g.ents;
       g.prints=[]; g.lightning=0; g.ents=[C,W,B,H];
       try{ updateEnts(0.016); } finally { g.ents=E0; g.prints=oPr; g.lightning=oLt; }
       if(C.face===f0) return 'SKIP: staging: the pillbox took no step';
       if(C.state!=='patrol') bad.push('a pillbox a round put in a hunt still reads '+C.state+' after its own step');
       if(W.state!=='patrol') bad.push('a Warden shot while it had not seen you still reads '+W.state+' after its own step');
       if(B.state!=='patrol') bad.push('THE OVERSEER sent to a noise while it had not seen you still reads '+B.state+' after its own step');
       if(H.state!=='chase') bad.push('control: a Warden that has seen you stopped hunting ('+H.state+')');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.22',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
