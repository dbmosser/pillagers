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

if ($s.Contains("  {v:'30.96',what:")) { throw "check 30.96 is in the fixture already" }

SubRx @'
  {v:'30.95',what:
'@ @'
  {v:'30.96',what:'the score cluster at the top centre sits on one plate: label, number and clock, hung from the top edge (the critic, 10-19)',
   run:function(){
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object'||typeof arcadeScoreHud!=='function') return 'SKIP: no arcade here';
     var g=null, oHp, calls=[], b, rs=say, pl, own=false;
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player||!raidClockOn()) return 'SKIP: no live arcade raid with a clock';
       say=function(){}; own=true;
       oHp=hudPlate; g.timeLeft=300;
       hudPlate=function(x,y,w,h){ calls.push({x:x,y:y,w:w,h:h}); return oHp.apply(this,arguments); };
       try{ b=arcadeScoreHud(60,1); } finally { hudPlate=oHp; }
       pl=calls.filter(function(c){ return c.y<=0&&c.x<W/2&&c.x+c.w>W/2; })[0];
       if(!pl) return 'no plate hangs from the top edge behind the score ('+calls.length+' plates)';
       if(pl.y+pl.h<(b||0)-2) return 'the plate ends at '+(pl.y+pl.h)+', above the bottom of the clock row '+b;
       if(Math.abs((pl.x+pl.w/2)-W/2)>2) return 'the plate is not centred';
       return null;
     } finally {
       if(own) say=rs;
       try{ if(oHp) hudPlate=oHp; }catch(_e){}
       try{ __endRaid('abandon'); }catch(_e2){}
       __topClear();
     } }},
  {v:'30.95',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
