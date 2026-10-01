$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
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

# THE HOST IS TOLD WHEN A TEAMMATE IS OUT OF THE RAID (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(st==='no'){ NET.status=nm+' could not go up with you: '+netUpWhyText(m.why)+'.'; netRefresh(); try{ if(typeof G!=='undefined'&&G&&!G.over) sayWhenFree(NET.status); }catch(_sn){} }
'@ @'
  // v17.63: a teammate whose raid ended is named in the raid of the others, as the host is (spec): killed, extracted or abandoned.
  // Before, the host was told nothing and found his teammate gone from the screen.
  if(st==='out'&&s!==0&&typeof G!=='undefined'&&G&&!G.over&&!G.sim){ hw=netClean(m.how,12); hw=(hw==='dead')?'killed':(hw==='extract')?'extracted':(hw==='abandon')?'abandoned':''; try{ sayWhenFree(nm+' is out of this raid'+(hw?' ('+hw+')':'')+'.'); }catch(_so){} }  if(st==='no'){ NET.status=nm+' could not go up with you: '+netUpWhyText(m.why)+'.'; netRefresh(); try{ if(typeof G!=='undefined'&&G&&!G.over) sayWhenFree(NET.status); }catch(_sn){} }
'@

SubRx @'
var VER='17.62';
'@ @'
var VER='17.63';
'@

$pat = "(?m)^  now:'v17\.62:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.63: When your teammate is out of the raid (killed, extracted or abandoned), you are told by name. Check 17.63 fails on v17.62',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
