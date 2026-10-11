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

if ($s.Contains("  {v:'23.31',what:")) { throw "check 23.31 is in the fixture already" }

SubRx @'
  {v:'23.30',what:
'@ @'
  {v:'23.31',what:'arcade10, his order 2026-10-11: an arcade hit takes half, every kill refunds half a magazine, every third kill adds a Bandage up to 5 heals',
   run:function(){
     var bad=[], g, p, h0, want, got, m, half, r0, e, i, nh, heals=function(){ var n=0,j,it; for(j=0;j<g.bag.length;j++){ it=ITEMS[g.bag[j]]; if(it&&it.use==='heal') n++; } return n; };
     try{
       __topClear(); __runPrep();
       if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object') return 'no arcadeDeploy in this build';
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); p=g.player;
       if(typeof arcadeShieldOff==='function') arcadeShieldOff();
       p.iv=0; p.armor=0; p.downed=false; p.hp=p.maxhp||100; h0=p.hp; want=20*CFG.eDmg*0.5;
       damagePlayer(20,'sentry','T');
       got=h0-p.hp;
       if(Math.abs(got-want)>1e-6) bad.push('an arcade hit of 20 took '+got+', not '+want+' (20 x eDmg '+CFG.eDmg+' x 0.5)');
       p.iv=0; p.downed=false; p.hp=p.maxhp||100;
       m=(p.wep&&p.wep.mag)|0;
       if(!(m>0)) return 'SKIP: the arcade gun in hand has no magazine';
       half=Math.ceil(m/2);
       ARCADE.kills=0; nh=heals();
       for(i=1;i<=6;i++){
         r0=+p.reserve||0;
         e=mkCrawler(p.x+300,p.y); e.byPlayer=1; e.elite=0; e.hp=0; g.ents.push(e);
         __ents(0.016);
         if(g.ents.indexOf(e)>=0){ bad.push('crawler '+i+' did not die'); break; }
         if((+p.reserve||0)!==r0+half) bad.push('kill '+i+' moved reserve '+r0+' to '+p.reserve+', not +'+half);
         if(i===2&&heals()!==nh) bad.push('two kills changed the heals from '+nh+' to '+heals());
         if(i===3&&heals()!==Math.min(5,nh+1)) bad.push('the third kill left '+heals()+' heals, not '+Math.min(5,nh+1));
       }
       if(i>6){
         if(heals()>5) bad.push('kill bandages went past 5 heals ('+heals()+')');
         if(heals()!==Math.min(5,nh+2)) bad.push('after six kills '+heals()+' heals, not '+Math.min(5,nh+2));
       }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       keys={};
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.30',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
