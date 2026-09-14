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
        if(_pk&&ITEMS[_pk]) grabbable(el,_pk,'plan:'+ix,ITEMS[_pk].name);
      })();
      dropzone(el,function(key,from){
        var why=(from==='rack')?rackPut(ix,key):planPut(ix,key);   // v11.95: a rack gun, like any item
'@ @'
        if(_pk&&ITEMS[_pk]) grabbable(el,_pk,'plan:'+ix,ITEMS[_pk].name);
      })();
      dropzone(el,function(key,from){
        // v14.17, Undercroft audit finding 3: A CLICK ON A FILLED BELT KEY CLEARS IT, as its tooltip says. The filled cell is
        // also a drag source with no movement threshold, so the press started a drag and the release landed on this same
        // cell: planPut ran on its own slot, renderHub rebuilt the row, and the click that clears never arrived. With nothing
        // of it packed, that release packed half the stash stack instead. Picked up and let go on its own key is a clear.
        if(from==='plan:'+ix){
          if(P.hotAssign) delete P.hotAssign[ix];
          saveProfile(); try{ sfx('pick'); }catch(e){}
          renderHub(); return;
        }
        var why=(from==='rack')?rackPut(ix,key):planPut(ix,key);   // v11.95: a rack gun, like any item
'@
SubRx @'
var VER='14.16';
'@ @'
var VER='14.17';
'@

$pat = "(?m)^  now:'v14\.16:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.17: A CLICK ON A FILLED BELT KEY CLEARS IT. The filled belt cell on the stash screen is also a drag source, so the press started a drag and the release dropped the item back on its own key: planPut ran, the row was rebuilt, and the click that clears never arrived, and with nothing of it packed the release packed half the stash stack. A release on its own key now clears the key and packs nothing. Check 14.17 clicks filled key 5 over six stash Medkits; it fails on v14.16',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
