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

if ($s.Contains("  {v:'32.12',what:")) { throw "check 32.12 is in the fixture already" }

SubRx @'
  {v:'32.11',what:
'@ @'
  {v:'32.12',what:'the extract distance line sits on a plate: a plate fill is drawn right before the words',
   run:function(){
     if(typeof __frame!=='function') return 'SKIP: no frame helper';
     var PR=CanvasRenderingContext2D.prototype, of=PR.fillText, ofl=PR.fill, pn=(function(){ var c=document.createElement('canvas').getContext('2d'); c.fillStyle=HUDC.plate; return String(c.fillStyle); })(), g=null, seen=0, plated=0, lastFill=false;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no raid';
       PR.fill=function(){ lastFill=(String(this.fillStyle)===pn); return ofl.apply(this,arguments); };
       PR.fillText=function(s){ var t=String(s).toUpperCase(); if(/^EXTRACT(ION)? \d+M$/.test(t)){ seen++; if(lastFill) plated++; } lastFill=false; return of.apply(this,arguments); };
       __frame(); __frame();
       PR.fillText=of; PR.fill=ofl;
       if(!seen) return 'SKIP: no extract distance line drawn';
       if(plated<seen) return 'the extract distance line is bare text, drawn with no plate under it ('+plated+' of '+seen+')';
       return null;
     } finally {
       PR.fillText=of; PR.fill=ofl;
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'32.11',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
