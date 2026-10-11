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

# WEATHER IN CAPS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var WEATHER=[
  {id:'clear',name:'Clear',view:1,noise:1,lights:1,rain:0,
   line:'Still air. Nothing out here is covering you.'},
'@ @'
// v22.90 (tr7fixb), the review of raid text batch 7: HIS ORDER (2026-10-09), a raid line is a short caps callout of at most 34
// characters. The weather said sentences (Rain. It covers your noise, and theirs. and The weather is turning. Storm. Lightning lights
// up the map...). Each sky now carries cap, said at the drop (a clear sky still says nothing, his v6.68 note), turn, said when the
// sky starts turning to it, and sub, the short detail under either. The fog detail is his own v7.43 line, byte for byte.
var WEATHER=[
  {id:'clear',name:'Clear',view:1,noise:1,lights:1,rain:0,
   cap:null,turn:'SKIES CLEARING',sub:'Nothing is covering you'},
'@

SubRx @'
   line:'Partly cloudy. This will not hold.'},
'@ @'
   cap:'PARTLY CLOUDY',turn:'CLOUDS ROLLING IN',sub:'The weather will turn'},
'@

SubRx @'
   line:'Rain. It covers your noise, and theirs.'},
'@ @'
   cap:'RAIN',turn:'RAIN INCOMING',sub:'Covers your noise and theirs'},
'@

SubRx @'
   line:'Limited visibility due to fog.'},
'@ @'
   cap:'FOG',turn:'FOG ROLLING IN',sub:'Limited visibility due to fog.'},   // his v7.43 words, kept whole as the detail
'@

SubRx @'
   line:'Grid is down. Every lamp on the map is dead.'},
'@ @'
   cap:'BLACKOUT',turn:'GRID GOING DOWN',sub:'Every lamp on the map is dead'},
'@

SubRx @'
   line:'Storm. Lightning lights up the map, and every flash makes you visible from farther away.'}   // v16.03, his order: the flash shows you to them, farther, not across the whole map
'@ @'
   cap:'STORM',turn:'STORM INCOMING',sub:'Lightning shows you from farther off'}   // v16.03, his order: the flash shows you to them, farther, not across the whole map
'@

SubRx @'
var WXBLEND={id:'turning',name:'TURNING',view:1,noise:1,lights:1,rain:0,fog:0,line:null};
'@ @'
var WXBLEND={id:'turning',name:'TURNING',view:1,noise:1,lights:1,rain:0,fog:0,cap:null,turn:null,sub:null};   // v22.90 (tr7fixb): the callout fields
'@

SubRx @'
    say('The weather is turning. '+nw.line,'chat');   // v22.xx (R35): chat
'@ @'
    say(nw.turn||'WEATHER TURNING','chat',{sub:nw.sub||''});   // v22.xx (R35): chat; v22.90 (tr7fixb): the caps callout, the sky as the detail
'@

SubRx @'
if(G.wx.id!=='clear'&&G.wx.line) say(G.wx.line,'chat');   // v22.xx (R35): chat
'@ @'
if(G.wx.id!=='clear'&&G.wx.cap) say(G.wx.cap,'chat',{sub:G.wx.sub||''});   // v22.xx (R35): chat; v22.90 (tr7fixb): the caps callout, the sky as the detail
'@

SubRx @'
  if(G.wxNext&&(!_wo||_wo.id!==G.wxNext.id)&&!(G.wx&&G.wx.id===G.wxNext.id)&&G.player){ say('The weather is turning. '+G.wxNext.line,'chat'); sfxHere('charge',G.player.x,G.player.y); }
'@ @'
  if(G.wxNext&&(!_wo||_wo.id!==G.wxNext.id)&&!(G.wx&&G.wx.id===G.wxNext.id)&&G.player){ say(G.wxNext.turn||'WEATHER TURNING','chat',{sub:G.wxNext.sub||''}); sfxHere('charge',G.player.x,G.player.y); }   // v22.90 (tr7fixb): the caps callout on the linked window too
'@

SubRx @'
var VER='22.89';
'@ @'
var VER='22.90';
'@

$pat = "(?m)^  now:'v22\.89:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.90: The weather reads as a short caps callout, such as RAIN at the drop and STORM INCOMING when the sky turns. Check 22.90 fails on v22.89',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
