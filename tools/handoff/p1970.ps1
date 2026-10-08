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

# THE STASH SPEAKS CONTROLLER ON A CONTROLLER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  .keybar{ display:flex; gap:16px; align-items:center; flex-wrap:wrap;
    padding:7px 12px; border-top:1px solid var(--steel-hi); }
'@ @'
  .keybar{ display:flex; gap:16px; align-items:center; flex-wrap:wrap;
    padding:7px 12px; border-top:1px solid var(--steel-hi); }
  /* v19.70, seen on the 4K controller screenshot (2026-10-08): on a controller the stash still listed DRAG, RIGHT CLICK, SHIFT, CTRL
     and ALT. While the pad is on (body.padon) the stash shows the pad's own row instead. */
  #invkeybarpad{ display:none; }
  body.padon #invkeybar{ display:none !important; }
  body.padon #invkeybarpad{ display:flex; }
'@

SubRx @'
        <div><kbd>1-9</kbd> bind to key</div>
      </div>
'@ @'
        <div><kbd>1-9</kbd> bind to key</div>
      </div>
      <!-- v19.70: the same row for a controller (A picks up and places, v16.79; Y opens all actions, v18.27; B backs out) -->
      <div class="keybar" id="invkeybarpad">
        <div><kbd>D-PAD</kbd> move the highlight</div>
        <div><kbd>A</kbd> pick up, A again to place</div>
        <div><kbd>Y</kbd> all actions</div>
        <div><kbd>B</kbd> back</div>
      </div>
'@

SubRx @'
function pollPad(){
'@ @'
// v19.70: body.padon follows PAD.on, so the DOM menus can show the pad's own hints. Touched only when it changes.
function padBodyCls(){ var on=!!(PAD&&PAD.on); if(PAD._bodyOn!==on){ PAD._bodyOn=on; try{ document.body.classList.toggle('padon',on); }catch(_b){} } }
function pollPad(){
'@

SubRx @'
  PAD.on=true;
'@ @'
  PAD.on=true; padBodyCls();   // v19.70: the page knows the pad is on (body.padon)
'@

SubRx @'
  if(!gp){ if(PAD.on) padRelease(); PAD.on=false; PAD.prev=[]; PAD.xWas=false; PAD.xDownAt=null; PAD.xSearched=false; PAD.mx=0; PAD.my=0; return; }
'@ @'
  if(!gp){ if(PAD.on) padRelease(); PAD.on=false; PAD.prev=[]; PAD.xWas=false; PAD.xDownAt=null; PAD.xSearched=false; PAD.mx=0; PAD.my=0; padBodyCls(); return; }
'@

SubRx @'
  padRelease(); PAD.on=false; PAD.announced=false; PAD.mx=0; PAD.my=0; PAD.aiming=false;
'@ @'
  padRelease(); PAD.on=false; PAD.announced=false; PAD.mx=0; PAD.my=0; PAD.aiming=false; padBodyCls();
'@

SubRx @'
var VER='19.69';
'@ @'
var VER='19.70';
'@

$pat = "(?m)^  now:'v19\.69:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.70: On a controller the stash shows the controller buttons. Check 19.70 fails on v19.69',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
