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

if ($s.Contains("  {v:'37.32',what:")) { throw "check 37.32 is in the fixture already" }

SubRx @'
  {v:'37.31',what:
'@ @'
  {v:'37.32',what:'a decoy pings a plain warden but not the Overseer (his answer g-13: the Overseer ignores decoys)',
   run:function(){
     if(typeof mkWarden!=='function'||typeof bossLair!=='function'||typeof updateThrowables!=='function'||typeof __ents!=='function') return 'SKIP: no warden, lair or throwable helper';
     var g=null, p, ls, ov, wd, dx, dy;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no raid';
       p=g.player; p.iv=99; p.hp=100; p.downed=false;
       ls=bossLair();
       ov=mkWarden(ls.x,ls.y); ov.boss=1; ov.name=BOSS_NAME; ov.lairX=ls.x; ov.lairY=ls.y; ov.tx=ls.x; ov.ty=ls.y; ov.state='patrol'; ov.cd=9; ov.seenYou=false; ov.alert=0;
       wd=mkWarden(ls.x+100,ls.y); wd.state='patrol'; wd.cd=9; wd.seenYou=false; wd.alert=0; wd.tx=wd.x; wd.ty=wd.y;
       g.ents=[ov,wd]; g.decoys.length=0; g.pings.length=0;
       p.x=ls.x+(ls.x>1500?-1400:1400); p.y=ls.y;
       dx=ls.x+200; dy=ls.y;
       g.decoys.push({x:dx,y:dy,t:0,life:6,acc:.7});
       updateThrowables(0.12); __ents(0.12);   // 0.7+0.1 is 0.7999 in floats and would not ping yet
       if(Math.abs(wd.tx-dx)>2||Math.abs(wd.ty-dy)>2) return 'SKIP: the decoy did not reach the plain warden ('+Math.round(wd.tx)+','+Math.round(wd.ty)+'), staging is off';
       if(Math.abs(ov.tx-ls.x)>2||Math.abs(ov.ty-ls.y)>2) return 'a decoy pulled the Overseer off its lair (tx,ty '+Math.round(ov.tx)+','+Math.round(ov.ty)+')';
       return null;
     } finally {
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'37.31',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
