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

if ($s.Contains("  {v:'16.63',what:")) { throw "check 16.63 is in the fixture already" }

SubRx @'
  {v:'16.62',what:
'@ @'
  {v:'16.63',what:'a spectating host takes no damage of any kind, blasts included, while a player in the raid still does',
   run:function(){
     if(typeof damagePlayer!=='function'||!window.__deploy||!window.__endRaid) return 'SKIP: this build has no player damage to test';
     var bad=[], p=null, hp0, oG=null;
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       p=G.player; oG=voxGrunt; voxGrunt=function(){};
       p.iv=0; p.specOut=1; hp0=p.hp; p.hurtAt=-1;
       damagePlayer(20,'blast','Frag Charge',p.x+5,p.y);
       if(p.hp!==hp0||p.hurtAt!==-1) bad.push('a blast hurt a spectating host (hp '+hp0+' to '+p.hp+')');
       p.specOut=0; p.iv=0; hp0=p.hp;
       damagePlayer(20,'blast','Frag Charge',p.x+5,p.y);
       if(!(p.hurtAt!==-1)) return 'SKIP: staging: a blast did not reach a player in the raid either, so this cannot measure a pass';
     } finally { try{ if(oG) voxGrunt=oG; if(p){ p.specOut=0; } __endRaid('abandon'); __topClear(); }catch(e){} }
     return bad.length?bad.join('; '):null; }},
  {v:'16.62',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
