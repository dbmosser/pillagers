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

if ($s.Contains("  {v:'34.68',what:")) { throw "check 34.68 is in the fixture already" }

SubRx @'
  {v:'34.67',what:
'@ @'
  {v:'34.68',what:'the lost pad title colours only its p1 or p2 tag, the words stay the title colour',
   run:function(){
     if(typeof padLostTitle!=='function') return 'no padLostTitle';
     var h=document.createElement('h3'), was=NET.same, tag, txt;
     try{
       NET.same='p2'; padLostTitle(h,true); tag=h.firstChild; txt=h.textContent;
       if(txt!=='p2 press a') return 'the title words changed: '+txt;
       if(!tag||tag.nodeType!==1||!/\bpl\b/.test(tag.className)||!/\bp2\b/.test(tag.className)) return 'the p2 tag is not its own coloured span';
       NET.same=''; padLostTitle(h,false); if(h.textContent!=='pad lost'||h.firstChild.nodeType!==3) return 'a window with no pair has a tag';
       return null;
     } finally { NET.same=was; }
   }},
  {v:'34.67',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
