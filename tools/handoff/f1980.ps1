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

if ($s.Contains("  {v:'19.80',what:")) { throw "check 19.80 is in the fixture already" }

SubRx @'
  {v:'19.79',what:
'@ @'
  {v:'19.80',what:'the section captions on the cream cards are readable: PROGRESS and REWARDS on the Mainframe card are drawn at 12.5px or more',
   run:function(){
     if(!(window.__hubEnter&&window.__station&&window.__wnseen)) return 'SKIP: this fixture cannot open the Mainframe';
     var bad=[], m, labs, i, f, n=0;
     try{
       __topClear(); __runPrep(); __cleanProfile(); __wnseen(1);
       __hubEnter(); __station('mf','KeyE');
       m=document.querySelector('.modal.on'); if(!m) return 'SKIP: the Mainframe did not open';
       labs=[].slice.call(m.querySelectorAll('.crlab'));
       for(i=0;i<labs.length;i++){ if(!/^(PROGRESS|REWARDS)$/.test(labs[i].textContent.trim())) continue; n++; f=parseFloat(getComputedStyle(labs[i]).fontSize); if(!(f>=12.4)) bad.push(labs[i].textContent.trim()+' is '+f+'px'); }
       if(!n) return 'SKIP: no PROGRESS or REWARDS caption showing';
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ [].slice.call(document.querySelectorAll('.modal.on')).forEach(function(x){ x.classList.remove('on'); }); }catch(_m){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.79',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
