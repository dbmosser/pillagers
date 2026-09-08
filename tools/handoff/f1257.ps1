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

# v12.57 CHECK, inserted before the v12.56 entry. It needs two open points, so
# it skips honestly on a map that only ever builds one. The countdown is put on
# the first point and then the man is stood in the second, which is the exact
# shape of walking through a ring on the way somewhere. Three arms: the pointer
# must stay on the point he called; with nothing running it must still follow
# him, which is the behaviour this build must not break; and a deliberate call
# at the second point must move it, because that is a choice and not a walk.
SubRx @'
  {v:'12.56',what:'Q moves the tactical belt as well as the hand: after choosing a different grenade the highlight, the caption and the hidden selector all name the same one, and a man carrying only one kind is left exactly where he was (2026-09-06 in-raid audit, the half v12.41 left)',
'@ @'
  {v:'12.57',what:'walking into a second open extraction point does not move the pointer off the one he called: the countdown, the banner and the warning all stay with his own extraction, while with nothing running the pointer still follows him and a deliberate call at the second point still moves it (2026-09-06 in-raid audit)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy a raid';
     if(typeof tryExtractTick!=='function') return 'SKIP: this build has no extraction tick to drive';
     var bad=[];
     function stage(){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],mapIx:0,seed:4242});
       var g=__state(); if(!g||!g.player||!g.zones) return null;
       if(g.zones.length<2) return {none:'this map and seed builds fewer than two extraction points, so there is no second one to walk into'};
       var p=g.player, A=g.zones[0], B=g.zones[1], i;
       for(i=0;i<g.zones.length;i++){ var Z=g.zones[i];
         Z.open=true; Z.beaconT=null; Z.hold=null; Z.pullT=null; Z.boardT=0; Z.callT=0; }
       g.beaconT=null; g.shipHold=null; g.active=A;
       p.downed=false; p.iv=99; p.hp=100;
       return {g:g,p:p,A:A,B:B};
     }
     try{
       // THE FINDING: his own extraction is inbound at A, and he walks into B.
       var st=stage();
       if(!st) return 'SKIP: no live raid with extraction points';
       if(st.none) return 'SKIP: '+st.none;
       var g=st.g, p=st.p, A=st.A, B=st.B;
       A.beaconT=18; g.beaconT=18; g.active=A;
       p.x=B.x; p.y=B.y;                       // standing in the other one
       tryExtractTick(0.05);
       if(g.active===B)
         bad.push('walking into a second open extraction point moved the pointer onto it while his own was still eighteen seconds out: the banner, the prompt, the approach pings and the last-seconds warning all follow that pointer, so his own extraction lands somewhere else and leaves without him');
       else if(g.active!==A)
         bad.push('walking into a second open extraction point left the pointer on neither the point he called nor the one he is standing in');
       if(!(A.beaconT>0)) bad.push('the countdown he paid for stopped running once he stood somewhere else');
       // CONTROL ONE: with nothing running anywhere, the pointer must still
       // follow him, which is what this line is for and must not be broken.
       var s2=stage();
       if(s2&&!s2.none){
         var g2=s2.g, B2=s2.B;
         s2.p.x=B2.x; s2.p.y=B2.y;
         tryExtractTick(0.05);
         if(g2.active!==B2) bad.push('control: with nothing running anywhere the pointer no longer follows him into an open point, so this build has broken the line it was meant to guard');
       }
       // CONTROL TWO: and a deliberate CALL at the second point moves it, because
       // that is a choice he made rather than a place he walked through.
       var s3=stage();
       if(s3&&!s3.none){
         var g3=s3.g, A3=s3.A, B3=s3.B, k;
         A3.beaconT=18; g3.beaconT=18; g3.active=A3;
         s3.p.x=B3.x; s3.p.y=B3.y;
         for(k=0;k<80&&(B3.beaconT===null||B3.beaconT===undefined);k++) tryExtractTick(0.05,true);
         if(B3.beaconT===null||B3.beaconT===undefined) bad.push('control: holding the key in the second point never called it, so this arm cannot say whether a call moves the pointer');
         else if(g3.active!==B3) bad.push('control: he called the second point himself and the pointer stayed on the first, so a call he actually made is being ignored');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var gz=__state(); if(gz&&gz.player) gz.player.iv=0; }catch(_a){}
       try{ var g4=__state(); if(g4&&!g4.over) __endRaid('abandon'); }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.56',what:'Q moves the tactical belt as well as the hand: after choosing a different grenade the highlight, the caption and the hidden selector all name the same one, and a man carrying only one kind is left exactly where he was (2026-09-06 in-raid audit, the half v12.41 left)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
