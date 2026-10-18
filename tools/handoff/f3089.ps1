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

if ($s.Contains("  {v:'30.89',what:")) { throw "check 30.89 is in the fixture already" }

SubRx @'
  {v:'30.88',what:
'@ @'
  {v:'30.89',what:'his Q43: the Settings window is a centred card that takes up nearly the whole screen (frame within 60 px of every screen edge) with its X in the card corner',
   run:function(){
     if(!(window.__station&&window.__hubEnter)) return 'SKIP: this fixture cannot walk the Undercroft';
     var bad=[], m, b, mr, br, z, cs, fw, fh, W=window.innerWidth, H=window.innerHeight, r;
     try{
       __topClear(); __hubEnter();
       r=__station('dev','KeyE'); if(r&&r.err) return 'station: '+r.err;
       m=document.getElementById('settingsmodal'); b=document.getElementById('closesettings');
       if(!m||!b||!m.classList.contains('on')) return 'the settings window did not open';
       UIM.step(600);
       mr=m.getBoundingClientRect(); br=b.getBoundingClientRect(); z=parseFloat(m.style.zoom)||1;
       cs=getComputedStyle(m,'::before');
       fw=parseFloat(cs.width)*z; fh=parseFloat(cs.height)*z;
       if(!(fw>=W-120)) bad.push('the card frame is '+Math.round(fw)+' px wide on a '+W+' px screen, want within 120');
       if(!(fh>=H-120)) bad.push('the card frame is '+Math.round(fh)+' px tall on a '+H+' px screen, want within 120');
       if(!(mr.right-br.right<=100*z)) bad.push('the X is '+Math.round(mr.right-br.right)+' px in from the right edge');
       if(!(br.top-mr.top<=100*z)) bad.push('the X is '+Math.round(br.top-mr.top)+' px down from the top');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'30.88',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
