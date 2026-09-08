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

# THE HARNESS PIN COMES FIRST. __pinDefaults pinned the two machine counts and
# not the per-house rate, and the per-house rate is what the crawler count is
# floored on, so moving the game default would have moved the world every check
# measures and turned the map fingerprint red for a reason that is his Settings
# table and not the build. Pinned explicitly at the old Standard figure, so the
# corpus keeps measuring the world it measured yesterday while a fresh profile
# opens on Few.
SubRx @'
nSentry:20,nCrawler:34,eDmg:1,raidSec:540}
'@ @'
nSentry:20,nCrawler:34,crawlerPerHouse:2.5,eDmg:1,raidSec:540}
'@

# v12.34 CHECK, inserted before the v12.28 entry.
SubRx @'
  {v:'12.28',what:'a Peddler purchase says where it went: a bought rifle names the belt key autoBelt pinned it to, a medkit with no key set says In your backpack, and a medkit on key 6 says key 6, with the credits falling by the prices (his note of 2026-09-07: purchases did not show up in the inventory)',
'@ @'
  {v:'12.34',what:'a fresh profile opens on Few machines and a Light extraction, the two Settings rows draw those words as their own default rather than in the changed colour, and the world the corpus measures is unmoved (his order of 2026-09-08)',
   run:function(){
     if(typeof GAMEOPTS==='undefined'||typeof DEF==='undefined'||typeof gameOptLive!=='function') return 'SKIP: this build has no Settings table to read';
     if(!window.__resetCfg||!window.__pinDefaults) return 'SKIP: this fixture cannot reset the dials';
     var bad=[], i, row, ix;
     function rowOf(k){ for(i=0;i<GAMEOPTS.length;i++) if(GAMEOPTS[i].k===k) return GAMEOPTS[i]; return null; }
     try{
       __topClear(); __cleanProfile();
       // A FRESH PROFILE IS WHAT DEF SAYS, so the dials are reset to it and read back.
       __resetCfg();
       if(CFG.nSentry!==12) bad.push('a fresh profile starts on '+CFG.nSentry+' sentries, not the 12 that Machines Few carries');
       if(CFG.nCrawler!==20) bad.push('a fresh profile starts on '+CFG.nCrawler+' crawlers, not the 20 that Machines Few carries');
       if(CFG.crawlerPerHouse!==1.5) bad.push('a fresh profile floors crawlers at '+CFG.crawlerPerHouse+' a house, not the 1.5 that Machines Few carries, so the row only moves half the machines');
       if(CFG.siegeVol!==0.6) bad.push('a fresh profile starts on a siege volume of '+CFG.siegeVol+', not the 0.6 that Heat Light carries');
       // THE ROW HAS TO AGREE: the live dials must land ON the option, and that
       // option must be the row's own default, or the button draws in the colour
       // that means he has changed something.
       row=rowOf('robots'); ix=gameOptLive('robots');
       if(!row) bad.push('there is no Machines row to read');
       else{
         if(ix<0||!row.opts[ix]) bad.push('with a fresh profile the Machines row matches no option at all and would read CUSTOM');
         else if(row.opts[ix].n!=='Few') bad.push('with a fresh profile the Machines row reads '+row.opts[ix].n+' and not Few');
         if(ix>=0&&ix!==row.def) bad.push('the Machines row is on '+(row.opts[ix]?row.opts[ix].n:ix)+' but calls option '+row.def+' its default, so the button draws in the changed colour on a profile nobody has touched');
       }
       row=rowOf('ext'); ix=gameOptLive('ext');
       if(!row) bad.push('there is no extraction heat row to read');
       else{
         if(ix<0||!row.opts[ix]) bad.push('with a fresh profile the extraction heat row matches no option at all and would read CUSTOM');
         else if(row.opts[ix].n!=='Light') bad.push('with a fresh profile the extraction heat row reads '+row.opts[ix].n+' and not Light');
         if(ix>=0&&ix!==row.def) bad.push('the extraction heat row is on '+(row.opts[ix]?row.opts[ix].n:ix)+' but calls option '+row.def+' its default');
       }
       // AND THE CORPUS STILL MEASURES THE OLD WORLD, which is what the harness
       // pin is for: this is the guard on the change I had to make to the harness.
       __pinDefaults(0);
       if(CFG.nSentry!==20||CFG.nCrawler!==34||CFG.crawlerPerHouse!==2.5) bad.push('control: after the harness pin the world is '+CFG.nSentry+'/'+CFG.nCrawler+'/'+CFG.crawlerPerHouse+' and not the 20/34/2.5 every fingerprint in this corpus was measured on');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ __resetCfg(); }catch(_c){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'12.28',what:'a Peddler purchase says where it went: a bought rifle names the belt key autoBelt pinned it to, a medkit with no key set says In your backpack, and a medkit on key 6 says key 6, with the credits falling by the prices (his note of 2026-09-07: purchases did not show up in the inventory)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
