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

if ($s.Contains("  {v:'31.00',what:")) { throw "check 31.00 is in the fixture already" }

SubRx @'
  {v:'30.99',what:
'@ @'
  {v:'31.00',what:'the title name box shows the default name in lower case, and the saves block is no wider than the mode column (critic on screen 01: capitals on screen, 898px block under a 558px column)',
   run:function(){
     var t=document.getElementById('title'), sp=document.getElementById('slotpanel'), pin=document.getElementById('pnamein'), was, w;
     if(!t||!sp||!pin) return 'SKIP: no title here';
     if(typeof titleNameShown!=='function') return 'the name box has no lower case door (titleNameShown)';
     if(titleNameShown('PILLAGER')!=='pillager') return 'the default name shows as '+titleNameShown('PILLAGER');
     if(titleNameShown('Bob')!=='Bob') return 'a typed name was changed to '+titleNameShown('Bob');
     if(P.pname==='PILLAGER'&&/[A-Z]/.test(pin.value)) return 'the name box still shows '+pin.value;
     was=t.classList.contains('on'); if(!was) t.classList.add('on');
     try{
       w=parseFloat(getComputedStyle(sp).maxWidth);
       return (w>561||isNaN(w))?('the saves block may be '+w+'px wide, wider than the 560px mode column'):null;
     } finally { if(!was) t.classList.remove('on'); } }},
  {v:'30.99',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
