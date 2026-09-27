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

if ($s.Contains("  {v:'16.47',what:")) { throw "check 16.47 is in the fixture already" }

SubRx @'
  {v:'16.46',what:
'@ @'
  {v:'16.47',what:'a controller places a map marker: the right stick moves a map cursor and a D-UP tap places the marker there',
   run:function(){
     var src='', i;
     try{ var ss=document.getElementsByTagName('script'); for(i=0;i<ss.length;i++) src+=ss[i].textContent||''; }catch(e){ return 'SKIP: the build cannot read its own script'; }
     var cut=src.indexOf('window.__frame=function'); if(cut>0) src=src.slice(0,cut);
     if(src.indexOf('if(G&&!G.over&&G.mapOpen&&G.player&&(rx||ry||G.mapCur)){')<0) return 'the right stick does not move a map cursor';
     if(src.indexOf('if(G.mapOpen&&G.mapCur) netWpFromMap();')<0) return 'a D-UP tap does not place the marker at the map cursor';
     if(typeof netWpFromMap!=='function'||typeof mapProj!=='function') return 'no map marker path';
     var kG=G, oS=say, oB=blip, r;
     try{
       say=function(){}; blip=function(){};
       var MP=mapProj(); G={waypoint:null};
       mouse.x=MP.ox+100*MP.sc; mouse.y=MP.oy+200*MP.sc;
       r=netWpFromMap();
     } finally { G=kG; say=oS; blip=oB; }
     if(!r||Math.abs(r.x-100)>2||Math.abs(r.y-200)>2) return 'the marker did not land under the map cursor ('+JSON.stringify(r)+')';
     return null; }},
  {v:'16.46',what:
'@


$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
