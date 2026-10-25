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

if ($s.Contains("  {v:'34.64',what:")) { throw "check 34.64 is in the fixture already" }

SubRx @'
  {v:'34.63',what:
'@ @'
  {v:'34.64',what:'the party window content shares one left edge and starts in the top half of the card: the title and the first line start at the same left, the title is in the top third',
   run:function(){
     if(typeof openParty!=='function') return 'SKIP: no party window';
     var pm, h, s, a, b, c;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       openParty();
       pm=document.getElementById('partymodal'); h=pm.querySelector('h3'); s=pm.querySelector('.msub');
       if(!h||!s) return 'SKIP: no party title or line';
       a=h.getBoundingClientRect(); b=s.getBoundingClientRect(); c=pm.getBoundingClientRect();
       if(Math.abs(a.left-b.left)>3) return 'the party title starts at '+Math.round(a.left)+' and its first line at '+Math.round(b.left)+', not one left edge';
       if(a.top>c.top+c.height/3) return 'the party title sits at '+Math.round(a.top-c.top)+' px down a '+Math.round(c.height)+' px card, not in the top third';
       return null;
     } finally {
       try{ __topClear(); }catch(_e){}
     } }},
  {v:'34.63',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
