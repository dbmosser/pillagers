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

if ($s.Contains("  {v:'37.28',what:")) { throw "check 37.28 is in the fixture already" }

SubRx @'
  {v:'37.27',what:
'@ @'
  {v:'37.28',what:'a kill feed line shows what made the kill: a gun picture for a round, fire for a burn, and the party list carries it too',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy';
     var g=null, e=null, i, ln, gi=gunIcon, ids=[], hp0, nf=NET.feed, h, how;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:['gun_rifle'],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: staging: no raid';
       for(i=0;i<g.ents.length;i++) if(g.ents[i].kind==='sentry'){ e=g.ents[i]; break; }
       if(!e) return 'SKIP: no sentry on this map';
       hp0=e.hp; e.byPlayer=true; e.bySeat=0; e.blow='g'; e.blowG='rifle'; e.blowEl=''; e.hp=0;
       ln=feedKillEnt(e);
       e.hp=hp0;
       if(!ln) return 'the kill took no feed line';
       if(!ln.how||ln.how.g!=='rifle') return 'the kill line does not carry the rifle: '+JSON.stringify(ln.how||null);
       gunIcon=function(c,id){ if((/feedDraw/).test(String(new Error().stack))) ids.push(id); return gi.apply(this,arguments); };
       feedDraw(); feedDraw();
       gunIcon=gi;
       if(ids.indexOf('rifle')<0) return 'the feed drew no rifle picture (rows '+FEEDBOX.rows.length+', on '+FEEDBOX.on+', gunIcon calls from feedDraw: '+ids.join(',')+')';
       e.blow='g'; e.blowG='rifle'; e.blowEl=''; e.burnT=2; e.burnDps=5000; e.burnBy=0; e.hp=1; e.armor=0; e.shield=0;
       elemTick(0.1);
       if(e.hp>0) return 'the burn did not take the last health';
       how=feedHow(e);
       if(!how||how.el!=='fire') return 'a burn kill shows '+JSON.stringify(how)+', not fire';
       h=feedHowStr(how); how=feedHowOf(h);
       if(h!=='e:fire'||!how||how.el!=='fire') return 'the party word for fire reads '+h;
       how=feedHowOf(feedHowStr({g:'rifle'}));
       if(!how||how.g!=='rifle') return 'the party word for the rifle is lost';
       NET.feed=[]; netFeedPush(0,'SENTRY',{g:'rifle'});
       if(!NET.feed.length||!NET.feed[0].how||NET.feed[0].how.g!=='rifle') return 'the party list line has no rifle';
       return null;
     } finally {
       gunIcon=gi; NET.feed=nf;
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'37.27',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
