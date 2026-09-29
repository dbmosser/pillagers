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

if ($s.Contains("  {v:'17.26',what:")) { throw "check 17.26 is in the fixture already" }

SubRx @'
  {v:'17.25',what:
'@ @'
  {v:'17.26',what:'a player 2 controller pick that is not plugged in, while player 1 picked none, falls to the first free controller: with one controller plugged in the player 2 window plays it in front and takes it when player 1 hands it over, and player 1 no longer takes it; a pick that is plugged in, and one while player 1 picked a controller, keep the old rule',
   run:function(){
     if(typeof NET==='undefined'||!NET||typeof netPadFor!=='function'||typeof netPadTick!=='function'||typeof netPadRecv!=='function'||typeof netPadNow!=='function'||typeof NET.padIx!=='number') return 'SKIP: this build has no same machine controllers';
     if(NET.same||NET.on) return 'SKIP: a party is on in this copy, and the check stands in for the player 2 window';
     var bad=[], keep={}, ks=[], k, q, r, PAIR='zqxpadmiss1';
     var ch={posted:[],onmessage:null,postMessage:function(m){ this.posted.push(m); },close:function(){}};
     function pd(ix,b){ var bts=[], j; for(j=0;j<17;j++) bts.push({pressed:j===b,value:(j===b)?1:0,touched:j===b}); return {connected:true,id:'probe pad '+ix,index:ix,mapping:'standard',timestamp:1,axes:[0,0,0,0],buttons:bts}; }
     function handed(){ var o=[], j; for(j=0;j<ch.posted.length;j++) if(ch.posted[j]&&ch.posted[j].t==='pad') o.push(ch.posted[j].ix); return o; }
     function st(ix,own){ return {t:'pad',pair:PAIR,ix:ix,own:own,p:[1,0],v:[1,0],a:[0,0,0,0]}; }
     for(k in NET) keep[k]=NET[k];
     try{
       var one=[pd(0,3)], two=[pd(0,3),pd(1,2)];
       r=netPadFor('p2',1,-1,one);
       if(r!==0) bad.push('player 2 kept a pick of controller 2, which is not plugged in, and with one controller plugged in and no player 1 pick is on pad '+r+', not controller 1');
       r=netPadFor('host',-1,1,one);
       if(r!==-1) bad.push('player 1 with no pick takes the only controller (pad '+r+') from player 2 whose kept pick is not plugged in');
       if(netPadFor('p2',2,0,two)!==-1) bad.push('control: with player 1 on controller 1 by pick, a player 2 pick of controller 3 that is not plugged in is now handed a controller');
       if(netPadFor('p2',1,-1,two)!==1) bad.push('control: a player 2 pick that is plugged in is not kept');
       // The player 2 window in front, one controller plugged in, kept pick controller 2: it plays the one and hands player 1 nothing.
       NET.same='p2'; NET.pair=PAIR; NET.mode='coop'; NET.bc=ch; NET.padIx=1; NET.padOther=-1; NET.padFwd=null; NET.padTs={}; ch.posted=[];
       NET.padLiveAt=netPadNow(); r=netPadTick(one);
       if(r!==one[0]) bad.push('the player 2 window in front, its kept pick not plugged in, plays '+(r?('pad '+r.index):'no controller')+' and not the one controller plugged in');
       if(handed().length) bad.push('the player 2 window in front handed player 1 the one controller (pad '+handed()[0]+')');
       // Player 1 in front hands that controller over: the player 2 window takes it.
       r=netPadRecv(st(0,-1));
       if(r!=='pad') bad.push('the player 2 window, its kept pick not plugged in, refused the one controller player 1 handed over ('+r+')');
       // Control: a pick that is plugged in is played in front and still refuses a state from another controller.
       NET.padFwd=null; NET.padTs={}; NET.padLiveAt=netPadNow(); r=netPadTick(two);
       if(r!==two[1]) bad.push('control: the player 2 window in front with controller 2 picked and plugged in does not play it');
       r=netPadRecv(st(0,-1));
       if(r!=='padnot') bad.push('control: the player 2 window with controller 2 picked and plugged in kept a state from controller 1 ('+r+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ for(k in NET) if(!Object.prototype.hasOwnProperty.call(keep,k)) ks.push(k); for(q=0;q<ks.length;q++) delete NET[ks[q]]; for(k in keep) NET[k]=keep[k]; }catch(_n){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.25',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
