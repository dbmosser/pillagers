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

if ($s.Contains("  {v:'27.91',what:")) { throw "check 27.91 is in the fixture already" }

SubRx @'
  {v:'27.90',what:
'@ @'
  {v:'27.91',what:'the big map draws the player as a neon green chevron (his order: easier to see)',
   run:function(){
     if(typeof drawMapOverlay!=='function') return 'SKIP: this build has no big map';
     var PR=CanvasRenderingContext2D.prototype, of=PR.fill, seen=[], g=null, n=0;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no raid to open the map in';
       g.mapOpen=true;
       PR.fill=function(){ n++; try{ seen.push(String(this.fillStyle).toLowerCase()); }catch(_e){} return of.apply(this,arguments); };
       drawMapOverlay();
       PR.fill=of;
       if(!n) return 'SKIP: the big map drew nothing in this fixture';
       if(seen.indexOf('#39ff14')<0) return 'the player marker on the big map is not neon green ('+n+' fills, none #39ff14)';
       return null;
     } finally {
       PR.fill=of;
       try{ if(g) g.mapOpen=false; }catch(_m){}
       try{ __endRaid('abandon'); }catch(_r){}
       __topClear();
     } }},
  {v:'27.90',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
