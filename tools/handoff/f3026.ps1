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

if ($s.Contains("  {v:'30.26',what:")) { throw "check 30.26 is in the fixture already" }

SubRx @'
  {v:'30.25',what:
'@ @'
  {v:'30.26',what:'vault guns (Longshot, Meridian Lance, Rocket Launcher) ride on the golden hoard and the Overseer hoard, and a kill has a low chance to leave one (his answer Q68)',
   run:function(){
     if(typeof vaultGunPick!=='function'||typeof vaultKillDrop!=='function') return 'no vault gun drops (no vaultGunPick, no vaultKillDrop)';
     var bad=[], oSay=say, oRnd=Math.random, c, e, n, vg=function(c){ return !!c&&c.loot.some(function(k){ return k==='gun_sniper'||k==='gun_lance'||k==='gun_rocket'; }); }, i, t, f, hit;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over||!G.player) return 'SKIP: no raid';
       say=function(){};
       c=goldDrop(G.player.x+100,G.player.y);
       if(!vg(c)) bad.push('the golden hoard holds no vault gun: '+(c&&c.loot));
       G.t=2.5; e=bossTick();
       if(!e) bad.push('no Overseer came up');
       else{ e.hp=0; updateEnts(0.05);
         t=null; for(i=0;i<G.containers.length;i++) if(G.containers[i]&&G.containers[i].tag==='OVERSEER HOARD') t=G.containers[i];
         if(!t) bad.push('no Overseer hoard'); else if(!vg(t)) bad.push('the Overseer hoard holds no vault gun: '+t.loot); }
       f={kind:'crawler',x:G.player.x+60,y:G.player.y,hp:0};
       Math.random=function(){ return 0.99; }; n=G.containers.length;
       if(vaultKillDrop(f)||G.containers.length!==n) bad.push('a vault gun dropped on a high roll');
       Math.random=function(){ return 0; };
       c=vaultKillDrop(f);
       if(!vg(c)) bad.push('no vault gun on a low roll');
       if(f.golden===undefined&&vaultKillDrop({kind:'crawler',x:0,y:0,hp:0,golden:1})) bad.push('the golden body drops a second one');
       // wired into the death path
       Math.random=oRnd; hit=null;
       for(i=0;i<G.ents.length;i++){ var q=G.ents[i]; if(q&&q.hp>0&&!q.boss&&!q.golden&&!q.summoned&&(q.kind==='crawler'||q.kind==='sentry'||q.kind==='bulwark'||q.kind==='howler')){ hit=q; break; } }
       if(hit){
         n=G.containers.length; hit.hp=0; Math.random=function(){ return 0; }; updateEnts(0.05); Math.random=oRnd;
         if(!G.containers.slice(n).some(vg)) bad.push('a kill on a low roll left no vault gun in the death path');
       }
     }catch(ex){ bad.push('threw: '+(ex&&ex.message||ex)); }
     finally{
       say=oSay; Math.random=oRnd;
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'30.25',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
