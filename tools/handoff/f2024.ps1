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

if ($s.Contains("  {v:'20.24',what:")) { throw "check 20.24 is in the fixture already" }

SubRx @'
  {v:'20.23',what:
'@ @'
  {v:'20.24',what:'the loadout question fits its buttons: on the WHAT ARE YOU TAKING UP card every choice sits on one line',
   run:function(){
     if(!(window.__hubEnter&&window.__station&&window.__wnseen)) return 'SKIP: this fixture cannot reach the lift';
     var bad=[], b, m, bs, i, fs;
     try{
       __topClear(); __runPrep(); __cleanProfile(); __wnseen(1);
       __hubEnter(); __station('lift','KeyE');
       b=[].slice.call(document.querySelectorAll('#sectormodal button')).filter(function(x){ return /ASCEND TO THIS SECTOR/.test(x.textContent); })[0];
       if(!b) return 'SKIP: no ascend button';
       b.click();
       m=document.getElementById('askmodal'); if(!m||!m.classList.contains('on')) return 'SKIP: the loadout question did not open';
       bs=[].slice.call(m.querySelectorAll('.askrow button')).filter(function(x){ return x.offsetWidth>0; });
       if(bs.length<4) return 'SKIP: the loadout choices are not showing ('+bs.length+')';
       for(i=0;i<bs.length;i++){ fs=parseFloat(getComputedStyle(bs[i]).fontSize)||12; if(bs[i].clientHeight>fs*2.6+parseFloat(getComputedStyle(bs[i]).paddingTop)*2){ bad.push(bs[i].textContent.trim()+' breaks over more than one line'); } }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ [].slice.call(document.querySelectorAll('.modal.on')).forEach(function(x){ x.classList.remove('on'); }); }catch(_m){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'20.23',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
