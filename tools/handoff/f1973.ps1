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

if ($s.Contains("  {v:'19.73',what:")) { throw "check 19.73 is in the fixture already" }

SubRx @'
  {v:'19.72',what:
'@ @'
  {v:'19.73',what:'the corner credits line up with a window heading: with the shop open the CREDITS and XP readout is centred on the heading row, and with no window open it is back in the corner',
   run:function(){
     if(!(window.__hubEnter&&window.__station)) return 'SKIP: this fixture cannot open a station';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing renders';
     var bad=[], tr=document.getElementById('topright'), m, h, a, b, t, z, d;
     if(!tr) return 'SKIP: no corner readout here';
     try{
       __topClear(); __runPrep(); __cleanProfile();
       t=document.getElementById('title'); if(t) t.classList.remove('on');
       __hubEnter(); __station('trader','KeyE');
       m=document.getElementById('tradermodal'); h=m&&m.querySelector('h3');
       if(!m||!m.classList.contains('on')||!h) return 'SKIP: the shop did not open';
       a=tr.getBoundingClientRect(); b=h.getBoundingClientRect();
       if(!(a.height>0&&b.height>0)) return 'SKIP: nothing laid out';
       d=Math.abs((a.top+a.bottom)/2-(b.top+b.bottom)/2);
       if(d>a.height*0.2) bad.push('with the shop open the readout is '+Math.round(d)+' px off the heading row (readout '+Math.round(a.top)+'-'+Math.round(a.bottom)+', heading '+Math.round(b.top)+'-'+Math.round(b.bottom)+')');
       if(typeof closeTrader==='function') closeTrader(); else m.classList.remove('on');
       if(m.classList.contains('on')) return 'SKIP: the shop would not close';
       z=parseFloat(tr.style.zoom)||1; a=tr.getBoundingClientRect();
       if(Math.abs(a.top/z-6)>2) bad.push('control: with no window open the readout is at '+Math.round(a.top/z)+' px, not in the corner');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(m&&m.classList.contains('on')&&typeof closeTrader==='function') closeTrader(); }catch(_c){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.72',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
