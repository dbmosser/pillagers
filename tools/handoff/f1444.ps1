$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
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
  {v:'14.43',what:
'@ @'
  {v:'14.44',what:'the full saves label clears when the save list is drawn again: with CREATE A NEW SAVE left reading that all eight saves are full, a redraw of the list puts its own label back (title and saves audit finding 4)',
   run:function(){
     var ng=document.getElementById('newgame');
     if(!ng||typeof titleRefresh!=='function'||!document.getElementById('slotlist')) return 'SKIP: no title save list in this document';
     var bad=[], was=ng.textContent;
     var FULL=['ALL EIGHT SAVES','HAVE PILLAGERS IN THEM'].join(' ');
     try{
       ng.textContent=FULL;
       titleRefresh();
       // CONTROL: the list was drawn, so the redraw ran.
       if(!document.querySelector('#slotlist [data-slot]')) return 'SKIP: the title list drew no save row, so the redraw did not run here';
       if(ng.textContent===FULL) bad.push('after the save list was drawn again CREATE A NEW SAVE still says all eight saves are full');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ ng.textContent=was; }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'14.43',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
