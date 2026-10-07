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

if ($s.Contains("  {v:'18.57',what:")) { throw "check 18.57 is in the fixture already" }

SubRx @'
  {v:'18.56',what:
'@ @'
  {v:'18.57',what:'the what is new card is stamped within 0.15 of the build and shows its newest news: the two player fixes, the new icons and dropping all sit in the lines the card draws',
   run:function(){
     if(typeof WHATSNEW==='undefined'||typeof WHATSNEW_VER==='undefined'||typeof VER==='undefined'||typeof WN_SHOW==='undefined') return 'SKIP: this build has no what is new card';
     var bad=[], d=parseFloat(VER)-parseFloat(WHATSNEW_VER), shown=WHATSNEW.slice(0,WN_SHOW).join(' | ');
     if(!(d<=0.15+1e-9)) bad.push('the card is stamped v'+WHATSNEW_VER+', '+d.toFixed(2)+' behind v'+VER);
     [['TWO PLAYERS,'+' FEWER SNAGS','the two player fixes'],['NEW ICONS AND'+' A CLEANER HUD','the new icons'],['TRADING IS'+' DROPPING','dropping items']].forEach(function(n){ if(shown.indexOf(n[0])<0) bad.push('the card does not show '+n[1]+' (not in its first '+WN_SHOW+' lines)'); });
     if(String(WHATSNEW[0]).indexOf('THIS IS AN'+' ALPHA')!==0) bad.push('the card no longer opens with the alpha line');
     return bad.length?bad.join('; '):null; }},
  {v:'18.56',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
