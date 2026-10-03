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

if ($s.Contains("  {v:'18.05',what:")) { throw "check 18.05 is in the fixture already" }

SubRx @'
  {v:'18.04',what:
'@ @'
  {v:'18.05',what:'trading in the Undercroft: with the pair linked the stash item menu offers an item to the other player, the offer goes over the pair as a hub gift, the other window takes it with T, the item leaves the giver stash only on the yes and lands in the taker stash on the hand-over',
   run:function(){
     if(typeof netHubOffer!=='function'||typeof netHubGiftTake!=='function'||typeof itemMenuRows!=='function') return 'there is no trading in the Undercroft';
     var bad=[], keep={on:NET.on,role:NET.role,peers:NET.peers,roster:NET.roster,hg:NET.hg,same:NET.same}, st0=P.stash.slice(), sent=[], oSend=netSend, peer={state:'in',seat:1,dc:{readyState:'open',send:function(){}}}, rows, row=null, off, r;
     try{
       netSend=function(q,m){ sent.push(m); return true; };
       NET.on=true; NET.role='host'; NET.same='host'; NET.peers=[peer]; NET.roster=[{seat:0,name:'HOST'},{seat:1,name:'KID'}]; NET.hg=null;
       P.stash=['bandage','bandage'];
       rows=itemMenuRows('bandage','stash',2);
       rows.forEach(function(x){ if(x&&x.label&&/Offer to KID/.test(x.label)) row=x; });
       if(!row) bad.push('the stash item menu has no Offer row ('+rows.map(function(x){ return x.label||''; }).join('|')+')');
       else row.act();
       off=sent.filter(function(m){ return m&&m.t==='gift'&&m.op==='offer'&&m.hub; })[0];
       if(!off) bad.push('no offer went over the pair ('+JSON.stringify(sent).slice(0,120)+')');
       if(P.stash.length!==2) bad.push('the item left the giver before the yes');
       r=netHubGiftTake(peer,{t:'gift',op:'offer',id:'q1',k:'frag',hub:1,from:1},1);
       if(r!=='offer'||!NET.hg||!NET.hg.in) bad.push('an arriving offer was answered '+r);
       if(!netHubGiftKey()) bad.push('T did not take the offer');
       if(!sent.some(function(m){ return m&&m.op==='yes'&&m.id==='q1'&&m.hub; })) bad.push('no yes went back');
       r=netHubGiftTake(peer,{t:'gift',op:'yes',id:off?off.id:'x',hub:1},1);
       if(r!=='gave') bad.push('the yes was answered '+r);
       if(P.stash.length!==1) bad.push('the stash holds '+P.stash.length+' after the hand-over');
       if(!sent.some(function(m){ return m&&m.op==='give'&&m.k==='bandage'&&m.hub; })) bad.push('no hand-over word went');
       r=netHubGiftTake(peer,{t:'gift',op:'give',id:'q1',k:'frag',hub:1},1);
       if(r!=='took') bad.push('the hand-over was answered '+r);
       if(P.stash.indexOf('frag')<0) bad.push('the taken item is not in the stash');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ netSend=oSend; NET.on=keep.on; NET.role=keep.role; NET.same=keep.same; NET.peers=keep.peers; NET.roster=keep.roster; NET.hg=keep.hg; P.stash=st0; try{ saveProfile(); }catch(_s){} try{ refreshInv(); }catch(_r){} }
     return bad.length?bad.join('; '):null; }},
  {v:'18.04',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
