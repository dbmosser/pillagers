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

if ($s.Contains("  {v:'22.87',what:")) { throw "check 22.87 is in the fixture already" }

SubRx @'
  {v:'22.86',what:
'@ @'
  {v:'22.87',what:'a line said with the map open draws over it: with the sector map open, an info line and an alert are drawn after the SECTOR MAP header, over the map, not under its backing; with the map shut they are still drawn',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__textTrace)) return 'SKIP: this fixture cannot deploy or trace';
     if(typeof drawMapOverlay!=='function'||typeof drawHUD!=='function') return 'SKIP: no sector map here';
     var bad=[], g, tr, i, ih=-1, il=-1, ia=-1, NL='ZQ MAP '+'LINE', NA='ZQ MAP '+'ALERT', HD='SECTOR '+'MAP';
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       g.msgT=0; g.msg=''; g.feed=[]; g.msgQ=[]; g.msgQM=[]; g.alert=null; g.alertQ=[]; g.loc=null;
       g.mapOpen=true; g.bagOpen=false;
       say(NL); say(NA,'warn');
       g.alert&&(g.alert.at=(g.t||0)-1);
       tr=__textTrace(function(){ drawHUD(); });
       for(i=0;i<tr.length;i++){
         if(ih<0&&tr[i].t===HD) ih=i;
         if(String(tr[i].t).indexOf(NL)>=0) il=i;
         if(String(tr[i].t).indexOf(NA)>=0) ia=i;
       }
       if(ih<0) return 'SKIP: staging: the open map drew no '+HD+' header';
       if(il<0) bad.push('with the map open the info line was not drawn at all');
       else if(il<ih) bad.push('with the map open the info line was drawn before the map (under its backing), at '+il+' against the header at '+ih);
       if(ia<0) bad.push('with the map open the alert was not drawn at all');
       else if(ia<ih) bad.push('with the map open the alert was drawn before the map (under its backing), at '+ia+' against the header at '+ih);
       // CONTROL: the map shut, the band is still drawn.
       g.mapOpen=false; il=-1;
       tr=__textTrace(function(){ drawHUD(); });
       for(i=0;i<tr.length;i++) if(String(tr[i].t).indexOf(NL)>=0) il=i;
       if(il<0) bad.push('control: with the map shut the info line was not drawn');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       try{ var g2=__state(); if(g2){ g2.mapOpen=false; g2.msgT=0; g2.msg=''; g2.feed=[]; g2.msgQ=[]; g2.msgQM=[]; g2.alert=null; g2.alertQ=[]; g2.pick=[]; } if(g2&&!g2.over){ g2.player.downed=false; g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.86',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
