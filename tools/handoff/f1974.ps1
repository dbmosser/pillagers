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

if ($s.Contains("  {v:'19.74',what:")) { throw "check 19.74 is in the fixture already" }

SubRx @'
  {v:'19.73',what:
'@ @'
  {v:'19.74',what:'the corner credits end where the window heading ends: with the shop open the XP readout right edge meets the end of the heading line, inside the frame',
   run:function(){
     if(!(window.__hubEnter&&window.__station)) return 'SKIP: this fixture cannot open a station';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing renders';
     var bad=[], tr=document.getElementById('topright'), m, h, a, b, t, d;
     if(!tr) return 'SKIP: no corner readout here';
     try{
       __topClear(); __runPrep(); __cleanProfile();
       t=document.getElementById('title'); if(t) t.classList.remove('on');
       __hubEnter(); __station('trader','KeyE');
       m=document.getElementById('tradermodal'); h=m&&m.querySelector('h3');
       if(!m||!m.classList.contains('on')||!h) return 'SKIP: the shop did not open';
       a=tr.getBoundingClientRect(); b=h.getBoundingClientRect();
       if(!(a.height>0&&b.width>0)) return 'SKIP: nothing laid out';
       d=a.right-b.right;
       if(Math.abs(d)>a.height*0.1) bad.push('with the shop open the readout ends '+Math.round(d)+' px from the end of the heading line');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(m&&m.classList.contains('on')&&typeof closeTrader==='function') closeTrader(); }catch(_c){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.73',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
