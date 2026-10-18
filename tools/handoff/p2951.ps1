$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
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

# The craft hold has a clear bar, and the bench crafts x5, x10 or Max (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  b.style.backgroundImage=pct?('linear-gradient(to right, rgba(255,192,74,.55) '+pct+'%, rgba(0,0,0,0) '+pct+'%)'):'';
'@ @'
  // v29.xx (cw-craftbar), HIS ORDER (2026-10-15): "Hold to craft does not work correctly: it needs a clear 1-second bar." The old fill was 55% amber over an amber
  // button, so nothing seemed to move. Now a press turns the button into a dark track (#2b2414) with a solid amber fill (#ffc04a) and light text with a shadow;
  // a negative f (cancel or fire) puts every inline style back.
  if(f<0){ b.style.backgroundImage=''; b.style.backgroundColor=''; b.style.color=''; b.style.textShadow=''; b.style.boxShadow=''; return; }
  b.style.backgroundColor='#2b2414'; b.style.color='#fff4d6'; b.style.textShadow='0 1px 3px #000'; b.style.boxShadow='inset 0 0 0 2px #ffc04a';
  b.style.backgroundImage='linear-gradient(to right, #ffc04a '+pct+'%, rgba(0,0,0,0) '+pct+'%)';
'@

SubRx @'
function craftHoldCancel(){
  if(!craftHold) return;
  craftHoldPaint(craftHold.b,0);
'@ @'
function craftHoldCancel(){
  if(!craftHold) return;
  craftHoldPaint(craftHold.b,-1);
'@

SubRx @'
  b.textContent=(kind==='repair')?'HOLD TO SERVICE':'HOLD TO CRAFT';
  b.disabled=btn?btn.disabled:true;
'@ @'
  // v29.xx (cw-craftbar), HIS ORDER (2026-10-15): "A way to craft multiples quickly (for example craft 10)." Chips x1, x5, x10 and Max above the hold button (shown when the
  // stash holds at least two sets); one 1-second hold then crafts that many, never more than the stash allows.
  careerStyle('cwcraftqty','#craftdetail .cqty{display:flex;gap:8px;margin-top:12px}#craftdetail .cqty button{flex:1;min-height:40px;font-size:16px;cursor:pointer;border:2px solid var(--acc,#ffc04a);background:transparent;color:var(--ui-paper-ink,#14130f);font-family:inherit}#craftdetail .cqty button.on{background:var(--acc,#ffc04a);color:var(--acc-ink,#14130f)}');
  var qn=1, maxN=1;
  if(kind!=='repair'&&btn&&!btn.disabled&&r&&r.need){
    maxN=99;
    for(var qk in r.need) maxN=Math.min(maxN,Math.floor((counts[qk]||0)/r.need[qk]));
    maxN=Math.max(1,maxN);
    qn=Math.max(1,Math.min(P._craftQty||1,maxN));
    if(maxN>1){
      var cq=document.createElement('div'); cq.className='cqty';
      [[1,'x1'],[5,'x5'],[10,'x10'],[99,'Max']].forEach(function(o){
        var cb=document.createElement('button'); cb.type='button'; cb.textContent=o[1];
        if(o[0]===(P._craftQty||1)) cb.className='on';
        cb.onclick=function(){ P._craftQty=o[0]; renderCraftDetail(rows); };
        cq.appendChild(cb);
      });
      d.appendChild(cq);
    }
  }
  function fireN(){
    var b0=0, i, ok2=null, oN=1;
    if(kind!=='repair'&&r&&r.out){ for(var ok4 in r.out){ ok2=ok4; oN=r.out[ok4]||1; break; } b0=stashCounts()[ok2]||0; }
    for(i=0;i<qn;i++) btn.click();
    if(qn>1&&ok2){ var made=Math.round(((stashCounts()[ok2]||0)-b0)/oN); if(made>1){ try{ say2('Crafted x'+made); }catch(_sq){} } }
  }
  b.textContent=(kind==='repair')?'HOLD TO SERVICE':('HOLD TO CRAFT'+(qn>1?' x'+qn:''));
  b.disabled=btn?btn.disabled:true;
'@

SubRx @'
craftHoldStart(b,function(){ btn.click(); });
'@ @'
craftHoldStart(b,fireN);
'@

SubRx @'
say2('Hold for one second to confirm.'); }catch(_cs){} return; } btn.click(); };
'@ @'
say2('Hold for one second to confirm.'); }catch(_cs){} return; } fireN(); };
'@

SubRx @'
var VER='29.50';
'@ @'
var VER='29.51';
'@

$pat = "(?m)^  now:'v29\.50:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.51: The craft hold fills a clear bar. Pick x5, x10 or Max on the bench to craft several with one hold. Check 29.51 fails on v29.50',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
