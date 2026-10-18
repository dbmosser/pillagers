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

if ($s.Contains("  {v:'30.65',what:")) { throw "check 30.65 is in the fixture already" }

SubRx @'
  {v:'30.64',what:
'@ @'
  {v:'30.65',what:'the title glass lets the world behind it show (centre scrim at most 0.65)',
   run:function(){
     var t=document.getElementById('title'); if(!t) return 'SKIP: no title here';
     var was=t.classList.contains('on'); if(!was) t.classList.add('on');
     try{
       var bi=getComputedStyle(t).backgroundImage, m=/linear-gradient\(([^]*)\)\s*$/.exec(bi), a=[], re=/rgba\(\s*17,\s*19,\s*21,\s*([0-9.]+)\)/g, x;
       if(!m) return 'no linear scrim on the title: '+bi.slice(0,80);
       while((x=re.exec(m[1]))) a.push(parseFloat(x[1]));
       if(a.length<4) return 'scrim stops not found: '+a.length;
       var mid=Math.max(a[1],a[2]);
       return mid>0.65?('the centre scrim is '+mid+', over 0.65, the world behind is flat'):null;
     } finally { if(!was) t.classList.remove('on'); } }},
  {v:'30.64',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
