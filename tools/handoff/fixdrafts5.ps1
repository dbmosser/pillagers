$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# Repairs to drafts 1192 to 1198 from the read-only review wf_cfc891c0-f2e
# (eight agents, 47 findings; the highs and mediums folded in here). Blocks
# from line arrays; line breaks match \r?\n; idempotent.
$enc = New-Object Text.UTF8Encoding $false
function L { param([string[]]$lines) return ($lines -join "`n") }
function RepRx([string]$file, [string]$old, [string]$new, [int]$n) {
  $path = 'C:\claudecode\dark raiders\tools\handoff\' + $file
  $s = [IO.File]::ReadAllText($path)
  if ($s.IndexOf($new) -ge 0 -and $s.IndexOf($old) -lt 0) { Write-Output ($file + ': already repaired'); return }
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($s, $pat)).Count
  if ($c -ne $n) { throw ($file + ': anchor matched ' + $c + ' times, wanted ' + $n + ': ' + $old.Substring(0, [Math]::Min(60, $old.Length))) }
  $s = [regex]::Replace($s, $pat, { param($m) $new })
  [IO.File]::WriteAllText($path, $s, $enc)
  Write-Output ($file + ': repaired')
}

# ---- 1192, the NEW IN card: the count was wrong (142, not 137, and it grows),
# the newest-entry assertion read the pinned ALPHA line, and no viewport guard.
RepRx 'p1192.ps1' "drew every one of its 137 entries" "drew every one of its entries, past a hundred and forty" 1
RepRx 'd1192.txt' "Worse, the list is 137 entries long and grows" "Worse, the list is past a hundred and forty entries and grows" 1
RepRx 'a1192.txt' "and the 137-entry list drew in full after the size fallback" "and the list, past a hundred and forty entries, drew in full after the size fallback" 1
RepRx 'cm1192.txt' "and drew all 137 entries after its size fallback" "and drew all of its entries, past a hundred and forty, after its size fallback" 1
RepRx 'f1192.ps1' "         if(/^1\. /.test(rec[i].t)) first++;" "         if(/^2\. /.test(rec[i].t)) first++;   // the second row: the first is the pinned ALPHA notice, which the cut always keeps" 1
RepRx 'f1192.ps1' (L @(
  "     if(!(window.__wnseen&&window.__hubEnter&&window.__hubFrame&&window.__forceSize&&window.__showScreen)) return 'SKIP: this fixture cannot drive the floor card';")) (L @(
  "     if(!(window.__wnseen&&window.__hubEnter&&window.__hubFrame&&window.__forceSize&&window.__showScreen)) return 'SKIP: this fixture cannot drive the floor card';",
  "     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing renders';")) 1
RepRx 'f1192.ps1' (L @(
  "       __topClear(); __runPrep(); __forceSize(1920,1080);",
  "       G=null; keys={}; __showScreen('hub'); __hubEnter();")) (L @(
  "       __topClear(); __runPrep(); __forceSize(1920,1080);",
  "       if(!(H>400)) return 'SKIP: the canvas came back '+W+'x'+H+', too small to measure the card';",
  "       G=null; keys={}; __showScreen('hub'); __hubEnter();")) 1

# ---- 1193, the name box: the check measures the blur and a second ENTER.
RepRx 'f1193.ps1' (L @(
  "       pin.value='KESTREL 4242'; try{ pin.focus(); }catch(_f){}",
  "       pin.dispatchEvent(new KeyboardEvent('keydown',{key:'Enter',code:'Enter',bubbles:true,cancelable:true}));",
  "       if(P2.pname!=='KESTREL 4242') bad.push('ENTER in the box left the name as '+P2.pname);",
  "       if(!t.classList.contains('on')) bad.push('control: ENTER in the box started the game');",
  "       t.classList.add('on');")) (L @(
  "       pin.value='KESTREL 4242'; try{ pin.focus(); }catch(_f){}",
  "       var focused=(document.activeElement===pin);   // a hidden pane may refuse focus; the blur is measured only when it took",
  "       pin.dispatchEvent(new KeyboardEvent('keydown',{key:'Enter',code:'Enter',bubbles:true,cancelable:true}));",
  "       if(P2.pname!=='KESTREL 4242') bad.push('ENTER in the box left the name as '+P2.pname);",
  "       if(!t.classList.contains('on')) bad.push('control: ENTER in the box started the game');",
  "       if(focused&&document.activeElement===pin) bad.push('ENTER committed the name but did not leave the box');",
  "       // A SECOND ENTER, with the box left, starts the game.",
  "       t.classList.add('on');",
  "       window.dispatchEvent(new KeyboardEvent('keydown',{key:'Enter',code:'Enter',bubbles:true,cancelable:true}));",
  "       if(t.classList.contains('on')) bad.push('a second ENTER after leaving the box did not start the game');",
  "       t.classList.add('on');")) 1
