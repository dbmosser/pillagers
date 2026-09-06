$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# HIS ORDER, 2026-09-06 (his 06:26 export, run 3): "KIA screen '40 seconds of
# cutting, lost with you.' -- I have no idea what the fuck that means, just
# remove it." The line is gone from the KILLED IN ACTION card. The seal still
# banks only if he walks out, which is its whole point; the card just no
# longer announces the loss in words that meant nothing to him.
SubRx @'
      saveProfile();
    } else {
      lines.push('<span style="color:var(--rust)">'+Math.round(G.seal.gained)+
        ' seconds of cutting, lost with you.</span>');
    }
  }
'@ @'
      saveProfile();
    }
    // v11.81, HIS ORDER: the KIA card no longer says how much cutting died
    // with him; it meant nothing to him. The cut still does not bank on a
    // death, which is the seal's whole point; the card just does not say so.
  }
'@

# STAMPS.
SubRx @'
var VER='11.80';
'@ @'
var VER='11.81';
'@
SubRx @'
var WHATSNEW_VER='11.80';
'@ @'
var WHATSNEW_VER='11.81';
'@
$cnt=([regex]::Matches($s,"now:'v11\.80:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.80 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.80:[^']*'",{ param($m) "now:'v11.81: HIS ORDER of 2026-09-06, the KIA card line about seconds of cutting lost with you is removed; it meant nothing to him. The seal still banks only on an extraction. Check 11.81 stages a cut of 40 seconds, ends a raid by death and requires the phrase absent from the card, and ends one by extraction and requires the banked line still present as the control; fails on v11.80.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
