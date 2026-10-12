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

if ($s.Contains("  {v:'23.78',what:")) { throw "check 23.78 is in the fixture already" }

SubRx @'
  {v:'23.77',what:
'@ @'
  {v:'23.78',what:'his #17: the gun stat card model reads every gun right (damage a pull, rate, magazine, range, handling) and calls an upgrade, a downgrade or a sidegrade',
   run:function(){
     if(typeof gunCompare!=='function'||typeof gunStats!=='function') return 'no gun stat model (gunStats, gunCompare)';
     var bad=[], c, s, k;
     s=gunStats(WEAPONS.shotgun);
     if(s.dmg!==WEAPONS.shotgun.dmg*WEAPONS.shotgun.pellets) bad.push('the Riot Scattergun reads '+s.dmg+' a pull, not every pellet ('+(WEAPONS.shotgun.dmg*WEAPONS.shotgun.pellets)+')');
     s=gunStats(WEAPONS.carbine);
     if(s.dmg!==WEAPONS.carbine.dmg*3) bad.push('the Burst Carbine reads '+s.dmg+' a pull, not the whole burst');
     s=gunStats(WEAPONS.rifle);
     if(s.rpm!==Math.round(60000/WEAPONS.rifle.rof)||s.mag!==WEAPONS.rifle.mag||s.rng!==Math.round(WEAPONS.rifle.rng/10)) bad.push('the Auto Rifle reads '+JSON.stringify(s));
     if(!(s.hand>0&&s.hand<=100)) bad.push('handling '+s.hand+' is outside 1 to 100');
     if(!(gunStats(WEAPONS.dmr).hand>gunStats(WEAPONS.shotgun).hand)) bad.push('the Marksman Rifle does not handle better than the Riot Scattergun');
     c=gunCompare(WEAPONS.lmg,WEAPONS.rifle); if(c.verdict!=='UPGRADE') bad.push('a Support MG over an Auto Rifle reads '+c.verdict);
     c=gunCompare(WEAPONS.pistol,WEAPONS.rifle); if(c.verdict!=='DOWNGRADE') bad.push('a Scav Pistol over an Auto Rifle reads '+c.verdict);
     if(!(c.d.dps<0)) bad.push('the Scav Pistol sustained damage delta against the Auto Rifle is '+c.d.dps+', not below 0');
     c=gunCompare(WEAPONS.rifle,WEAPONS.rifle); if(c.verdict!=='SIDEGRADE') bad.push('the same gun reads '+c.verdict);
     for(k in c.d) if(c.d[k]!==0) bad.push('the same gun has a '+k+' delta of '+c.d[k]);
     c=gunCompare(WEAPONS.pistol,WEAPONS.fists); if(c.verdict!=='UPGRADE'||c.h!==null) bad.push('a gun over bare hands reads '+c.verdict);
     c=gunCompare(WEAPONS.pistol,null); if(c.verdict!=='UPGRADE') bad.push('a gun over nothing reads '+c.verdict);
     c=gunCompare(WEAPONS.smg,WEAPONS.chatter);
     if(['UPGRADE','DOWNGRADE','SIDEGRADE'].indexOf(c.verdict)<0) bad.push('same-tier guns read '+c.verdict);
     return bad.length?bad.join('; '):null; }},
  {v:'23.77',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
