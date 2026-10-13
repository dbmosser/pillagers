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

if ($s.Contains("  {v:'24.86',what:")) { throw "check 24.86 is in the fixture already" }

SubRx @'
  {v:'24.85',what:
'@ @'
  {v:'24.86',what:'his answer 2026-10-12: a DEMO kill gives no ammo back and no Bandage, as a CAREER kill does not',
   run:function(){
     var bad=[], g, p, i, e, r0, nh, heals=function(){ var n=0,j,it; for(j=0;j<g.bag.length;j++){ it=ITEMS[g.bag[j]]; if(it&&it.use==='heal') n++; } return n; };
     try{
       __topClear(); __runPrep();
       if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object') return 'no arcadeDeploy in this build';
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); p=g.player;
       if(typeof arcadeShieldOff==='function') arcadeShieldOff();
       if(!(((p.wep&&p.wep.mag)|0)>0)) return 'SKIP: the arcade gun in hand has no magazine';
       ARCADE.kills=0; nh=heals();
       for(i=1;i<=3;i++){
         r0=+p.reserve||0;
         e=mkCrawler(p.x+300,p.y); e.byPlayer=1; e.elite=0; e.hp=0; g.ents.push(e);
         __ents(0.016);
         if(g.ents.indexOf(e)>=0){ bad.push('crawler '+i+' did not die'); break; }
         if((+p.reserve||0)!==r0) bad.push('DEMO kill '+i+' moved the reserve '+r0+' to '+p.reserve);
       }
       if((ARCADE.kills|0)<3) bad.push('the kills were not counted ('+ARCADE.kills+')');
       if(heals()!==nh) bad.push('three DEMO kills changed the heals from '+nh+' to '+heals());
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       keys={};
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'24.85',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
