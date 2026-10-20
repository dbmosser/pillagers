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

if ($s.Contains("  {v:'32.13',what:")) { throw "check 32.13 is in the fixture already" }

SubRx @'
  {v:'32.12',what:
'@ @'
  {v:'32.13',what:'the gun name on the gun card is smaller than the head size, so the ammo figure is the hero',
   run:function(){
     if(typeof __frame!=='function') return 'SKIP: no frame helper';
     var PR=CanvasRenderingContext2D.prototype, of=PR.fillText, g=null, fs=[], nm='', px=function(f){ var m=/([\d.]+)px/.exec(String(f)); return m?+m[1]:0; };
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||!g.player.wep) return 'SKIP: no raid';
       nm=String(g.player.wep.name).toLowerCase();
       PR.fillText=function(s){ if(String(s).toLowerCase()===nm&&this.textAlign==='right') fs.push(px(this.font)); return of.apply(this,arguments); };
       __frame(); __frame();
       PR.fillText=of;
       if(!fs.length) return 'SKIP: the gun name was not drawn on the card';
       var head=px(FS(TYPE.head));
       for(var i=0;i<fs.length;i++) if(fs[i]>=head-0.01) return 'the gun name is drawn at '+fs[i]+'px, the head size, as heavy as the ammo figure';
       return null;
     } finally {
       PR.fillText=of;
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'32.12',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
