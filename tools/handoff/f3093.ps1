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

if ($s.Contains("  {v:'30.93',what:")) { throw "check 30.93 is in the fixture already" }

SubRx @'
  {v:'30.92',what:
'@ @'
  {v:'30.93',what:'the left feed: a long detail sentence is not on the line, and an old line stays readable (dim 0.6 or more)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy';
     var g=null, ln, F;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:['gun_shotgun','gun_rifle'],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: staging: no raid';
       feedSay('FOG ZQ','info',{sub:'Limited visibility due to fog.'});
       F=g.fd; if(!F||!F.lines.length) return 'the feed took no line';
       ln=F.lines[F.lines.length-1];
       if((/visibility/i).test(ln.txt)) return 'the feed line carries a sentence: '+ln.txt;
       feedSay('STRONGHOLD ZQ','info',{sub:'1 on the map'});
       ln=F.lines[F.lines.length-1];
       if(!(/1 on the map/i).test(ln.txt)) return 'a short detail left the feed line: '+ln.txt;
       F.t+=FEED.hold+FEED.fade+1;
       if(feedAlpha(ln)<0.59) return 'an old feed line reads '+feedAlpha(ln)+', under 0.6';
       return null;
     } finally {
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'30.92',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
