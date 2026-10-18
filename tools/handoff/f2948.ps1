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

if ($s.Contains("  {v:'29.48',what:")) { throw "check 29.48 is in the fixture already" }

SubRx @'
  {v:'29.47',what:
'@ @'
  {v:'29.48',what:'the mouse cursor shows (the arrow, and no reticle) while the item wheel is open with a mouse, and the reticle cursor is back when it closes (his order 2026-10-15)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: no raid here';
     var g=null, bad=[], cur0=_curNow, st0=null;
     try{ st0=cv.style.cursor; }catch(_c){}
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no raid';
       g.bag=['bandage','medkit']; g.paused=false; g.bagOpen=false; g.mapOpen=false; g.wheel=null; g.player.hand=null; g.player.iv=99;
       keys={}; mouse.down=false;
       _curNow='none'; cv.style.cursor='none';
       if(!wheelOpen()||!g.wheel) return 'SKIP: the wheel did not open';
       g.wheel.pad=0;
       try{ render2D(0); }catch(_r){}
       drawHUD();
       if(cv.style.cursor!=='default') bad.push('with the wheel open the cursor is '+cv.style.cursor+', not the arrow');
       g.wheel=null; drawHUD();
       if(cv.style.cursor!=='none') bad.push('after the wheel closed the cursor is '+cv.style.cursor+', not the reticle cursor');
       return bad.length?bad.join('; '):null;
     } finally {
       try{ if(g) g.wheel=null; }catch(_w){}
       try{ _curNow=cur0; if(st0!==null) cv.style.cursor=st0; }catch(_c2){}
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'29.47',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
