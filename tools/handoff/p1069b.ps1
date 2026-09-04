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

# ==== THE COUNT CHANGED THE THING IT WAS COUNTING. The new check caught it
# ==== straight away: the line said 10 and 11 cards were actually hidden. The
# ==== line sits in the same column as the list, so showing it shortens the box
# ==== by its own height and pushes one more card under the fold. The first count
# ==== is out of date the moment it is acted on. Counted twice, so the number
# ==== printed is the number that is true once the line is on the page.
SubRx @'
function primerCue(){
  var host=document.getElementById('primerlist'), mo=document.getElementById('primermore');
  if(!host||!mo) return 0;
  var box=host.getBoundingClientRect(), n=0;
  for(var i=0;i<host.children.length;i++){
    if(host.children[i].getBoundingClientRect().top>=box.bottom-4) n++;
  }
  if(n>0){ mo.textContent=n+' more below. Click here, or scroll the list.'; mo.classList.add('show'); }
  else { mo.textContent=''; mo.classList.remove('show'); }
  return n;
}
'@ @'
function primerCue(){
  var host=document.getElementById('primerlist'), mo=document.getElementById('primermore');
  if(!host||!mo) return 0;
  function count(){
    var box=host.getBoundingClientRect(), k=0;
    for(var i=0;i<host.children.length;i++){
      if(host.children[i].getBoundingClientRect().top>=box.bottom-4) k++;
    }
    return k;
  }
  // TWICE. The line lives in the same column as the list, so showing it shortens
  // the box by its own height and pushes one more card under the fold. Counting
  // once printed a number that stopped being true the instant it was printed.
  // Two passes settle it: if the line is wanted it stays wanted, so this cannot
  // flip back and forth.
  var n=0;
  for(var pass=0;pass<2;pass++){
    n=count();
    if(n>0){ mo.textContent=n+' more below. Click here, or scroll the list.'; mo.classList.add('show'); }
    else { mo.textContent=''; mo.classList.remove('show'); }
  }
  return n;
}
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
