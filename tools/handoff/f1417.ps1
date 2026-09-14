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
  {v:'14.16',what:
'@ @'
  {v:'14.17',what:'a click on a filled tactical belt key clears it: press and release on filled key 5 of the stash screen belt unbinds the key and packs nothing, where it kept the key and packed half the stash stack (Undercroft audit finding 3)',
   run:function(){
     var bad=[], prof;
     var medkits=function(a){ return (a||[]).filter(function(x){ return x==='medkit'; }).length; };
     try{
       __topClear(); __cleanProfile(); prof=__P();
       try{ __hubEnter(); __station('stash'); }catch(_h){}
       prof.stash=['medkit','medkit','medkit','medkit','medkit','medkit']; prof.kit=[]; prof.hotAssign={4:'medkit'};
       try{ renderHub(); }catch(_r){}
       var cell=document.querySelector('#hotplanwrap [data-plan="4"]');
       if(!cell||typeof cell.__grabDrop!=='function') return 'SKIP: no stash screen belt key 5 drop cell to drive';
       // CONTROL: the filled cell is a drag source, which is why a click on it is a drag at all.
       if(cell.style.cursor!=='grab') bad.push('control: filled belt key 5 is not a drag source, so a click is not a drag here');
       // The real press and release when the cell is on screen and on top; the drop handler itself otherwise.
       var rc=cell.getBoundingClientRect(), cx=rc.left+rc.width/2, cy=rc.top+rc.height/2;
       var hit=(rc.width>0)?document.elementFromPoint(cx,cy):null;
       if(hit&&hit.closest&&hit.closest('[data-drop]')===cell){
         cell.dispatchEvent(new MouseEvent('mousedown',{button:0,clientX:cx,clientY:cy,bubbles:true,cancelable:true}));
         document.dispatchEvent(new MouseEvent('mouseup',{button:0,clientX:cx,clientY:cy,bubbles:true,cancelable:true}));
       } else cell.__grabDrop('medkit','plan:4');
       if(prof.hotAssign&&prof.hotAssign[4]!==undefined) bad.push('a click on filled belt key 5 left it bound to '+prof.hotAssign[4]);
       if(medkits(prof.kit)) bad.push('a click on filled belt key 5 packed '+medkits(prof.kit)+' Medkits from the stash');
       if(medkits(prof.stash)!==6) bad.push('control: the stash holds '+medkits(prof.stash)+' Medkits, not six');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(typeof GRAB!=='undefined'&&GRAB) grabEnd(); }catch(_g){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'14.16',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
