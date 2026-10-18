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

if ($s.Contains("  {v:'31.21',what:")) { throw "check 31.21 is in the fixture already" }

SubRx @'
  {v:'31.20',what:
'@ @'
  {v:'31.21',what:'the stamina word does not reach the belt: it ends left of belt slot 1 at 1080p (the critic, 10-19: it overlapped slot 1)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy';
     var g=null, oFT=ctx.fillText, at=null, aw=0, cv=ctx.canvas;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:['gun_shotgun','gun_rifle'],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: staging: no raid';
       g.bagOpen=false; g.mapOpen=false; g.paused=false; keys={}; mouse.down=false;
       ctx.fillText=function(s,x,y){ if(String(s)==='STAMINA'||String(s)==='WINDED'){ at=x; aw=ctx.measureText(String(s)).width; } return oFT.apply(this,arguments); };
       try{ __frame(0.016); }finally{ ctx.fillText=oFT; }
       if(at===null) return 'the stamina word is not drawn';
       if(at+aw>16+300+8+aw+1) return 'the stamina word starts too far right (x '+at+')';
       if(at>16+300+9) return 'the stamina word is past the 300 wide bar end plus gap (x '+at+')';
       return null;
     } finally {
       ctx.fillText=oFT;
       try{ __endRaid('abandon'); }catch(_e2){}
       __topClear();
     } }},
  {v:'31.20',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
