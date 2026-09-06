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

# FIRST TEN MINUTES AUDIT, 2026-09-06: the title's name box has no key
# handler, so ENTER in it does nothing (the title's own listener steps aside
# while the box has focus), and the start button never reads the box, so a
# name typed and not committed with CHANGE NAME is thrown away. The box is
# the only place a pillager is ever named.
SubRx @'
    var go=function(){
      if(!t.classList.contains('on')) return;
      t.classList.remove('on');
      ac(); showScreen('hub');
    };
    document.getElementById('titlestart').onclick=go;
'@ @'
    // v11.93: THE NAME HE TYPED IS THE NAME HE GETS. The box had no key handler,
    // so ENTER in it did nothing, and the start button never read the box, so a
    // name typed and not committed with CHANGE NAME was thrown away and he was
    // PILLAGER for the rest of the alpha. ENTER commits and leaves the box, so
    // a second ENTER starts; the start button commits whatever is typed.
    if(pin) pin.onkeydown=function(ev){
      if(ev.code!=='Enter'&&ev.code!=='NumpadEnter'&&ev.key!=='Enter') return;
      ev.preventDefault(); ev.stopPropagation();
      if(psv) psv.onclick();
      try{ pin.blur(); }catch(_b){}
    };
    var go=function(){
      if(!t.classList.contains('on')) return;
      var _nv=(pin&&pin.value||'').trim().slice(0,16);
      if(_nv&&_nv!==P.pname){ P.pname=_nv; saveProfile(); }
      t.classList.remove('on');
      ac(); showScreen('hub');
    };
    document.getElementById('titlestart').onclick=go;
'@

# STAMPS.
SubRx @'
var VER='11.92';
'@ @'
var VER='11.93';
'@
SubRx @'
var WHATSNEW_VER='11.92';
'@ @'
var WHATSNEW_VER='11.93';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'ENTER IN THE NAME BOX SETS YOUR NAME, and so does the start button: what you typed is what you are called.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.92:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.92 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.92:[^']*'",{ param($m) "now:'v11.93: from the 2026-09-06 first-ten-minutes audit, the title name box had no key handler and the start button never read it, so a name typed and not committed with CHANGE NAME was thrown away. ENTER in the box commits the name and leaves the box; the start button commits whatever is typed. Check 11.93 types a name, presses ENTER in the box, and clicks the start button with another name typed, requiring both to reach the profile; fails on v11.92.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
