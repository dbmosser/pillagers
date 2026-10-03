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

# THE STYLING PASS, STAGE B: THE TITLE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
   #title.on { background:rgba(9,15,40,.80); }   /* v17.83: the Undercroft shows through the title */
'@ @'
   /* v18.11, THE STYLING PASS, STAGE B: THE TITLE. A vignette instead of a flat wash, so the Undercroft still shows through
      (v17.83) and the column reads; a wordmark with a gold gradient and a glow; the three step cards as glass cards. */
   #title.on { background:radial-gradient(ellipse 70% 62% at 50% 42%, rgba(9,15,40,.60) 0%, rgba(9,15,40,.84) 70%, rgba(5,8,22,.96) 100%); }
   #title .wordmark{ font-family:'Titan One','Rubik',sans-serif; font-size:64px; letter-spacing:.16em; line-height:1;
     background:linear-gradient(180deg,#ffe9a8 0%,#ffc04a 55%,#e08a1a 100%); -webkit-background-clip:text; background-clip:text; color:transparent;
     filter:drop-shadow(0 4px 0 rgba(0,0,0,.55)) drop-shadow(0 0 22px rgba(255,192,74,.28)); }
   #title .tcard{ border:1px solid rgba(127,146,216,.35); border-radius:10px; padding:14px 16px;
     background:linear-gradient(180deg,rgba(127,146,216,.10),rgba(0,0,0,.32)); box-shadow:0 10px 30px rgba(0,0,0,.25), inset 0 1px 0 rgba(255,255,255,.06); }
   #title .tstep{ font-size:11px; letter-spacing:.22em; color:var(--amber); font-weight:700; }
   #title .tcard .tbody{ font-size:12px; color:var(--ash); margin-top:6px; line-height:1.5; }
'@

SubRx @'
    <div style="font-family:'Titan One','Rubik',sans-serif;font-size:58px;letter-spacing:.14em;
         color:var(--amber);line-height:1;text-shadow:0 3px 0 rgba(0,0,0,.55)">PILLAGERS</div>
'@ @'
    <div class="wordmark">PILLAGERS</div>
'@

SubRx @'
      <div style="border:1px solid var(--steel-hi);border-radius:4px;padding:11px 13px;background:rgba(0,0,0,.28)">
        <div style="font-size:10.5px;letter-spacing:.2em;color:var(--amber)">1 &middot; ASCEND</div>
        <div style="font-size:11.5px;color:var(--ash);margin-top:5px;line-height:1.5">
'@ @'
      <div class="tcard">
        <div class="tstep">1 &middot; ASCEND</div>
        <div class="tbody">
'@

SubRx @'
      <div style="border:1px solid var(--steel-hi);border-radius:4px;padding:11px 13px;background:rgba(0,0,0,.28)">
        <div style="font-size:10.5px;letter-spacing:.2em;color:var(--amber)">2 &middot; PILLAGE</div>
        <div style="font-size:11.5px;color:var(--ash);margin-top:5px;line-height:1.5">
'@ @'
      <div class="tcard">
        <div class="tstep">2 &middot; PILLAGE</div>
        <div class="tbody">
'@

SubRx @'
      <div style="border:1px solid var(--steel-hi);border-radius:4px;padding:11px 13px;background:rgba(0,0,0,.28)">
        <div style="font-size:10.5px;letter-spacing:.2em;color:var(--amber)">3 &middot; EXTRACT</div>
        <div style="font-size:11.5px;color:var(--ash);margin-top:5px;line-height:1.5">
'@ @'
      <div class="tcard">
        <div class="tstep">3 &middot; EXTRACT</div>
        <div class="tbody">
'@

SubRx @'
var VER='18.10';
'@ @'
var VER='18.11';
'@

$pat = "(?m)^  now:'v18\.10:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.11: The title screen has a gold wordmark, glass step cards and a vignette backdrop. Check 18.11 fails on v18.10',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
