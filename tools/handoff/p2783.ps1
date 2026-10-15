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

# THE FINISHER SAYS HOW (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  c.font=hudFS(TYPE.micro); c.textAlign='center'; c.fillStyle='rgba(255,192,74,.96)';
  c.fillText(f>0?'FINISHING':'FINISH ['+keyLabel('KeyV','V')+']',s.x,s.y-r-6*z);
  return true;
'@ @'
  // v27.xx (feel2e), HIS WORDS (2026-10-14): "i didn't see a prompt telling me how to do the finisher -- keep it though". THE FINISHER HAS THE STANDARD WORLD PROMPT. A downed pillager in
  // reach showed FINISH [V] in tiny type over a ring, under the REVIVE prompt of the same man, and nobody saw it. It is now hudPrompt, the prompt every other world action uses (the
  // plate, the bone caps, the key drawn as a keycap): HOLD [V] FINISH, in danger red, over the man at the same spot as the REVIVE prompt and stacked under it when both are up. The ring
  // under him stays and fills while you hold. The key is named as set (CHANGE KEYS) and, on a controller, the button as bound (Y by default, TRIANGLE on a PlayStation pad; v27.xx feel2g).
  {
    var _fp=w2s(e.x,26,e.y), _fhs, _fy;
    if(_fp){
      _fhs=hudAtIn(_fp.x,_fp.y);
      try{
        _fy=_fp.y+((G.nearDown===e&&promptPick(p)==='down')?LH(26):0);
        hudPrompt('HOLD ['+keyLabel('KeyV','V')+'] FINISH',_fp.x,_fy,{col:HUDC.danger});
      } finally { c.textAlign='left'; if(_fhs) c.restore(); }
    }
  }
  return true;
'@

SubRx @'
var VER='27.82';
'@ @'
var VER='27.83';
'@

$pat = "(?m)^  now:'v27\.82:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.83: A downed pillager in reach shows HOLD V FINISH in the standard world prompt, stacked under the revive prompt. Check 27.83 fails on v27.82',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