RepRx 'd1193.txt' "the box itself, requires it on the profile and the title still up; then" (L @(
  "the box itself, requires it on the profile, the title still up and the box",
  "left (when the pane could focus it at all), then a second ENTER to start; then")) 1

# ---- 1194, the pause note: the abandon button closes the box first and then
# ends the raid, so its copy of the banking lines goes too, and the comment
# tells the truth.
RepRx 'p1194.ps1' (L @(
  "  // of the box over a live raid banks it now; the resume button's own copy of",
  "  // these lines is gone, and the abandon path keeps its copy because it ends",
  "  // the raid before it closes the box.")) (L @(
  "  // of the box over a live raid banks it now, and the two copies of these",
  "  // lines the resume and abandon buttons carried are gone: both close the box",
  "  // before anything ends the raid, so this is the one place that banks.")) 1
RepRx 'p1194.ps1' (L @(
  "# STAMPS.",
  "SubRx @'",
  "var VER='11.93';")) (L @(
  "SubRx @'",
  "  var note=document.getElementById('pausenote').value.trim();",
  "  if(note&&G){ G.tel.notes.push({t:Math.round(elapsed()),txt:note}); document.getElementById('pausenote').value=''; }",
  "  togglePauseBox(false);",
  "this.style.display='none';",
  "'@ @'",
  "  togglePauseBox(false);   // v11.94: the close banks the note",
  "this.style.display='none';",
  "'@",
  "",
  "# STAMPS.",
  "SubRx @'",
  "var VER='11.93';")) 1
RepRx 'p1194.ps1' "and the resume button lost its own copy of the lines" "and the resume and abandon buttons lost their own copies of the lines" 1
RepRx 'd1194.txt' (L @(
  "the run's notes, whenever the box closes over a live raid. The resume",
  "button's own copy of those lines is deleted so there is one copy. The",
  "abandon path keeps its copy, because it ends the raid before it closes the",
  "box and the close would then see a raid that is over.")) (L @(
  "the run's notes, whenever the box closes over a live raid. The resume and",
  "abandon buttons each carried their own copy of those lines; both are",
  "deleted so there is one copy. Both buttons close the box before anything",
  "ends the raid, so the close is what banks.")) 1
RepRx 'a1194.txt' "the resume button lost its duplicate copy; the abandon path keeps its own because it ends the raid first" "the resume and abandon buttons lost their duplicate copies (both close the box before the raid ends)" 1
RepRx 'cm1194.txt' "it now, for the button and for ESC alike; the button's duplicate is gone." "it now, for the buttons and for ESC alike; both buttons' duplicates are gone." 1

# ---- 1195, the first session: the default literal carries the zoom and the
# boot runs the Settings pass once more, so a loader that threw part way
# cannot skip either; and the wording claim is narrowed to the DOM.
RepRx 'p1195.ps1' (L @(
  "  // runs only when a save exists. A friend on his first launch had none, so",
  "  // the Settings rows were never applied (the wording watcher of v9.74 stayed",
  "  // unarmed and every reworded sentence shipped since v11.42 was missing until",
  "  // his second launch), and the menus drew at zoom 1.0 and grew a third larger",
  "  // the next day. Both are set here, on every load, save or none.")) (L @(
  "  // runs only when a save exists. A friend on his first launch had none, so",
  "  // the Settings rows were never applied (the wording watcher of v9.74 stayed",
  "  // unarmed, so the menus and panels showed none of the reworded sentences",
  "  // shipped since v11.42 until his second launch; canvas text had them), and",
  "  // the menus drew at zoom 1.0 and grew a third larger the next day. Both are",
  "  // set here, on every load, save or none, and the Settings pass runs again at",
  "  // the end of the boot, where a loader that threw part way cannot skip it.")) 1
RepRx 'p1195.ps1' (L @(
  "# STAMPS.",
  "SubRx @'",
  "var VER='11.94';")) (L @(
  "SubRx @'",
  "  log:[],pack:0,contracts:[],cfg:null,lastSim:null,autoExport:true,autoDownload:false,",
  "'@ @'",
  "  log:[],pack:0,contracts:[],cfg:null,menuZoom:1.3,lastSim:null,autoExport:true,autoDownload:false,",
  "'@",
  "SubRx @'",
  "  try{ applyMenuZoom(); }catch(_am){}",
  "'@ @'",
  "  try{ applyGameOpts(); }catch(_ag2){}   // v11.95: once more here, where a loader that threw part way cannot skip it",
  "  try{ applyMenuZoom(); }catch(_am){}",
  "'@",
  "",
  "# STAMPS.",
  "SubRx @'",
  "var VER='11.94';")) 1
