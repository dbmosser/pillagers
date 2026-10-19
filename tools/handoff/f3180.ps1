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

if ($s.Contains("  {v:'31.80',what:")) { throw "check 31.80 is in the fixture already" }

SubRx @'
  {v:'31.79',what:
'@ @'
  {v:'31.80',what:'the armed abandon confirm X sits inside the card and the money left behind is danger coloured (the critic on 59 and 60)',
   run:function(){
     var pb=document.getElementById('pausebox'), px=document.getElementById('pausex'), abtn=document.getElementById('abandonbtn'), cb=document.getElementById('confirmabandon'), bad=[], wasShown, d, r, host, b, cs;
     if(!pb||!px||!abtn||!cb) return 'the pause box has no abandon, confirm or X';
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       wasShown=cb.style.display;
       if(cb.style.display!=='none') abtn.click();
       pb.classList.remove('asking'); pb.classList.add('on');
       var t0=parseFloat(getComputedStyle(px).top);
       abtn.click();
       if(!pb.classList.contains('asking')) bad.push('the confirm did not arm');
       var t1=parseFloat(getComputedStyle(px).top);
       if(!(t1>t0+30)) bad.push('the armed X top is '+t1+' against '+t0+' unarmed: it still hangs off the tall frame');
       abtn.click(); cb.style.display=wasShown||'none';
       host=document.createElement('div'); host.className='ocloss'; host.innerHTML='<b>$1</b><span>x</span>'; document.getElementById('outcome').appendChild(host);
       b=host.querySelector('b'); var c=getComputedStyle(b).color;
       var dv=getComputedStyle(document.getElementById('root')||document.body).getPropertyValue('--danger').trim();
       host.remove();
       if(c==='rgb(240, 234, 220)'||/^rgb\(2[0-4]\d, 2[0-4]\d, 2[0-4]\d\)$/.test(c)) bad.push('the loss number is still cream '+c);
       return bad.length?bad.join('; '):null;
     } finally { try{ pb.classList.remove('on'); }catch(_e){} __topClear(); }
   }},
  {v:'31.79',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
