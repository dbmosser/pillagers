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

if ($s.Contains("  {v:'30.90',what:")) { throw "check 30.90 is in the fixture already" }

SubRx @'
  {v:'30.89',what:
'@ @'
  {v:'30.90',what:'the title key legend is five hints at most (crouch, backpack and map live in the F1 list) and the top-right buttons are 48px high (critic on screen 01, 3 of 5: nine hints, small buttons)',
   run:function(){
     var t=document.getElementById('title'), kb=t&&t.querySelector('.kbrow'), tr=document.getElementById('titleres'), n, bt, was, h;
     if(!t||!kb||!tr) return 'SKIP: no title here';
     was=t.classList.contains('on'); if(!was) t.classList.add('on');
     try{
       n=kb.querySelectorAll('b').length;
       if(n>5) return 'the title key legend has '+n+' hints, more than 5';
       if(!/\bf1\s+controls/i.test(kb.textContent||'')) return 'the title key legend lost F1 controls';
       bt=tr.querySelector('button'); if(!bt) return 'no top-right button';
       h=parseFloat(getComputedStyle(bt).minHeight);   // CSS px, before the page zoom
       return h<47.5?('the top-right buttons are '+Math.round(h)+'px high, not 48'):null;
     } finally { if(!was) t.classList.remove('on'); } }},
  {v:'30.89',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
