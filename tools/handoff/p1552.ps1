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

SubRx @'
  if(!PAD.focus||list.indexOf(PAD.focus)<0||!md.contains(PAD.focus)){
    var _pfi=(PAD.focusMd===md&&typeof PAD.focusIx==='number'&&PAD.focusIx>=0)?Math.min(PAD.focusIx,list.length-1):0;
    padSetFocus(list[_pfi]);
  }
'@ @'
  // v15.52, rack audit finding: BUILD A RACK KEEPS THE CONTROLLER HIGHLIGHT WHEN IT GREYS OUT. padFocusables leaves out a
  // disabled control, so a button that greyed out under the pad dropped off the list on the next poll, and the v14.22 line
  // below put the focus on whatever now stood at its place in the list. Building the last rack you could afford greys BUILD A
  // RACK out, and SLOT A DATA CORE slid into its place, so the next A spent the Data Core for good; building the tenth rack
  // greys it out and makes FOLD 10 RACKS INTO AN ARRAY live in its place, so the next A folded all ten racks. A mouse click
  // never moves anything. A control that goes disabled while it is still laid out in the same panel now keeps the pad: A on it
  // does nothing, the same as a click on a disabled button, and the D-pad still steps off it from where it sits. A rebuilt
  // panel still finds its place as v14.22 set it, because the old control has left the panel, and a control hidden with its
  // tab measures nothing and hands the pad on as before.
  var _pdf=PAD.focus, _pdStay=false;
  if(_pdf&&_pdf.disabled&&md.contains(_pdf)){
    var _pdr=_pdf.getBoundingClientRect(), _pdc=getComputedStyle(_pdf);
    _pdStay=(_pdr.width>=4&&_pdr.height>=4&&_pdc.display!=='none'&&_pdc.visibility!=='hidden');
  }
  if(!_pdStay&&(!PAD.focus||list.indexOf(PAD.focus)<0||!md.contains(PAD.focus))){
    var _pfi=(PAD.focusMd===md&&typeof PAD.focusIx==='number'&&PAD.focusIx>=0)?Math.min(PAD.focusIx,list.length-1):0;
    padSetFocus(list[_pfi]);
  }
'@
SubRx @'
  PAD.focusIx=list.indexOf(PAD.focus); PAD.focusMd=md;
'@ @'
  // v15.52, rack audit finding: BUILD A RACK KEEPS THE CONTROLLER HIGHLIGHT WHEN IT GREYS OUT. A disabled control kept under
  // the pad is not in the list, so the place it last held is kept for the panel rather than written over with -1.
  var _pix=list.indexOf(PAD.focus); if(_pix>=0) PAD.focusIx=_pix; PAD.focusMd=md;
'@
SubRx @'
var VER='15.51';
'@ @'
var VER='15.52';
'@

$pat = "(?m)^  now:'v15\.51:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.52: BUILD A RACK KEEPS THE CONTROLLER HIGHLIGHT WHEN IT GREYS OUT. On a controller, the last rack you could afford greyed BUILD A RACK out and the highlight slid onto SLOT A DATA CORE, or after the tenth rack onto FOLD 10 RACKS INTO AN ARRAY, so the next A spent a Data Core or folded the wall. A control that greys out under the highlight now keeps it, and A on it does nothing, the same as a mouse click on it. Check 15.52 presses A twice on BUILD A RACK with a faked controller, with parts for two racks, for one rack and a Data Core, and at nine racks; it fails on v15.51',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
