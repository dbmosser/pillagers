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

if ($s.Contains("  {v:'18.69',what:")) { throw "check 18.69 is in the fixture already" }

SubRx @'
  {v:'18.68',what:
'@ @'
  {v:'18.69',what:'zone names on the sector maps never print into each other: on every sector preview no two drawn names overlap',
   run:function(){
     if(typeof sectorPreviewDraw!=='function'||typeof FIXED_MAPS==='undefined') return 'SKIP: no sector previews here';
     var bad=[], mi, M, cv2, c2, boxes, i, j, A, B, n=0;
     for(mi=0;mi<FIXED_MAPS.length;mi++){
       M=FIXED_MAPS[mi]; if(!M||!M.zones) continue;
       cv2=document.createElement('canvas'); cv2.width=420; cv2.height=Math.round(420*M.h/M.w); c2=cv2.getContext('2d'); boxes=[];
       c2.fillText=function(s,x,y){ var m=CanvasRenderingContext2D.prototype.measureText.call(this,String(s)), fsz=parseFloat(String(this.font).replace(/^[^0-9]*/,''))||11; boxes.push({s:String(s),l:x-m.width/2,r:x+m.width/2,t:y-fsz*0.8,b:y+fsz*0.2}); return CanvasRenderingContext2D.prototype.fillText.apply(this,arguments); };
       try{ sectorPreviewDraw(cv2,M); }catch(e){ bad.push(M.name+' threw: '+(e&&e.message||e)); continue; }
       for(i=0;i<boxes.length;i++) for(j=i+1;j<boxes.length;j++){ A=boxes[i]; B=boxes[j]; n++;
         if(A.l<B.r-1&&B.l<A.r-1&&A.t<B.b-1&&B.t<A.b-1) bad.push(M.name+': '+A.s+' prints into '+B.s); }
     }
     if(!n) return 'SKIP: no zone names were drawn';
     return bad.length?bad.slice(0,4).join('; '):null; }},
  {v:'18.68',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
