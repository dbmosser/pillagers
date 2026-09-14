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
    if(code==='ArrowUp'){ G.bagSel=(G.bagSel-_bc+_stN)%_stN; if(ev) ev.preventDefault(); }
    if(code==='ArrowDown'){ G.bagSel=(G.bagSel+_bc)%_stN; if(ev) ev.preventDefault(); }
'@ @'
    // v14.59, backpack audit finding 4: UP AND DOWN REACH EVERY STACK. A row step wrapped by the stack count, so with twelve
    // columns and six stacks down went from stack 0 back to stack 0, and a controller, which browses with up and down only,
    // could select, drop or inspect nothing but the first stack. Down walks a column and then moves to the top of the next
    // column; up walks back and then to the bottom of the column before.
    if(code==='ArrowUp'){
      if(G.bagSel-_bc>=0) G.bagSel-=_bc;
      else { var _ucol=(G.bagSel%_bc)-1; if(_ucol<0) _ucol=Math.min(_bc,_stN)-1; while(_ucol+_bc<_stN) _ucol+=_bc; G.bagSel=_ucol; }
      if(ev) ev.preventDefault(); }
    if(code==='ArrowDown'){ G.bagSel=(G.bagSel+_bc<_stN)?G.bagSel+_bc:((G.bagSel%_bc)+1)%Math.min(_bc,_stN); if(ev) ev.preventDefault(); }
'@
SubRx @'
var VER='14.58';
'@ @'
var VER='14.59';
'@

$pat = "(?m)^  now:'v14\.58:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.59: UP AND DOWN REACH EVERY BACKPACK STACK. A row step wrapped by the stack count, so with twelve columns and six stacks down stayed on the first stack, and a controller, which browses with up and down only, could reach nothing else. Down now walks a column and moves on to the next; up walks back. Check 14.59 presses down and up six times each over six stacks; it fails on v14.58',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
