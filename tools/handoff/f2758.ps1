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

if ($s.Contains("  {v:'27.58',what:")) { throw "check 27.58 is in the fixture already" }

SubRx @'
  {v:'27.57',what:
'@ @'
  {v:'27.58',what:'his 2026-10-14 note (UI cleanup uic10): CHANGE KEYS and CHANGE PAD BUTTONS list the actions in two columns across the window (one column used 1100 px of 1920 and the right 40 percent was empty)',
   run:function(){
     if(typeof keysOpen!=='function') return 'SKIP: no keys window in this build';
     var bad=[], m=null, was=false;
     try{
       __topClear();
       [false,true].forEach(function(pad){
         keysOpen(pad);
         m=document.getElementById('keysmodal'); var list=document.getElementById('keyslist');
         if(!m||!list||!m.classList.contains('on')){ bad.push('the '+(pad?'pad':'keys')+' window did not open'); return; }
         var cols=String(getComputedStyle(list).gridTemplateColumns||'none').split(' ').filter(function(x){ return x&&x!=='none'; }).length;
         var rows=list.querySelectorAll('.row'), lb=list.getBoundingClientRect(), a=rows[0], b=rows[1];
         if(cols!==2) bad.push('the '+(pad?'pad':'keys')+' list has '+cols+' column(s)');
         else if(a&&b){ var ra=a.getBoundingClientRect(), rb=b.getBoundingClientRect(); if(!(rb.left-ra.left>300)||Math.abs(rb.top-ra.top)>8) bad.push('the first two rows of the '+(pad?'pad':'keys')+' list are not side by side'); }
         if(!(lb.width>1.4*1100*(parseFloat(m.style.zoom)||1)*0.95-10)&&lb.width<1200*(parseFloat(m.style.zoom)||1)) bad.push('the '+(pad?'pad':'keys')+' list is only '+Math.round(lb.width)+' px wide');
       });
       return bad.length?bad.join('; '):null;
     } finally { try{ if(m) m.classList.remove('on'); KEYS.pad=false; }catch(_c){} try{ __topClear(); }catch(_t){} } }},
  {v:'27.57',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
