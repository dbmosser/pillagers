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

if ($s.Contains("  {v:'33.65',what:")) { throw "check 33.65 is in the fixture already" }

SubRx @'
  {v:'33.64',what:
'@ @'
  {v:'33.65',what:'cw-pixcrowd (86c): THE PIXEL UNDERCROFT CROWD. With the pixel look on, a plain pillager drawn on the Undercroft canvas is the pixel body (you, the crowd and the party), a body on any other small canvas is still the vector one, and with the look off nothing is pixel',
   run:function(){
     if(typeof pixBodyTry!=='function'||typeof hcv==='undefined'||!hcv) return 'no pixel body or no hub canvas';
     if(!(window.__topClear&&window.__runPrep)) return 'SKIP: this fixture cannot draw bodies';
     var bad=[], keep=wc, hx, oc, ox, b0, st, n, f0;
     function body(c2){   // a few frames so the bake budget lets every layer in
       var j, before=PIX.bodies;
       for(j=0;j<14&&PIX.bodies===before;j++){
         pixFrame(); wc=c2; c2.save(); c2.setTransform(2,0,0,2,200,200);
         try{ drawOp(0,0,0,0,'#242832',0,0,'none',0,{hero:1,moving:false,sprint:false,ads:false,hurt:0,rl:0,own:{wep:null}}); } finally { c2.restore(); wc=keep; }
       }
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       hx=hcv.getContext('2d'); oc=document.createElement('canvas'); oc.width=128; oc.height=128; ox=oc.getContext('2d');
       f0=pixFaults();
       CFG.xfPix=1; b0=PIX.bodies; body(hx); n=PIX.bodies-b0;
       if(n!==1) bad.push('a body on the hub canvas gave '+n+' pixel bodies, not 1');
       b0=PIX.bodies; body(ox); n=PIX.bodies-b0;
       if(n!==0) bad.push('a body on a small canvas gave '+n+' pixel bodies, not 0');
       CFG.xfPix=0; b0=PIX.bodies; body(hx); n=PIX.bodies-b0;
       if(n!==0) bad.push('with the look off a hub body gave '+n+' pixel bodies');
       if(pixFaults()>f0) bad.push('the pixel paths logged a fault');
       return bad.length?bad.join('; '):null;
     } catch(err){
       return 'pixel crowd check: '+String(err&&err.message||err);
     } finally {
       wc=keep; CFG.xfPix=0;
       keys={}; __resetCfg(); __topClear(); __cleanProfile();
     } }},
  {v:'33.64',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
