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

if ($s.Contains("  {v:'24.63',what:")) { throw "check 24.63 is in the fixture already" }

SubRx @'
  {v:'24.62',what:
'@ @'
  {v:'24.63',what:'his #50 (UI redesign ui5q1a, from the AAA judge of the title shots): the mode list reads from the couch: mode rows at least 50px tall with labels of 17px or more, 1 PLAYER larger and taller still, the COMING LATER tag inside its greyed row, and the saves block at most 960px wide with CREATE A NEW SAVE on the name row',
   run:function(){
     var ti=document.getElementById('title'), m=document.getElementById('modemenu'), bad=[], was, b, s, st, sp, tg, br, tr, ng, pn, mw;
     if(!ti||!m) return 'SKIP: no mode menu here';
     was=ti.classList.contains('on');
     try{
       ti.classList.add('on');
       b=document.getElementById('modecoop'); st=document.getElementById('titlestart');
       if(!b) return 'SKIP: no 2 PLAYER CO-OP row here';
       s=getComputedStyle(b);
       if(!(parseFloat(s.fontSize)>=17)) bad.push('a mode row label is '+s.fontSize);
       if(!(parseFloat(s.minHeight)>=50)) bad.push('a mode row is only held to '+s.minHeight+' tall');
       if(st){
         if(!(parseFloat(getComputedStyle(st).fontSize)>=20)) bad.push('1 PLAYER is '+getComputedStyle(st).fontSize);
         if(!(st.getBoundingClientRect().height>b.getBoundingClientRect().height+4)) bad.push('1 PLAYER is no taller than the other rows');
       }
       tg=document.querySelector('#modemenu .modelater span'); b=tg&&tg.parentNode.querySelector('button');
       if(tg&&b){ br=b.getBoundingClientRect(); tr=tg.getBoundingClientRect(); if(br.width>0&&(tr.left<br.left-1||tr.right>br.right+1)) bad.push('the COMING LATER tag hangs outside its row'); }
       sp=document.getElementById('slotpanel');
       if(sp){ mw=parseFloat(getComputedStyle(sp).maxWidth); if(!(mw<=960)) bad.push('the saves block has no width cap ('+getComputedStyle(sp).maxWidth+')'); }
       ng=document.getElementById('newgame'); pn=document.getElementById('pnamein');
       if(ng&&pn&&ng.parentNode!==pn.parentNode) bad.push('CREATE A NEW SAVE is a full width row of its own under the name box');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ if(!was) ti.classList.remove('on'); try{ if(typeof titleFit==='function') titleFit(); }catch(_t){} }
     return bad.length?bad.join('; '):null; }},
  {v:'24.62',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
