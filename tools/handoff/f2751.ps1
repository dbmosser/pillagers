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

if ($s.Contains("  {v:'27.51',what:")) { throw "check 27.51 is in the fixture already" }

SubRx @'
  {v:'27.50',what:
'@ @'
  {v:'27.51',what:'his order: the banners that came in at their own heights of the centre are alerts in the top centre lane: a notoriety rise and the drop-in count, and the notoriety is in the feed',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__frame||typeof notoStamp!=='function'||typeof arcadeDropHud!=='function'||typeof ARCADE==='undefined') return 'SKIP: no raid or arcade here';
     var bad=[], g, a, i, holdWas=ARCADE.holdT, hit=false, F, ln, ni=ARCADE.on;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       g.bagOpen=false; g.mapOpen=false; g.ents.length=0; keys={}; g.arcade=0; g.alert=null; g.alertQ=[];
       notoStamp('YOU STARTED THAT FIGHT');
       a=g.alert; if(!a||String(a.m).indexOf('NOTORIETY')!==0) bad.push('a notoriety rise is not an alert in the top lane');
       else if(a.sub!=='YOU STARTED THAT FIGHT') bad.push('the alert detail reads "'+a.sub+'", not why');
       F=g.fd; ln=null; if(F) for(i=0;i<F.lines.length;i++) if(F.lines[i].txt.indexOf('NOTORIETY')===0) ln=F.lines[i];
       if(!ln) bad.push('the notoriety rise is not a line in the feed');
       for(i=0;i<document.scripts.length&&!hit;i++) if(String(document.scripts[i].text).indexOf('v8.27: THE NOTO'+'RIETY STAMP')>=0) hit=true;
       if(hit) bad.push('the notoriety banner draw is still in the source');
       g.alert=null; g.alertQ=[];
       ARCADE.holdT=2.4; arcadeDropHud();
       a=g.alert; if(!a||a.m!=='DROPPING IN 3') bad.push('the drop-in count is not an alert (reads '+(a?a.m:'nothing')+')');
       ARCADE.holdT=1.2; arcadeDropHud();
       a=g.alert; if(!a||a.m!=='DROPPING IN 2') bad.push('the drop-in alert is not refreshed in place (reads '+(a?a.m:'nothing')+')');
       F=g.fd; if(F) for(i=0;i<F.lines.length;i++) if(F.lines[i].txt.indexOf('DROPPING IN')===0) bad.push('the drop-in count is written into the feed');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ ARCADE.holdT=holdWas; ARCADE.on=ni; }catch(_h){} try{ var g2=__state(); if(g2){ g2.alert=null; g2.alertQ=[]; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'27.50',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
