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

if ($s.Contains("  {v:'24.44',what:")) { throw "check 24.44 is in the fixture already" }

SubRx @'
  {v:'24.43',what:
'@ @'
  {v:'24.44',what:'his #50 (UI redesign ui5q1c, from the AAA judge of the title shot with a pick stopped on the blocked window note): the picked row carries the amber rail, 1 PLAYER is no longer the amber fill while the pick waits, the note is an alert card at 15px or more, RETRY is the amber primary, and clearing the note clears the marks',
   run:function(){
     if(typeof netModeMsg!=='function'||typeof NET!=='object') return 'SKIP: no mode menu here';
     var bad=[], co=document.getElementById('modecoop'), st=document.getElementById('titlestart'), mg=document.getElementById('modemsg'), rt=document.getElementById('moderetry'), ti=document.getElementById('title'), was, pk0=NET.pick, ap0=NET.arcPick, s, nt=null;
     if(!co||!st||!mg||!rt) return 'SKIP: no mode rows here';
     was=ti&&ti.classList.contains('on');
     function fill(el){ return getComputedStyle(el).backgroundColor; }
     try{
       if(ti) ti.classList.add('on');
       nt=document.createElement('style'); nt.textContent='#modemenu, #modemenu *{ transition:none !important; }'; document.head.appendChild(nt);   // read the end state, not a fade in progress
       netModeMsg('');
       var stIdle=fill(st);
       NET.pick='coop'; NET.arcPick=false;
       netModeMsg('A NOTE '+'FOR THE CHECK',true);
       s=getComputedStyle(co);
       if(!/inset/.test(s.boxShadow)) bad.push('the picked row 2 PLAYER CO-OP does not show it is the pick ('+s.boxShadow+')');
       if(fill(st)===stIdle) bad.push('1 PLAYER keeps its amber fill ('+stIdle+') while the pick waits');
       s=getComputedStyle(mg);
       if(!(parseFloat(s.fontSize)>=15)) bad.push('the note is '+s.fontSize);
       s=getComputedStyle(document.getElementById('modealert')||mg);
       if(!(parseFloat(s.borderLeftWidth)>=3)) bad.push('the note has no alert rail');
       if(fill(rt)!==stIdle) bad.push('RETRY is not the amber primary ('+fill(rt)+' against '+stIdle+')');
       netModeMsg('');
       if(co.classList.contains('picked')||fill(st)!==stIdle) bad.push('clearing the note left the pick marks on');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(nt) nt.remove(); }catch(_n){} NET.pick=pk0; NET.arcPick=ap0; try{ netModeMsg(''); }catch(_m){} if(ti&&!was) ti.classList.remove('on'); }
     return bad.length?bad.join('; '):null; }},
  {v:'24.43',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
