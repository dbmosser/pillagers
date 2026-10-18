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

# TITLE: ONE LINE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    <div style="margin-top:26px;font-size:13.5px;line-height:1.65;color:var(--bone);max-width:760px;margin-left:auto;margin-right:auto">
      The elites left the surface to the machines and went somewhere better.
      You go up, you take what is worth taking, and you come back down.
    </div>

    <div style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:12px;margin-top:26px;text-align:left">
      <div class="tcard">
        <div class="tstep">1 &middot; ASCEND</div>
        <div class="tbody">
          Take the lift up with whatever you dare carry. What you bring, you can lose.</div>
      </div>
      <div class="tcard">
        <div class="tstep">2 &middot; PILLAGE</div>
        <div class="tbody">
          Hold E on anything worth opening. Beware of hostile robots and fellow pillagers.</div>
      </div>
      <div class="tcard">
        <div class="tstep">3 &middot; EXTRACT</div>
        <div class="tbody">
          Stand in a ring and hold E to call for extraction. Die out there and it is all gone.</div>
      </div>
    </div>
'@ @'
    <!-- v28.xx (cw-title-line), his Q51 (2026-10-18): "drop the story paragraph and the three step cards for one line". The story paragraph and the ASCEND, PILLAGE, EXTRACT cards are gone; this is the one line. Q53: nothing sits beside the logo. -->
    <div id="titletag" style="max-width:760px;margin:0 auto">Ascend. Pillage. Extract.</div>
'@

SubRx @'
#root #title .tstep{ color:var(--acc); }
'@ @'
#root #title .tstep{ color:var(--acc); }
/* v28.xx (cw-title-line), his Q51: the one line that replaces the story and the cards. Title size, tracked, the one bone colour; nothing else carries the accent here. */
#root #title #titletag{ margin-top:var(--sp-3); font:700 var(--fs-title)/1.1 var(--f-cond); letter-spacing:var(--track); color:var(--tx-1); }
'@

SubRx @'
var VER='30.40';
'@ @'
var VER='30.41';
'@

$pat = "(?m)^  now:'v30\.40:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.41: The title shows one line, Ascend. Pillage. Extract., instead of the story and the three step cards. Check 30.41 fails on v30.40',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
