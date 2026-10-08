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

# THE SECTOR CARDS READ AT A GLANCE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
       '<div><b style="color:'+(sel?'var(--amber)':'var(--bone)')+'">'+M.name+'</b>'+
       ' <span style="color:var(--ash);font-size:11px">'+sizeTag(i)+'</span>'+
       (sel?' <span style="color:var(--amber);font-size:11px">ASCENDING HERE</span>':'')+
       '<div class="hint" style="margin:2px 0 0">'+SECTOR_CHAR[i]+'</div>'+
       '<div class="hint" style="margin:2px 0 0;color:var(--ash)">'+facts.join('  &middot;  ')+'</div></div></div>';
'@ @'
       // v18.65, seen on the lift screenshot (2026-10-07): each sector card is as tall as its map, and the name and facts were
       // 16 and 13 pixel lines across the top of it, a big empty card. The name is a heading now and the lines under it read
       // at a glance; the words are his, untouched.
       '<div><b style="font-size:28px;letter-spacing:.04em;line-height:1.15;color:'+(sel?'var(--amber)':'var(--bone)')+'">'+M.name+'</b>'+
       ' <span style="color:var(--ash);font-size:14px;letter-spacing:.08em">'+sizeTag(i)+'</span>'+
       (sel?' <span style="color:var(--amber);font-size:14px;letter-spacing:.08em">ASCENDING HERE</span>':'')+
       '<div class="hint" style="margin:10px 0 0;font-size:17px;line-height:1.5">'+SECTOR_CHAR[i]+'</div>'+
       '<div class="hint" style="margin:8px 0 0;font-size:16px;line-height:1.6;color:var(--ash)">'+facts.join('  &middot;  ')+'</div></div></div>';
'@

SubRx @'
var VER='18.64';
'@ @'
var VER='18.65';
'@

$pat = "(?m)^  now:'v18\.64:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.65: On the lift page the sector names and facts are big enough to read from the couch. Check 18.65 fails on v18.64',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
