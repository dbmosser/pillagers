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

if ($s.Contains("  {v:'24.40',what:")) { throw "check 24.40 is in the fixture already" }

SubRx @'
  {v:'24.39',what:
'@ @'
  {v:'24.40',what:'spr23: hostile glare: a foe pillager has brow bars over almond eyes, an ally keeps round eyes',
   run:function(){
     if(typeof drawOp!=='function'||typeof wc==='undefined') return 'SKIP: no drawOp here';
     var c=document.createElement('canvas'); c.width=200; c.height=300; var x=c.getContext('2d'), w0=wc, bad=[];
     function eyes(tm,mc){
       x.setTransform(1,0,0,1,0,0); x.clearRect(0,0,200,300); x.setTransform(6,0,0,6,100,280); wc=x;
       try{ drawOp(0,0,Math.PI/2,0,'#4a5b7d',0,0,'none',0,{moving:false,sprint:false,ads:false,hurt:0,rl:0,bulk:0,build:'lean',hair:'dark',cut:'crop',skin:'fair',team:tm,merc:mc}); }
       finally{ wc=w0; }
       var d=x.getImageData(0,0,200,300).data, ink=0, wh=0, px, py, k, ux, uy;
       for(py=0;py<300;py++) for(px=0;px<200;px++){ ux=(px-100)/6; uy=(280-py)/6; if(Math.abs(ux)>6.4||uy<26.8||uy>33.2) continue;
         k=(py*200+px)*4; if(d[k+3]<200) continue;
         if(d[k]<40&&d[k+1]<40&&d[k+2]<40) ink++;
         if(d[k]>240&&d[k+1]>232&&d[k+2]>205) wh++; }
       return {ink:ink,wh:wh};
     }
     try{
       var f=eyes('foe',0), a=eyes('ally',0), h=eyes('foe',1);
       if(f.ink-a.ink<60) bad.push('a foe has no brow bars ('+f.ink+' dark pixels round the eyes against '+a.ink+' on an ally)');
       if(a.wh-f.wh<120) bad.push('the foe eyes are not cut to almonds ('+f.wh+' eye white pixels against '+a.wh+' on an ally)');
       if(Math.abs(h.ink-a.ink)>20) bad.push('a hire glares like a foe');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ wc=w0; }
     return bad.length?bad.join('; '):null; }},
  {v:'24.39',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
