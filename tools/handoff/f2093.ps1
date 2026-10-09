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

if ($s.Contains("  {v:'20.93',what:")) { throw "check 20.93 is in the fixture already" }

SubRx @'
  {v:'20.92',what:
'@ @'
  {v:'20.93',what:'the PARTY window TRADING line starts where the other lines start: its words line up with the line above it and with HOST A PARTY, not a step to the right',
   run:function(){
     if(!window.__station||!window.__hubEnter) return 'SKIP: this fixture cannot open the PARTY window';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing renders';
     var bad=[], t, pm, tr, st, a, b, hb, h;
     function words(el){ var r=document.createRange(); r.selectNodeContents(el); return r.getBoundingClientRect(); }
     try{
       __topClear(); __runPrep(); __cleanProfile();
       t=document.getElementById('title'); if(t) t.classList.remove('on');
       __hubEnter(); __station('lift','KeyF');
       pm=document.getElementById('partymodal'); tr=document.getElementById('partytrade'); st=document.querySelector('#partymodal .msub');
       if(!pm||!tr||!st||!pm.classList.contains('on')) return 'SKIP: the PARTY window did not open';
       a=words(tr); b=words(st);
       if(!(a.width>0&&b.width>0)) return 'SKIP: the PARTY lines have no size here';
       if(Math.abs(a.left-b.left)>2) bad.push('the TRADING words start '+Math.round(a.left-b.left)+' px off the line above them');
       hb=document.getElementById('partyhost'); h=hb?hb.getBoundingClientRect():null;
       if(h&&h.width>0&&Math.abs(a.left-h.left)>2) bad.push('the TRADING words start '+Math.round(a.left-h.left)+' px off the HOST A PARTY button');
       h=tr.getBoundingClientRect(); a=st.getBoundingClientRect();
       if(h.right>a.right+2) bad.push('the TRADING line box runs '+Math.round(h.right-a.right)+' px past the lines above it');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ var m=document.getElementById('partymodal'); if(m) m.classList.remove('on'); }catch(_m){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'20.92',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
