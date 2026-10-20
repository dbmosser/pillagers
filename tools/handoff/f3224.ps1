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

if ($s.Contains("  {v:'32.24',what:")) { throw "check 32.24 is in the fixture already" }

SubRx @'
  {v:'32.23',what:
'@ @'
  {v:'32.24',what:'the fire chip above the belt is not lime filled: the keycap behind the word fire is not the accent colour',
   run:function(){
     if(typeof __frame!=='function') return 'SKIP: no frame helper';
     var PR=CanvasRenderingContext2D.prototype, of=PR.fillText, ofl=PR.fill, ac=(function(){ var c=document.createElement('canvas').getContext('2d'); c.fillStyle=UIC.acc; return String(c.fillStyle); })(), g=null, seen=0, lime=0, lastFill='';
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:['bandage','medkit','gun_rifle'],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no raid';
       g.legendOn=0;
       PR.fill=function(){ lastFill=String(this.fillStyle); return ofl.apply(this,arguments); };
       PR.fillText=function(s){ if(String(s).toLowerCase()==='fire'){ seen++; if(lastFill===ac) lime++; } return of.apply(this,arguments); };
       __frame(); __frame();
       PR.fillText=of; PR.fill=ofl;
       if(!seen) return 'the fire keycap was never drawn';
       if(lime) return 'the fire chip is filled with the lime accent ('+lime+' of '+seen+')';
       return null;
     } finally {
       PR.fillText=of; PR.fill=ofl;
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'32.23',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
