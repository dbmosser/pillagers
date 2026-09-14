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
  {v:'14.87',what:
'@ @'
  {v:'14.88',what:'a word clicked in edit mode is not also pressed: with the words editor on, a press on a button opens the editor on its word and the click after it does not press the button (words audit finding 1)',
   run:function(){
     if(typeof txClick!=='function'||typeof txClose!=='function'||typeof CFG==='undefined') return 'SKIP: no words editor in this build';
     var bad=[], keep=CFG.textEdit, b=null, pressed=0;
     try{
       __topClear();
       b=document.createElement('button'); b.textContent='zqx probe press';
       b.style.cssText='position:fixed;left:40px;top:40px;width:220px;height:40px;z-index:99990';
       b.onclick=function(){ pressed++; };
       document.body.appendChild(b);
       CFG.textEdit=1;
       var r=b.getBoundingClientRect(), cx=r.left+r.width/2, cy=r.top+r.height/2;
       b.dispatchEvent(new MouseEvent('mousedown',{bubbles:true,cancelable:true,clientX:cx,clientY:cy,button:0}));
       var box=document.querySelector('input[data-txorig]');
       // CONTROL: the editor opened on the button's word.
       if(!box||String(box.getAttribute('data-txorig')).indexOf('zqx probe press')<0) return 'SKIP: the words editor did not open on the button here';
       b.dispatchEvent(new MouseEvent('click',{bubbles:true,cancelable:true,clientX:cx,clientY:cy,button:0}));
       if(pressed) bad.push('clicking the word on a button in edit mode also pressed the button');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ CFG.textEdit=keep; txClose(); }catch(_a){}
       try{ if(b&&b.parentNode) b.parentNode.removeChild(b); }catch(_b){}
       try{ if(typeof TXEAT!=='undefined') TXEAT=0; }catch(_e){}
       try{ __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'14.87',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
