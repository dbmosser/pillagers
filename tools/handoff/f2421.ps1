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

if ($s.Contains("  {v:'24.21',what:")) { throw "check 24.21 is in the fixture already" }

SubRx @'
  {v:'24.20',what:
'@ @'
  {v:'24.21',what:'his #50 (UI redesign ui6): one window frame: in the shop, the Mainframe, Settings, Fashion, the stash, Wirt and the Last Pour CLOSE sits in a footer at the bottom right of its frame (within 48 of its right edge and 96 of its foot), the full windows and the stash put it at one height, and the frame is the chamfered plate',
   run:function(){
     if(!(window.__station&&window.__hubEnter)) return 'SKIP: this fixture cannot walk the Undercroft';
     var bad=[], cases=[['trader','tradermodal','closetrader',0],['mf','opmodal','closeop',0],['dev','settingsmodal','closesettings',0],['mirror','appearmodal','closeappear',0],
       ['term','hub','stashclose',0],['gamble','gamblemodal','closegamble',1],['bar','barmodal','closebar',1]], tops=[], i, c, r, m, b, mr, br, z, cs, fr, n=0, lo, hi, cp;
     try{
       for(i=0;i<cases.length;i++){
         c=cases[i]; __topClear(); __hubEnter();
         r=__station(c[0],'KeyE'); if(r&&r.err){ bad.push(c[0]+': '+r.err); continue; }
         m=document.getElementById(c[1]); b=document.getElementById(c[2]);
         if(!m||!b||!m.classList.contains('on')){ bad.push(c[0]+': its window did not open'); continue; }
         mr=m.getBoundingClientRect(); br=b.getBoundingClientRect();
         if(!(br.width>0&&br.height>0)){ bad.push(c[0]+': CLOSE is not shown'); continue; }
         z=parseFloat(m.style.zoom)||1;
         if(c[3]){ cs=getComputedStyle(m,'::before'); fr={right:mr.left+mr.width/2+parseFloat(cs.width)*z/2, bottom:mr.top+mr.height/2+parseFloat(cs.height)*z/2}; }
         else fr={right:mr.right, bottom:mr.bottom};
         if(fr.right-br.right>48*z) bad.push(c[0]+': CLOSE is '+Math.round(fr.right-br.right)+' px in from the right edge of its frame');
         if(fr.bottom-br.bottom>96*z) bad.push(c[0]+': CLOSE is '+Math.round(fr.bottom-br.bottom)+' px up from the foot of its frame');
         if(br.right>fr.right+1||br.bottom>fr.bottom+1) bad.push(c[0]+': CLOSE hangs out of its frame');
         if(!c[3]) tops.push(br.top);
         n++;
       }
       if(tops.length>1){ lo=Math.min.apply(null,tops); hi=Math.max.apply(null,tops); if(hi-lo>2) bad.push('CLOSE is at '+tops.map(Math.round).join(', ')+' px down in the full windows, not at one height'); }
       cp=getComputedStyle(document.getElementById('settingsmodal'),'::before').clipPath||'';
       if(!(/polygon/).test(cp)) bad.push('the window frame has no cut corner ('+cp.slice(0,30)+')');
       if(n<5) bad.push('only '+n+' windows were measured');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'24.20',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
