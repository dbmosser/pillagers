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
  {v:'14.15',what:
'@ @'
  {v:'14.16',what:'the stash hover key stays on its screen: with the stash screen and the ascent check both closed, a leftover hover item takes no J junk tag and no number key binding or packing, and on the stash screen J still tags it (Undercroft audit finding 2)',
   run:function(){
     if(typeof INVHOVER==='undefined') return 'SKIP: no stash hover key in this build';
     var bad=[], prof, hub=document.getElementById('hub'), stg=document.getElementById('stagemodal');
     if(!hub) return 'SKIP: no stash screen element';
     var press=function(k){ document.dispatchEvent(new KeyboardEvent('keydown',{key:k,bubbles:true,cancelable:true})); };
     var medkits=function(){ return (prof.kit||[]).filter(function(x){ return x==='medkit'; }).length; };
     try{
       __topClear(); __cleanProfile(); prof=__P();
       try{ __hubEnter(); }catch(_h){}
       prof.stash=['medkit','medkit','medkit','medkit']; prof.kit=[]; prof.hotAssign={}; prof.junk={};
       // ARM 1, THE FIX: both screens closed, with a hover item left behind.
       hub.classList.remove('on'); if(stg) stg.classList.remove('on');
       INVHOVER='medkit';
       press('j');
       if(prof.junk&&prof.junk.medkit) bad.push('with the stash screen closed, J tagged the leftover hover item as junk');
       INVHOVER='medkit';
       press('7');
       if(prof.hotAssign&&prof.hotAssign[6]!==undefined) bad.push('with the stash screen closed, key 7 bound the leftover hover item ('+prof.hotAssign[6]+')');
       if(medkits()) bad.push('with the stash screen closed, key 7 packed '+medkits()+' Medkits');
       // ARM 2, the control: on the stash screen J still tags what is under the cursor.
       prof.junk={};
       try{ renderHub(); }catch(_r){}
       hub.classList.add('on');
       INVHOVER='medkit';
       press('j');
       if(!(prof.junk&&prof.junk.medkit)) bad.push('control: on the stash screen J did not tag the hovered item as junk');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ INVHOVER=null; }catch(_i){} try{ hub.classList.remove('on'); }catch(_o){} try{ if(prof) prof.junk={}; }catch(_j){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'14.15',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
