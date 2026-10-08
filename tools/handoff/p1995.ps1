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

# THE TITLE SPEAKS CONTROLLER ON A CONTROLLER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    <div style="margin-top:22px;font-size:11.5px;color:var(--ash);letter-spacing:.05em;line-height:2">
      <b style="color:var(--bone)">WASD</b> move &nbsp;
'@ @'
    <div class="kbrow" style="margin-top:22px;font-size:11.5px;color:var(--ash);letter-spacing:.05em;line-height:2">
      <b style="color:var(--bone)">WASD</b> move &nbsp;
'@

SubRx @'
      <b style="color:var(--bone)">H</b> controls
    </div>
'@ @'
      <b style="color:var(--bone)">H</b> controls
    </div>
    <!-- v19.95, seen on the controller pass (2026-10-08): with a pad on, the title's key row named WASD, MOUSE and LMB. The pad row
         (his layout, LEGEND_PAD) shows instead, through padB on a PlayStation pad. -->
    <div class="padrow" style="margin-top:22px;font-size:11.5px;color:var(--ash);letter-spacing:.05em;line-height:2">
      <b style="color:var(--bone)">L STICK</b> move &nbsp;
      <b style="color:var(--bone)">R STICK</b> aim &nbsp;
      <b style="color:var(--bone)">RT</b> fire &nbsp;
      <b style="color:var(--bone)">B</b> crouch &nbsp;
      <b style="color:var(--bone)">X</b> search &nbsp;
      <b style="color:var(--bone)">VIEW</b> backpack &nbsp;
      <b style="color:var(--bone)">D-UP</b> hold for the map &nbsp;
      <b style="color:var(--bone)">MENU</b> pause
    </div>
'@

SubRx @'
  #invkeybarpad{ display:none; }
'@ @'
  #invkeybarpad{ display:none; }
  .padrow{ display:none; } body.padon .kbrow{ display:none !important; } body.padon .padrow{ display:block; }   /* v19.95: the title's key row on a pad */
'@

SubRx @'
r=document.getElementById('invkeybarpad'); if(r){ if(!r.dataset.src) r.dataset.src=r.innerHTML; r.innerHTML=padB(r.dataset.src); }
'@ @'
[].forEach.call(document.querySelectorAll('#invkeybarpad,.padrow'),function(r){ if(!r.dataset.src) r.dataset.src=r.innerHTML; r.innerHTML=padB(r.dataset.src); });
'@

SubRx @'
var VER='19.94';
'@ @'
var VER='19.95';
'@

$pat = "(?m)^  now:'v19\.94:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.95: On a controller the title screen shows the controller buttons. Check 19.95 fails on v19.94',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
