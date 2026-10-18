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

# Initials for each player, no rude ones (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
out.push({run:x.run.slice(0,40),i:(typeof x.i==='string')?x.i.slice(0,3).toUpperCase():'',
'@ @'
out.push({run:x.run.slice(0,40),i:(typeof x.i==='string')?x.i.slice(0,3).toUpperCase():'',i2:(typeof x.i2==='string')?x.i2.slice(0,3).toUpperCase():'',
'@

SubRx @'
o=m[x.run]={run:x.run,i:x.i||'',s:x.s,
'@ @'
o=m[x.run]={run:x.run,i:x.i||'',i2:x.i2||'',s:x.s,
'@

SubRx @'
    if(!o.i&&x.i) o.i=x.i;
'@ @'
    if(!o.i&&x.i) o.i=x.i;
    if(!o.i2&&x.i2) o.i2=x.i2;   // v28.xx (cw-iniplayer), his Q62: player 2 has initials of its own
'@

SubRx @'
var id=ARCADE.run.id, s=arcadeTeam(), r, i, ini='';
'@ @'
var id=ARCADE.run.id, s=arcadeTeam(), r, i, ini='', ini2='';
'@

SubRx @'
if(!ini&&r[i].i) ini=r[i].i;
'@ @'
if(!ini&&r[i].i) ini=r[i].i; if(!ini2&&r[i].i2) ini2=r[i].i2;
'@

SubRx @'
r.push({run:id,i:ini,s:s,
'@ @'
r.push({run:id,i:ini,i2:ini2,s:s,
'@

SubRx @'
if(r[i].run===id) return !r[i].i;
'@ @'
if(r[i].run===id) return !r[i].i||(r[i].m!==1&&!r[i].i2);
'@

SubRx @'
function arcadeBoardIni(id,ini){
'@ @'
function arcadeBoardIni(id,ini,who){
'@

SubRx @'
if(r[i].run===id){ r[i].i=ini; n++; }
'@ @'
if(r[i].run===id){ if(who===2) r[i].i2=ini; else r[i].i=ini; n++; }
'@

SubRx @'
ARCADE.ini={run:run,l:['A','A','A'],pos:0,at:Date.now(),touched:0,mirror:0};
'@ @'
ARCADE.ini={run:run,l:['A','A','A'],pos:0,at:Date.now(),touched:0,mirror:0,who:1};
'@

SubRx @'
return netSamePost({t:'arcinis',pair:NET.pair,run:n.run,l:n.l.join(''),pos:n.pos,on:1});
'@ @'
return netSamePost({t:'arcinis',pair:NET.pair,run:n.run,l:n.l.join(''),pos:n.pos,on:1,w:n.who|0});
'@

SubRx @'
ARCADE.ini={run:String(m.run||'').slice(0,40),l:l,pos:clamp(m.pos|0,0,2),at:Date.now(),touched:1,mirror:1};
'@ @'
ARCADE.ini={run:String(m.run||'').slice(0,40),l:l,pos:clamp(m.pos|0,0,2),at:Date.now(),touched:1,mirror:1,who:(m.w===2)?2:1};
'@

SubRx @'
  if(op==='done') return arcadeIniEnd();
'@ @'
  if(op==='done') return arcadeIniDone();
'@

SubRx @'
  if(n.pos>2) return arcadeIniEnd();
'@ @'
  if(n.pos>2) return arcadeIniDone();
'@

SubRx @'
// The card closes: the owner writes the initials (??? when never touched); a mirror just goes.
'@ @'
// v28.xx (cw-iniplayer), HIS ANSWERS Q62 and Q63 (2026-10-18): "One board entry per player" and "Block rude initials". A 2 player row takes
// two sets of initials, player 1 first and then player 2 (the card says whose turn it is; any pad or the keyboard drives it, as before), and
// the board shows both. A short list of rude three letter sets is refused on DONE (the letters reset and it says so) and becomes ??? when
// the card times out with one on it.
var ARCADE_INI_RUDE=['ASS','FAG','FCK','FUC','FUK','FUQ','DIK','DCK','CUM','CNT','TIT','SHT','SEX','KKK','NIG','JIZ','TWT','WTF','HOE','NAZ'];
function arcadeIniRude(s){ return ARCADE_INI_RUDE.indexOf(String(s||'').toUpperCase())>=0; }
function arcadeIniDone(){
  var n=ARCADE.ini, s;
  if(!n||n.mirror) return '';
  s=n.touched?n.l.join(''):'???';
  if(n.touched&&arcadeIniRude(s)){
    n.l=['A','A','A']; n.pos=0; n.touched=0; n.at=Date.now(); ARCADE.iniAy=1;
    try{ sndUi('deny'); }catch(_d){}
    try{ say('Pick other initials','warn'); }catch(_s){}
    arcadeIniPost();
    try{ arcadeOverSync(); }catch(_o){}
    return '';
  }
  return arcadeIniEnd();
}
// The card closes: the owner writes the initials (??? when never touched); a mirror just goes.
'@

SubRx @'
  var n=ARCADE.ini, s='';
  if(!n) return '';
  ARCADE.ini=null;
  if(!n.mirror){
    s=n.touched?n.l.join(''):'???';
    try{ arcadeBoardIni(n.run,s); }catch(_bi){}
'@ @'
  var n=ARCADE.ini, s='';
  if(!n) return '';
  if(!n.mirror){
    s=n.touched?n.l.join(''):'???';
    if(arcadeIniRude(s)) s='???';
    if(!ARCADE.solo&&(n.who|0)!==2){   // v28.xx (cw-iniplayer), his Q62: player 1 is in, player 2 enters its own initials next
      try{ arcadeBoardIni(n.run,s,1); }catch(_b1){}
      n.who=2; n.l=['A','A','A']; n.pos=0; n.touched=0; n.at=Date.now(); ARCADE.iniAy=1;
      arcadeIniPost();
      try{ arcadeOverSync(); }catch(_o1){}
      return s;
    }
  }
  ARCADE.ini=null;
  if(!n.mirror){
    try{ arcadeBoardIni(n.run,s,(n.who|0)===2?2:1); }catch(_bi){}
'@

SubRx @'
el.textContent='TOP 10 TONIGHT \u00b7 ENTER INITIALS';
'@ @'
el.textContent=ARCADE.solo?'TOP 10 TONIGHT \u00b7 ENTER INITIALS':('Player '+((n.who|0)===2?2:1)+' \u00b7 enter initials');   // v28.xx (cw-iniplayer), his Q62
'@

SubRx @'
(i+1)+'.  '+String(r.i||'???').slice(0,3).toUpperCase(),arcadeCr(r.s)
'@ @'
(i+1)+'.  '+String(r.i||'???').slice(0,3).toUpperCase()+((r.m!==1&&r.i2)?' \u00b7 '+String(r.i2).slice(0,3).toUpperCase():''),arcadeCr(r.s)
'@

SubRx @'
var VER='30.35';
'@ @'
var VER='30.36';
'@

$pat = "(?m)^  now:'v30\.35:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.36: Each player enters initials in a 2 player run, and rude initials are blocked. Check 30.36 fails on v30.35',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
