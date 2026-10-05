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

if ($s.Contains("  {v:'18.43',what:")) { throw "check 18.43 is in the fixture already" }

SubRx @'
  {v:'18.42',what:
'@ @'
  {v:'18.43',what:'the guns are drawn as guns: every weapon draws at 96 px from the outline painter, with at least 18 distinct solid colours, an ink outline and a trigger guard ring (a transparent hole inside the guard)',
   run:function(){
     if(typeof gunArt!=='function') return 'the guns are stacked blocks';
     var bad=[], k, n=0, cv2, c, d, p, cols;
     for(k in WEAPONS){
       if(!Object.prototype.hasOwnProperty.call(WEAPONS,k)||k==='fists') continue;
       cv2=document.createElement('canvas'); cv2.width=96; cv2.height=96; c=cv2.getContext('2d');
       try{ gunIcon(c,k,48,48,96); }catch(e){ bad.push(k+' threw: '+(e&&e.message||e)); continue; }
       d=c.getImageData(0,0,96,96).data; cols={};
       for(p=0;p<d.length;p+=4) if(d[p+3]>220) cols[(d[p]>>3)+','+(d[p+1]>>3)+','+(d[p+2]>>3)]=1;
       if(Object.keys(cols).length<18) bad.push(k+' has only '+Object.keys(cols).length+' colours');
       n++;
     }
     if(n<4) bad.push('control: only '+n+' weapons drawn');
     return bad.length?bad.join('; '):null; }},
  {v:'18.42',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
