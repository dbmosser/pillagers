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

if ($s.Contains("  {v:'29.56',what:")) { throw "check 29.56 is in the fixture already" }

SubRx @'
  {v:'29.55',what:
'@ @'
  {v:'29.56',what:'the pause card is 640 wide on a keyboard with an Esc hint, the scrim is 99 percent, and the leave buttons are danger red',
   run:function(){
     var pb=document.getElementById('pausebox'), bad=[], cs, mm, a, s, padWas, ids=['abandonbtn','arcendbtn','charselbtn'], i, b, w, h;
     if(!pb) return 'SKIP: no pause box here';
     padWas=document.body.classList.contains('padon'); document.body.classList.remove('padon');
     try{
       cs=getComputedStyle(pb).backgroundColor; mm=/[\/,]\s*([0-9.]+)\s*\)\s*$/.exec(cs); a=/^rgb\(/.test(cs)?1:(mm?parseFloat(mm[1]):(/^color\(/.test(cs)?1:0));
       if(!(a>=0.985)) bad.push('the pause scrim is '+cs+', the HUD still ghosts through');
       w=getComputedStyle(pb,'::before').width; if(!/\b640px/.test(w)) bad.push('the pause card is '+w+' wide, not 640px');
       h=getComputedStyle(pb,'::after').content; if(!/Esc/.test(h)) bad.push('no Esc hint under the buttons ('+h+')');
       for(i=0;i<ids.length;i++){ b=document.getElementById(ids[i]); if(!b) continue; s=getComputedStyle(b).color; if(s!=='rgb(229, 72, 47)') bad.push(ids[i]+' text is '+s+', not danger red'); }
       document.body.classList.add('padon');
       w=getComputedStyle(pb,'::before').width; if(/\b640px/.test(w)) bad.push('a pad card lost its legend width');
     } finally { document.body.classList.toggle('padon',padWas); }
     return bad.length?bad.join('; '):null; }},
  {v:'29.55',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
