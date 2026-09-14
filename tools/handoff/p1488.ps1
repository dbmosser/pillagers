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
var TXBOX=null;
'@ @'
var TXBOX=null, TXEAT=0;   // v14.88: set when the editor took a mousedown, so the click after it is eaten too
'@
SubRx @'
      if(CFG.textEdit!==1||!DEV_LOCAL) return;   // v10.49: never away from his machine
      if(TXBOX&&ev.target===TXBOX) return;
      var r=txClick(ev.clientX,ev.clientY);
      if(!r){ txClose(); return; }
      ev.preventDefault(); ev.stopPropagation();
      if(r.kind==='dom') return;
'@ @'
      TXEAT=0;
      if(CFG.textEdit!==1||!DEV_LOCAL) return;   // v10.49: never away from his machine
      if(TXBOX&&ev.target===TXBOX) return;
      if(ev.target&&ev.target.closest&&ev.target.closest('#go_textEdit')) return;   // v14.88: the switch that turns this off stays a switch
      var r=txClick(ev.clientX,ev.clientY);
      if(!r){ txClose(); return; }
      ev.preventDefault(); ev.stopPropagation();
      // v14.88, words audit finding 1: AND THE CLICK THAT FOLLOWS IS EATEN. Stopping mousedown does not stop the click after it,
      // so a word clicked on a button or a menu row opened the editor and pressed the button too: Equip all equipped, HIRE
      // hired, a Settings row changed its option.
      TXEAT=1;
      if(r.kind==='dom') return;
'@
SubRx @'
    },true);
  }catch(e){}
})();
// v11.52, HIS NOTE: credits and XP
'@ @'
    },true);
    document.addEventListener('click',function(ev){ if(!TXEAT) return; TXEAT=0; ev.preventDefault(); ev.stopPropagation(); },true);   // v14.88
  }catch(e){}
})();
// v11.52, HIS NOTE: credits and XP
'@
SubRx @'
var VER='14.87';
'@ @'
var VER='14.88';
'@

$pat = "(?m)^  now:'v14\.87:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.88: A WORD CLICKED IN EDIT MODE IS NOT ALSO PRESSED. The words editor stopped the mousedown but not the click after it, so clicking the word on a button or menu row opened the editor and pressed it too, equipping, hiring or changing a setting. The click that follows is now eaten, and the Edit the words switch itself still works. Check 14.88 clicks a button word in edit mode; it fails on v14.87',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
