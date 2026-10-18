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

# Pause and end cards ease in too (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
scope:'#title,#partymodal',ring:null
'@ @'
scope:'#title,#partymodal,#pausebox,#outcome,#settingsmodal,#keysmodal',ring:null
'@

SubRx @'
UIM.watch(document.getElementById('title')); UIM.watch(document.getElementById('partymodal'));
'@ @'
// v29.61 (cw-uimotion2), UI STEP 2b (his words: "they are just reallly compelling and smooth"): the pause card, the end card, Settings and Keys ease open and shut
// on the same layer as the title menu and the party window. The end card makes no open sound of its own (the extraction sting plays there).
['title','partymodal','pausebox','outcome','settingsmodal','keysmodal'].forEach(function(id){ UIM.watch(document.getElementById(id)); });
'@

SubRx @'
    document.getElementById('keysreset').onclick=function(){
'@ @'
    try{ UIM.watch(m); }catch(_uw){}   // v29.61 (cw-uimotion2): the Keys window is built on first use, so it joins the motion layer here
    document.getElementById('keysreset').onclick=function(){
'@

SubRx @'
  if(on){ UIM.open(el); if(modal){ try{ sndUi('open'); }catch(_s){} } }
  else if(modal){ UIM.close(el); try{ sndUi('close'); }catch(_s){} }

'@ @'
  if(on){ UIM.open(el); if(modal&&el.id!=='outcome'){ try{ sndUi('open'); }catch(_s){} } }   // v29.61 (cw-uimotion2): the end card keeps its own sting
  else if(modal){ UIM.close(el); if(el.id!=='outcome'){ try{ sndUi('close'); }catch(_s){} } }

'@

SubRx @'
var VER='29.61';
'@ @'
var VER='29.62';
'@

$pat = "(?m)^  now:'v29\.61:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.62: The pause card, the end card, Settings and Keys now ease open and shut. Check 29.62 fails on v29.61',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
