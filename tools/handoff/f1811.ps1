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

if ($s.Contains("  {v:'18.11',what:")) { throw "check 18.11 is in the fixture already" }

SubRx @'
  {v:'18.10',what:
'@ @'
  {v:'18.11',what:'stage B of the styling pass: the title wordmark is a gold gradient clipped to the letters, the three step cards are rounded glass cards, and the title backdrop is a vignette that still lets the Undercroft show through',
   run:function(){
     var t=document.getElementById('title'), wm=t&&t.querySelector('.wordmark'), cards=t?t.querySelectorAll('.tcard'):[], bad=[], s, was;
     if(!t) return 'SKIP: no title';
     if(!wm) return 'the title has no wordmark';
     was=t.classList.contains('on'); if(!was) t.classList.add('on');
     try{
       s=getComputedStyle(wm);
       if(!/gradient/.test(s.backgroundImage)) bad.push('the wordmark is flat');
       if(!/text/.test(String(s.webkitBackgroundClip||s.backgroundClip))) bad.push('the gradient is not clipped to the letters');
       if(cards.length!==3) bad.push('the title has '+cards.length+' step cards, not 3');
       else { s=getComputedStyle(cards[0]); if(parseFloat(s.borderTopLeftRadius)<8) bad.push('the step cards are square'); if(!/gradient/.test(s.backgroundImage)) bad.push('the step cards are flat'); }
       s=getComputedStyle(t);
       if(!/gradient/.test(s.backgroundImage)) bad.push('the title backdrop is a flat wash');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ if(!was) t.classList.remove('on'); }
     return bad.length?bad.join('; '):null; }},
  {v:'18.10',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
