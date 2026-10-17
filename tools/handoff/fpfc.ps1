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

if ($s.Contains("  {v:'28.96',what:")) { throw "check 28.96 is in the fixture already" }

SubRx @'
  {v:'28.95',what:
'@ @'
  {v:'28.96',what:'the heal bar over the head is drawn in the world text pass, after every wall (his order: bars above the head are never blocked by buildings)',
   run:function(){
     if(typeof __frame!=='function') return 'SKIP: no frame helper';
     var PR=CanvasRenderingContext2D.prototype, of=PR.fillRect, g=null, p=null, hits=[], i;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no raid';
       p=g.player; p.prep={t:10,max:30,kind:'heal',key:'bandage'};
       PR.fillRect=function(x,y,w,h){ if(this.fillStyle==='#6fe0a0'&&h===9) hits.push((/_wtA/).test(String(new Error().stack))); return of.apply(this,arguments); };
       __frame(); __frame();
       PR.fillRect=of;
       if(!hits.length) return 'the heal bar was not drawn while a heal was applying';
       for(i=0;i<hits.length;i++) if(!hits[i]) return 'the heal bar is drawn in the depth-sorted world pass, where a wall in front of the player covers it';
       return null;
     } finally {
       PR.fillRect=of;
       try{ if(p) p.prep=null; }catch(_p){}
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'28.95',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
