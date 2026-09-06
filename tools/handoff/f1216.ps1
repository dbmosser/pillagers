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

# v12.16 CHECK, inserted before the v12.15 entry. A raid with some base XP
# is ended by death with two doses in the blood; the XP the card prints must
# equal the XP the profile was paid.
SubRx @'
  {v:'12.15',what:'the controls card no longer teaches an X (or pad Y) gun swap that has no handler; it names the belt keys instead (2026-09-06 first-ten-minutes audit)',
'@ @'
  {v:'12.16',what:'a death banks the XP its card printed, dose bonus included, instead of paying the run without the bonus after the drink is cleared (2026-09-06 first-ten-minutes audit)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot deploy';
     if(typeof buzzXpMul!=='function') return 'SKIP: no dose bonus in this build';
     var bad=[], P2=__P(), keepBuzz=(P2.buzz||[]).slice(), keepXp=P2.xp||0;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player;
       g.tel.containers=40; g.tel.kills={crawler:12,sentry:4};   // enough base XP for a 5 percent bonus to show
       P2.buzz=[{id:'liquor',tag:'drunk',t:200,dur:200},{id:'liquor',tag:'drunk',t:200,dur:200}];
       var mul=buzzXpMul();
       if(!(mul>1)) return 'SKIP: two doses did not raise the multiplier ('+mul+')';
       var xp0=P2.xp||0;
       p.downed=false; __endRaid('dead');
       var txt=''; try{ txt=((document.getElementById('outcome')||{}).innerText||'').replace(/\s+/g,' '); }catch(_t){}
       var m=/\+([\d,]+) XP/.exec(txt);
       if(!m) bad.push('control: the card printed no XP line ('+txt.slice(0,80)+')');
       else {
         var shown=parseInt(m[1].replace(/,/g,''),10), banked=(P2.xp||0)-xp0;
         if(!(shown>0)) bad.push('control: the card printed no XP gain');
         if(banked!==shown) bad.push('the card says +'+shown+' XP and the profile was paid '+banked);
         var rec=(P2.log||[]).slice(-1)[0];
         if(!(rec&&rec.doseMul>1)) bad.push('control: the banked record carries no dose multiplier, so nothing was multiplied');
         else if(shown!==Math.round(rec.xpBase*rec.doseMul)) bad.push('the card printed +'+shown+' against a base of '+rec.xpBase+' times '+rec.doseMul);
       }
       if((P2.buzz||[]).length) bad.push('control: the death did not clear the drink');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ P2.buzz=keepBuzz; P2.xp=keepXp; try{ saveProfile(); }catch(_s){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'12.15',what:'the controls card no longer teaches an X (or pad Y) gun swap that has no handler; it names the belt keys instead (2026-09-06 first-ten-minutes audit)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
