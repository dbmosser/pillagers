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

if ($s.Contains("  {v:'28.70',what:")) { throw "check 28.70 is in the fixture already" }

SubRx @'
  {v:'28.69',what:
'@ @'
  {v:'28.70',what:'his order 2026-10-15 (frame cap): the Frame cap setting also offers 75, 90, 120, 144, 165 and 240 after Off, 60 and 30 (saved choices keep their meaning), and the cap passes about the right share of a fast clock',
   run:function(){
     if(typeof GAMEOPTS==='undefined'||typeof frameCapSkip!=='function'||typeof CAP_LAST==='undefined') return 'SKIP: no settings rows or frame cap here';
     var bad=[], row=null, i, want=[75,90,120,144,165,240], got=[], c0=CFG.fpsCap, l0=CAP_LAST, n, ts;
     for(i=0;i<GAMEOPTS.length;i++) if(GAMEOPTS[i].k==='fpsCap') row=GAMEOPTS[i];
     if(!row) return 'SKIP: no Frame cap row';
     try{
       for(i=0;i<row.opts.length;i++) got.push(row.opts[i].cfg.fpsCap);
       if(got[0]!==0||got[1]!==60||got[2]!==30) bad.push('the first three Frame cap options moved ('+got.slice(0,3).join(',')+')');
       for(i=0;i<want.length;i++) if(got.indexOf(want[i])<0) bad.push('no Frame cap option for '+want[i]+' (the row has '+got.join(',')+')');
       CFG.fpsCap=120; CAP_LAST=0; n=0;
       for(i=0,ts=10000;i<240;i++,ts+=1000/240) if(!frameCapSkip(ts)) n++;
       if(n<100||n>130) bad.push('a 120 cap drew '+n+' of the 240 frames of a 240 Hz clock, not about 120');
       CFG.fpsCap=240; CAP_LAST=0; n=0;
       for(i=0,ts=10000;i<240;i++,ts+=1000/240) if(!frameCapSkip(ts)) n++;
       if(n<230) bad.push('a 240 cap skipped frames of a 240 Hz clock ('+n+' of 240 drawn)');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{ CFG.fpsCap=c0; CAP_LAST=l0; }
     return bad.length?bad.join('; '):null; }},
  {v:'28.69',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
