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

if ($s.Contains("  {v:'35.73',what:")) { throw "check 35.73 is in the fixture already" }

SubRx @'
  {v:'35.72',what:
'@ @'
  {v:'35.73',what:'his picture 2026-10-28 ("+2,386 xpthe seal on cold storage is broken..."): on the CAREER extracted card the xp line keeps its own line, so the line after it no longer runs into it',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__runPrep&&window.__endRaid&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile&&window.__P&&window.__applyLoaded)) return 'SKIP: this fixture cannot deploy';
     if(typeof ocLedger!=='function') return 'SKIP: no ledger here';
     var bad=[], g, c0=(typeof CAREER_ON==='number')?CAREER_ON:0, snap=null, man, t, i, L, xl=-1;
     try{
       snap=JSON.parse(JSON.stringify(__P()));
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       CAREER_ON=1;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       if(!g.career||!g.cs) return 'SKIP: no CAREER raid in this build';
       g.player.iv=99; g.player.hp=100; g.player.downed=false;
       g.bag=['scrap','board','optic'];
       g.cs.s=750; g.cs.k=4; g.cs.b={kill:600,style:150};
       G.strayPaid=120;
       __endRaid('extract');
       man=document.getElementById('oc_manifest'); t=(man&&man.innerText)||'';
       L=t.split('\n');
       for(i=0;i<L.length;i++) if(/\+[\d,]+ xp/i.test(L[i])){ xl=i; break; }
       if(xl<0) return 'SKIP: this card has no xp line ('+JSON.stringify(t.slice(-120))+')';
       if(!/^\s*\+[\d,]+ xp(\s+\S\s+\d+% penalty)?\s*$/i.test(L[xl])) bad.push('the xp line runs into the next line: '+JSON.stringify(L[xl].slice(0,100)));
       if(t.toLowerCase().indexOf('the survivor paid you')<0) bad.push('the line after the xp line is not on the card');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ G.strayPaid=0; }catch(_z){}
       try{ CAREER_ON=c0; }catch(_r){}
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       try{ if(snap&&window.__applyLoaded) __applyLoaded(snap); }catch(_s){}
       __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'35.72',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
