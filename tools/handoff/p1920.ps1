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

# A FASHION CLICK BUILDS THE RACKS ONCE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      saveProfile();
      renderCosmetics(target,kindOnly,hid,pid);
      try{ renderAvatar(hid,pid); }catch(e){}
'@ @'
      saveProfile();
      // v19.20, from the review (2026-10-07): renderAvatar draws the racks again itself (renderAvPicker), so in FASHION every click built
      // all the racks twice, about 0.5 MB of pictures parsed twice in one click. When the racks are the picker renderAvatar fills, it is
      // left to do it once.
      var _rk1=false; try{ _rk1=!!(hid&&pid&&document.getElementById(hid)&&document.getElementById(pid)===target); }catch(_rk){}
      if(!_rk1) renderCosmetics(target,kindOnly,hid,pid);
      try{ renderAvatar(hid,pid); }catch(e){ if(_rk1) renderCosmetics(target,kindOnly,hid,pid); }
'@

SubRx @'
var VER='19.19';
'@ @'
var VER='19.20';
'@

$pat = "(?m)^  now:'v19\.19:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.20: Clicking through FASHION is quicker. Check 19.20 fails on v19.19',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
