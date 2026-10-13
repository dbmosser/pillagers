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

if ($s.Contains("  {v:'25.13',what:")) { throw "check 25.13 is in the fixture already" }

SubRx @'
  {v:'25.12',what:
'@ @'
  {v:'25.13',what:'his mode design and rule (2026-10-12): a CAREER raid scores kills exactly as the DEMO does (points by kind, the streak), into its own store G.cs, never into the DEMO score, and the clock spot reads SCORE and the figure',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__runPrep&&window.__ents&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof mkCrawler!=='function'||typeof ARCADE!=='object') return 'SKIP: no crawler or arcade here';
     var bad=[], g, p, e, c0=(typeof CAREER_ON==='number')?CAREER_ON:0, m0=ARCADE.mine|0, rh=null, ownH=false, txt=[];
     try{
       __topClear(); __runPrep();
       CAREER_ON=1;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       if(!g.career||!g.cs) return 'SKIP: no CAREER raid in this build';
       p=g.player;
       e=mkCrawler(p.x+300,p.y); e.byPlayer=1; e.elite=0; e.hp=0; g.ents.push(e); __ents(0.016);
       if(g.ents.indexOf(e)>=0) bad.push('the crawler did not die');
       if(g.cs.s!==50||g.cs.k!==1) bad.push('a crawler kill in a CAREER raid scored '+g.cs.s+' with '+g.cs.k+' kills, not 50 and 1');
       e=mkCrawler(p.x+300,p.y); e.byPlayer=1; e.elite=0; e.hp=0; g.ents.push(e); __ents(0.016);
       if(g.cs.s!==150) bad.push('a second kill inside the streak gap took the score to '+g.cs.s+', not 50 + 50 x2 = 150');
       if((ARCADE.mine|0)!==m0) bad.push('a CAREER kill changed the DEMO score');
       if(typeof arcadeScoreHud==='function'&&typeof hudText==='function'){
         rh=hudText; hudText=function(s){ txt.push(String(s)); return rh.apply(this,arguments); }; ownH=true;
         try{ arcadeScoreHud(80,1); }catch(_h){ bad.push('the score line threw: '+(_h&&_h.message||_h)); }
         hudText=rh; ownH=false;
         if(txt.indexOf('SCORE')<0||!txt.some(function(s){ return s.indexOf('150')>=0; })) bad.push('the clock spot does not read SCORE and 150 in a CAREER raid ('+txt.join(' | ')+')');
       }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{ if(ownH) hudText=rh; try{ CAREER_ON=c0; }catch(_r){} try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'25.12',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
