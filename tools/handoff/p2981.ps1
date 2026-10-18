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

# End cards: a stats row and achievement chips (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  #root .ocwin .fbhead::after{ color:var(--tx-2); }
'@ @'
  #root .ocwin .fbhead::after{ color:var(--tx-2); }
  /* v28.xx (cw-endcard-stats), the critic on the Extracted, KIA and Abandoned cards (2 of 5): "the stats are a run-on dotted sentence at 14px in dim grey; the guide asks for a row of 4, a 24px value over a 16px label. The achievements are a pile of sentences". The sentence stays in the card as hidden text (the checks and screen readers read it), a row of four cells shows instead: 24px value, 16px label, 1px dividers, and the achievements are name chips with a 3px accent bar. */
  #root .ocsr{ display:none; }
  #root .ocsr + br{ display:none; }
  #root .ocstat{ display:flex; width:100%; max-width:624px; margin:0 auto 24px; border-top:1px solid var(--ui-line); border-bottom:1px solid var(--ui-line); box-sizing:border-box; }
  #root .ocstat > div{ flex:1; padding:16px 8px; text-align:center; border-left:1px solid var(--ui-line); }
  #root .ocstat > div:first-child{ border-left:0; }
  #root .ocstat b{ display:block; font-family:var(--f-cond); font-size:24px; font-weight:700; line-height:1.1; letter-spacing:0; color:var(--tx-1); }
  #root .ocstat span{ display:block; margin-top:4px; font-size:16px; line-height:1.2; letter-spacing:.04em; color:var(--tx-2); }
  #root .ocachs{ display:flex; flex-wrap:wrap; gap:8px; justify-content:center; margin:16px 0 8px; }
  #root .ocach{ padding:8px 16px; font-size:16px; line-height:1.2; color:var(--tx-1); background:var(--ui-raised); border:1px solid var(--ui-line); border-left:3px solid var(--acc); border-radius:4px; }
'@

SubRx @'
function ocLedger(how,lines,x){
'@ @'
// v28.xx (cw-endcard-stats): the critic, "a run-on dotted sentence at 14px". The one stats sentence (containers, accuracy, kills, time) becomes a row of four cells and each
// achievement becomes a name chip; the old words stay in the card as hidden spans (class ocsr), so nothing that reads the card text moves. A career card has its own ledger and is left alone.
function ocStatRow(lines,st){
  var out=[], i, k, ln, m, names=[], cells, h, chips;
  for(i=0;i<lines.length;i++){ m=/ACHIEVEMENT: ([^<]*)<\/span>/.exec(String(lines[i])); if(m) names.push(m[1]); }
  for(i=0;i<lines.length;i++){
    ln=String(lines[i]);
    if(/^You extracted with \d+ of 100 health$/.test(ln)){ out.push('<span class="ocsr">'+ln+'</span>'); continue; }
    if(ln.indexOf(' accuracy &middot; ')>=0){
      cells=[[st.c|0,'Containers'],[st.k|0,'Kills'],[(st.acc|0)+'%','Accuracy'],[fmtClock(st.sec|0),'Time']];
      h='<div class="ocstat">';
      for(k=0;k<cells.length;k++) h+='<div><b>'+cells[k][0]+'</b><span>'+cells[k][1]+'</span></div>';
      out.push(h+'</div><span class="ocsr">'+ln+'</span>'); continue;
    }
    if(ln.indexOf('>ACHIEVEMENT: ')>=0){
      chips='';
      if(names.length){ chips='<div class="ocachs">'; for(k=0;k<names.length;k++) chips+='<span class="ocach">'+names[k]+'</span>'; chips+='</div>'; names=[]; }
      out.push(chips+'<span class="ocsr">'+ln+'</span>'); continue;
    }
    out.push(ln);
  }
  return out;
}
function ocLedger(how,lines,x){
'@

SubRx @'
  try{ if(G.career&&G.cs&&!G.sim&&(how==='extract'||how==='dead')) lines=ocLedger(how,lines,{acc:acc,sec:_tsec,hp:Math.round(G.player.hp),haul:haul}); }catch(_lg){ OC_LG=null; }   // v27.NN (cboard2): the AFTER ACTION LEDGER
'@ @'
  try{ if(G.career&&G.cs&&!G.sim&&(how==='extract'||how==='dead')) lines=ocLedger(how,lines,{acc:acc,sec:_tsec,hp:Math.round(G.player.hp),haul:haul}); }catch(_lg){ OC_LG=null; }   // v27.NN (cboard2): the AFTER ACTION LEDGER
  try{ if(!OC_LG){ var _kn2=0; for(var _kk2 in (T.kills||{})) _kn2+=(T.kills[_kk2]||0); lines=ocStatRow(lines,{c:T.containers|0,k:_kn2,acc:acc,sec:_tsec}); } }catch(_sr){}   // v28.xx (cw-endcard-stats): the stats row and the achievement chips
'@

SubRx @'
var VER='29.80';
'@ @'
var VER='29.81';
'@

$pat = "(?m)^  now:'v29\.80:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.81: End cards show a tidy row of stats and short achievement chips. Check 29.81 fails on v29.80',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
