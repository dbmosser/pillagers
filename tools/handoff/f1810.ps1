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

if ($s.Contains("  {v:'18.10',what:")) { throw "check 18.10 is in the fixture already" }

SubRx @'
  {v:'18.09',what:
'@ @'
  {v:'18.10',what:'the gun icons are painted like objects: every weapon draws without throwing at 22 and at 160 px, and on a 160 px pistol the slide is lighter along its top edge than along its underside (the bevel)',
   run:function(){
     if(typeof gunIcon!=='function'||typeof WEAPONS==='undefined') return 'SKIP: no gun painter here';
     var bad=[], cv2=document.createElement('canvas'), c2, k, n=0, top, bot, S=160, u=S/40;
     cv2.width=S; cv2.height=S; c2=cv2.getContext('2d');
     function lum(x,y){ var d=c2.getImageData(Math.round(x),Math.round(y),1,1).data; return d[0]*0.3+d[1]*0.59+d[2]*0.11; }
     try{
       for(k in WEAPONS){ if(!Object.prototype.hasOwnProperty.call(WEAPONS,k)||k==='fists') continue; c2.clearRect(0,0,S,S); gunIcon(c2,k,S/2,S/2,S); gunIcon(c2,k,S/2,S/2,22); n++; }
       if(n<4) bad.push('control: only '+n+' weapons to paint');
       c2.clearRect(0,0,S,S); gunIcon(c2,'pistol',S/2,S/2,S);
       // x +6 units: forward of the frame (ends at +2) and short of the front sight (from +8), so nothing lies over the slide there on either painter
       top=lum(S/2+6*u,S/2-6*u); bot=lum(S/2+6*u,S/2-1*u);
       if(!(top>bot+12)) bad.push('the slide has no bevel: top '+top.toFixed(0)+' against underside '+bot.toFixed(0));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     return bad.length?bad.join('; '):null; }},
  {v:'18.09',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
