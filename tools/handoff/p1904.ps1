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

# THE KIA CARD SHOWS WHAT WAS LOST WITH PICTURES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      lines.push('<span style="color:'+(RCOL[dispR(_lk2)||li2.r]||'#cdd6dd')+'">'+li2.name+'</span>'+
'@ @'
      lines.push(iconImgHTML(_lk2,24)+' '+'<span style="color:'+(RCOL[dispR(_lk2)||li2.r]||'#cdd6dd')+'">'+li2.name+'</span>'+   // v19.04, seen on the KIA card screenshot (2026-10-07): each lost thing with its picture, as the backpack and stash show it
'@

SubRx @'
        lines.push('<span style="color:#cdd6dd">'+gone[j].name+'</span><span style="color:var(--rust)">  LOST</span>'); }
'@ @'
        lines.push((ITEMS['gun_'+gone[j].id]?iconImgHTML('gun_'+gone[j].id,24)+' ':'')+'<span style="color:#cdd6dd">'+gone[j].name+'</span><span style="color:var(--rust)">  LOST</span>'); }   // v19.04: and the gun's picture
'@

SubRx @'
      else lines.push('<span style="color:#cdd6dd">'+gone[j].name+'</span><span style="color:var(--rust)">  LOST</span>');
'@ @'
      else lines.push((ITEMS['gun_'+gone[j].id]?iconImgHTML('gun_'+gone[j].id,24)+' ':'')+'<span style="color:#cdd6dd">'+gone[j].name+'</span><span style="color:var(--rust)">  LOST</span>');   // v19.04: and the gun's picture
'@

SubRx @'
var VER='19.03';
'@ @'
var VER='19.04';
'@

$pat = "(?m)^  now:'v19\.03:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.04: The KILLED IN ACTION card shows a picture beside each item and gun you lost. Check 19.04 fails on v19.03',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
