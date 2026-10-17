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

if ($s.Contains("  {v:'28.77',what:")) { throw "check 28.77 is in the fixture already" }

SubRx @'
  {v:'28.76',what:
'@ @'
  {v:'28.77',what:'the low alarm only sounds near you, at most once every 4 s, and says MACHINE ALERT (his note: an annoying low siren too often, meaning unknown)',
   run:function(){
     if(typeof alarmOk!=='function') return 'the alarm has no range, no cooldown and no words (no alarmOk)';
     var g=null, rs=say, said=[], a, b, c, d;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no raid';
       say=function(m){ said.push(String(m)); };
       ALARM_LAST=-99;
       a=alarmOk(g.player.x+2000,g.player.y);
       b=alarmOk(g.player.x+100,g.player.y);
       c=alarmOk(g.player.x+100,g.player.y);
       ALARM_LAST=-99; d=alarmOk(g.player.x+50,g.player.y);
       if(a) return 'an alarm 2000 away still sounds';
       if(!b) return 'an alarm 100 away does not sound';
       if(c) return 'a second alarm inside 4 s still sounds';
       if(!d) return 'the alarm does not sound again after its cooldown';
       if(said.indexOf('MACHINE ALERT')<0) return 'the alarm does not say MACHINE ALERT';
       return null;
     } finally {
       say=rs; ALARM_LAST=-99;
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'28.76',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
