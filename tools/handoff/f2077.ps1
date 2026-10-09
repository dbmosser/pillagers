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

if ($s.Contains("  {v:'20.77',what:")) { throw "check 20.77 is in the fixture already" }

SubRx @'
  {v:'20.76',what:
'@ @'
  {v:'20.77',what:'a stick held in a menu steps once a fifth of a second of real time, at 240 frames a second and at 30 alike',
   run:function(){
     if(typeof padMenu!=='function'||typeof PAD!=='object'||!PAD||typeof netPadNow!=='function'||typeof padStep!=='function'||typeof padOpenModal!=='function'||typeof padFocusables!=='function') return 'SKIP: no pad menu here';
     var bad=[], oOM=padOpenModal, oFo=padFocusables, oSt=padStep, oNow=netPadNow, PK={}, PV={}, k, md=document.createElement('div'), b1=document.createElement('button'), steps=0, T=0, n240=-1, n30=-1;
     md.appendChild(b1);
     function nf(){ return false; }
     function hold(hz,n,base){ var s0=steps, j; PAD.mrep=0; for(j=0;j<n;j++){ T=base+j/hz; padMenu(nf); } return steps-s0; }
     for(k in PAD) PK[k]=PAD[k];
     if(PAD.prev) for(k in PAD.prev) PV[k]=PAD.prev[k];
     try{
       padOpenModal=function(){ return md; };
       padFocusables=function(){ return [b1]; };
       padStep=function(){ steps++; return null; };
       netPadNow=function(){ return T; };
       PAD.ax=[1,0,0,0]; PAD.focus=b1; PAD.focusMd=md; PAD.focusIx=0; delete PAD.mrepAt;
       n240=hold(240,101,1000);
       n30=hold(30,14,2000);
       if(n240!==3) bad.push('at 240 frames a second a 0.42 s hold on the stick stepped '+n240+' times, not 3');
       if(n30!==3) bad.push('at 30 frames a second a 0.43 s hold on the stick stepped '+n30+' times, not 3');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       padOpenModal=oOM; padFocusables=oFo; padStep=oSt; netPadNow=oNow;
       for(k in PAD) if(!(k in PK)) delete PAD[k];
       for(k in PK) PAD[k]=PK[k];
       if(PAD.prev){ for(k in PAD.prev) if(!(k in PV)) delete PAD.prev[k]; for(k in PV) PAD.prev[k]=PV[k]; }
     }
     return bad.length?bad.join('; '):null; }},
  {v:'20.76',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
