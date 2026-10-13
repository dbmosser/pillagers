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

if ($s.Contains("  {v:'24.61',what:")) { throw "check 24.61 is in the fixture already" }

SubRx @'
  {v:'24.60',what:
'@ @'
  {v:'24.61',what:'spr22: a team lamp on the shoulder strap, and the hire wears your colour with an amber armband',
   run:function(){
     if(typeof drawOp!=='function'||typeof wc==='undefined'||typeof TEAMCOL==='undefined') return 'SKIP: no drawOp or team colours here';
     var c=document.createElement('canvas'); c.width=300; c.height=300; var x=c.getContext('2d'), w0=wc, bad=[];
     function body(st){
       var s={moving:false,sprint:false,ads:false,hurt:0,rl:0,bulk:0,build:'lean',hair:'dark',cut:'crop',skin:'fair',own:{wep:(typeof WEAPONS!=='undefined'&&WEAPONS.carbine)||null}}, k;
       for(k in st) s[k]=st[k];
       x.setTransform(1,0,0,1,0,0); x.clearRect(0,0,300,300); x.setTransform(6,0,0,6,100,280); wc=x;
       try{ drawOp(0,0,0,0,'#5a6a5a',0,0,'',0,s); } finally{ wc=w0; }
       return x.getImageData(0,0,300,300).data;
     }
     function count(d,u0,u1,v0,v1,fn){ var n=0,px,py,k; for(py=Math.round(280+6*v0);py<=Math.round(280+6*v1);py++) for(px=Math.round(100+6*u0);px<=Math.round(100+6*u1);px++){ k=(py*300+px)*4; if(d[k+3]>200&&fn(d[k],d[k+1],d[k+2])) n++; } return n; }
     function blue(r,g,b){ return b>220&&g>150&&g<200&&r<130; }
     function amber(r,g,b){ return r>220&&g>140&&g<185&&b<70; }
     try{
       var al=body({team:'ally'}), fo=body({team:'foe'}), hi=body({team:'ally',merc:1});
       var la=count(al,-4.4,-2.0,-23.0,-20.6,blue), lf=count(fo,-4.4,-2.0,-23.0,-20.6,blue);
       if(la<30) bad.push('no ally lamp on the shoulder strap ('+la+' ally blue pixels there)');
       if(lf>5) bad.push('a foe wears the ally lamp');
       var am=count(hi,0,10,-24,-16,amber), am0=count(al,0,10,-24,-16,amber);
       if(am<30||am0>5) bad.push('no amber armband on the hire gun arm ('+am+' amber pixels, '+am0+' on a plain ally)');
       var src=[].slice.call(document.scripts).map(function(s){ return s.text; }).join('\n');
       if(src.indexOf("team:(e2.merc||e2.friendly)?'al"+"ly':'foe',merc:")<0) bad.push('the pillager draw does not put the hire on your side');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ wc=w0; }
     return bad.length?bad.join('; '):null; }},
  {v:'24.60',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