RepRx 'a1195.txt' "(the wording watcher and every reworded sentence since v11.42 were dead all session)" "(the wording watcher was unarmed, so the menus and panels showed none of the reworded sentences since v11.42 all session)" 1
RepRx 'cm1195.txt' (L @(
  "ran the Settings pass (the wording watcher and every reworded sentence",
  "since v11.42 were dead for the session) and never set the 1.3 menu zoom.")) (L @(
  "ran the Settings pass (the wording watcher was unarmed, so the menus and",
  "panels showed none of the reworded sentences since v11.42 all session) and",
  "never set the 1.3 menu zoom.")) 1
RepRx 'd1195.txt' (L @(
  "it every reworded sentence he has been given since v11.42, the whole",
  "shipped-wording layer, was missing from every window for the entire first",
  "session; the first click on a Settings row armed it and silently rewrote")) (L @(
  "it the menus and panels showed none of the reworded sentences he has been",
  "given since v11.42 for the entire first session (canvas text is reworded at",
  "draw time and had them); the first click on a Settings row armed it and rewrote")) 1
RepRx 'd1195.txt' (L @(
  "THE BUILD. Two lines at the end of the loader, outside the branch: the",
  "menu zoom default, and the Settings pass. They run on every load, save or",
  "none, and both are already idempotent")) (L @(
  "THE BUILD. Two lines at the end of the loader, outside the branch: the",
  "menu zoom default, and the Settings pass. The default profile literal now",
  "carries the zoom as well, and the boot runs the Settings pass once more at",
  "its end, so a loader that threw part way cannot leave either unset. They",
  "run on every load, save or none, and both are already idempotent")) 1

# ---- 1196, the freebie death: the loaner leaves the ledger entirely, and the
# check starts the raid the way the lift does, because __deploy clears the
# free kit flag before it builds.
RepRx 'p1196.ps1' "      if(!_egFree){ _gunN++; if(ITEMS['gun_'+gone[j].id]) _gunVal+=ival('gun_'+gone[j].id); }" (L @(
  "      if(_egFree) continue;   // out of the ledger entirely, as an issued loaner already is: no count, no price, no line",
  "      _gunN++; if(ITEMS['gun_'+gone[j].id]) _gunVal+=ival('gun_'+gone[j].id);")) 1
RepRx 'f1196.ps1' (L @(
  "     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';",
  "     var bad=[], P2=__P(), keepW=(P2.weapons||[]).slice(), keepEq=P2.equipped, keepFree=P2.freeKit, keepKit=(P2.kit||[]).slice(), keepChosen=P2.kitChosen;",
  "     try{",
  "       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();",
  "       P2.weapons=['pistol']; P2.equipped='fists'; P2.freeKit=1; P2.kit=[]; P2.kitChosen=1; saveProfile();",
  "       __deploy({kit:[],safe:null,mapIx:0,seed:4242});",
  "       var g=__state(), p=g.player;",
  "       if(!g.freeKit) return 'SKIP: the deploy did not take the free kit';")) (L @(
  "     if(!(window.__startRaid&&window.__state&&window.__endRaid&&window.__P&&typeof commitKit==='function')) return 'SKIP: this fixture cannot start a raid';",
  "     var bad=[], P2=__P(), keepW=(P2.weapons||[]).slice(), keepEq=P2.equipped, keepFree=P2.freeKit, keepKit=(P2.kit||[]).slice(), keepChosen=P2.kitChosen, keepStash=(P2.stash||[]).slice(), keepSafe=P2.safe, keepKBF=P2.kitBeforeFree;",
  "     try{",
  "       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();",
  "       // Not __deploy: it clears the free kit flag before it builds the raid. The",
  "       // route the lift takes: the free kit chosen, commitKit stamps it, startRaid reads it.",
  "       P2.stash=[]; P2.kit=[]; P2.safe=null; P2.weapons=['pistol']; P2.equipped='fists'; P2.freeKit=1; P2.kitChosen=0; saveProfile();",
  "       commitKit(); __startRaid({mapIx:0,seed:4242});",
  "       var g=__state(), p=g.player;",
  "       if(!g||!g.freeKit) bad.push('control: the raid did not take the free kit');")) 1
