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

# THE PAUSE BOX SHOWS WHAT THE RAID PAYS IN SP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  <!-- v35.xx (cw-msgroute): the last lines of the run log, so a line that no longer shows in the raid is not lost (pauseLogSync) -->
  <div id="pauselog" style="display:none;font-size:13px;color:var(--ash);margin-top:8px;max-width:620px;line-height:1.6;text-align:left;text-transform:lowercase;opacity:.85"></div>
'@ @'
  <!-- v35.75 (cw-pausesp): what this raid pays in sp, setting by setting (pauseSpSync). It replaces the run log list (cw-msgroute), which stays in the run report -->
  <div id="pausesp" style="display:none"></div>
'@

SubRx @'
// v35.xx (cw-msgroute): THE RUN LOG ON THE PAUSE BOX. Most raid lines now go only into the run log (msgReach), so the pause box lists its last 8 lines, oldest
// first, with a detail after a middle dot. It is the log the run report already keeps (G.msgLog, 16 lines), not a new screen; pickup rows are left out.
var PAUSELOGN=8;
function pauseLogSync(on){
  var el=document.getElementById('pauselog'), M=(G&&G.msgLog)||[], L=[], i, e, s, d;
  if(!el) return;
  if(!(on&&G&&!G.over)){ el.style.display='none'; return; }
  for(i=M.length-1;i>=0&&L.length<PAUSELOGN;i--){ e=M[i]; if(!e||e.k==='pick'||!e.m) continue; s=String(e.m)+(e.sub?'  \u00b7  '+String(e.sub):''); L.unshift(s.length>90?s.slice(0,88)+'...':s); }
  el.textContent='';
  if(L.length){ d=document.createElement('div'); d.textContent='run log'; d.style.color='var(--steel-hi)'; el.appendChild(d); }
  for(i=0;i<L.length;i++){ d=document.createElement('div'); d.textContent=L[i].toLowerCase(); el.appendChild(d); }
  el.style.display=L.length?'':'none';
}
'@ @'
// v35.75 (cw-pausesp), HIS ORDER (2026-10-28), on a picture of the pause box: "this isnt really helpful -- this is where all the modifiers/settings that impact sp should be shown, so the player knows exactly what they are playing".
// THE SCORE PANEL ON THE PAUSE BOX, in a raid (career or demo; never on the floor). The headline is the settings multiplier this raid pays (diffMul, what spMul
// puts on every sp), then one row per setting that moves it, with the choice it stands at and its own factor: pillager bots, machines, how hard they hit, heat
// when you call for extraction and fog of war as the raid was built with them (G.dmrows, kept beside G.dmul at the build, so a linked window shows the host's
// rows, as it is paid), and superhot as it stands now (read live, as diffMul reads it). The rows multiply to the headline. Under them the two end rules every
// raid scores by: an extraction doubles the raid score, a death halves it. Words are the Settings labels, so a row can be found there. The run log list that
// stood here (cw-msgroute) is gone from the box; the run log itself (G.msgLog) still goes out in the run report.
function gameOptLabel(k){ for(var i=0;i<GAMEOPTS.length;i++) if(GAMEOPTS[i].k===k) return String(GAMEOPTS[i].label).toLowerCase(); return k; }
function dmulRows(c){
  var t=diffTiers(c), K=[['raiders','raiders'],['robots','robots'],['hits','hits'],['ext','ext'],['fog','fogWar']], out=[], i, k, oi, w, row;
  for(i=0;i<K.length;i++){
    k=K[i][0]; row=null;
    for(oi=0;oi<GAMEOPTS.length;oi++) if(GAMEOPTS[oi].k===K[i][1]) row=GAMEOPTS[oi];
    if(k==='fog') w=t.fog?'on':'off';
    else { oi=gameOptLive(K[i][1]); w=(row&&oi>=0)?row.opts[oi].n:'custom'; }
    out.push([gameOptLabel(K[i][1]),String(w).toLowerCase(),DMUL_ON?1+DMUL_STEP[k]*(t[k]|0):1]);
  }
  return out;
}
function pauseSpSync(on){
  var el=document.getElementById('pausesp'), R, h, i, sh;
  if(!el) return false;
  if(!(on&&G&&!G.over&&!G.sim)){ el.style.display='none'; el.textContent=''; return false; }
  R=(G.dmrows&&G.dmrows.length)?G.dmrows:dmulRows(CFG);
  sh=(CFG&&CFG.superhot)?1:(DMUL_ON?1+DMUL_STEP.superhot:1);
  function rw(l,w,x){ return '<div class="psprow'+(x>1?'':' z')+'"><span>'+escHtml(l)+'</span><i>'+escHtml(w)+'</i><b>x'+x.toFixed(2)+'</b></div>'; }
  h='<div class="psph"><span>score</span><b>x'+diffMul().toFixed(2)+'</b></div>';
  for(i=0;i<R.length;i++) h+=rw(R[i][0],R[i][1],R[i][2]);
  h+=rw(gameOptLabel('superhot'),(CFG&&CFG.superhot)?'on':'off',sh);
  h+='<div class="psprule psp1"><span>extract</span><b>x2</b></div><div class="psprule"><span>killed in action</span><b>-50%</b></div>';
  el.innerHTML=h; el.style.display='';
  return true;
}
'@

