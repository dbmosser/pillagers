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

if ($s.Contains("  {v:'19.38',what:")) { throw "check 19.38 is in the fixture already" }

SubRx @'
  {v:'19.37',what:
'@ @'
  {v:'19.38',what:'the YOUR STATS card titles are whole: in a narrow grid every card title fits its card, none cut off with dots',
   run:function(){
     if(!window.__station||!window.__hubEnter) return 'SKIP: this fixture cannot open the Mainframe';
     var bad=[], t, tab, sg, w0, ks, i, cut=[];
     try{
       __topClear(); __runPrep(); __cleanProfile();
       t=document.getElementById('title'); if(t) t.classList.remove('on');
       __hubEnter(); __station('mf','KeyE');
       tab=document.querySelector('[data-optab="rec"]'); if(!tab) return 'SKIP: no YOUR STATS tab';
       tab.click();
       sg=document.getElementById('statgrid'); if(!sg) return 'SKIP: no stat grid';
       w0=sg.style.width; sg.style.width='700px';
       ks=sg.querySelectorAll('.scard .sk'); if(!ks.length) return 'SKIP: no stat cards';
       for(i=0;i<ks.length;i++) if(ks[i].scrollWidth>ks[i].clientWidth+1) cut.push(String(ks[i].textContent||'').trim());
       if(cut.length) bad.push(cut.length+' card titles are cut off: '+cut.slice(0,3).join(', '));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ if(sg) sg.style.width=w0||''; __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.37',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
