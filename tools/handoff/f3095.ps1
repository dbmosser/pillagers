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

if ($s.Contains("  {v:'30.95',what:")) { throw "check 30.95 is in the fixture already" }

SubRx @'
  {v:'30.94',what:
'@ @'
  {v:'30.95',what:'on the wide Settings card a row stepper sits within 420 px of its label, never at the far edge of the 960 column',
   run:function(){
     if(!(window.__station&&window.__hubEnter)) return 'SKIP: this fixture cannot walk the Undercroft';
     var bad=[], m, row, lab, st, r;
     try{
       __topClear(); __hubEnter();
       r=__station('dev','KeyE'); if(r&&r.err) return 'station: '+r.err;
       m=document.getElementById('settingsmodal');
       if(!m||!m.classList.contains('on')) return 'the settings window did not open';
       UIM.step(600);
       row=document.querySelector('#setlist .row:not(.setjump) > button'); if(!row) return 'no stepper row';
       row=row.parentNode; lab=row.firstElementChild.getBoundingClientRect(); st=row.querySelector(':scope > button').getBoundingClientRect();
       var z=parseFloat(m.style.zoom)||1;
       if(!((st.left-lab.left)<=420*z)) bad.push('the stepper starts '+Math.round((st.left-lab.left)/z)+' px from the label, want 420 or less');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'30.94',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
