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

# SEND PLAY DATA LEADS WITH COPY, THE TEXT IS FOLDED AWAY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    <div class="msub">copy the raid log</div>
'@ @'
    <div class="msub" id="expsum">copy the raid log</div>
'@

SubRx @'
      <button id="copybtn" style="padding:8px 22px">Copy to clipboard</button>
'@ @'
      <button id="copybtn" style="padding:8px 22px">Copy to clipboard</button>
      <button id="showdata" class="ghost" style="padding:8px 22px">show data</button>
'@

SubRx @'
  if(!_smOn) SETSUB='';   // v32.xx (cw-expmenu1)
'@ @'
  try{ expShow(0); expSum(); }catch(_ex){}   // v34.51 (cw-playdata) job 113: the play data page opens folded, with a one line summary
  if(!_smOn) SETSUB='';   // v32.xx (cw-expmenu1)
'@

SubRx @'
  var ta=document.getElementById('exporttext'), b=document.getElementById('copybtn'), was='Copy to clipboard';
'@ @'
  var ta=document.getElementById('exporttext'), b=document.getElementById('copybtn'), was='Copy to clipboard', _shut=expIsOpen()?0:1;
  expShow(1);   // v34.51 (cw-playdata): the box is folded away by default and a hidden box cannot be selected, so it opens for the copy
'@

SubRx @'
  function done(){ show('report copied',2600); }
'@ @'
  function done(){ if(_shut) expShow(0); show('report copied',2600); }
'@

SubRx @'
  function failed(){ try{ ta.focus(); ta.select(); }catch(_f){}
'@ @'
  function failed(){ expShow(1); try{ ta.focus(); ta.select(); }catch(_f){}
'@

SubRx @'
document.getElementById('exportbtn').onclick=function(){ openSettings('rec'); };
'@ @'
// v34.51 (cw-playdata) job 113, critic on screen 31 (2): "a raw debug dump filling the screen". The export text stays whole and selectable but is folded away
// by default behind show data; one muted line says what is in it. Nothing the recorder keeps or the copy sends changes.
function expIsOpen(){ var p=document.getElementById('spane_rec'); return !!(p&&p.classList.contains('expopen')); }
function expShow(on){
  var p=document.getElementById('spane_rec'), b=document.getElementById('showdata');
  if(p) p.classList.toggle('expopen',!!on);
  if(b) b.textContent=on?'hide data':'show data';
}
function expSum(){
  var s=document.getElementById('expsum'); if(!s) return;
  var n=(P.log||[]).length, f=(P.floorNotes||[]).length, c=(P.crashes||[]).length;
  s.textContent=n+(n===1?' run':' runs')+', '+f+(f===1?' note':' notes')+(c?', '+c+(c===1?' crash':' crashes'):'')+' ready to send';
}
document.getElementById('showdata').onclick=function(){ expShow(!expIsOpen()); };
document.getElementById('exportbtn').onclick=function(){ openSettings('rec'); };
'@

SubRx @'
    document.getElementById('exporttext').value=buildExport(); }
'@ @'
    document.getElementById('exporttext').value=buildExport(); try{ expSum(); }catch(_es){} }
'@

SubRx @'
if(v&&v.id==='go_superhot') html+='<div class="sdh">key: left of 1</div>';
'@ @'
if(v&&v.id==='go_superhot') html+='<div class="sdh sdkey">key: left of 1</div>';
'@

SubRx @'
#root #settingsmodal #setlist .row[style*="opacity:.7"]{ margin-top:var(--sp-3) !important; }
'@ @'
#root #settingsmodal #setlist .row[style*="opacity:.7"]{ margin-top:var(--sp-3) !important; }
/* v34.51 (cw-playdata) job 113, critic on screens 31 (2) and 92 (3). 31: the export text is folded away until show data, the summary line is muted, the copy button is the one hero, and the page packs to the top under the tab strip (the critic: 180px of dead space above the first label). 92: the focused row value is the pane hero (56px, accent) and the key line is a chip, so the pane is no longer a title and two grey lines over 800px of empty panel. */
#root #settingsmodal.recmode #spane_rec:not(.expopen) #exporttext{ display:none !important; }
#root #settingsmodal.recmode #spane_rec{ justify-content:flex-start; padding-top:var(--sp-4); }
#root #settingsmodal.recmode #spane_rec > #expsum{ font:400 var(--fs-body)/1.4 var(--f-body); color:var(--tx-2); margin:0 0 var(--sp-3); }
#root #settingsmodal.recmode #exporttext{ order:1; margin-top:var(--sp-2); }
#root #settingsmodal.recmode #exporttext + div + div{ order:2; }
#root #settingsmodal.recmode #showdata{ height:56px; min-height:56px; padding:0 var(--sp-3) !important; font:600 var(--fs-body)/1 var(--f-cond); letter-spacing:var(--track); background:transparent; color:var(--tx-1); border:1px solid var(--ui-line-hi); border-radius:var(--rad); }
#root #settingsmodal.recmode #showdata:hover, #root #settingsmodal.recmode #showdata:focus-visible, #root #settingsmodal.recmode #showdata.padfocus{ color:var(--acc); border-color:var(--acc); outline:0; }
#root #settingsmodal #setwrap > #setdetail:not(.daily-restore-detail) .sdv{ display:block; flex:1 1 100%; margin:var(--sp-2) 0 0; padding:0; border:0; font:800 var(--fs-hero)/1.1 var(--f-cond); letter-spacing:var(--track); color:var(--acc); overflow-wrap:anywhere; }
#root #settingsmodal #setwrap > #setdetail .sdkey{ display:inline-block; flex:0 0 auto; padding:var(--sp-1) var(--sp-2); border:1px solid var(--ui-line-hi); border-radius:var(--rad); color:var(--tx-1); font:600 var(--fs-label)/1.2 var(--f-cond); }
'@

SubRx @'
var VER='34.50';
'@ @'
var VER='34.51';
'@

$pat = "(?m)^  now:'v34\.50:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.51: Send play data opens on one big copy button and a short line of what is in it; show data opens the full text. Check 34.51 fails on v34.50',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
