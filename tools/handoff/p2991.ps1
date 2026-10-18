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

# OPERATOR CARD GETS A CLOSE X AND KEYS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
d=document.createElement('div'); d.className='arcoptitle';
'@ @'
// v28.xx (cw-partyx) critic 62 and 63 (3 and 2 of 5): "no close X, no key hints". A 48px ghost X sits top right, as on every modal, and a key strip runs under the rows.
  d=document.createElement('button'); d.className='arcopx'; d.setAttribute('aria-label','Close'); d.innerHTML=uiIcon('close',24);
  d.style.cssText='position:absolute;top:var(--sp-3);right:var(--sp-3);width:var(--btn-h-sm);height:var(--btn-h-sm);padding:0;display:flex;align-items:center;justify-content:center;background:transparent;color:var(--tx-1);border:1px solid var(--ui-line-hi);border-radius:var(--rad);cursor:pointer;outline:none';
  d.onclick=function(ev){ try{ ev.stopPropagation(); }catch(_s){} arcadeOpClose(); };
  el.appendChild(d);
  d=document.createElement('div'); d.className='arcoptitle';
'@

SubRx @'
  arcadeOpStyle();
}
function arcadeOpStyle(){
'@ @'
  arcadeOpHints(el);
  arcadeOpStyle();
}
function arcadeOpHints(el){
  var h=document.createElement('div'), ks=[['\u2191\u2193','Move'],['Enter','Pick'],['Esc','Back']], i, c, w;
  h.className='arcophint';
  h.style.cssText='display:flex;gap:var(--sp-3);align-items:center;margin-top:var(--sp-3);padding-top:var(--sp-2);border-top:1px solid var(--ui-line);font:600 var(--fs-label)/1 var(--f-cond);letter-spacing:var(--track);color:var(--tx-2)';
  for(i=0;i<ks.length;i++){
    w=document.createElement('span'); w.style.cssText='display:inline-flex;align-items:center;gap:var(--sp-1)';
    c=document.createElement('b'); c.textContent=ks[i][0]; c.style.cssText='display:inline-block;padding:var(--sp-1);border:1px solid var(--ui-line-hi);border-radius:var(--rad);font-weight:600;color:var(--tx-1)';
    w.appendChild(c); w.appendChild(document.createTextNode(ks[i][1])); h.appendChild(w);
  }
  el.appendChild(h);
}
function arcadeOpStyle(){
'@

SubRx @'
pl.textContent='PLAYER 2. This window links up with the player 1 window on its own. Drag it to your second screen. Your controller works here whether this window is in front or not. World sound plays from the player 1 window; the SOUND row in the PARTY window switches it. MODE: '+netModeName(NET.mode)+'.'; pl.style.display='';
'@ @'
pl.textContent='Player 2 window'; pl.style.display='';   /* v28.xx (cw-partyx) critic 58 (2 of 5): a stack of small explaining sentences. One short line now */
'@

SubRx @'
#p2line{ font-size:13px; line-height:1.5; color:var(--amber); max-width:640px; }
'@ @'
#p2line{ font:600 var(--fs-label)/1.3 var(--f-cond); letter-spacing:var(--track); color:var(--tx-2); max-width:var(--menu-w); }   /* v28.xx (cw-partyx) critic 58: was an amber 13px paragraph */
'@

SubRx @'
var VER='29.90';
'@ @'
var VER='29.91';
'@

$pat = "(?m)^  now:'v29\.90:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.91: The operator card has a close X and a key strip. The player 2 window shows one short line. Check 29.91 fails on v29.90',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
