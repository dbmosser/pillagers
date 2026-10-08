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

# LONG CONTRACTS WRAP EVENLY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawBossBar(){
'@ @'
var CONDWRAP={}, CONDWRAPN=0;   // v19.82: the CONDITIONS box's wrapped lines, by font, width and text (see wrap() below)
function drawBossBar(){
'@

SubRx @'
    function wrap(t){
      var words=String(t).split(' '),lines=[],cur='';
      for(var i=0;i<words.length;i++){
        var trial=cur?(cur+' '+words[i]):words[i];
        if(ctx.measureText(trial).width<=inner){ cur=trial; }
        else { if(cur) lines.push(cur); cur=words[i]; }
      }
      if(cur) lines.push(cur);
      return lines.length?lines:[''];
    }
'@ @'
    // v19.82, seen on the 4K raid screenshot (2026-10-08): greedy wrapping left one word and the count alone on a second line
    // (Extract carrying 1x Data / Core 0/1), splitting the item name. The same number of lines, so the box keeps its height, but
    // the words are shared out: the narrowest width that needs no more lines. Kept per font, width and text, so a frame
    // measures nothing new.
    function wrap(t){
      var ck=ctx.font+'|'+inner+'|'+t, best, n, lo, hi, mid, tr, it;
      if(CONDWRAP[ck]) return CONDWRAP[ck];
      function greedy(w){
        var words=String(t).split(' '),lines=[],cur='';
        for(var i=0;i<words.length;i++){
          var trial=cur?(cur+' '+words[i]):words[i];
          if(ctx.measureText(trial).width<=w){ cur=trial; }
          else { if(cur) lines.push(cur); cur=words[i]; }
        }
        if(cur) lines.push(cur);
        return lines.length?lines:[''];
      }
      best=greedy(inner); n=best.length; lo=inner*0.4; hi=inner;
      if(n>1){ for(it=0;it<9;it++){ mid=(lo+hi)/2; tr=greedy(mid); if(tr.length<=n){ best=tr; hi=mid; } else lo=mid; } }
      if(++CONDWRAPN>300){ CONDWRAP={}; CONDWRAPN=1; }
      return (CONDWRAP[ck]=best);
    }
'@

SubRx @'
var VER='19.81';
'@ @'
var VER='19.82';
'@

$pat = "(?m)^  now:'v19\.81:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.82: Long contracts in the CONDITIONS box break into even lines instead of leaving one word behind. Check 19.82 fails on v19.81',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
