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

if ($s.Contains("  {v:'18.66',what:")) { throw "check 18.66 is in the fixture already" }

SubRx @'
  {v:'18.65',what:
'@ @'
  {v:'18.66',what:'the contract list reads from the couch: on the Mainframe a contract line is 17 pixels or more, its progress line 15 or more and its pays line 13 or more',
   run:function(){
     if(typeof __station!=='function'||typeof __hubEnter!=='function') return 'SKIP: no stations here';
     var bad=[], t, row, f, gd;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       t=document.getElementById('title'); if(t) t.classList.remove('on');
       __hubEnter(); __station('mf','KeyE');
       row=document.querySelector('.modal.on .crow');
       if(!row) return 'SKIP: the Mainframe drew no contract';
       f=parseFloat(getComputedStyle(row.querySelector('.cd')||row).fontSize); if(!(f>=17)) bad.push('a contract line is '+f+'px');
       if(row.querySelector('.cp')){ f=parseFloat(getComputedStyle(row.querySelector('.cp')).fontSize); if(!(f>=15)) bad.push('the progress line is '+f+'px'); }
       gd=[].filter.call(document.querySelectorAll('.modal.on .crow div'),function(d){ return (/^Pays: /).test(d.textContent||''); })[0];
       if(gd){ f=parseFloat(getComputedStyle(gd).fontSize); if(!(f>=13)) bad.push('the pays line is '+f+'px'); }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'18.65',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
