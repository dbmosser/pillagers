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

if ($s.Contains("  {v:'28.65',what:")) { throw "check 28.65 is in the fixture already" }

SubRx @'
  {v:'28.64',what:
'@ @'
  {v:'28.65',what:'cloud-robust-air-tally: a body shot with a gun and then killed by the air strike adds nothing to that gun kill tally',
   run:function(){
     if(typeof airCall!=='function'||typeof airFoe!=='function'||typeof gunKillNote!=='function'||typeof render2D!=='function'||!window.__deploy) return 'SKIP: no air strike or gun tally here';
     var bad=null, co=CAREER_ON, R0=render2D, ts, e, i;
     function fr(n){ for(var q=0;q<n;q++){ ts+=50; if(G&&G.player) G.player.hp=Math.max(G.player.hp,90); HID.fromWorker=1; try{ loop(ts); } finally{ HID.fromWorker=0; } } }
     try{
       render2D=function(){};
       __topClear(); __runPrep(); CAREER_ON=1; __deploy({kit:[],mapIx:0,seed:3});
       if(!G||!G.player||G.arcade) return 'SKIP: no CAREER raid was built';
       ts=performance.now()+100000; fr(40);
       e=G.ents.filter(function(x){ return airFoe(x)&&x.kind==='crawler'; })[0];
       if(!e) return 'SKIP: no crawler to strike';
       e.blow='g'; e.blowT=G.t; e.blowG='pistol'; e.hp=5; G.gunK={};
       airCall(e.x,e.y);
       for(i=0;i<120&&e.hp>0;i++){ e.vx=0; e.vy=0; fr(1); }
       fr(5);
       if(e.hp>0) return 'SKIP: the strike did not kill the crawler';
       if(G.gunK&&G.gunK.pistol) bad='an air strike kill was added to the Scav Pistol tally ('+G.gunK.pistol+')';
     } finally {
       render2D=R0;
       try{ if(G&&!G.over) endRaid('abandon'); }catch(_e){}
       CAREER_ON=co; __topClear();
     }
     return bad; }},
  {v:'28.64',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
