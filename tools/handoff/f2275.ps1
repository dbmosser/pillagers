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

if ($s.Contains("  {v:'22.75',what:")) { throw "check 22.75 is in the fixture already" }

SubRx @'
  {v:'22.74',what:
'@ @'
  {v:'22.75',what:'an offer is shown once and ends from the update: drawGiftLine with an offer that ran out says nothing, the lane tick after it says one feed row and ends the offer, the same for an offer nobody took, and an offer word to this seat says no offers you line',
   run:function(){
     if(typeof drawGiftLine!=='function'||typeof netGiftTake!=='function'||typeof msgTick!=='function'||typeof GIFT_T==='undefined') return 'SKIP: no raid trade here';
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     var bad=[], oSend=netSend, _say=say, said=[], g, p, keep={on:NET.on,role:NET.role,peers:NET.peers,roster:NET.roster,seat:NET.seat}, peer={state:'in',seat:1,dc:{readyState:'open',send:function(){}}}, r, n, i, OY=' offers '+'you', EX='EXPI'+'RED', DT='DID NOT '+'TAKE';
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       p=g.player; p.downed=false; keys={};
       NET.on=true; NET.role='host'; NET.seat=0; NET.peers=[peer]; NET.roster=[{seat:0,name:'HOST'},{seat:1,name:'ZQXKID'}];
       netSend=function(q,m){ return true; };
       say=function(m){ said.push(String(m)); try{ return _say.apply(this,arguments); }catch(_s){} };
       // ONE: an offer to this player that ran out, drawn.
       g.giftIn={id:'r30a',k:'bandage',from:1,t:(g.t||0)-GIFT_T-1}; g.giftOut=null; said.length=0;
       drawGiftLine();
       if(said.length) bad.push('drawing the offer line said '+said.length+' lines ('+said.join(' | ')+'); it should only draw');
       said.length=0; msgTick(0.016);
       n=0; for(i=0;i<said.length;i++) if(said[i].indexOf(EX)>=0&&said[i].indexOf('ZQXKID')>=0) n++;
       if(n!==1) bad.push('one lane tick after an offer ran out said '+n+' expiry rows naming the giver, not one ('+said.join(' | ')+')');
       if(g.giftIn) bad.push('the lane tick kept an offer that ran out');
       // TWO: his own offer nobody took.
       g.giftIn=null; g.giftOut={id:'r30b',k:'bandage',to:1,t:(g.t||0)-GIFT_T-6}; said.length=0;
       drawGiftLine();
       if(said.length) bad.push('drawing the giver line said '+said.length+' lines ('+said.join(' | ')+')');
       said.length=0; msgTick(0.016);
       n=0; for(i=0;i<said.length;i++) if(said[i].indexOf(DT)>=0) n++;
       if(n!==1) bad.push('one lane tick after an unanswered offer said '+n+' not taken rows, not one ('+said.join(' | ')+')');
       if(g.giftOut) bad.push('the lane tick kept an unanswered offer');
       // THREE: an offer word to this seat.
       g.giftIn=null; g.giftOut=null; said.length=0;
       r=netGiftTake(peer,{t:'gift',op:'offer',id:'r30c',k:'bandage',to:0});
       if(r!=='offer'||!g.giftIn) bad.push('SKIP: staging: the offer word was not taken as an offer ('+r+')');
       else { n=0; for(i=0;i<said.length;i++) if(said[i].indexOf(OY)>=0) n++; if(n) bad.push('an offer word said '+n+' offers you lines over the offer line ('+said.join(' | ')+')'); }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       netSend=oSend; say=_say; NET.on=keep.on; NET.role=keep.role; NET.peers=keep.peers; NET.roster=keep.roster; NET.seat=keep.seat; keys={};
       try{ var g2=__state(); if(g2){ g2.giftIn=null; g2.giftOut=null; g2.msgT=0; g2.msg=''; g2.feed=[]; g2.msgQ=[]; g2.msgQM=[]; g2.alert=null; g2.alertQ=[]; g2.pick=[]; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     for(i=0;i<bad.length;i++) if(bad[i].indexOf('SKIP: ')===0&&bad.length===1) return bad[0];
     return bad.length?bad.join('; '):null; }},
  {v:'22.74',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
