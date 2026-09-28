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

if ($s.Contains("  {v:'16.90',what:")) { throw "check 16.90 is in the fixture already" }

SubRx @'
  {v:'16.89',what:
'@ @'
  {v:'16.90',what:'no line of the game, comments included, uses the old verb phrase for extraction: it is call for extraction everywhere',
   run:function(){
     var src='', i, ss, cut, needle=new RegExp('call'+'\\s+'+'extraction','i'), m;
     try{ ss=document.getElementsByTagName('script'); for(i=0;i<ss.length;i++) src+=ss[i].textContent||''; }catch(e){ return 'SKIP: the build cannot read its own script'; }
     cut=src.indexOf('window.__frame=function'); if(cut>0) src=src.slice(0,cut);
     m=needle.exec(src);
     return m?('the build still says '+src.slice(Math.max(0,m.index-40),m.index+30).replace(/\s+/g,' ')):null; }},
  {v:'16.89',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
