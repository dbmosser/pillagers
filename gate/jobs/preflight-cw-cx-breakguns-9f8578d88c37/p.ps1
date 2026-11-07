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

# BREAK DOWN STASH GUNS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    var _sn=Math.min(count||1,held);
'@ @'
    // v28.xx (cw-cx-breakguns), his g-40 answer: "Yes, break it down". One stash gun, parts only, through the same keys/pad menu as selling.
    var _breakParts={common:{comp:1,scrap:2},uncommon:{servo:1,board:1,comp:1},rare:{servo:2,board:2,comp:1},elite:{servo:3,board:3,optic:1,comp:2}}[it.r];
    if(ctx==='stash'&&held>0&&_hbS&&_hbS.classList.contains('on')&&!stashLocked(key)&&it.use==='gun'&&_breakParts) rows.push({label:'break down',hint:Object.keys(_breakParts).map(function(k){ return k+' '+_breakParts[k]; }).join(', '),act:function(){
      if(!_hbS.classList.contains('on')||stashLocked(key)) return;
      var ix=P.stash.indexOf(key); if(ix<0) return;
      P.stash.splice(ix,1); clearKeysFor(key);
      Object.keys(_breakParts).forEach(function(k){ for(var i=0;i<_breakParts[k];i++) P.stash.push(k); });
      forgeSweep(); saveProfile(); refreshInv();
    }});
    var _sn=Math.min(count||1,held);
'@

SubRx @'
var VER='37.56';
'@ @'
var VER='37.57';
'@

$pat = "(?m)^  now:'v37\.56:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.57: Unlocked stash guns have break down in the same item menu for keys and pad. Common gives comp 1 and scrap 2; uncommon servo 1, board 1, comp 1; rare servo 2, board 2, comp 1; elite servo 3, board 3, optic 1, comp 2. One copy is consumed and orphaned forge records are cleared. Check 37.57 fails on v37.56',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
