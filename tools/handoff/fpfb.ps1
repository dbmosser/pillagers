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

if ($s.Contains("  {v:'30.34',what:")) { throw "check 30.34 is in the fixture already" }

SubRx @'
  {v:'30.33',what:
'@ @'
  {v:'30.34',what:'the Riot Scattergun kicks the camera 6.5 a shot, up from 2.2 (under half a pixel), and the other guns keep their kick (his Q5: gun feel)',
   run:function(){
     if(typeof gunShake!=='function'||typeof GUN_SHAKE!=='object') return 'a gun has no kick of its own (no gunShake)';
     var g=null, w, r, a, b, c;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no raid';
       var kick=function(id){ var ww=WEAPONS[id]; G.shake=0; fireWeapon(g.player,ww,g.player.x+200,g.player.y,true); return G.shake; };
       a=kick('shotgun'); b=kick('smg'); c=kick('magnum');
       if(Math.abs(a-6.5)>0.01) return 'a Riot Scattergun shot kicks the camera '+a+', not 6.5';
       if(Math.abs(b-2.2)>0.01) return 'the Compact SMG kick moved to '+b+', it should stay 2.2';
       if(Math.abs(c-4.5)>0.01) return 'the Magnum kick moved to '+c+', it should stay 4.5';
       return null;
     } finally {
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'30.33',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
