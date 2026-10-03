$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
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

if ($s.Contains("  {v:'18.23',what:")) { throw "check 18.23 is in the fixture already" }

SubRx @'
  {v:'18.22',what:
'@ @'
  {v:'18.23',what:'a trade that fails says why: an offer to a downed player is answered with a no that names it, a no with that reason is said as such and closes the giver offer, an offer that ran out says so on the receiver side, and an unanswered offer says so on the giver side',
   run:function(){
     if(typeof netGiftTake!=='function'||typeof drawGiftLine!=='function') return 'SKIP: no raid trade here';
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     var bad=[], oSend=netSend, oSay=say, sent=[], said=[], g, p, keep={on:NET.on,role:NET.role,peers:NET.peers,roster:NET.roster,seat:NET.seat}, peer={state:'in',seat:1,dc:{readyState:'open',send:function(){}}}, r;
     try{
       netSend=function(q,m){ sent.push(m); return true; }; say=function(t){ said.push(String(t)); };
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g.player; keys={};
       NET.on=true; NET.role='host'; NET.seat=0; NET.peers=[peer]; NET.roster=[{seat:0,name:'HOST'},{seat:1,name:'KID'}];
       p.downed=true; r=netGiftTake(peer,{t:'gift',op:'offer',id:'d1',k:'bandage'});
       if(!sent.some(function(m){ return m&&m.op==='no'&&m.id==='d1'&&m.why==='down'; })) bad.push('an offer to a downed player was not refused with the reason ('+r+')');
       p.downed=false;
       g.giftOut={id:'d2',k:'bandage',to:1,t:g.t}; said.length=0;
       netGiftTake(peer,{t:'gift',op:'no',id:'d2',why:'down'});
       if(!said.some(function(s){ return /is down/.test(s); })) bad.push('a no for a downed taker was not said as such ('+said.join('|')+')');
       if(g.giftOut) bad.push('the giver offer stayed open after the no');
       g.giftIn={id:'d3',k:'bandage',from:1,t:g.t-GIFT_T-1}; said.length=0; drawGiftLine();
       if(g.giftIn) bad.push('an offer that ran out was kept'); if(!said.some(function(s){ return /ran out/.test(s); })) bad.push('an offer that ran out was not said ('+said.join('|')+')');
       g.giftOut={id:'d4',k:'bandage',to:1,t:g.t-GIFT_T-6}; said.length=0; drawGiftLine();
       if(g.giftOut) bad.push('an unanswered offer was kept'); if(!said.some(function(s){ return /did not take/.test(s); })) bad.push('an unanswered offer was not said ('+said.join('|')+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ netSend=oSend; say=oSay; NET.on=keep.on; NET.role=keep.role; NET.peers=keep.peers; NET.roster=keep.roster; NET.seat=keep.seat; keys={}; try{ var g2=__state(); if(g2){ g2.giftIn=null; g2.giftOut=null; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'18.22',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
