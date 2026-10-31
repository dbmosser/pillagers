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

if ($s.Contains("  {v:'36.78',what:")) { throw "check 36.78 is in the fixture already" }

SubRx @'
  {v:'36.77',what:
'@ @'
  {v:'36.78',what:'a danger said while you are down stands over the downed card, never on it',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&typeof __frame==='function')||typeof alertSay!=='function') return 'SKIP: no alert fixture';
     var PR=CanvasRenderingContext2D.prototype, of=PR.fillRect, g=null, p=null, tabs=[], z, bad=[], al;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||g.sim||!g.player) return 'SKIP: no live raid';
       p=g.player; g.ents=[]; g.bagOpen=false; g.mapOpen=false; g.paused=false;
       g.alert=null; g.alertQ=[]; g.alertSeen={};
       p.downed=true; p.downT=(CFG.downTime||30)*0.8; p.revived=false;
       __frame(); __frame();
       alertSay('TEST DANGER OVER CARD','warn',{key:'t-card'}); if(g.alert) g.alert.at=(g.t||0)-1;
       PR.fillRect=function(x,y,w,h){ var m=this.getTransform(); if(w===36&&h===3) tabs.push(m.f+y*m.d); return of.apply(this,arguments); };
       __frame(); __frame();
       PR.fillRect=of;
       z=(HUDZ.msg||1)*hudRes()*hudUserZ('msg'); al=ALERTL;
       if(!tabs.length) return 'the downed card tab was not drawn';
       if(!al||!al.a||al.a.m!=='TEST DANGER OVER CARD') return 'the danger plate was not laid out while down';
       if((al.y+al.h)*z>tabs[tabs.length-1]) bad.push('the danger plate ends at '+Math.round((al.y+al.h)*z)+', under the top of the downed card at '+Math.round(tabs[tabs.length-1]));
       return bad.length?bad.join('; '):null;
     } finally {
       PR.fillRect=of;
       try{ p.downed=false; }catch(_e0){}
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'36.77',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
