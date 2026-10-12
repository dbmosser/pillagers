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

if ($s.Contains("  {v:'24.03',what:")) { throw "check 24.03 is in the fixture already" }

SubRx @'
  {v:'24.02',what:
'@ @'
  {v:'24.03',what:'forge2: the Forge model: a MK II Auto Rifle has 29.9 damage, 32 rounds and a 1640 reload, WEAPONS is untouched, forging twice never compounds, and a MK III rifle is no downgrade against a plain Support MG',
   run:function(){
     if(typeof forgeApply!=='function'||typeof gunTierOf!=='function'||typeof ELEM!=='object') return 'no forge model (forgeApply, gunTierOf, ELEM)';
     var bad=[], a, b, c, l, q, v, k;
     try{
       a=forgeApply(WEAPONS.rifle,1);
       if(a.dmg!==29.9) bad.push('MK II rifle damage '+a.dmg+', want 29.9');
       if(a.mag!==32) bad.push('MK II rifle magazine '+a.mag+', want 32');
       if(a.reload!==1640) bad.push('MK II rifle reload '+a.reload+', want 1640');
       if(a.name!=='Auto Rifle MK II') bad.push('MK II rifle name '+a.name);
       if(a.fk!==1||a.el) bad.push('MK II rifle fk '+a.fk+' el '+a.el);
       if(WEAPONS.rifle.dmg!==23||WEAPONS.rifle.mag!==25||WEAPONS.rifle.reload!==2050||WEAPONS.rifle.name!=='Auto Rifle'||WEAPONS.rifle.fk) bad.push('WEAPONS.rifle was changed');
       if(a.rof!==WEAPONS.rifle.rof||a.spread!==WEAPONS.rifle.spread||a.rng!==WEAPONS.rifle.rng||a.noise!==WEAPONS.rifle.noise) bad.push('the forge changed fire rate, spread, range or noise');
       b=forgeApply(WEAPONS.rifle,2,'cryo');
       if(b.el!=='cryo'||b.tint!==ELEM.cryo.c||b.fk!==2||b.name!=='Auto Rifle MK III') bad.push('MK III cryo rifle reads '+b.fk+' '+b.el+' '+b.tint+' '+b.name);
       c=forgeApply(a,1);
       if(c.dmg!==29.9||c.mag!==32||c.reload!==1640||c.name!=='Auto Rifle MK II') bad.push('forging a MK II again compounds: '+c.dmg+' '+c.mag+' '+c.reload+' '+c.name);
       c=forgeApply(a,2,'fire');
       if(c.dmg!==29.9||c.mag!==32||c.name!=='Auto Rifle MK III'||c.el!=='fire') bad.push('MK II to MK III compounds: '+c.dmg+' '+c.mag+' '+c.name);
       if(forgeApply(WEAPONS.rifle,2,'bogus').el) bad.push('a bogus element was kept');
       l=forgeApply(WEAPONS.lance,1);
       if(l.mag!==4) bad.push('MK II Lance magazine '+l.mag+', want 4');
       if(gunTierOf(a)!==4) bad.push('MK II rifle ranks '+gunTierOf(a)+', want 4');
       if(gunTierOf(WEAPONS.rifle)!==3) bad.push('a plain rifle ranks '+gunTierOf(WEAPONS.rifle));
       v=gunCompare(b,WEAPONS.lmg).verdict;
       if(v==='DOWNGRADE') bad.push('a MK III rifle reads DOWNGRADE against a plain Support MG');
       if(gunStats(b).tier!==5) bad.push('the stat card tier of a MK III rifle is '+gunStats(b).tier);
       q={}; for(k in WEAPONS.rifle) q[k]=WEAPONS.rifle[k]; q.dmg=25.3; q.name='Pristine Auto Rifle'; q.q='pristine'; q.qRank=3;
       c=forgeApply(q,1);
       if(c.dmg!==32.9||c.q!=='pristine'||c.name!=='Pristine Auto Rifle MK II') bad.push('a rolled quality is not kept through a forge: '+c.dmg+' '+c.q+' '+c.name);
       if(forgeApply(WEAPONS.fists,1)!==WEAPONS.fists) bad.push('bare hands were forged');
     }catch(ex){ bad.push('threw: '+(ex&&ex.message||ex)); }
     return bad.length?bad.join('; '):null; }},
  {v:'24.02',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
