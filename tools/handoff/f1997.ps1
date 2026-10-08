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

if ($s.Contains("  {v:'19.97',what:")) { throw "check 19.97 is in the fixture already" }

SubRx @'
  {v:'19.96',what:
'@ @'
  {v:'19.97',what:'a sector thumbnail zone name clears the extraction rings: a name whose zone centre sits on a ring is drawn above or below the ring, not through it',
   run:function(){
     if(typeof sectorPreviewDraw!=='function') return 'SKIP: no sector thumbnails here';
     var cv=document.createElement('canvas'), c, rec=[], M, sc, rx, ry, r, i, bad=[], hh;
     cv.width=300; cv.height=300; c=cv.getContext('2d'); if(!c) return 'SKIP: no canvas';
     M={w:1000,h:1000,zones:[{x:0,y:0,w:1000,h:1000,name:'ZQ ZONE'}],extracts:[{x:500,y:500}]};
     c.fillText=function(t,x,y){ rec.push({t:String(t),x:x,y:y,w:c.measureText(String(t)).width,f:c.font}); return CanvasRenderingContext2D.prototype.fillText.apply(c,arguments); };
     try{ sectorPreviewDraw(cv,M); }catch(e){ return 'threw: '+(e&&e.message||e); }
     sc=0.3; rx=150; ry=150; r=Math.max(4,78*sc);
     for(i=0;i<rec.length;i++){ if(rec[i].t!=='ZQ ZONE') continue; hh=(parseFloat((/(\d+)px/.exec(rec[i].f)||[0,11])[1])||11)*0.5; var cyl=rec[i].y-3; if(Math.abs(cyl-ry)<r+hh) bad.push('the zone name is drawn through the ring (centre '+Math.round(cyl)+', ring '+ry+' r '+Math.round(r)+')'); }
     if(!rec.some(function(q){ return q.t==='ZQ ZONE'; })) return 'SKIP: the zone name was not drawn';
     return bad.length?bad.join('; '):null; }},
  {v:'19.96',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
