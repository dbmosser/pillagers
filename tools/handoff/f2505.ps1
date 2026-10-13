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

if ($s.Contains("  {v:'25.05',what:")) { throw "check 25.05 is in the fixture already" }

SubRx @'
  {v:'25.04',what:
'@ @'
  {v:'25.05',what:'his mode design (2026-10-12): a raid from the Undercroft is a CAREER raid, the DEMO clock of 10 minutes, no ring closes early, G.career with its own score store, the same seeded raid; CAREER_ON 0 gives the old raid',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__runPrep&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     var bad=[], g, c0=(typeof CAREER_ON==='number')?CAREER_ON:0, i, n=0, e1=-1, k1=-1, rl0=-1;
     function nv(gg){ return gg.containers.filter(function(c){ return c&&!c.vault; }).length; }   // the vaults (a later build) add their own boxes
     try{
       __topClear(); __runPrep();
       CAREER_ON=0;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       if(g.career) bad.push('CAREER_ON 0 still built a CAREER raid');
       e1=g.ents.length; k1=nv(g); rl0=g.raidLen;
       __endRaid('abandon'); __topClear(); __runPrep();
       CAREER_ON=1;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return bad.concat(['SKIP: no second raid']).join('; ');
       if(g.career!==1) bad.push('a raid from the Undercroft is not a CAREER raid (career '+g.career+')');
       if(g.raidLen!==600||!(g.timeLeft>590)) bad.push('the CAREER clock is '+g.raidLen+' / '+g.timeLeft+', not 10 minutes (the old raid is '+rl0+')');
       for(i=0;i<(g.zones||[]).length;i++) if(g.zones[i].closeAt!==undefined) n++;
       if(n) bad.push(n+' rings still close early in a CAREER raid');
       if(!g.cs||g.cs.s!==0||g.cs.k!==0) bad.push('a CAREER raid has no score store');
       if(g.arcade) bad.push('a CAREER raid is a DEMO raid');
       if(g.ents.length!==e1||nv(g)!==k1) bad.push('the CAREER raid of seed 4242 differs: ents '+g.ents.length+' vs '+e1+', containers '+nv(g)+' vs '+k1);
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{ try{ CAREER_ON=c0; }catch(_r){} try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'25.04',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
