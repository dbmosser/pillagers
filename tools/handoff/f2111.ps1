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

if ($s.Contains("  {v:'21.11',what:")) { throw "check 21.11 is in the fixture already" }

SubRx @'
  {v:'21.10',what:
'@ @'
  {v:'21.11',what:'at 4K the boss plate is drawn at the screen scale, like the message plate above it: the name of THE OVERSEER is drawn under a transform grown by the screen factor',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof drawBossBar!=='function'||typeof bossTick!=='function'||typeof hudRes!=='function') return 'SKIP: no boss bar here';
     var bad=[], g, b, W0=W, H0=H, own=Object.prototype.hasOwnProperty.call(ctx,'fillText'), of=ctx.fillText, a0=null, a1=null, r, nm;
     try{
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       g.t=Math.max(g.t||0,30); g.bossDone=0; var cb0=CFG.boss; if(CFG.boss===0) CFG.boss=1; b=bossTick(true); CFG.boss=cb0; if(!b) return 'SKIP: staging: no Overseer';
       b.x=g.player.x+200; b.y=g.player.y; b.barSeen=1; b.hp=Math.max(1,Math.round(b.maxhp*0.5)); nm=b.name;
       W=3840; H=2160; r=hudRes();
       if(!(r>1.5)) return 'SKIP: staging: the screen factor did not rise';
       ctx.save(); ctx.setTransform(1,0,0,1,0,0);
       ctx.fillText=function(t){ if(String(t)===nm){ var m=ctx.getTransform(); a1=m.a; } return of.apply(this,arguments); };
       a0=ctx.getTransform().a;
       drawBossBar();
       ctx.restore();
       if(a1===null) return 'SKIP: staging: the boss plate was not drawn';
       if(Math.abs(a1/a0-r)>0.05) bad.push('at 4K (screen factor '+r.toFixed(2)+') the boss name is drawn at scale '+(a1/a0).toFixed(2));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       W=W0; H=H0;
       if(own) ctx.fillText=of; else delete ctx.fillText;
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'21.10',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
