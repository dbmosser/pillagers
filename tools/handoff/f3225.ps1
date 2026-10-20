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

if ($s.Contains("  {v:'32.25',what:")) { throw "check 32.25 is in the fixture already" }

SubRx @'
  {v:'32.24',what:
'@ @'
  {v:'32.25',what:'the bottom left feed is not drawn over the open map: with a line in the feed and the map open, no feed row is laid out',
   run:function(){
     if(typeof __frame!=='function') return 'SKIP: no frame helper';
     var g=null, before=-1, during=-1, after=-1;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:['bandage','medkit','gun_rifle'],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no raid';
       g.legendOn=0; g.mapFirst=false; g.mapOpen=false;
       say('FEED MAP PROBE','info');
       __frame(0.016); __frame(0.016);
       before=FEEDBOX.rows.length;
       if(!before) return 'control failed: the feed drew no row with the map shut';
       g.mapOpen=true; __frame(0.016); __frame(0.016);
       during=FEEDBOX.rows.length;
       g.mapOpen=false; __frame(0.016); __frame(0.016);
       after=FEEDBOX.rows.length;
       if(during) return 'the feed drew '+during+' rows over the open map';
       if(!after) return 'the feed did not come back after the map closed';
       return null;
     } finally {
       try{ var g2=__state(); if(g2){ g2.mapOpen=false; } }catch(_e){}
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'32.24',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
