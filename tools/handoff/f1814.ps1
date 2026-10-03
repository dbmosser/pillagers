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

if ($s.Contains("  {v:'18.14',what:")) { throw "check 18.14 is in the fixture already" }

SubRx @'
  {v:'18.13',what:
'@ @'
  {v:'18.14',what:'the item icons get a lift: a flat grey square run through the lift is lighter at its top left than at its bottom right and casts a shadow just outside its edge, and the menu icon painter runs the lift on its icons',
   run:function(){
     if(typeof iconLift!=='function'||typeof itemIconURL!=='function') return 'the item icons are flat';
     var bad=[], cv2=document.createElement('canvas'), c, tl, br, sh, needle='iconLi'+'ft(';
     cv2.width=80; cv2.height=80; c=cv2.getContext('2d');
     function lum(x,y){ var d=c.getImageData(x,y,1,1).data; return d[0]*0.3+d[1]*0.59+d[2]*0.11; }
     try{
       c.fillStyle='#808080'; c.fillRect(20,20,40,40);
       if(!iconLift(c,80,80)) bad.push('the lift refused a plain canvas');
       tl=lum(24,24); br=lum(56,56);
       if(!(tl>br+10)) bad.push('no lift: top left '+tl.toFixed(0)+' against bottom right '+br.toFixed(0));
       sh=c.getImageData(61,62,1,1).data[3];
       if(!(sh>10)) bad.push('no shadow beside the shape (alpha '+sh+')');
       if(itemIconURL.toString().indexOf(needle)<0) bad.push('the menu icons do not get the lift');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     return bad.length?bad.join('; '):null; }},
  {v:'18.13',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
