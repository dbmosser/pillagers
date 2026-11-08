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

if ($s.Contains("  {v:'37.59',what:")) { throw "check 37.59 is in the fixture already" }

SubRx @'
  {v:'37.58',what:
'@ @'
  {v:'37.59',what:'juggernaut spawns once far from the Overseer, mirrors, pays boss SP and drops its hoard',run:function(){
    var oldCareer=CAREER_ON,oldFX=FXS,g,e,L,mirror,seed,body;
    function need(ok,msg){ if(!ok) throw Error(msg); }
    try{
      __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
      CAREER_ON=1; __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state();
      g.t=5; g.player.iv=9999;
      need(g.career&&!g.over&&!g.boss2Done&&CFG.boss!==0&&!(NET.on&&NET.role==='join'),'invalid career authority staging');
      // v28.xx (cw-cx-juggernaut): pin the independent effects stream too. The first freeSpot proposal is (122.78,3290.29), in the far southwest strip.
      FXS=24241;
      need(typeof bossTick2==='function','no second boss spawner'); seed=RNGS; bossTick2(); need(seed===RNGS,'spawn changed seeded stream'); __ents(0);
      body=g.ents.filter(function(a){return a.boss2;}); need(body.length===1,'expected one juggernaut, got '+body.length); e=body[0]; L=bossLair();
      need(dist(e,L)>=1800,'too near Overseer'); need(e.kind==='bulwark'&&!e.boss&&!e.elite&&e.r===31,'wrong body');
      need(e.maxhp===Math.round(3000*CFG.eHp)&&e.dmg===22&&e.rng===420,'wrong stats');
      g.zones.forEach(function(z){need(dist(e,z)>=900,'too near ring');}); g.map.spawns.forEach(function(s){need(dist(e,s)>=900,'too near spawn');});
      seed=RNGS; bossTick2(); need(RNGS===seed&&g.ents.filter(function(a){return a.boss2;}).length===1,'repeat spawn or seeded draw');
      mirror=netEntMake(99999,'bulwark',e.x,e.y); netEntFill(mirror,netEntNewWord(e));
      need(mirror.boss2&&!mirror.boss&&mirror.r===31&&netPingName(mirror)===BOSS2_NAME&&mirror.lairX===e.lairX&&mirror.lairY===e.lairY,'peer identity or lair');
      need(Math.abs(machMul(e)/machMul({kind:'bulwark'})-1.3)<.001,'body size');
      need(arcadeKillPts('bulwark',0,0,1)===spMul(ARCADE_BOSSPTS/2),'boss score');
      e.hp=0; __ents(0); var c=g.containers.filter(function(a){return a.tag==='juggernaut hoard';});
      need(c.length===1&&c[0].time===3,'missing hoard'); need(c[0].loot.length===4,'wrong hoard loot');
      __ents(0); need(g.containers.filter(function(a){return a.tag==='juggernaut hoard';}).length===1,'duplicate hoard');
      return null;
    }finally{ FXS=oldFX; CAREER_ON=oldCareer; try{__endRaid('abandon');}catch(_e){} __topClear(); }
  }},
  {v:'37.58',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
