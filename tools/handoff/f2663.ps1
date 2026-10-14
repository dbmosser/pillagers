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

if ($s.Contains("  {v:'26.63',what:")) { throw "check 26.63 is in the fixture already" }

SubRx @'
  {v:'26.62',what:
'@ @'
  {v:'26.63',what:'feel15, his order: a round that reaches the player inside the roll invulnerable window refunds the roll stamina, adds 25 to the run score (DEMO and CAREER) and calls CLOSE CALL once per roll; a round that finds the player standing does none of that',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: no raid here';
     var bad=[], g, p, all, own, oStam, oIv, oRoll, oHp, oCareer, oCs, oArc, oOn, oMine, hp0, sh, said=[], oLabel;
     function shot(){ g.bullets.length=0; g.bullets.push({x:p.x,y:p.y,vx:0.01,vy:0,dmg:20,life:0.5,player:false,owner:own,tint:'#ffffff',thru:0}); updateBullets(0.001); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(g.sim) return 'SKIP: the fixture raid is a sim raid';
       p=g.player; all=g.ents.slice();
       own=all.filter(function(x){ return x.kind==='sentry'||x.kind==='crawler'; })[0];
       if(!own) return 'SKIP: no machine on this map';
       g.ents=[]; oStam=p.stam; oIv=p.iv; oRoll=p.roll; oHp=p.hp; oCareer=g.career; oCs=g.cs; oArc=g.arcade; oOn=ARCADE.on; oMine=ARCADE.mine; oLabel=label;
       // ONE: CAREER, rolling: refund and score
       g.career=true; g.cs={s:0,k:0}; g.arcade=false; p.ccT=undefined; p.iv=0.25; p.roll=0.2; p.stam=10; hp0=p.hp;
       shot();
       if(Math.abs(p.stam-(10+ROLLSTAM))>0.01) bad.push('ONE: the stamina is '+p.stam+', not 10 + '+ROLLSTAM+' after a roll through a round');
       if(g.cs.s!==25) bad.push('ONE: the CAREER score is '+g.cs.s+', not 25');
       if(p.hp<hp0) bad.push('ONE: the round hurt a rolling player');
       // once per roll
       shot();
       if(Math.abs(p.stam-(10+ROLLSTAM))>0.01||g.cs.s!==25) bad.push('TWO: a second round in the same roll paid again (stamina '+p.stam+', score '+g.cs.s+')');
       // TWO: standing: nothing
       p.ccT=undefined; p.iv=0; p.roll=0; p.stam=10; g.cs.s=0; hp0=p.hp+(p.armor||0);
       shot();
       if(p.stam!==10||g.cs.s!==0) bad.push('TWO: a round that hit a standing player refunded stamina or paid (stamina '+p.stam+', score '+g.cs.s+')');
       if(!(p.hp+(p.armor||0)<hp0)) bad.push("TWO: the round staged did not hurt a standing player");
       // THREE: DEMO scores the same
       g.career=false; g.cs=undefined; g.arcade=true; ARCADE.on=1; ARCADE.mine=0; p.ccT=undefined; p.iv=0.25; p.roll=0.2; p.stam=10;
       shot();
       if(ARCADE.mine!==25) bad.push('THREE: the DEMO score is '+ARCADE.mine+', not 25');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(g){ g.career=oCareer; g.cs=oCs; g.arcade=oArc; if(all) g.ents=all.slice(); g.bullets.length=0; } ARCADE.on=oOn; ARCADE.mine=oMine; if(p){ p.stam=oStam; p.iv=oIv; p.roll=oRoll; p.hp=oHp; p.ccT=undefined; } }catch(_h){}
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'26.62',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
