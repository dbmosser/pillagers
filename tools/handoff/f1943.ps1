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

if ($s.Contains("  {v:'19.43',what:")) { throw "check 19.43 is in the fixture already" }

SubRx @'
  {v:'19.42',what:
'@ @'
  {v:'19.43',what:'the bar warning sits under its own name: on the Undercroft floor the EXPERIMENTAL line is no more than about the width of THE LAST POUR, or shrunk as far as it goes',
   run:function(){
     if(!(window.__hubEnter&&window.__hubFrame&&window.__showScreen)) return 'SKIP: this fixture cannot draw the floor';
     if(typeof wc==='undefined'||!wc) return 'SKIP: no floor canvas';
     var bad=[], t, proto=CanvasRenderingContext2D.prototype, o=proto.fillText, lab=null, tag=null;
     try{
       __topClear(); __runPrep();
       t=document.getElementById('title'); if(t) t.classList.remove('on');
       G=null; keys={}; __showScreen('hub'); __hubEnter();
       proto.fillText=function(s,x,y){ if(this===wc){ var str=String(s), w=this.measureText((typeof TX==='function')?TX(str):str).width, fm=(/([\d.]+)px/).exec(String(this.font)); if(str==='THE LAST POUR'&&!lab) lab={w:w}; if(str.indexOf('EXPERIMENTAL')>=0&&!tag) tag={w:w,fp:fm?parseFloat(fm[1]):0}; } return o.apply(this,arguments); };
       __hubFrame(0.016);
       if(!lab||!tag) return 'SKIP: the bar name or its warning was not drawn';
       if(tag.w>lab.w*1.2+2){ var full=0; proto.fillText=o; wc.save(); wc.font=FS(TYPE.micro); full=wc.measureText(String(typeof TX==='function'?TX('***EXPERIMENTAL***'):'***EXPERIMENTAL***')).width; wc.restore(); if(tag.w>full*0.72) bad.push('the warning is '+Math.round(tag.w)+' wide under a '+Math.round(lab.w)+' wide name and was not shrunk'); }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ proto.fillText=o; __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.42',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
