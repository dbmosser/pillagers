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

# ARCADE: INITIALS AT THE FIRST TOP 10 EXTRACTION (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  try{ arcadeBoardPut(); }catch(_bp){}   // v23.41 (arcade18): the board row is written at every extraction
'@ @'
  try{ arcadeBoardPut(); }catch(_bp){}   // v23.41 (arcade18): the board row is written at every extraction
  try{ arcadeIniExtract(); }catch(_ie){}   // v23.45 (arcade22): the first extraction into tonights top 10 offers the initials card
'@

SubRx @'
  try{ arcadeCardHud(); }catch(_ach){}   // v23.42 (arcade19): the controls card while shielded and 4 s after
'@ @'
  try{ arcadeCardHud(); }catch(_ach){}   // v23.42 (arcade19): the controls card while shielded and 4 s after
  try{ arcadeIniHud(); }catch(_aih){}   // v23.45 (arcade22): the initials card at a top 10 extraction
'@

SubRx @'
  var t=+ARCADE.holdT||0, n, y, cx=Math.round(W/2), s;
  if(!(t>0)) return;
'@ @'
  var t=+ARCADE.holdT||0, n, y, cx=Math.round(W/2), s;
  if(!(t>0)) return;
  if(arcadeIniRaid()) return;   // v23.45 (arcade22): the initials card holds the drop, so no count yet
'@

SubRx @'
  if(G&&G.arcade&&!arcadeBenched()) return false;            // a raid is on here: the key plays (v23.25, arcade6: unless player 1 is benched)
'@ @'
  if(arcadeIniRaid()) return arcadeIniKey(e);   // v23.45 (arcade22): the initials card at an extraction takes the keys (ESC still pauses)
  if(G&&G.arcade&&!arcadeBenched()) return false;            // a raid is on here: the key plays (v23.25, arcade6: unless player 1 is benched)
'@

SubRx @'
  run=(typeof run==='string'&&run)?run:((ARCADE.run&&ARCADE.run.id)||'');
  if(!ARCADE.on||!run) return false;
  ARCADE.ini={run:run,l:['A','A','A'],pos:0,at:Date.now(),touched:0,mirror:0};
'@ @'
  run=(typeof run==='string'&&run)?run:((ARCADE.run&&ARCADE.run.id)||'');
  if(!ARCADE.on||!run) return false;
  if(ARCADE.ini&&!ARCADE.ini.mirror&&ARCADE.ini.run===run) return true;   // v23.45 (arcade22): the card from the extraction stays, letters and all
  ARCADE.ini={run:run,l:['A','A','A'],pos:0,at:Date.now(),touched:0,mirror:0};
'@

