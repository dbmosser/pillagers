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

if ($s.Contains("  {v:'16.32',what:")) { throw "check 16.32 is in the fixture already" }

SubRx @'
  {v:'16.31',what:
'@ @'
  {v:'16.32',what:'player 2 search bar counts the items left: a box made from the host word keeps the count, and a loot word lowers it',
   run:function(){
     if(typeof netContMake!=='function') return 'SKIP: no net containers in this build';
     var ct=netContMake(99001,{ty:'crate',x:10,y:10,tm:1,n:3});
     if(!ct) return 'netContMake refused a plain crate word';
     if(ct.netLeft!==3) return 'a box made from a host word with n 3 holds count '+ct.netLeft+', not 3';
     var src='', i;
     try{ var ss=document.getElementsByTagName('script'); for(i=0;i<ss.length;i++) src+=ss[i].textContent||''; }catch(e){ return 'SKIP: the build cannot read its own script'; }
     var cut=src.indexOf('window.__frame=function'); if(cut>0) src=src.slice(0,cut);
     if(src.indexOf("ct.netLeft=Math.max(0,ct.netLeft-items.length)")<0) return 'a loot word does not lower the count';
     if(src.indexOf("(_sc.net&&typeof _sc.netLeft==='number')?_sc.netLeft")<0) return 'the search bar does not read the count on a linked window';
     return null; }},
  {v:'16.31',what:
'@


$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
