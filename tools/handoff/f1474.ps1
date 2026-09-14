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
  {v:'14.73',what:
'@ @'
  {v:'14.74',what:'A on a controller packs one from the stash: a pad press on two Bandages in the stash packs one, while a mouse click on them still packs nothing (stash and trader audit finding 2)',
   run:function(){
     if(typeof renderHub!=='function'||typeof ITEMS==='undefined'||!ITEMS.bandage||!document.getElementById('stashgrid')) return 'SKIP: no stash grid in this build';
     var bad=[], prof=null, keep=null, nm=ITEMS.bandage.name+'  x';
     function cell(){ return [].slice.call(document.querySelectorAll('#stashgrid .cell')).filter(function(c){ return String(c.title||'').indexOf(nm)===0; })[0]; }
     try{
       __topClear(); __cleanProfile(); prof=__P();
       keep={s:(prof.stash||[]).slice(),k:(prof.kit||[]).slice(),h:JSON.parse(JSON.stringify(prof.hotAssign||{})),t:prof.stashTab};
       prof.stash=['bandage','bandage']; prof.kit=[]; prof.hotAssign={}; prof.stashTab='all';
       renderHub();
       var c=cell(); if(!c) return 'SKIP: the stash drew no Bandage stack';
       // CONTROL: a mouse click packs nothing, as it always has.
       c.dispatchEvent(new MouseEvent('click',{bubbles:true,cancelable:true,detail:1}));
       if(__P().kit.length!==0) return 'SKIP: a mouse click on a stash stack packed '+__P().kit.length+' here';
       c=cell(); if(!c) return 'SKIP: the Bandage stack left the stash grid';
       c.click();   // what padMenu does for A
       if(__P().kit.length!==1) bad.push('A on a controller over two Bandages in the stash packed '+__P().kit.length+', not one');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(prof&&keep){ var q=__P(); q.stash=keep.s; q.kit=keep.k; q.hotAssign=keep.h; q.stashTab=keep.t; } }catch(_a){} try{ __topClear(); __cleanProfile(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'14.73',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