SubRx @'
// NEW HIGH SCORE: the run authority, every half second in an arcade raid. The bar is tonights best of the other runs, read once per run.
'@ @'
// v23.45, HIS YES (2026-10-11), arcade22: INITIALS AT THE FIRST QUALIFYING EXTRACTION. His words: a team that walks away still gets its
// name on the board. The initials card came only at the run end, so a party that walked off mid-run left ??? or nothing. Now the
// first extraction that puts the run into tonights top 10 (no initials yet) opens the 3 letter card on the EXTRACTED banner, on the
// run authority. It holds the drop (DROPPING IN waits at 3) while it is up, takes the keyboard (letters, Backspace, Enter, the
// arrows; ESC still pauses) and this window pad (up and down change the letter, right or A next, left or B back, MENU done), and
// closes as at the run end: 20 s with no input keeps what is there, or ??? if never touched. The row keeps the initials, so the
// run end asks no more. Only an arcade raid reaches any of it.
function arcadeIniRaid(){
  var n=ARCADE.ini;
  return !!(ARCADE.on&&n&&n.raid&&!n.mirror&&G&&G.arcade&&!G.over&&!G.sim&&!arcadeBenched());
}
function arcadeIniExtract(){
  if(!G||!G.arcade||G.sim||!arcadeBoardAuth()||!ARCADE.run||!ARCADE.run.id) return false;
  var id=ARCADE.run.id;
  if(arcadeIniLive()||ARCADE.iniX===id||!arcadeBoardQual(id)) return false;
  if(!arcadeIniStart(id)||!ARCADE.ini) return false;
  ARCADE.iniX=id; ARCADE.ini.raid=1;
  return true;
}
function arcadeIniHud(){
  var n=ARCADE.ini, cx, y, bw, bh, i, gx, lx, left;
  if(!arcadeIniRaid()||!ctx) return;
  cx=Math.round(W/2); y=Math.round(H*0.56); bw=LH(500); bh=LH(156); gx=LH(56);
  left=Math.max(0,Math.ceil((ARCADE_BOARD.iniMs-(Date.now()-(+n.at||0)))/1000));
  ctx.save(); ctx.textAlign='center'; ctx.textBaseline='alphabetic';
  ctx.fillStyle='rgba(6,9,13,.86)'; ctx.fillRect(cx-bw/2,y-LH(46),bw,bh);
  ctx.strokeStyle='rgba(127,227,212,.75)'; ctx.lineWidth=2; ctx.strokeRect(cx-bw/2+1,y-LH(46)+1,bw-2,bh-2);
  ctx.font=FS(TYPE.head); ctx.fillStyle='#7fe3d4'; hudText('TOP 10 TONIGHT \u00b7 ENTER INITIALS',cx,y-LH(18));
  for(i=0;i<3;i++){
    lx=Math.round(cx+(i-1)*gx);
    ctx.font=FSz(TYPE.huge,1.3); ctx.fillStyle=(i===n.pos)?'#ffc04a':'#f2e6c8'; hudText(n.l[i]||'A',lx,y+LH(36));
    ctx.fillRect(lx-LH(19),y+LH(44),LH(38),(i===n.pos)?3:2);
  }
  ctx.font=FS(TYPE.micro); ctx.fillStyle='rgba(242,230,200,.82)';
  hudText(padB('TYPE OR \u25b2\u25bc  \u00b7  A NEXT  \u00b7  B BACK  \u00b7  ENTER / MENU DONE')+'  \u00b7  '+left,cx,y+LH(80));
  ctx.restore();
}
// NEW HIGH SCORE: the run authority, every half second in an arcade raid. The bar is tonights best of the other runs, read once per run.
'@

SubRx @'
  if(padMenu(pressed)){ padRelease(); return; }
'@ @'
  // v23.45 (arcade22): the initials card at an arcade extraction takes this window pad, with its own latch, so a press does nothing else
  if(typeof ARCADE==='object'&&ARCADE&&ARCADE.on&&arcadeIniRaid()){
    var _irw=[], _iri;
    for(_iri=0;_iri<bt.length;_iri++) if(pressed(_iri)&&!PAD.prev[_iri]) _irw.push(_iri);
    for(_iri=0;_iri<bt.length;_iri++) PAD.prev[_iri]=pressed(_iri);
    padRelease();
    try{ arcadePadIni(_irw,ax); }catch(_api){}
    return;
  }
  if(padMenu(pressed)){ padRelease(); return; }
'@

SubRx @'
ARCADE.holdT=Math.max(0,(+ARCADE.holdT||0)-dt); netPausedStep(dt); }
'@ @'
ARCADE.holdT=Math.max(arcadeIniRaid()?3:0,(+ARCADE.holdT||0)-dt); netPausedStep(dt); }   /* v23.45 (arcade22): the initials card holds the drop at 3 */
'@

SubRx @'
var VER='23.44';
'@ @'
var VER='23.45';
'@

$pat = "(?m)^  now:'v23\.44:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.45: In the arcade the first extraction that makes tonights top 10 opens the 3 letter initials card and holds the drop until it is done, and the board row keeps those initials. Check 23.45 fails on v23.44',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
