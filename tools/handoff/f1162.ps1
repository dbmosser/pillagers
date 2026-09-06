$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# v11.62 HOOK: whether a weather id counts as hard, so a check can force a
# multiplier into play.
SubRx @'
window.__loadProfile=function(){ return loadProfile(); };
'@ @'
window.__loadProfile=function(){ return loadProfile(); };
window.__wxHard=function(id){ try{ return wxHardId(id); }catch(e){ return null; } };
'@

# v11.62 CHECK, inserted before the v11.61 entry.
SubRx @'
  {v:'11.61',what:'a hired merc has a roster row, so when he boards an earlier ship and you extract, the card says he extracted earlier and pays your ten percent instead of saying he was left out there',
'@ @'
  {v:'11.62',what:'the XP printed on the outcome card is exactly the XP the profile banks for that run, with the weather (or night, or dose) multiplier in play',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P&&window.__wxHard)) return 'SKIP: this fixture cannot end a raid and read the card';
     __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
     var P=window.__P(), bad=[];
     __deploy({kit:[],safe:null,mapIx:0,seed:4242});
     var g=__state(), p=g.player;
     // A multiplier must be in play or the two figures agree by accident: force hard weather.
     var hard=null; if(window.__wxHard('storm')) hard='storm'; else if(window.__wxHard('fog')) hard='fog';
     if(!hard) return 'SKIP: no weather counts as hard, so there is no multiplier to disagree on';
     if(!g.wx) g.wx={}; g.wx.id=hard;
     // Something to bank: a bag worth carrying out.
     p.bag=['medkit','medkit','frag','frag']; g.over=false; p.downed=false;
     var n0=(P.log||[]).length;
     try{ __endRaid('extract'); }catch(e){ bad.push('endRaid threw: '+String(e&&e.message||e).slice(0,80)); }
     var txt=''; try{ txt=(document.getElementById('outcome')||{}).innerText||''; }catch(e2){}
     var m=/\+\s*([\d,]+)\s*XP/.exec(txt);
     var card=m?parseInt(m[1].replace(/,/g,''),10):null;
     var rec=(P.log&&P.log.length>n0)?P.log[P.log.length-1]:null;
     if(card===null) bad.push('the card printed no "+N XP" line (card says: '+txt.replace(/\s+/g,' ').slice(0,80)+')');
     if(!rec||typeof rec.xpGot!=='number') bad.push('the run was not banked with an xpGot figure');
     if(card!==null&&rec&&typeof rec.xpGot==='number'){
       // THE FIX: what the card says is what was banked.
       if(card!==rec.xpGot) bad.push('the card printed +'+card+' XP but the profile banked '+rec.xpGot+' (base '+rec.xpBase+', weather hard '+rec.wxHard+')');
       // CONTROL: the multiplier really was in play, or the agreement proves nothing.
       if(!rec.wxHard) bad.push('control: the banked record does not carry the hard-weather flag, so no multiplier was in play');
     }
     __topClear(); __cleanProfile();
     return bad.length?bad.join('; '):null; }},
  {v:'11.61',what:'a hired merc has a roster row, so when he boards an earlier ship and you extract, the card says he extracted earlier and pays your ten percent instead of saying he was left out there',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
