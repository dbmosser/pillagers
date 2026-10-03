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

if ($s.Contains("  {v:'18.20',what:")) { throw "check 18.20 is in the fixture already" }

SubRx @'
  {v:'18.19',what:
'@ @'
  {v:'18.20',what:'a waiting trade offer is taken first: with the backpack open and an offer waiting, T sends the yes and starts no offer of its own; with none waiting it still offers the selected item',
   run:function(){
     if(typeof netGiftKey!=='function'||typeof netGiftSend!=='function') return 'SKIP: no raid trade here';
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     var bad=[], keep={on:NET.on,role:NET.role,peers:NET.peers,up:NET.up,upSeed:NET.upSeed,roster:NET.roster,seat:NET.seat}, oSend=netSend, sent=[], g, p, peer={state:'in',seat:1,dc:{readyState:'open',send:function(){}}}, r;
     try{
       netSend=function(q,m){ sent.push(m); return true; };
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:['bandage'],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g.player; keys={};
       NET.on=true; NET.role='host'; NET.seat=0; NET.peers=[peer]; NET.roster=[{seat:0,name:'HOST'},{seat:1,name:'KID'}]; NET.upSeed=(g.seed>>>0);
       NET.up=[]; NET.up[1]={seat:1,x:p.x+60,y:p.y,f:0,tx:p.x+60,ty:p.y,tf:0,mv:0,roll:0,bob:0,age:0,n:3,lk:null,cr:0,sp:0,dn:0,w:'',sd:(g.seed>>>0),wep:null,pz:0,sa:1};
       if(g.bag.indexOf('bandage')<0) g.bag.push('bandage');
       g.bagOpen=true; g.bagSel=0; g.giftOut=null;
       g.giftIn={id:'w1',k:'frag',from:1,t:g.t};
       r=netGiftKey();
       if(!r) bad.push('T did nothing with an offer waiting and the backpack open');
       if(!sent.some(function(m){ return m&&m.t==='gift'&&m.op==='yes'&&m.id==='w1'; })) bad.push('the waiting offer was not taken');
       if(sent.some(function(m){ return m&&m.t==='gift'&&m.op==='offer'; })) bad.push('T started an offer of its own instead');
       sent.length=0; g.giftIn=null;
       r=netGiftKey();
       if(!sent.some(function(m){ return m&&m.t==='gift'&&m.op==='offer'; })) bad.push('control: with nothing waiting T no longer offers the selected item ('+r+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       netSend=oSend; NET.on=keep.on; NET.role=keep.role; NET.peers=keep.peers; NET.up=keep.up; NET.upSeed=keep.upSeed; NET.roster=keep.roster; NET.seat=keep.seat; keys={};
       try{ var g2=__state(); if(g2){ g2.giftIn=null; g2.giftOut=null; g2.bagOpen=false; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'18.19',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
