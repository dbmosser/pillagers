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

if ($s.Contains("  {v:'18.80',what:")) { throw "check 18.80 is in the fixture already" }

SubRx @'
  {v:'18.79',what:
'@ @'
  {v:'18.80',what:'the outfit previews fill their tiles: a fresh preview paints a figure at least 100 of its 128 pixels tall and wholly inside the picture, for every outfit',
   run:function(){
     if(typeof outfitPreviewURL!=='function'||typeof OUTFITS==='undefined') return 'SKIP: no outfit previews here';
     var ids=Object.keys(OUTFITS), bad=[], i, k, cv2, d, x, y, top, bot, w, h;
     for(i=0;i<ids.length;i++){
       for(k in OUTPREV) delete OUTPREV[k];
       outfitPreviewURL(ids[i]); cv2=OUTPREV._cv;
       if(!cv2){ bad.push('no preview canvas was kept to measure'); break; }
       w=cv2.width; h=cv2.height; d=cv2.getContext('2d').getImageData(0,0,w,h).data; top=999; bot=-1;
       for(y=0;y<h;y++) for(x=0;x<w;x++) if(d[(y*w+x)*4+3]>40){ if(y<top) top=y; if(y>bot) bot=y; }
       if(bot<0){ bad.push(ids[i]+' painted nothing'); continue; }
       if(bot-top+1<100) bad.push(ids[i]+' is only '+(bot-top+1)+' of '+h+' pixels tall');
       if(top<=0||bot>=h-1) bad.push(ids[i]+' runs off the picture');
     }
     return bad.length?bad.slice(0,3).join('; '):null; }},
  {v:'18.79',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
