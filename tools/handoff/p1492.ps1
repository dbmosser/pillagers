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
    var tn=null,i;
    for(i=0;i<el.childNodes.length;i++){
'@ @'
    // v14.92, words audit finding 5: THE PIECE OF TEXT UNDER THE POINTER. A sentence with a bold phrase is several text pieces,
    // and this always took the first, so clicking the words after the bold part opened the editor on the words before it and
    // his typing replaced those. The piece under the pointer is taken when there is one; the first piece is the fallback.
    var tn=null,i;
    try{ var cr=document.caretRangeFromPoint&&document.caretRangeFromPoint(cx,cy), cn=cr&&cr.startContainer;
      if(cn&&cn.nodeType===3&&cn.parentNode===el&&cn.nodeValue.replace(/\s+/g,'').length) tn=cn; }catch(_cr){}
    for(i=0;!tn&&i<el.childNodes.length;i++){
'@
SubRx @'
var VER='14.91';
'@ @'
var VER='14.92';
'@

$pat = "(?m)^  now:'v14\.91:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.92: THE WORDS EDITOR OPENS ON THE TEXT UNDER THE POINTER. In a sentence with a bold phrase the editor always took the first piece of text, so clicking the words after the bold part opened it on the words before, and his typing replaced those. It now takes the piece under the pointer. Check 14.92 clicks both sides of a bold phrase; it fails on v14.91',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
