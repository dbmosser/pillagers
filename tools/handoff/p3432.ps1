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

# END CARDS: SHORT XP LINE, 32PX TITLE, TILES UNDER THE LOSS, GHOST FEEDBACK BUTTON (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
if((m=/^(<span style="color:var\(--amber\)">\+[\d,]+ XP)(  &middot;  [\d,]+ of [\d,]+)(<\/span>.*)$/.exec(ln))){ out.push(m[1]+'<span class="ocsr">'+m[2]+'</span>'+m[3]); continue; }
'@ @'
// v34.xx (cw-endcards2), the critic on 35 and 60 (3 of 5, P1): "the xp line explains too much: the penalty clause, a total, and the figure twice". Q8, reason in notes/ui/changes.md: the card shows "+65 xp . 50% penalty" (or "+65 xp"); the penalty sentence and the totals stay as hidden text (class ocsr) so nothing that reads the card moves.
    if((m=/^(<span style="color:var\(--amber\)">\+[\d,]+ XP)(?: (\((\d+)% penalty [^)]*\)))?(  &middot;  [\d,]+(?: of [\d,]+| XP in all))(<\/span>.*)$/.exec(ln))){ out.push(m[1]+(m[3]?'  &middot;  '+m[3]+'% penalty':'')+'<span class="ocsr">'+(m[2]?' '+m[2]:'')+m[4]+'</span>'+m[5]); continue; }
'@

SubRx @'
    out.push(ln);
  }
  return out;
}
function ocLedger
'@ @'
    out.push(ln);
  }
  // v34.xx (cw-endcards2), the critic on 35 (3 of 5, P1): "the item tiles sit above the number and read as filler". The style guide puts the tile row under the hero: the loss figure comes first, the tiles it is made of under it.
  var _ti=-1, _li=-1;
  for(i=0;i<out.length;i++){ if(_ti<0&&String(out[i]).indexOf('<div class="octiles">')===0) _ti=i; if(_li<0&&String(out[i]).indexOf('<div class="ocloss">')===0) _li=i; }
  if(_ti>=0&&_li>_ti) out.splice(_li,0,out.splice(_ti,1)[0]);
  return out;
}
function ocLedger
'@

SubRx @'
function feedDraw(){

'@ @'
// v34.xx (cw-endcards2), the critic on 59 (3 of 5, P1): "a toast (running slowly) sits over the 80 percent scrim, the brightest thing on screen after the card". The feed waits behind the abandon question as it waits behind the map.
function feedWaits(){ var _pb=document.getElementById('pausebox'); return !!(G&&G.mapOpen)||!!(_pb&&_pb.classList.contains('asking')); }
function feedDraw(){

'@

SubRx @'
if(G.mapOpen) return 0;   // v28.xx (cw-feedmap)
'@ @'
if(feedWaits()) return 0;   // v28.xx (cw-feedmap)
'@

SubRx @'
#root #pausebox.asking #pausex{ top:calc(50% - var(--sp-1) * 20 + var(--sp-3)); }
'@ @'
#root #pausebox.asking #pausex{ top:calc(50% - var(--sp-1) * 20 + var(--sp-5) - var(--sp-1)); }   /* v34.xx (cw-endcards2), the critic on 59 (3 of 5): "the x is centred on a different baseline than the title (428 against 444)". 16px lower, on the title row. */
'@

SubRx @'
  #root .ocwin .haulstrip{ margin:8px 0 24px !important; }

'@ @'
  #root .ocwin .haulstrip{ margin:8px 0 24px !important; }
  /* v34.xx (cw-endcards2), the critic on 35, 38, 60 (3, 3 and 3 of 5) and his guide (end cards, section 2): one hero, the title is the 32px title size, the red is in ONE place, the tile row sits under the hero, the feedback line is a real ghost button.
     (1) title 40 to 32px (guide fs-title); the extracted title was a second hero beside the 56px haul figure.
     (2) killed card: the title is the red (guide: KIA is danger); the $ figure is bone, its 16px label is the red. Abandoned card keeps the red figure (the title there is bone, so the loss still reads as a loss).
     (3) tiles 80px with a 56px picture, 16px under the hero (the JS moves them under it), 32px below.
     (4) how did that run feel: 1px line-hi border, 40px high, 3px lime ring on focus. */
  #root .outcome h1{ font-size:32px; }
  #root .outcome:has(#oc_title[style*="hazard"]) .ocloss b{ color:var(--tx-1); }
  #root .outcome:has(#oc_title[style*="hazard"]) .ocloss span{ color:#ff6e55; }
  #root .octile{ width:80px; height:80px; }
  #root .octile img{ width:56px !important; height:56px !important; }
  #root .ocloss ~ .octiles{ margin:-16px 0 32px; }
  #root .ocwin .fbhead{ border:1px solid var(--ui-line-hi); border-radius:4px; min-height:40px !important; padding:8px 24px; font-size:16px; margin-top:8px; }
  #root .ocwin .fbhead:focus-visible, #root .ocwin .fbhead.padfocus{ outline:3px solid var(--acc); outline-offset:4px; }

'@

SubRx @'
var VER='34.31';
'@ @'
var VER='34.32';
'@

$pat = "(?m)^  now:'v34\.31:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.32: End cards show a short xp line, a 32px title, tiles under the loss figure and a bordered feedback button; the abandon question hides the raid feed and its x sits on the title row. Check 34.32 fails on v34.31',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
