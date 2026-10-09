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

if ($s.Contains("  {v:'21.60',what:")) { throw "check 21.60 is in the fixture already" }

SubRx @'
  {v:'21.59',what:
'@ @'
  {v:'21.60',what:'the pillbox is gentler, his note: 850 health, 17 a shot, and a shot every 0.60 to 0.90 seconds',
   run:function(){
     if(typeof mkChoir!=='function'||typeof CHOIR_HP==='undefined') return 'SKIP: no pillbox here';
     var bad=[], c=mkChoir(0,0), e0=CFG.eHp;
     if(CHOIR_HP!==850) bad.push('pillbox health is '+CHOIR_HP+', not 850');
     if(c.dmg!==17) bad.push('a pillbox shot does '+c.dmg+', not 17');
     var src=[].slice.call(document.scripts).map(function(s){ return s.text||''; }).join(''), nd='e.cd=rnd(0.'+'60,0.90)';
     if(src.indexOf(nd)<0) bad.push('the pillbox still fires every 0.42 to 0.66 seconds');
     return bad.length?bad.join('; '):null; }},
  {v:'21.59',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
