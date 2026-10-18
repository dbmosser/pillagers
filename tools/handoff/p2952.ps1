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

# The end cards share one flat shell (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  #root .ocwin:not(.fbopen) #tagwrap, #root .ocwin:not(.fbopen) #oc_note{ display:none; }
'@ @'
  #root .ocwin:not(.fbopen) #tagwrap, #root .ocwin:not(.fbopen) #oc_note{ display:none; }
  /* v28.xx (cw-endcard-shell): the critic scored the Extracted, KIA, Abandoned and haul cards 2 of 5: "a debug dialog": the world and HUD
     read through the scrim, a glowing 14px glass card with a gradient, 44px buttons with tracked caps, amber text lines, tiles boxed in full rarity colour.
     One shell now (style guide 2, end cards): the scrim blurs what is behind it, a flat 720px panel with a 1px line and a 4px radius, a 32px title with
     no glow, a 56px primary (20px, 200px wide) beside a 56px ghost, lines in 16px, rarity as a 3px bar under each tile. Words and ids unchanged. */
  #root .outcome{ background:rgba(6,7,8,.84); -webkit-backdrop-filter:blur(10px); backdrop-filter:blur(10px); }
  #root .ocwin{ width:min(720px,calc(100% - 32px)); max-width:720px; box-sizing:border-box; padding:32px 48px 0; border-radius:4px; border:1px solid var(--ui-line-hi);
    background:var(--ui-panel); box-shadow:none; }
  #root .ocacts{ width:calc(100% + 96px); margin-left:-48px; margin-right:-48px; gap:16px; padding:16px 0 24px; background:var(--ui-panel); }
  #root .ocacts::before{ background:linear-gradient(180deg,rgba(0,0,0,0),var(--ui-panel)); }
  #root .outcome h1{ font-size:32px; letter-spacing:.02em; text-shadow:none; }
  #root .outcome .sub{ font-size:16px; letter-spacing:.04em; color:var(--tx-2); margin-bottom:16px; }
  #root .ocwin .manifest{ font-size:16px; line-height:1.6; max-width:624px; }
  #root #oc_manifest span[style*="var(--amber)"]{ color:var(--tx-1) !important; }
  #root #oc_btn, #root #oc_copy{ min-height:56px; min-width:200px; padding:0 32px !important; font-size:20px; letter-spacing:0; border-radius:4px; }
  #root #oc_btn{ background:var(--acc); background-image:none; border:1px solid var(--acc); color:var(--acc-ink); font-weight:700; box-shadow:none; }
  #root #oc_copy{ background:transparent; border:1px solid var(--ui-line-hi); color:var(--tx-1); font-weight:600; }
  #root .ocwin .fbhead{ font-size:16px; letter-spacing:.04em; padding:12px 24px; border-radius:4px; }
  #root .ocwin .haulit{ border-radius:4px !important; background:var(--ui-raised) !important; border:1px solid var(--ui-line) !important; border-bottom-width:3px !important; }
  #root .ocwin .haulit[data-r="common"]{ border-bottom-color:var(--r-common) !important; }
  #root .ocwin .haulit[data-r="uncommon"]{ border-bottom-color:var(--r-uncommon) !important; }
  #root .ocwin .haulit[data-r="rare"]{ border-bottom-color:var(--r-rare) !important; }
  #root .ocwin .haulit[data-r="elite"]{ border-bottom-color:var(--r-elite) !important; }
  #root .ocwin .haulit[data-r="gold"]{ border-bottom-color:var(--r-gold) !important; }
'@

SubRx @'
var VER='29.51';
'@ @'
var VER='29.52';
'@

$pat = "(?m)^  now:'v29\.51:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.52: The end cards are cleaner: flat panel, bigger buttons, the world blurred behind. Check 29.52 fails on v29.51',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
