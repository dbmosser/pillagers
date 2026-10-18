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

if ($s.Contains("  {v:'29.42',what:")) { throw "check 29.42 is in the fixture already" }

SubRx @'
  {v:'29.41',what:
'@ @'
  {v:'29.42',what:'the pause screen hides the HUD behind it (scrim 97 percent) and the Keys window has no explaining sentence above its list',
   run:function(){
     var pb=document.getElementById('pausebox'), host, m, s, cs, a, mm, bad=[];
     if(!pb) return 'SKIP: no pause box here';
     cs=getComputedStyle(pb).backgroundColor; mm=/[\/,]\s*([0-9.]+)\s*\)\s*$/.exec(cs); a=/^rgb\(/.test(cs)?1:(mm?parseFloat(mm[1]):(/^color\(/.test(cs)?1:0));
     if(!(a>=0.96)) bad.push('the pause scrim is '+cs+', the HUD shows through');
     host=pb.parentNode; m=document.createElement('div'); m.className='modal'; m.id='keysmodal'; m.innerHTML='<h3>Keys</h3><div class="msub">x</div>';
     host.appendChild(m);
     try{ s=getComputedStyle(m.querySelector('.msub')).display; if(s!=='none') bad.push('the Keys window still opens with a sentence ('+s+')'); }
     finally{ host.removeChild(m); }
     return bad.length?bad.join('; '):null; }},
  {v:'29.41',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
