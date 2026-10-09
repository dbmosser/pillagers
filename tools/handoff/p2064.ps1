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

# A CRIER CANNOT TURN BACK A MAN WHO IS LEAVING (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
            if(eb.state!=='chase'){
              eb.state='investigate';
              eb.tx=e.markX+rnd(-40,40); eb.ty=e.markY+rnd(-40,40);
              eb.alert=Math.max(eb.alert,2.5);
            }
'@ @'
            if(eb.state!=='chase'){
              // v20.64, from the whole-game bug hunt of 2026-10-08 (H13): A MAN LEAVING KEEPS LEAVING, AND YOUR HIRE TAKES NO ORDERS FROM
              // A CRIER. The alarm turned a pillager already running for the ring back to the mark, where he went back to looting and
              // opened one more box before setting off again; every other pull keeps a man who is leaving (v2.93, the crew shout, the
              // siege). He still hears it (the alert), as he does under the siege. The alarm no longer sends your hire either, as the
              // crew shout never does; the noise of the alarm is a separate rule (ping) and is unchanged. Both scatter draws are still
              // taken, in the same order, for every man the old loop reached, so the seeded stream does not move.
              var _amx=e.markX+rnd(-40,40), _amy=e.markY+rnd(-40,40);
              if(eb.merc) continue;
              eb.alert=Math.max(eb.alert,2.5);
              if(eb.state==='extract') continue;
              eb.state='investigate';
              eb.tx=_amx; eb.ty=_amy;
            }
'@

SubRx @'
var VER='20.63';
'@ @'
var VER='20.64';
'@

$pat = "(?m)^  now:'v20\.63:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.64: A pillager running for extraction keeps running when a Crier raises the alarm. Check 20.64 fails on v20.63',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
