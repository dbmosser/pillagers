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

if ($s.Contains("  {v:'21.44',what:")) { throw "check 21.44 is in the fixture already" }

SubRx @'
  {v:'21.43',what:
'@ @'
  {v:'21.44',what:'an armoury gun player 2 dropped is never in two saves: after his abandon put it back and his card closed, the host taking it takes it out of his armoury, and a closed window never brings it back',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET||typeof dropItem!=='function'||typeof netGunGoneTake!=='function') return 'SKIP: no raid or party here';
     var NK={}, k, bad=[], oSend=netSend, gk=null, key=null, i, ks=Object.keys(ITEMS), g, w0, rs0, gp0, e0, s0, g0;
     for(i=0;i<ks.length;i++) if(/^gun_/.test(ks[i])&&ITEMS[ks[i]]&&ITEMS[ks[i]].gk&&WEAPONS[ITEMS[ks[i]].gk]){ key=ks[i]; gk=ITEMS[key].gk; break; }
     if(!key) return 'SKIP: no armoury gun item here';
     for(k in NET) NK[k]=NET[k];
     w0=(P.weapons||[]).slice(); rs0=P.raidSpliced; gp0=P.gunPiled; e0=P.equipped; s0=P.equippedSec;
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       netSend=function(){ return true; };
       NET.on=true; NET.role='join'; NET.seat=1; NET.max=4; NET.peers=[{seat:0,state:'in'}]; NET.upSeed=g.seed>>>0;
       P.weapons=P.weapons.filter(function(x){ return x!==gk; }); g.spliced=[gk]; P.raidSpliced=[gk]; delete P.gunPiled;
       g.bag.push(key); dropItem(g.bag.length-1);
       if((P.raidSpliced||[]).indexOf(gk)>=0) bad.push('the dropped gun stays on the saved list, so a closed window would bring it home while the host can bank it');
       g.player.downed=false; __endRaid('abandon');
       if(P.weapons.indexOf(gk)<0) return bad.length?bad.join('; '):'SKIP: staging: the abandon did not put the gun back';
       g0=G; G=null;
       try{ netGunGoneTake({seat:0,state:'in'},{t:'gungone',k:gk}); }finally{ G=g0; }
       if(P.weapons.indexOf(gk)>=0) bad.push('after his abandon and his card closed, the host took the gun and it stayed in his armoury too (two saves)');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       netSend=oSend;
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ var g2=__state(); if(g2&&!g2.over){ g2.spliced=[]; g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       P.weapons=w0; P.raidSpliced=rs0; if(gp0===undefined) delete P.gunPiled; else P.gunPiled=gp0; P.equipped=e0; P.equippedSec=s0;
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'21.43',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