SubRx @'
  try{ pauseLogSync(on); }catch(_pls){}   // v35.xx (cw-msgroute): the run log's last lines
'@ @'
  try{ pauseSpSync(on); }catch(_pls){}   // v35.75 (cw-pausesp): what this raid pays in sp, setting by setting (it was the run log's last lines, cw-msgroute)
'@

SubRx @'
  g.dmul=diffMulOf(CFG,1);   // v35.xx (cw-diffmul): the settings multiplier rows this raid was built with (a linked window builds under the host word)
'@ @'
  g.dmul=diffMulOf(CFG,1);   // v35.xx (cw-diffmul): the settings multiplier rows this raid was built with (a linked window builds under the host word)
  try{ g.dmrows=dmulRows(CFG); }catch(_dr){ g.dmrows=null; }   // v35.75 (cw-pausesp): each row's choice and factor, for the pause box score panel
'@

SubRx @'
  g.dmul=diffMulOf(CFG,1);   // v35.xx (cw-diffmul): the settings multiplier rows, as for a career raid (his rule: the demo and career play the same)
'@ @'
  g.dmul=diffMulOf(CFG,1);   // v35.xx (cw-diffmul): the settings multiplier rows, as for a career raid (his rule: the demo and career play the same)
  try{ g.dmrows=dmulRows(CFG); }catch(_dr){ g.dmrows=null; }   // v35.75 (cw-pausesp): each row's choice and factor, for the pause box score panel
'@

SubRx @'
  if(SETSUB){ SETSUB=''; renderSettings(); return; }   // v32.xx (cw-expmenu1): esc and B leave the experimental page first
  document.getElementById('settingsmodal').classList.remove('on');
};
'@ @'
  if(SETSUB){ SETSUB=''; renderSettings(); return; }   // v32.xx (cw-expmenu1): esc and B leave the experimental page first
  document.getElementById('settingsmodal').classList.remove('on');
  try{ if(pauseOpen) pauseSpSync(true); }catch(_psr){}   // v35.75 (cw-pausesp): a superhot switched in Settings mid raid shows at once on the pause box
};
'@

SubRx @'
#root #pausebox.asking #pausex{ top:calc(50% - var(--sp-1) * 20 + var(--sp-5) - var(--sp-1)); }   /* v34.xx (cw-endcards2), the critic on 59 (3 of 5): "the x is centred on a different baseline than the title (428 against 444)". 16px lower, on the title row. */
'@ @'
#root #pausebox.asking #pausex{ top:calc(50% - var(--sp-1) * 20 + var(--sp-5) - var(--sp-1)); }   /* v34.xx (cw-endcards2), the critic on 59 (3 of 5): "the x is centred on a different baseline than the title (428 against 444)". 16px lower, on the title row. */
/* v35.75 (cw-pausesp): the score panel under the title, the column's own width (--pw). Headline row: score label left, the multiplier in the sp gold at title size.
   A row: the setting, its choice, its factor; a factor of x1.00 is muted. A line, then the two end rules. Hidden while abandon asks and while a pad is lost. */
#root #pausebox #pausesp{ box-sizing:border-box; width:var(--pw); max-width:100%; display:flex; flex-direction:column; text-align:left; font:600 var(--fs-label)/1.25 var(--f-cond); letter-spacing:var(--track); color:var(--tx-1); }
#root #pausebox #pausesp .psph{ display:flex; align-items:baseline; justify-content:space-between; padding:0 0 var(--sp-1); }
#root #pausebox #pausesp .psph span{ color:var(--tx-2); }
#root #pausebox #pausesp .psph b{ font:700 var(--fs-title)/1 var(--f-cond); color:#ffc04a; font-variant-numeric:tabular-nums; }
#root #pausebox #pausesp .psprow{ display:grid; grid-template-columns:1fr auto calc(var(--sp-1) * 7); gap:var(--sp-2); align-items:baseline; padding:4px 0; }
#root #pausebox #pausesp .psprule{ display:grid; grid-template-columns:1fr calc(var(--sp-1) * 7); gap:var(--sp-2); align-items:baseline; padding:4px 0; color:var(--tx-2); }
#root #pausebox #pausesp .psp1{ margin-top:var(--sp-1); padding-top:calc(var(--sp-1) + 4px); border-top:1px solid var(--ui-line); }
#root #pausebox #pausesp i{ font-style:normal; color:var(--tx-2); }
#root #pausebox #pausesp .psprow b, #root #pausebox #pausesp .psprule b{ text-align:right; color:#ffc04a; font-variant-numeric:tabular-nums; }
#root #pausebox #pausesp .psprow.z b{ color:var(--tx-2); }
#root #pausebox.asking #pausesp, #root #pausebox.padlost #pausesp{ display:none !important; }
'@

SubRx @'
var VER='35.74';
'@ @'
var VER='35.75';
'@

$pat = "(?m)^  now:'v35\.74:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.75: the pause box shows what your raid pays in sp, setting by setting Check 35.75 fails on v35.74',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
