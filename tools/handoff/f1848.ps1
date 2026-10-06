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

if ($s.Contains("  {v:'18.48',what:")) { throw "check 18.48 is in the fixture already" }

SubRx @'
  {v:'18.47',what:
'@ @'
  {v:'18.48',what:'the baked sprites are sharp at any scale: the sprite scale rounds up (2.6 gives 3) and reaches 4 for 4K, a shadow stamp takes the scale of the canvas it is drawn on, and a lost canvas drops every sprite store',
   run:function(){
     if(typeof wallSpriteScale!=='function'||typeof SHADSPR==='undefined') return 'SKIP: no baked sprites here';
     var bad=[], oZ=ZOOM, oD=DPR, cv2=document.createElement('canvas'), oWc=wc, src='';
     try{
       ZOOM=function(){ return 2.6; }; DPR=1;
       if(wallSpriteScale()!==3) bad.push('a scale of 2.6 bakes at '+wallSpriteScale());
       ZOOM=function(){ return 2.0; }; DPR=2;
       if(wallSpriteScale()!==4) bad.push('a scale of 4 bakes at '+wallSpriteScale());
       ZOOM=oZ; DPR=oD;
       cv2.width=300; cv2.height=300; wc=cv2.getContext('2d'); wc.setTransform(3,0,0,3,0,0);
       SHADSPR.m={}; SHADSPR.n=0; SHADSPR.ss=0;
       shadowE(40,40,20,8,0.3);
       if(SHADSPR.ss!==3) bad.push('a shadow on a canvas scaled 3 was stamped at '+SHADSPR.ss);
       src=onCtxRestored.toString();
       ['WALLSPR','VEGSPR','SHADSPR','ICONSPR'].forEach(function(k){ if(src.indexOf(k)<0) bad.push('a restored canvas keeps the old '+k); });
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ ZOOM=oZ; DPR=oD; wc=oWc; SHADSPR.m={}; SHADSPR.n=0; SHADSPR.ss=0; }
     return bad.length?bad.join('; '):null; }},
  {v:'18.47',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
