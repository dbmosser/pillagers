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
  {v:'14.91',what:
'@ @'
  {v:'14.92',what:'the words editor opens on the text under the pointer: in a line with a bold phrase, a click over the words before it opens on those and a click over the words after it opens on those (words audit finding 5)',
   run:function(){
     if(typeof txClick!=='function'||typeof txClose!=='function'||typeof CFG==='undefined') return 'SKIP: no words editor in this build';
     var bad=[], keep=CFG.textEdit, d=null;
     try{
       __topClear();
       d=document.createElement('div');
       d.style.cssText='position:fixed;left:40px;top:120px;z-index:99990;font:20px monospace;color:#fff;background:#000;white-space:nowrap;padding:4px';
       d.innerHTML='AAAA <b>BB</b> CCCCCCCCCCCC';
       document.body.appendChild(d);
       CFG.textEdit=1;
       var r=d.getBoundingClientRect(), cy=r.top+r.height/2;
       var hA=txClick(r.left+12,cy); txClose();
       // CONTROL: a click over the first words opens the editor on them.
       if(!hA||hA.kind!=='dom'||String(hA.orig).indexOf('AAAA')<0) return 'SKIP: a click over the first words did not open on them here ('+(hA&&hA.orig)+')';
       var hC=txClick(r.right-30,cy); txClose();
       if(!hC||String(hC.orig).indexOf('CCCC')<0) bad.push('a click over the words after the bold phrase opened the editor on '+JSON.stringify(hC&&hC.orig));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ CFG.textEdit=keep; txClose(); }catch(_a){} try{ if(d&&d.parentNode) d.parentNode.removeChild(d); }catch(_b){} try{ __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'14.91',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
