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

if ($s.Contains("  {v:'21.32',what:")) { throw "check 21.32 is in the fixture already" }

SubRx @'
  {v:'21.31',what:
'@ @'
  {v:'21.32',what:'on the lift page the facts under each sector name start at the left edge of the name, not indented to the right of it',
   run:function(){
     if(typeof __station!=='function'||typeof __hubEnter!=='function') return 'SKIP: no stations here';
     var bad=[], t, rows, i, j, k, b, hs, br, rg, rc, lf, n=0;
     function shut(){ var a=document.querySelectorAll('.modal.on'), q; for(q=0;q<a.length;q++) a[q].classList.remove('on'); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       t=document.getElementById('title'); if(t) t.classList.remove('on');
       __hubEnter(); __station('lift','KeyE');
       rows=document.querySelectorAll('.modal.on .sectorpick');
       if(!rows.length) return 'SKIP: the lift page drew no sector card';
       for(i=0;i<rows.length;i++){
         b=rows[i].querySelector('b'); hs=rows[i].querySelectorAll('.hint');
         if(!b||!hs.length) continue;
         br=b.getBoundingClientRect(); if(!(br.width>0)) continue;
         for(j=0;j<hs.length;j++){
           if(getComputedStyle(hs[j]).display==='none') continue;
           rg=document.createRange(); rg.selectNodeContents(hs[j]); rc=rg.getClientRects(); lf=null;
           for(k=0;k<rc.length;k++) if(rc[k].width>0){ lf=rc[k].left; break; }
           if(lf===null) continue;
           n++;
           if(Math.abs(lf-br.left)>1.5) bad.push('the '+(j===hs.length-1?'facts':'description')+' line of sector card '+(i+1)+' starts '+Math.round(lf-br.left)+' px right of the sector name');
         }
       }
       if(!n) return 'SKIP: no sector line has words here';
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ shut(); __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'21.31',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
