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

if ($s.Contains("  {v:'33.87',what:")) { throw "check 33.87 is in the fixture already" }

SubRx @'
  {v:'33.86',what:
'@ @'
  {v:'33.87',what:'cw-cx-propsread: opened pixel containers blit at 72 percent opacity, closed ones stay opaque and vector mode retains 62 percent',
   run:function(){
     var cfg=CFG.xfPix, blit=pixBlit, wc0=wc, seen=[], bad=[], ct;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile(); CFG.xfPix=1;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); keys={}; __frame(0);
       wc0=wc;
       pixBlit=function(){ seen.push(wc.globalAlpha); return blit.apply(this,arguments); };
       ct={x:G.player.x,y:G.player.y,r:15,type:'crate',opened:true,loot:[],time:1,prog:0};
       for(var i=0;i<3&&!seen.length;i++){ pixFrame(); drawContS(ct); }
       if(!seen.length||Math.abs(seen[seen.length-1]-0.72)>0.001) bad.push('opened pixel alpha '+seen.join(','));
       ct.opened=false; seen=[];
       for(i=0;i<3&&!seen.length;i++){ pixFrame(); drawContS(ct); }
       if(!seen.length||seen[seen.length-1]!==1) bad.push('closed pixel alpha '+seen.join(','));
       pixBlit=blit; CFG.xfPix=0; ct.opened=true;
       var own=Object.getOwnPropertyDescriptor(wc,'fillRect'), fill=wc.fillRect, alpha=[];
       wc.fillRect=function(){ alpha.push(wc.globalAlpha); return fill.apply(this,arguments); };
       try{ drawContS(ct); }finally{ if(own) Object.defineProperty(wc,'fillRect',own); else delete wc.fillRect; }
       if(!alpha.some(function(a){ return Math.abs(a-0.62)<0.001; })) bad.push('vector open dim changed');
       return bad.length?bad.join('; '):null;
     } finally{
       pixBlit=blit; wc=wc0;
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       keys={}; __resetCfg(); __topClear(); __cleanProfile(); CFG.xfPix=cfg;
     }
   }},
  {v:'33.86',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
