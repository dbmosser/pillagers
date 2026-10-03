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

# THE STYLING PASS, STAGE A: ONE LOOK FOR EVERY MENU (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
</style>
'@ @'
  /* v17.94, THE STYLING PASS, STAGE A (his order 2026-10-03: styling across all menus and HUDs). One look for every HTML menu, laid
     over the rules above: glass panes with a soft light from the top, one header style, rounded buttons of one height with a
     real primary, quiet rows that light on hover, dark inputs with a focus ring, thin scrollbars. Ids and classes are unchanged. */
  #root .modal{ background:radial-gradient(1200px 700px at 50% -10%, rgba(127,146,216,.12), transparent 60%), rgba(8,12,28,.95);
    padding:26px 32px; }
  #root .modal h3{ font-size:22px; letter-spacing:.22em; text-transform:uppercase; color:var(--amber); margin:0 0 14px;
    padding-bottom:12px; border-bottom:1px solid rgba(127,146,216,.22); }
  #root .msub{ font-size:15px; line-height:1.5; color:var(--ash); max-width:1180px; }
  #root .hint{ font-size:13.5px; line-height:1.55; }
  #root .row{ border-radius:6px; border:1px solid transparent; transition:background .12s, border-color .12s; }
  #root .row:hover{ background:rgba(127,146,216,.07); }
  #root .plist .row + .row{ border-top-color:rgba(127,146,216,.10); border-radius:0; }
  #root button{ border-radius:6px; border-color:rgba(127,146,216,.45); padding:9px 18px; min-height:38px; font-weight:600; letter-spacing:.08em; }
  #root button:hover:not(:disabled){ background:rgba(255,192,74,.10); box-shadow:0 0 0 1px rgba(255,192,74,.25) inset; }
  #root button:active:not(:disabled){ transform:translateY(1px); }
  #root .deploy{ background:linear-gradient(180deg,#ffd97f 0%,#ffb634 100%); color:#1a1408; border:1px solid #ffe9b0; border-radius:8px;
    box-shadow:0 8px 22px rgba(255,180,50,.22), 0 1px 0 rgba(255,255,255,.35) inset; letter-spacing:.24em; font-weight:800; }
  #root .deploy:hover:not(:disabled){ filter:brightness(1.06); color:#1a1408; background:linear-gradient(180deg,#ffe08f 0%,#ffbd40 100%); box-shadow:0 10px 26px rgba(255,180,50,.3); }
  #root .deploy.ghost{ background:transparent; color:var(--amber); border-color:rgba(255,192,74,.55); box-shadow:none; }
  #root .deploy.ghost:hover:not(:disabled){ background:rgba(255,192,74,.10); color:var(--amber); }
  #root input:not([type=range]):not([type=checkbox]), #root textarea{ background:rgba(0,0,0,.35); border:1px solid rgba(127,146,216,.35); border-radius:6px;
    color:var(--bone); padding:9px 12px; }
  #root input:not([type=range]):focus, #root textarea:focus{ border-color:var(--amber); outline:none; box-shadow:0 0 0 2px rgba(255,192,74,.22); }
  *::-webkit-scrollbar{ width:8px; height:8px; }
  *::-webkit-scrollbar-thumb{ background:rgba(127,146,216,.35); border-radius:8px; }
  *::-webkit-scrollbar-thumb:hover{ background:rgba(127,146,216,.55); }
  *::-webkit-scrollbar-track{ background:transparent; }
</style>
'@

SubRx @'
var VER='17.93';
'@ @'
var VER='17.94';
'@

$pat = "(?m)^  now:'v17\.93:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.94: Every menu shares one look now: glass panes, one header style, rounded buttons with a proper primary, cleaner rows, inputs and scrollbars. More stages follow for the title, the raid HUD and the stash. Check 17.94 fails on v17.93',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
