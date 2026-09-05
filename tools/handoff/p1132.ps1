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

# COPY REPORT SAID "COPIED" WHEN NOTHING WAS COPIED. The rejection handler of
# writeText was the same function as the success handler, and the fallback
# selected a textarea inside a display:none modal, where execCommand copies
# nothing, then reported success anyway. This is the channel his friends'
# bugs reach him by.
SubRx @'
  var b=document.getElementById('oc_copy'), was='Copy report';
  function done(){ b.textContent='Copied. Paste it to Daniel.'; setTimeout(function(){ b.textContent=was; },2600); }
  try{
    if(navigator.clipboard&&navigator.clipboard.writeText) navigator.clipboard.writeText(txt).then(done,done);
    else { if(ta){ ta.select(); document.execCommand('copy'); } done(); }
  }catch(_cp){ done(); }
};
'@ @'
  var b=document.getElementById('oc_copy'), was='Copy report';
  function done(){ b.textContent='Copied. Paste it to Daniel.'; setTimeout(function(){ b.textContent=was; },2600); }
  // v11.32: a refused copy says so. The rejection handler was done() too, and
  // the fallback selected a textarea inside a hidden modal, so "Copied" came
  // up over an empty clipboard.
  function failed(){ b.textContent='Could not copy. The report is under Settings, Recorder.'; setTimeout(function(){ b.textContent=was; },4200); }
  function fallbackCopy(){
    var ok=false, tmp=document.createElement('textarea');
    tmp.value=txt; tmp.setAttribute('readonly','');
    tmp.style.cssText='position:fixed;left:0;top:0;width:2px;height:2px;opacity:0.01;font-size:16px';
    document.body.appendChild(tmp);
    try{ tmp.focus(); tmp.select(); if(tmp.setSelectionRange) tmp.setSelectionRange(0,txt.length); ok=!!document.execCommand('copy'); }catch(_e){ ok=false; }
    document.body.removeChild(tmp);
    return ok;
  }
  try{
    if(navigator.clipboard&&navigator.clipboard.writeText) navigator.clipboard.writeText(txt).then(done,function(){ if(fallbackCopy()) done(); else failed(); });
    else { if(fallbackCopy()) done(); else failed(); }
  }catch(_cp){ if(fallbackCopy()) done(); else failed(); }
};
'@

SubRx @'
var VER='11.31';
'@ @'
var VER='11.32';
'@
SubRx @'
var WHATSNEW_VER='11.31';
'@ @'
var WHATSNEW_VER='11.32';
'@
SubRx @'
  'THE STASH NO LONGER SAYS IT IS EMPTY UNDER YOUR GUN. On a fresh save the ALL tab showed your Scav Pistol and, under it, "Nothing in the stash". The message only appears when there really is nothing to show.',
'@ @'
  'COPY REPORT TELLS THE TRUTH. If your browser refuses the clipboard, the button says so and points you at Settings, Recorder, instead of saying Copied over an empty clipboard. This is how your bug reports reach me.',
  'THE STASH NO LONGER SAYS IT IS EMPTY UNDER YOUR GUN. On a fresh save the ALL tab showed your Scav Pistol and, under it, "Nothing in the stash". The message only appears when there really is nothing to show.',
'@
SubRx @'
  now:'v11.31: the stash on a fresh save said "Nothing in the stash. Ascend, pillage, extract." directly under the one Scav Pistol cell it had just drawn, because the ALL tab draws the owned guns like GUNS does but the empty-grid guard exempted GUNS alone. Reproduced on a fresh profile in memory: ALL 1, one cell, the message. The guard exempts ALL on the same terms. From the second bounded agent (Undercroft and stash), reproduced in the page first.',
'@ @'
  now:'v11.32: Copy report said Copied when nothing was copied. The clipboard rejection handler was the success handler, and on a plain http page (no navigator.clipboard) the fallback selected a textarea inside a hidden modal, where execCommand copies nothing, then reported success. This is the channel his friends bugs reach him by. A refused copy now says so and names Settings, Recorder; the fallback copies from a visible off-screen textarea and believes execCommand. Reverted and held open this session: the combat beat-to-react floor, reproduced but its edge-fix could not be proven to fire without a line-of-sight harness.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