RepRx 'f1196.ps1' (L @(
  "       if(/and 1 gun/.test(txt)) bad.push('the card counts the loaner as a gun you lost');")) (L @(
  "       if(txt.indexOf('KILLED IN ACTION')<0) bad.push('control: the card did not open on the death');",
  "       if(/and 1 gun/.test(txt)) bad.push('the card counts the loaner as a gun you lost');")) 1
RepRx 'f1196.ps1' "     finally{ P2.weapons=keepW; P2.equipped=keepEq; P2.freeKit=keepFree; P2.kit=keepKit; P2.kitChosen=keepChosen; try{ saveProfile(); }catch(_s){} __topClear(); __cleanProfile(); }" (L @(
  "     finally{",
  "       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('extract'); } }catch(_e){}",
  "       P2.weapons=keepW; P2.equipped=keepEq; P2.freeKit=keepFree; P2.kit=keepKit; P2.kitChosen=keepChosen; P2.stash=keepStash; P2.safe=keepSafe; P2.kitBeforeFree=keepKBF;",
  "       try{ saveProfile(); }catch(_s){} __topClear(); __cleanProfile();",
  "     }")) 1
RepRx 'd1196.txt' (L @(
  "free-kit raid, is neither counted in ""and N guns"" nor priced; it still",
  "prints its LOST line, one word, one outcome, as v9.55 asked.")) (L @(
  "free-kit raid, is out of the ledger entirely, as an issued loaner already",
  "is: not counted, not priced, no LOST line, so the count and the lines",
  "agree, which is the v10.72 rule.")) 1
RepRx 'd1196.txt' (L @(
  "MEASURED. Check 11.96 sets the profile to own one pistol with the free kit",
  "chosen, deploys, confirms the issued pistol is in hand, ends the raid by")) (L @(
  "MEASURED. Check 11.96 sets the profile to own one pistol with the free kit",
  "chosen, starts the raid the way the lift does (commitKit, then startRaid;",
  "the harness deploy clears the free kit flag before it builds, which the",
  "review caught), confirms the issued pistol is in hand, ends the raid by")) 1
RepRx 'a1196.txt' "the loaner is neither counted nor priced" "the loaner is out of the ledger entirely, as an issued gun is" 1
RepRx 'cm1196.txt' "from-armoury flag; the loaner is neither counted nor priced." "from-armoury flag; the loaner is out of the ledger entirely." 1

# ---- 1197, the heal verb: the doubled quote would have broken the game; and
# the queue can only deliver to the running heal's own ceiling.
RepRx 'p1197.ps1' "so a second Bandage above the first one''s reach was spent for nothing" "so a second Bandage above the reach of the first was spent for nothing" 1
RepRx 'p1197.ps1' (L @(
  "  if(p.hp+(p.healQ||0)>=p.maxhp){",
  "    say((p.healQ>0)?'Already healing.':'Already at full');",
  "    return false;",
  "  }",
  "  var idx=findHeal();   // skips anything that cannot raise him past what is inbound")) (L @(
  "  // What the queue can DELIVER, not what was poured in: a running heal stops",
  "  // at its own ceiling (healCap), so a Medkit over two Bandages that end at",
  "  // 85 is not refused as Already healing.",
  "  var _reach=Math.min(p.hp+(p.healQ||0),(p.healCap===undefined?p.maxhp:p.healCap));",
  "  if(_reach>=p.maxhp){",
  "    say((p.healQ>0)?'Already healing.':'Already at full');",
  "    return false;",
  "  }",
  "  var idx=findHeal();   // skips anything that cannot raise him past what is inbound")) 1
RepRx 'p1197.ps1' "    if(G.player&&G.player.hp+(G.player.healQ||0)>=healCeil(it)) continue;   // v11.97: what is inbound counts" "    if(G.player&&Math.min(G.player.hp+(G.player.healQ||0),(G.player.healCap===undefined?G.player.maxhp:G.player.healCap))>=healCeil(it)) continue;   // v11.97: what is inbound counts, up to what the running heal can deliver" 1
RepRx 'p1197.ps1' "      if(_pp.hp+(_pp.healQ||0)>=healCeil(ait)){ say(ait.name+' will not take you past '+Math.round(healCeil(ait))+'.'); return; }" "      if(Math.min(_pp.hp+(_pp.healQ||0),(_pp.healCap===undefined?_pp.maxhp:_pp.healCap))>=healCeil(ait)){ say(ait.name+' will not take you past '+Math.round(healCeil(ait))+'.'); return; }" 1
RepRx 'f1197.ps1' "       g.bag=['bandage']; p.hp=cap-20; p.healQ=25; p.prep=null; window.__lastSay=null;" "       g.bag=['bandage']; p.hp=cap-20; p.healQ=25; p.healCap=cap; p.prep=null; window.__lastSay=null;" 1
RepRx 'f1197.ps1' (L @(
  "       var r3=useMedical();",
  "       if(r3||g.bag.length!==1) bad.push('a second Bandage was spent although the first already reaches '+cap+' (bag now '+g.bag.join(',')+')');")) (L @(
  "       var r3=useMedical();",
  "       if(r3||g.bag.length!==1) bad.push('a second Bandage was spent although the first already reaches '+cap+' (bag now '+g.bag.join(',')+')');",
  "       // FIVE: a Medkit over running Bandages is still taken; the queue delivers only to their ceiling.",
  "       g.bag=['medkit']; p.hp=cap-20; p.healQ=25; p.healCap=cap; p.prep=null; window.__lastSay=null;",
  "       var r5=useMedical();",
  "       if(!r5||g.bag.length!==0) bad.push('a Medkit over running Bandages was refused (""'+String(window.__lastSay||'')+'"")');",
  "       p.healQ=0; p.healCap=undefined; p.prep=null;")) 1
