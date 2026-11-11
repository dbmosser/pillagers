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

if ($s.Contains("  {v:'37.68',what:")) { throw "check 37.68 is in the fixture already" }

SubRx @'
  {v:'37.67',what:
'@ @'
  {v:'37.68',what:'stash break down menu uses readable parts hints and a five by two key grid, clear of stash tiles and pad stats',
   run:function(){
     if(typeof stashMenuPlace!=='function') return 'no stash menu placement';
     var saved=P, hub=document.getElementById('hub'), store=storeSet, save=saveProfile, oldZoom=P.menuZoom, oldW=W, oldH=H, bad=[];
     function overlap(a,b){ return a.left<b.right-1&&a.right>b.left+1&&a.top<b.bottom-1&&a.bottom>b.top+1; }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       storeSet=function(){}; saveProfile=function(){};
       P.stash=['gun_rifle','servo','board','comp']; P.kit=[]; P.weapons=['pistol']; P.equipped='pistol'; P.freeKit=0; P.keep={}; P.junk={}; P.stashTab='all'; P.stashSort='type'; P.menuZoom=1;
       hub.classList.add('on');
         __forceSize(1920,1080); applyMenuZoom(); renderHub();
         var cell=document.querySelector('#stashgrid .cell.c-elite');
         if(!cell) return 'no rifle cell';
         [false,true].forEach(function(tip){
           if(tip&&typeof cell.onmouseenter==='function') cell.onmouseenter(); stashCardAt(tip?cell:null);
           var c=cell.getBoundingClientRect(); openItemMenu(c.left+c.width/2,c.top+c.height/2,'gun_rifle','stash',1);
           var m=document.querySelector('.imenu'), r=m.getBoundingClientRect(), z=parseFloat(m.style.zoom)||1, row=[].filter.call(m.querySelectorAll('.imenurow'),function(e){ return /break down/.test(e.textContent); })[0];
           if(!m.classList.contains('stash-actions')||!row||!/servo 3, board 3, optic 1, comp 2/.test(row.textContent)) bad.push('missing stash parts hint');
           if(row){ var rs=getComputedStyle(row), hint=row.querySelector('em'), hs=hint&&getComputedStyle(hint); if(parseFloat(rs.fontSize)*z<19.9||!hs||parseFloat(hs.fontSize)*z<15.9||/serif$/.test(rs.fontFamily)&&!/sans-serif/.test(rs.fontFamily)) bad.push('parts menu type below floor'); }
           var kb=m.querySelectorAll('.imenukeys button');
           if(kb.length!==10) bad.push('key count is not ten');
           else { var a=kb[0].getBoundingClientRect(), b=kb[4].getBoundingClientRect(), c2=kb[5].getBoundingClientRect(), d2=kb[9].getBoundingClientRect(); if(Math.abs(a.top-b.top)>1||Math.abs(c2.top-d2.top)>1||c2.top<=a.top||Math.abs(a.left-c2.left)>1||Math.abs(b.right-d2.right)>1) bad.push('keys are not an even five by two grid'); }
           [].forEach.call(document.querySelectorAll('#stashgrid .cell'),function(e){ if(overlap(r,e.getBoundingClientRect())) bad.push('menu covers a stash tile'); });
           var d=document.getElementById('stashdetail'); if(tip&&d.classList.contains('sdon')&&overlap(r,d.getBoundingClientRect())) bad.push('menu covers pad stats');
           if(r.left<0||r.top<0||r.right>window.innerWidth+1||r.bottom>window.innerHeight+1) bad.push('menu outside viewport');
           closeItemMenu();
         });
       return bad.length?bad.join('; '):null;
     }finally{
       closeItemMenu(); stashCardAt(null); storeSet=store; saveProfile=save; P=saved; P.menuZoom=oldZoom;
       try{ __forceSize(oldW,oldH); applyMenuZoom(); __endRaid('abandon'); }catch(e){} __topClear();
     }
   }},
  {v:'37.67',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
