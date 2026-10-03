$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
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

if ($s.Contains("  {v:'17.92',what:")) { throw "check 17.92 is in the fixture already" }

SubRx @'
  {v:'17.91',what:
'@ @'
  {v:'17.92',what:'F11 toggles fullscreen in this window: the game answers the key itself (the second window is a popup the browser ignores F11 in)',
   run:function(){
     if(typeof fsToggle!=='function') return 'SKIP: no fullscreen toggle in this fixture';
     var bad=[], o=fsToggle, n=0, ev;
     try{
       fsToggle=function(){ n++; return true; };
       ev=new KeyboardEvent('keydown',{code:'F11',key:'F11',bubbles:true,cancelable:true}); window.dispatchEvent(ev);
       if(n!==1) bad.push('F11 ran the fullscreen toggle '+n+' times');
       if(!ev.defaultPrevented) bad.push('F11 was left to the browser');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ fsToggle=o; }
     return bad.length?bad.join('; '):null; }},
  {v:'17.91',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
