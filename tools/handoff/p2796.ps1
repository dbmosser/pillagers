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

# THE RUN CARD ENDS ON THE RESULT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  /* vNN.xx, UI REDESIGN ui5q1c (his #50, from the AAA judge
'@ @'
  /* vNN.xx, UI CLEANUP uic2 (his 2026-10-14 note, "ui and player messaging just isn't as clean as it should be", from the 1080p shots of
     the extracted, killed and abandoned cards): THE RUN CARD ENDS ON THE RESULT. Twenty-nine feedback tags and a note box took more than
     half of every run card (the haul reveal card ran past the screen and cut the bottom tag row off behind the buttons). HOW DID THAT RUN
     FEEL is a bar that opens them now, shut on every new card, a button so the pad reaches it. Every tag and the note work as before. */
  #root .ocwin .fbhead{ appearance:none; display:inline-flex; align-items:center; gap:10px; margin-top:12px; padding:9px 16px; min-height:0 !important; min-width:0 !important;
    background:transparent; border:1px solid var(--ui-line); border-radius:0; color:var(--tx-2); font-family:var(--f-cond); font-weight:700; font-size:13px; letter-spacing:.14em;
    text-transform:uppercase; cursor:pointer; }
  #root .ocwin .fbhead:hover, #root .ocwin.fbopen .fbhead{ color:var(--tx-1); border-color:var(--tx-3, #8a96a1); }
  #root .ocwin .fbhead::after{ content:'+'; color:var(--acc); font-size:17px; line-height:1; }
  #root .ocwin.fbopen .fbhead::after{ content:'\2212'; }
  #root .ocwin:not(.fbopen) #tagwrap, #root .ocwin:not(.fbopen) #oc_note{ display:none; }
  /* vNN.xx, UI REDESIGN ui5q1c (his #50, from the AAA judge
'@

SubRx @'
  <div style="font-size:13px;color:var(--ash);letter-spacing:.12em;margin-top:16px">HOW DID THAT RUN FEEL</div>
'@ @'
  <button type="button" class="fbhead" id="fbhead">HOW DID THAT RUN FEEL</button>   <!-- v27.xx (uic2): opens the tags and the note; shut on every new card -->
'@

SubRx @'
function buildTags(){
  var w=document.getElementById('tagwrap'); w.innerHTML='';
'@ @'
// v27.xx, UI CLEANUP uic2: the bar over the feedback tags opens and shuts them (the card shuts them whenever it comes up)
(function(){ var h=document.getElementById('fbhead'), w=h&&h.closest?h.closest('.ocwin'):null; if(h&&w) h.addEventListener('click',function(){ w.classList.toggle('fbopen'); }); })();
function buildTags(){
  var w=document.getElementById('tagwrap'); w.innerHTML='';
'@

SubRx @'
  selTags=[]; buildTags();
  document.getElementById('oc_note').value='';
'@ @'
  selTags=[]; buildTags();
  try{ var _fbw=document.querySelector('#outcome .ocwin'); if(_fbw) _fbw.classList.remove('fbopen'); }catch(_fbo){}   // v27.xx (uic2): every card comes up with the tags shut
  document.getElementById('oc_note').value='';
'@

SubRx @'
var VER='27.95';
'@ @'
var VER='27.96';
'@

$pat = "(?m)^  now:'v27\.95:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.96: The run cards end on the result, with the feedback tags behind a bar that opens them. Check 27.96 fails on v27.95',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
