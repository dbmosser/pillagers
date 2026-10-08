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

if ($s.Contains("  {v:'18.94',what:")) { throw "check 18.94 is in the fixture already" }

SubRx @'
  {v:'18.93',what:
'@ @'
  {v:'18.94',what:'the Blotter colours turn at the dose speed, not the clock: an hour into a session, a coming-on dose turns the hue a few degrees per step, not a hundred',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof drawBuzzFx!=='function'||typeof BUZZT==='undefined') return 'SKIP: no Blotter effects here';
     var bad=[], oB=P.buzz, oT=BUZZT, oDI=wc.drawImage, hs=[], a1, a2, dlt, i;
     function hueNow(){ hs=[]; wc.drawImage=function(){ var f=String(wc.filter||''); if(f.indexOf('hue-rotate(')===0&&f.indexOf('saturate(')>0) hs.push(parseFloat(f.slice(11))); return oDI.apply(this,arguments); }; try{ drawBuzzFx(); } finally { delete wc.drawImage; if(wc.drawImage!==oDI) wc.drawImage=oDI; } return hs.length?hs[0]:null; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       P.buzz=[{tag:'lsd',dur:180,t:150}];
       BUZZT=3600; if(typeof BUZZPH!=='undefined') BUZZPH.lt=null;
       hueNow(); BUZZT+=0.25; P.buzz[0].t-=0.25; a1=hueNow();
       BUZZT+=0.25; P.buzz[0].t-=0.25; a2=hueNow();
       if(a1===null||a2===null) return 'SKIP: the hue pass was not drawn';
       dlt=((a2-a1)%360+360)%360; if(dlt>180) dlt=360-dlt;
       if(dlt>12) bad.push('an hour in, a coming-on dose turns the hue '+Math.round(dlt)+' degrees in a quarter second');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ delete wc.drawImage; if(wc.drawImage!==oDI) wc.drawImage=oDI; P.buzz=oB; BUZZT=oT; try{ if(typeof BUZZPH!=='undefined') BUZZPH.lt=null; }catch(_p){} try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'18.93',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
