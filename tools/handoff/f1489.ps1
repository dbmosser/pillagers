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
  {v:'14.88',what:
'@ @'
  {v:'14.89',what:'a key held when the words editor opens is let go: W held, the editor opened, W released inside it, and the game no longer holds W (words audit finding 4)',
   run:function(){
     if(typeof txOpen!=='function'||typeof txClose!=='function'||typeof keys==='undefined') return 'SKIP: no words editor in this build';
     var bad=[];
     try{
       keys.KeyW=true;
       var el=txOpen('zqx probe line','zqx probe line',0,0,50,14);
       // CONTROL: the editor box is open.
       if(!el||!el.parentNode) return 'SKIP: the words editor did not open here';
       el.dispatchEvent(new KeyboardEvent('keyup',{code:'KeyW',key:'w',bubbles:true,cancelable:true}));
       txClose();
       if(keys.KeyW) bad.push('W released inside the words editor is still held by the game');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ keys.KeyW=false; txClose(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'14.88',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
