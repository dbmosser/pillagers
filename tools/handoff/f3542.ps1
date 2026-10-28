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

if ($s.Contains("  {v:'35.42',what:")) { throw "check 35.42 is in the fixture already" }

SubRx @'
  {v:'35.41',what:
'@ @'
  {v:'35.42',what:'THE STASH HOVER KEEPS EVERY BOX: mousing over six different items (a gun, an SMG, a medkit, armour, a grenade, junk) and an idle line leaves every panel of the stash screen at the same size and place to the pixel, and the item line holds the longest gun',
   run:function(){
     if(!window.__hubEnter||!window.__station) return 'SKIP: this fixture cannot walk the Undercroft';
     var bad=[], hub, cells, i, j, c, det, base, now, hov=[], picked=0, rows, w;
     function snap(){
       var o=[], els=document.querySelectorAll('#hub *'), e, r, k;
       for(k=0;k<els.length;k++){ e=els[k]; if(e.closest('#stashdetail')) continue; r=e.getBoundingClientRect(); o.push([e.id||(e.className&&e.className.baseVal===undefined?String(e.className).split(' ')[0]:e.tagName), Math.round(r.left*100)/100, Math.round(r.top*100)/100, Math.round(r.width*100)/100, Math.round(r.height*100)/100]); }
       return o;
     }
     function same(a,b){
       var k, n=0, first='';
       if(a.length!==b.length) return 'the panel count moved '+a.length+' to '+b.length;
       for(k=0;k<a.length;k++) if(a[k].slice(1).join()!==b[k].slice(1).join()){ n++; if(!first) first=a[k][0]+' '+a[k].slice(1).join('/')+' became '+b[k].slice(1).join('/'); }
       return n?(n+' boxes moved, first '+first):'';
     }
     try{
       __topClear(); __runPrep(); __pinDPR(1); __forceSize(1920,1080); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __hubEnter();
       P.stash.push('gun_rifle','gun_smg','medkit','medkit','bandage','plate','frag','smoke'); P.junk={bandage:1}; saveProfile();
       __station('term','KeyE'); renderHub();
       hub=document.getElementById('hub'); det=document.getElementById('stashdetail');
       cells=document.querySelectorAll('#stashgrid .cell');
       if(!hub||!det||cells.length<6){ bad.push('staging: '+(cells?cells.length:0)+' cells on the stash screen'); }
       else {
         base=snap();
         if(getComputedStyle(det).display==='none') bad.push('the item line is hidden while nothing is hovered, so it opens on the first hover and moves the grids');
         for(i=0;i<cells.length&&picked<7;i++){
           c=cells[i]; c.dispatchEvent(new MouseEvent('mouseenter'));
           if(!String(det.textContent||'').length) continue;
           picked++; hov.push(String(det.textContent).slice(0,24));
           now=snap(); w=same(base,now); if(w) bad.push('hover '+picked+' ('+hov[picked-1]+'): '+w);
         }
         if(picked<6) bad.push('staging: only '+picked+' hovers drew an item line');
         // the longest real gun line: an upgrade and an element row, the full stat list and a kill tally, with the longest damage text
         rows=document.createElement('div');
         rows.style.cssText='margin-top:5px';
         [['UPGRADE','MK III'],['ELEMENT','Frost   slows what it hits and cracks armour'],['DAMAGE','124.8 a hit   Rare +20%   8 pellets of 15.6   3-round burst   ~245/sec held'],['RATE','167 rpm   automatic'],['MAGAZINE','24 rounds   1.9s reload'],['RANGE','50m'],['ACCURACY','scattergun'],['NOISE','very loud'],['KILLS','1,234']].forEach(function(r){
           var d=document.createElement('div'); d.style.cssText='display:flex;gap:8px;font-size:11px;line-height:1.5';
           d.innerHTML='<span style="width:88px;opacity:.55;letter-spacing:.1em">'+r[0]+'</span><span style="color:var(--bone)">'+r[1]+'</span>'; rows.appendChild(d); });
         det.replaceChild(rows,det.lastElementChild);
         now=snap(); w=same(base,now); if(w) bad.push('the longest gun line: '+w);
         if(innerWidth>=1600&&det.scrollHeight>det.clientHeight+1) bad.push('the longest gun line does not fit its box ('+det.scrollHeight+' in '+det.clientHeight+') win '+innerWidth+'x'+innerHeight+' zoom '+getComputedStyle(hub).zoom+' rowH '+[].map.call(rows.children,function(x){return Math.round(x.getBoundingClientRect().height);}).join(',')+' fs '+getComputedStyle(rows.firstChild.lastChild).fontSize+' ff '+getComputedStyle(det).fontFamily.slice(0,30));
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ var hb=document.getElementById('hub'); if(hb) hb.classList.remove('on'); }catch(_h){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'35.41',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
