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

if ($s.Contains("  {v:'26.14',what:")) { throw "check 26.14 is in the fixture already" }

SubRx @'
  {v:'26.13',what:
'@ @'
  {v:'26.14',what:'the team lamp on the shoulder strap shows in front of a held rifle or carbine whichever way the body faces',
   run:function(){
     if(typeof drawOp!=='function'||typeof wc==='undefined'||typeof TEAMCOL==='undefined'||typeof WEAPONS==='undefined') return 'SKIP: no drawOp or team colours here';
     var c=document.createElement('canvas'); c.width=300; c.height=300; var x=c.getContext('2d'), w0=wc, bad=[], names=['E','SE','S','SW','W','NW','N','NE'], guns=['carbine','rifle'], gi, fi, n, d, px, py, k, wep, s, hid=[], tried=0;
     function blue(r,g,b){ return b>220&&g>150&&g<200&&r<130; }
     try{
       for(gi=0;gi<guns.length;gi++){
         wep=WEAPONS[guns[gi]]; if(!wep) continue;
         for(fi=0;fi<8;fi++){
           s={moving:false,sprint:false,ads:false,hurt:0,rl:0,bulk:0,build:'lean',hair:'dark',cut:'crop',skin:'fair',team:'ally',own:{wep:wep}};
           x.setTransform(1,0,0,1,0,0); x.clearRect(0,0,300,300); x.setTransform(6,0,0,6,100,280); wc=x;
           try{ drawOp(0,0,fi*Math.PI/4,0,'#5a6a5a',0,0,'',0,s); } finally{ wc=w0; }
           d=x.getImageData(0,0,300,300).data; n=0; tried++;
           for(py=Math.round(280+6*-23.0);py<=Math.round(280+6*-20.6);py++) for(px=Math.round(100+6*-4.4);px<=Math.round(100+6*-2.0);px++){ k=(py*300+px)*4; if(d[k+3]>200&&blue(d[k],d[k+1],d[k+2])) n++; }
           if(n<30) hid.push(guns[gi]+' facing '+names[fi]+' ('+n+' blue pixels)');
         }
       }
       if(!tried) return 'SKIP: no rifle or carbine here';
       if(hid.length) bad.push('the team lamp is hidden under the held gun: '+hid.join(', '));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ wc=w0; }
     return bad.length?bad.join('; '):null; }},
  {v:'26.13',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
