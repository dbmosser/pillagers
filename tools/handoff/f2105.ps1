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

if ($s.Contains("  {v:'21.05',what:")) { throw "check 21.05 is in the fixture already" }

SubRx @'
  {v:'21.04',what:
'@ @'
  {v:'21.05',what:'a sector map marker tag stays inside the map frame: a locked room tag on the right edge of the map and one on the left edge are both drawn wholly inside the frame',
   run:function(){
     if(typeof mapLabel!=='function'||typeof mapLabelReset!=='function'||typeof mapProj!=='function') return 'SKIP: no map tags here';
     if(!(W>0&&H>0)) return 'SKIP: no screen';
     var bad=[], oFT=ctx.fillText, rec=[], M=mapProj(), fl=M.ox, fr=M.ox+WORLD_W*M.sc, t1='ZQX COLD VAULT  -  LOCKED', t2='ZQY EAST SAFE  -  LOCKED', i, r, saved=false;
     try{
       ctx.save(); saved=true;
       ctx.fillText=function(s,x,y){ rec.push({s:String(s),x:x,w:CanvasRenderingContext2D.prototype.measureText.call(ctx,String(s)).width,ta:ctx.textAlign}); };
       mapLabelReset();
       mapLabel(t1,fr-4,M.oy+M.sc*WORLD_H*0.3,'#ffc04a');
       mapLabel(t2,fl+4,M.oy+M.sc*WORLD_H*0.7,'#ffc04a');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; if(saved){ try{ ctx.restore(); }catch(_r){} } try{ mapLabelReset(); }catch(_m){} }
     var seen=0;
     for(i=0;i<rec.length;i++){ r=rec[i]; if(r.s!==t1&&r.s!==t2) continue; seen++;
       if(r.ta!=='center'){ bad.push(r.s+' was drawn '+r.ta+' aligned'); continue; }
       if(r.x+r.w/2>fr+1) bad.push(r.s+' runs '+Math.round(r.x+r.w/2-fr)+' px past the right of the map frame');
       if(r.x-r.w/2<fl-1) bad.push(r.s+' runs '+Math.round(fl-(r.x-r.w/2))+' px past the left of the map frame'); }
     if(!seen&&!bad.length) return 'SKIP: no tag was drawn';
     return bad.length?bad.join('; '):null; }},
  {v:'21.04',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
