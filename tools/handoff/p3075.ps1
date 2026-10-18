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

# party prompts follow the last input device (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var d=attEl(), v=d.querySelector('video'), ap=d.querySelector('.attpress'), w=(ARCADE.role==='p2')?'PLAYER 2: PRESS A':(arcadeBenched()?'PLAYER 1: PRESS ANY BUTTON':'PRESS ANY BUTTON'), pr;
'@ @'
var d=attEl(), v=d.querySelector('video'), ap=d.querySelector('.attpress'), w=(ARCADE.role==='p2')?'PLAYER 2: PRESS A':((arcadeBenched()?'PLAYER 1: ':'')+'PRESS ANY '+(padOn()?'BUTTON':'KEY')), pr;   // v30.xx (cw-glyphs2), HIS ORDER (2026-10-18): "player should get key prompts if that is the last input they used -- xbox controller prompts should only pop up if player is actively using the controller -- e.g. real time glyph switching". The host attract names the device last used; player 2 is the pad window and keeps PRESS A
'@

SubRx @'
say('STILL PLAYING?','warn',{sub:'PRESS ANY BUTTON',key:'arcidle'}); }catch(_s1){} }
'@ @'
say('STILL PLAYING?','warn',{sub:'PRESS ANY '+(padOn()?'BUTTON':'KEY'),key:'arcidle'}); }catch(_s1){} }   // v30.xx (cw-glyphs2): key or button by the last device used
'@

SubRx @'
say((end?'RUN ENDS IN ':'OUT IN ')+n,'warn',{sub:'PRESS ANY BUTTON',key:'arcidle'}); }catch(_s2){} }
'@ @'
say((end?'RUN ENDS IN ':'OUT IN ')+n,'warn',{sub:'PRESS ANY '+(padOn()?'BUTTON':'KEY'),key:'arcidle'}); }catch(_s2){} }   // v30.xx (cw-glyphs2): key or button by the last device used
'@

SubRx @'
hudText(padB('Y or A  yes  \u00b7  N or B  no')+'  \u00b7  '+Math.ceil(left/1000),cx,y+LH(18));
'@ @'
hudText((padOn()?padB('A yes  \u00b7  B no'):'Y yes  \u00b7  N no')+'  \u00b7  '+Math.ceil(left/1000),cx,y+LH(18));   // v30.xx (cw-glyphs2), HIS ORDER (2026-10-18): "player should get key prompts if that is the last input they used -- xbox controller prompts should only pop up if player is actively using the controller -- e.g. real time glyph switching". The card named both devices (Y or A, N or B); it names the one in use
'@

SubRx @'
function arcadeIniDraw(c,n){
'@ @'
// v30.xx (cw-glyphs2), HIS ORDER (2026-10-18): "player should get key prompts if that is the last input they used -- xbox controller prompts should only pop up
// if player is actively using the controller". The initials hint said TYPE OR the arrows, A NEXT, B BACK, ENTER / MENU DONE: both devices at once. It names the keys
// of the keyboard, or the buttons of the pad (MENU stays an upper case word so a PlayStation pad can rename it, see padB), by the last device used.
function iniHint(){ return padOn()?padB('\u25b2\u25bc letter  \u00b7  A next  \u00b7  B back  \u00b7  MENU done'):'Type or \u25b2\u25bc  \u00b7  Space next  \u00b7  Backspace back  \u00b7  Enter done'; }
function arcadeIniDraw(c,n){
'@

SubRx @'
el.className='aoq'; el.textContent=padB('TYPE OR \u25b2\u25bc  \u00b7  A NEXT  \u00b7  B BACK  \u00b7  ENTER / MENU DONE'); c.appendChild(el);
'@ @'
el.className='aoq'; el.textContent=iniHint(); c.appendChild(el);   // v30.xx (cw-glyphs2): the hint of the device last used (arcadeOverSync keeps it current)
'@

SubRx @'
hudText(padB('TYPE OR \u25b2\u25bc  \u00b7  A NEXT  \u00b7  B BACK  \u00b7  ENTER / MENU DONE')+'  \u00b7  '+left,cx,y+LH(80));
'@ @'
hudText(iniHint()+'  \u00b7  '+left,cx,y+LH(80));   // v30.xx (cw-glyphs2): the hint of the device last used
'@

SubRx @'
if(on&&oc){ try{ arcadeOverCount(c,o); }catch(_cu){} }   // v23.xx (his answer 20): the score counts up
'@ @'
if(on&&oc){ try{ arcadeOverCount(c,o); }catch(_cu){} }   // v23.xx (his answer 20): the score counts up
  if(on&&ini){ try{ var _iq=c.querySelector('.aoq'), _it=iniHint(); if(_iq&&_iq.textContent!==_it) _iq.textContent=_it; }catch(_qx){} }   // v30.xx (cw-glyphs2): the initials hint follows the last device used, in place (the card itself is rebuilt only when a letter changes)
'@

SubRx @'
say2(nm+' offers you '+it.name+'. Press T or '+padB('Y')+' to take it.'); try{ blip('pick'); }catch(_b){}
'@ @'
say2(nm+' offers you '+it.name+'. Press '+(padOn()?padB('Y'):'T')+' to take it.'); try{ blip('pick'); }catch(_b){}   // v30.xx (cw-glyphs2): the taker sees the one key of the device in use
'@

SubRx @'
s=hubGiftName(gi.from)+' offers you '+(it?it.name:gi.k)+'.  T or '+padB('Y')+' to take it.  '+Math.ceil(t)+'s'; }
'@ @'
s=hubGiftName(gi.from)+' offers you '+(it?it.name:gi.k)+'.  '+(padOn()?padB('Y'):'T')+' to take it.  '+Math.ceil(t)+'s'; }   // v30.xx (cw-glyphs2): one key, the device in use
'@

SubRx @'
var VER='30.74';
'@ @'
var VER='30.75';
'@

$pat = "(?m)^  now:'v30\.74:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.75: Party prompts now show keys or buttons by what you used last: press any key or button, yes or no, the initials hint and the trade offer. Check 30.75 fails on v30.74',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
