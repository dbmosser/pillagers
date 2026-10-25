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

if ($s.Contains("  {v:'34.71',what:")) { throw "check 34.71 is in the fixture already" }

SubRx @'
  {v:'34.70',what:
'@ @'
  {v:'34.71',what:'the raid backpack card has a close button inside it and a click on it closes the backpack like ESC (his Q1)',
   run:function(){
     var g, bp, cb, f;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:['gun_carbine','medkit','bandage','bandage','plate','frag','smoke'],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no raid';
       g.ents.length=0; g.player.iv=99; g.bagOpen=true;
       for(f=0;f<8;f++) __loop(performance.now()+f*16.7);
       bp=g.bagPanel; cb=g.bagClose;
       if(!bp) return 'the backpack panel was not drawn';
       if(!cb) return 'the raid backpack has no close button';
       if(cb.x<bp.x||cb.y<bp.y||cb.x+cb.w>bp.x+bp.w||cb.y+cb.h>bp.y+bp.h) return 'the close button is outside the backpack card';
       g.drag={key:'medkit',bagIx:0};
       mouse.x=cb.x+cb.w/2; mouse.y=cb.y+cb.h/2;
       cv.dispatchEvent(new MouseEvent('mousedown',{button:0,bubbles:true,cancelable:true}));
       if(g.bagOpen) return 'a click on the close button left the backpack open';
       if(g.drag) return 'the close button left a held drag';
       return null;
     } finally {
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'34.70',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
