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

if ($s.Contains("  {v:'28.75',what:")) { throw "check 28.75 is in the fixture already" }

SubRx @'
  {v:'28.74',what:
'@ @'
  {v:'28.75',what:'a named cache keeps its name over the walls: the name is drawn in the world text pass after every wall (his picture of CHILL ROW CACHE cut by a wall)',
   run:function(){
     if(typeof __frame!=='function') return 'SKIP: no frame helper';
     var PR=CanvasRenderingContext2D.prototype, of=PR.fillText, g=null, ct=null, i, c, hits=[];
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no raid';
       for(i=0;i<g.containers.length;i++){ c=g.containers[i]; if(c.cache&&c.tag&&!c.strong){ ct=c; break; } }
       if(!ct) return 'SKIP: no named cache on this map';
       g.player.x=ct.x; g.player.y=ct.y+90;
       PR.fillText=function(s){ if(String(s)===String(ct.tag)) hits.push((/_wtA/).test(String(new Error().stack))); return of.apply(this,arguments); };
       __frame(); __frame();
       PR.fillText=of;
       if(!hits.length) return 'the cache name '+ct.tag+' was not drawn with the player beside it';
       for(i=0;i<hits.length;i++) if(!hits[i]) return 'the cache name '+ct.tag+' is drawn in the depth-sorted world pass, where a wall in front of the box covers it';
       return null;
     } finally {
       PR.fillText=of;
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'28.74',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
