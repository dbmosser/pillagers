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

if ($s.Contains("  {v:'33.95',what:")) { throw "check 33.95 is in the fixture already" }

SubRx @'
  {v:'33.94',what:
'@ @'
  {v:'33.95',what:'the what is new card is stamped with this build or later and still shows the three short lowercase real notes',
   run:function(){
     if(typeof WHATSNEW==='undefined'||typeof WHATSNEW_VER==='undefined'||typeof VER==='undefined'||typeof wnList!=='function') return 'SKIP: this build has no what is new card';
     if(parseFloat(WHATSNEW_VER)>33.95+0.001) return 'SKIP: the card has moved on, a later card check covers it';
     var bad=[], d=parseFloat(VER)-parseFloat(WHATSNEW_VER), lines=wnList(), i;
     if(!(parseFloat(WHATSNEW_VER)>=33.95-0.001)) bad.push('the card is stamped v'+WHATSNEW_VER+', before v33.95');
     if(!(d<=0.15+1e-9)) bad.push('the card is stamped v'+WHATSNEW_VER+', '+d.toFixed(2)+' behind v'+VER);
     if(lines.length!==3) bad.push('the card shows '+lines.length+' notes, not three');
     for(i=0;i<lines.length;i++){ if(String(lines[i])!==String(lines[i]).toLowerCase()||String(lines[i]).length>48) bad.push('note '+i+' is not short lowercase text'); }
     if(/\balpha\b|polish pass/i.test(WHATSNEW.join('|'))) bad.push('the news has filler copy');
     return bad.length?bad.join('; '):null; }},
  {v:'33.94',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
