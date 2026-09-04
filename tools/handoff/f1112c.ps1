$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# MY BUG: the helper shared its loop index with the loop that called it, so
# after the first call the caller read cand[z] with z past the end and threw.
SubRx @'
       function openAt(x,y){ if(x<120||y<120) return false;
         for(z=0;z<WW.length;z++){ var w=WW[z]; if(x>w.x-34&&x<w.x+w.w+34&&y>w.y-34&&y<w.y+w.h+34) return false; }
         for(z=0;z<B.length;z++){ var b=B[z]; if(x>b.x-34&&x<b.x+b.w+34&&y>b.y-34&&y<b.y+b.h+34) return false; }
         return true; }
'@ @'
       function openAt(x,y){ if(x<120||y<120) return false; var u;
         for(u=0;u<WW.length;u++){ var w=WW[u]; if(x>w.x-34&&x<w.x+w.w+34&&y>w.y-34&&y<w.y+w.h+34) return false; }
         for(u=0;u<B.length;u++){ var b=B[u]; if(x>b.x-34&&x<b.x+b.w+34&&y>b.y-34&&y<b.y+b.h+34) return false; }
         return true; }
'@

SubRx @'
       function open3(x,y){ if(x<120||y<120) return false;
         for(k=0;k<W3.length;k++){ var w3=W3[k]; if(x>w3.x-34&&x<w3.x+w3.w+34&&y>w3.y-34&&y<w3.y+w3.h+34) return false; }
         for(k=0;k<B3.length;k++){ var bb=B3[k]; if(x>bb.x-34&&x<bb.x+bb.w+34&&y>bb.y-34&&y<bb.y+bb.h+34) return false; }
         return true; }
'@ @'
       function open3(x,y){ if(x<120||y<120) return false; var u;
         for(u=0;u<W3.length;u++){ var w3=W3[u]; if(x>w3.x-34&&x<w3.x+w3.w+34&&y>w3.y-34&&y<w3.y+w3.h+34) return false; }
         for(u=0;u<B3.length;u++){ var bb=B3[u]; if(x>bb.x-34&&x<bb.x+bb.w+34&&y>bb.y-34&&y<bb.y+bb.h+34) return false; }
         return true; }
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