RepRx 'f1197.ps1' "g2.player.prep=null; g2.player.healQ=0; __endRaid('extract');" "g2.player.prep=null; g2.player.healQ=0; g2.player.healCap=undefined; __endRaid('extract');" 1
RepRx 'f1197.ps1' "and keeps a second Bandage that cannot raise you past what is already inbound (2026-09-06 audits)'" "and keeps a second Bandage that cannot raise you past what is already inbound, while a Medkit over running Bandages is still taken (2026-09-06 audits)'" 1
RepRx 'f1198.ps1' "and keeps a second Bandage that cannot raise you past what is already inbound (2026-09-06 audits)'" "and keeps a second Bandage that cannot raise you past what is already inbound, while a Medkit over running Bandages is still taken (2026-09-06 audits)'" 2

# ---- 1198, the notes line: the doubled quote again; and the CONDITIONS
# panel, which also starts under the readout, starts under the line.
RepRx 'p1198.ps1' "requires the line under the readout''s bottom edge" "requires the line under the bottom edge of the readout" 1
RepRx 'p1198.ps1' "    var _nly=Math.max(26,Math.ceil(topRightBottom())+LH(16));" "    var _nly=Math.max(26,Math.ceil(topRightBottom())+LH(14));" 1
RepRx 'p1198.ps1' "    // the readout printed over each other from the first note he left." (L @(
  "    // the readout printed over each other from the first note he left. The",
  "    // CONDITIONS panel, which starts under the readout, starts under this too.")) 1
RepRx 'p1198.ps1' (L @(
  "# STAMPS.",
  "SubRx @'",
  "var VER='11.97';")) (L @(
  "SubRx @'",
  "    by=Math.max(by,Math.ceil((topRightBottom()+8)/_cz));",
  "'@ @'",
  "    by=Math.max(by,Math.ceil((topRightBottom()+8+((T.notes&&T.notes.length)?LH(20):0))/_cz));   // v11.98: and under the notes-logged line when there is one",
  "'@",
  "",
  "# STAMPS.",
  "SubRx @'",
  "var VER='11.97';")) 1
RepRx 'f1198.ps1' "       else if(ln.y>H) bad.push('the notes line is drawn off the canvas at y '+Math.round(ln.y));" (L @(
  "       else if(ln.y>H) bad.push('the notes line is drawn off the canvas at y '+Math.round(ln.y));",
  "       var C=(typeof HUDBOX!=='undefined')&&HUDBOX.cond;",
  "       if(ln&&C&&ln.y>C.y&&ln.y<C.y+C.h) bad.push('the notes line is drawn at y '+Math.round(ln.y)+', inside the conditions panel at '+Math.round(C.y)+' to '+Math.round(C.y+C.h));")) 1
RepRx 'd1198.txt' "topRightBottom helper the gear stack already uses to keep clear of it." (L @(
  "topRightBottom helper the gear stack already uses to keep clear of it. The",
  "CONDITIONS panel, which also starts under the readout, starts under the",
  "line when there is one, so one overlap is not traded for another (the",
  "review caught the first draft doing exactly that).")) 1
RepRx 'd1198.txt' "requires the notes line under that edge and inside the canvas." "requires the notes line under that edge, inside the canvas and outside the CONDITIONS panel's box." 1
RepRx 'a1198.txt' "It is drawn under the readout's bottom edge now, through topRightBottom." "It is drawn under the readout's bottom edge now, through topRightBottom, and the CONDITIONS panel starts under it." 1
RepRx 'cm1198.txt' "It sits under the readout's bottom edge now." "It sits under the readout's bottom edge now, and the CONDITIONS panel starts under it." 1
