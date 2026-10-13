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

if ($s.Contains("  {v:'25.53',what:")) { throw "check 25.53 is in the fixture already" }

SubRx @'
  {v:'25.52',what:
'@ @'
  {v:'25.53',what:'his mode design and answers (2026-10-12): a CAREER extraction doubles the score and pays 1 credit a point into his credits, the card reads CAREER SCORE, and the run goes on his CAREER board; a death pays nothing and leaves the board alone',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__runPrep&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     var bad=[], g, c0=(typeof CAREER_ON==='number')?CAREER_ON:0, cr0, b0=null, hb=false, bb0, m, cr1;
     try{
       __topClear(); __runPrep();
       b0=P.careerBoard; hb=('careerBoard' in P); bb0=P.careerBest; P.careerBoard=[];
       CAREER_ON=1;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       if(!g.career||!g.cs) return 'SKIP: no CAREER raid in this build';
       g.cs.s=700; g.cs.k=5; cr0=+P.credits||0;
       __endRaid('extract');
       if(g.careerPaid!==1400) bad.push('a CAREER extraction with 700 paid '+g.careerPaid+', not 700 x2 = 1400');
       if(!((+P.credits||0)-cr0>=1400)) bad.push('his credits rose '+((+P.credits||0)-cr0)+' on a 1400 payout');
       m=(document.getElementById('oc_manifest')||{}).textContent||'';
       if(m.indexOf('CAREER'+' SCORE')<0) bad.push('the EXTRACTED card does not read CAREER SCORE');
       if(m.indexOf('CAREER'+' BEST')<0) bad.push('the first banked run does not read CAREER BEST');
       if(!Array.isArray(P.careerBoard)||!P.careerBoard.length||P.careerBoard[0].s!==1400||P.careerBoard[0].k!==5) bad.push('the CAREER board does not hold the 1400 run ('+JSON.stringify(P.careerBoard)+')');
       __topClear(); __runPrep();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return bad.concat(['SKIP: no second raid']).join('; ');
       g.cs.s=700; cr1=+P.credits||0;
       __endRaid('dead');
       if(g.careerPaid!==0) bad.push('a CAREER death paid '+g.careerPaid);
       if((+P.credits||0)-cr1>=1400) bad.push('a CAREER death raised his credits by '+((+P.credits||0)-cr1));
       if(!Array.isArray(P.careerBoard)||P.careerBoard.length!==1) bad.push('a CAREER death changed the board ('+JSON.stringify(P.careerBoard)+')');
       m=(document.getElementById('oc_manifest')||{}).textContent||'';
       if(m.indexOf('SCORE'+' LOST')<0) bad.push('the KIA card does not read SCORE LOST');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ CAREER_ON=c0; }catch(_r){}
       try{ if(hb) P.careerBoard=b0; else delete P.careerBoard; if(bb0===undefined) delete P.careerBest; else P.careerBest=bb0; }catch(_b){}
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'25.52',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
