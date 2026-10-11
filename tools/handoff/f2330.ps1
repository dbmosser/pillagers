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

if ($s.Contains("  {v:'23.30',what:")) { throw "check 23.30 is in the fixture already" }

SubRx @'
  {v:'23.29',what:
'@ @'
  {v:'23.30',what:'arcade9, his order 2026-10-11: an arcade drop is shielded, a shielded hit takes nothing, the shield tag shows, moving drops the shield and the next hit lands',
   run:function(){
     var bad=[], g, p, h0, h1, f, ft=null, own=false, seen=[], i, tagged=false, nS='SHI'+'ELD';
     try{
       __topClear(); __runPrep();
       if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object') return 'no arcadeDeploy in this build';
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); p=g.player;
       if(p.arcSh!==1) bad.push('a fresh arcade drop is not shielded (arcSh '+p.arcSh+')');
       p.iv=0; p.armor=0; h0=p.hp;
       damagePlayer(40,'sentry','T');
       if(p.hp!==h0) bad.push('a shielded player took a hit: hp '+h0+' to '+p.hp);
       keys={};
       ft=wc.fillText; own=true;
       wc.fillText=function(s){ seen.push(String(s)); return ft.apply(this,arguments); };
       for(f=0;f<3;f++) __loop(performance.now()+f*16.7);
       delete wc.fillText; own=false;
       if(seen.length){ for(i=0;i<seen.length;i++) if(seen[i].indexOf(nS)===0) tagged=true; if(!tagged) bad.push('no SHIELD tag drawn on the shielded player'); }
       if(__state()!==g||g.over) bad.push('the arcade raid ended');
       else {
         if(p.arcSh!==1) bad.push('standing still dropped the shield');
         keys={}; keys.KeyD=true; __sim(0.1); keys.KeyD=false; keys={};
         if(p.arcSh!==0) bad.push('moving did not drop the shield (arcSh '+p.arcSh+')');
         p.iv=0; p.armor=0; p.hp=p.maxhp||100; h1=p.hp;
         damagePlayer(40,'sentry','T');
         if(!(p.hp<h1)) bad.push('after moving a hit still took nothing (hp '+p.hp+')');
       }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(own){ try{ delete wc.fillText; }catch(_df){} }
       keys={};
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.29',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
