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

if ($s.Contains("  {v:'36.63',what:")) { throw "check 36.63 is in the fixture already" }

SubRx @'
  {v:'36.62',what:
'@ @'
  {v:'36.63',what:'both recent machine contributors earn full SP within 2.5 seconds, score only, host and addressed peer',run:function(){
    if(typeof sharedMachineDeath!=='function') return 'shared machine credit missing';
    var g,e,n,oldSend=netSend,oldPeer=netPeerOfSeat,oldSc=arcadeScSend,arc={on:ARCADE.on,mine:ARCADE.mine,kills:ARCADE.kills},pack=[],saved={},nk=['on','role','seat','upSeed','entMap'],i,base,kills;
    function ok(v,s){if(!v)throw Error(s);}
    function body(kind){return {nid:991,kind:kind||'crawler',hp:100,x:g.player.x+100,y:g.player.y};}
    function hurt(e,seat){e.hp-=arcadeBmDamage(e,10,seat);}
    try{
      __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();
      for(i=0;i<nk.length;i++)saved[nk[i]]=NET[nk[i]];
      __deploy({kit:['gun_rifle'],safe:null,mapIx:0,seed:4242});g=__state();g.arcade=false;g.career=true;g.cs={s:0,k:0};g.hotZone=null;g.t=10;
      NET.on=true;NET.role='host';NET.upSeed=g.seed;
      netPeerOfSeat=function(s){return s===1?{state:'in',seat:1}:null;};netSend=function(q,m){pack.push(m);return true;};
      e=body();hurt(e,0);g.t+=2.5;hurt(e,1);e.hp=0;e.bySeat=1;
      base=arcadeKillPts('crawler',false,false);kills=g.tel.kills.crawler;
      sharedMachineDeath(e);ok(g.cs.s===base,'host did not get full SP at inclusive 2.5s');
      sharedMachineDeath(e);ok(g.cs.s===base&&g.cs.k===0&&g.tel.kills.crawler===kills,'duplicate points or extra kill');
      e=body();hurt(e,0);g.t+=2.501;hurt(e,1);e.hp=0;e.bySeat=1;sharedMachineDeath(e);ok(g.cs.s===base,'expired host hit paid');
      e=body();hurt(e,1);g.t+=0.1;hurt(e,0);e.hp=0;e.byPlayer=true;sharedMachineDeath(e);
      ok(pack.length===1&&pack[0].share===1&&pack[0].seat===1,'peer score credit missing or duplicated');
      NET.role='join';NET.seat=1;NET.entMap={991:e};n=g.cs.s;
      ok(netKillTake({state:'in'},pack[0])==='shared'&&g.cs.s===n+base,'addressed peer did not get full SP');
      ok(g.cs.k===0&&g.tel.kills.crawler===kills,'peer assist added a kill');
      ok(netKillTake({state:'in'},pack[0])==='ignored'&&g.cs.s===n+base,'duplicate peer credit paid');
      NET.seat=2;ok(netKillTake({state:'in'},pack[0])==='ignored','wrong seat credited');NET.role='host';
      n=g.cs.s;e=body('raider');hurt(e,0);hurt(e,1);e.hp=0;e.bySeat=1;sharedMachineDeath(e);ok(g.cs.s===n,'human shared credit');
      e=body();hurt(e,-1);hurt(e,1);e.hp=0;e.bySeat=1;sharedMachineDeath(e);ok(g.cs.s===n,'environment counted as contributor');
      g.arcade=true;g.career=false;ARCADE.on=true;ARCADE.mine=0;ARCADE.kills=7;arcadeScSend=function(){};
      e=mkCrawler(g.player.x+100,g.player.y);e.nid=992;e.elite=0;e.affix=null;
      hurt(e,0);hurt(e,1);e.hp=0;e.bySeat=1;e.byPlayer=false;g.ents=[e];
      n=arcadeKillPts(e.kind,false,false);if(arcadeRushOn())n=Math.round(n*1.05);
      // v28.xx (cw-cx-sharedmachine): use the actual death path; the fixture wraps updateEnts for timing.
      updateEnts(0);
      ok(g.ents.indexOf(e)<0&&e.sharedPaid===1,'entity death did not settle shared machine credit');
      ok(ARCADE.mine===n&&ARCADE.kills===7,'arcade full score or kill ownership wrong');
      n=g.cs.s;g.sim=true;e=body();hurt(e,0);hurt(e,1);e.hp=0;sharedMachineDeath(e);ok(!e.sharedHits&&g.cs.s===n,'sim tracked or paid');g.sim=false;
      return null;
    }finally{netSend=oldSend;netPeerOfSeat=oldPeer;arcadeScSend=oldSc;Object.assign(ARCADE,arc);if(g){g.sim=false;g.arcade=false;}try{__endRaid('abandon');}catch(_e){}for(i=0;i<nk.length;i++)NET[nk[i]]=saved[nk[i]];__topClear();}
  }},
  {v:'36.62',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
