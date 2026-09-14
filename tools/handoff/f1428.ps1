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

SubRx @'
  {v:'14.27',what:
'@ @'
  {v:'14.28',what:'under Blackout Protocol blackout weather is not hard weather: with the term signed, Blackout at a lit hour does not count as hard, while without the term it does, and fog still counts under the term (progression audit finding 1)',
   run:function(){
     if(typeof wxHardId!=='function'||typeof hasTerm!=='function') return 'SKIP: no hard weather rule or terms in this build';
     var bad=[], _ht=hasTerm, lit={id:'zqxlit',lights:1};
     try{
       // CONTROL: no term, and Blackout at a lit daytime hour is hard.
       hasTerm=function(){ return false; };
       if(wxHardId('blackout',true,lit)!==1) bad.push('control: without the term Blackout at a lit hour is not counted as hard, so this check cannot see the bonus');
       // THE FIX: the term signed, the same weather at the same hour.
       hasTerm=function(id){ return id==='blackout'; };
       if(wxHardId('blackout',true,lit)!==0) bad.push('with BLACKOUT PROTOCOL signed, Blackout weather still counted as hard and paid the hard weather bonus for lamps the term never placed');
       // And weather that cuts sight by itself still counts under the term.
       if(wxHardId('fog',true,lit)!==1) bad.push('with BLACKOUT PROTOCOL signed, fog stopped counting as hard weather');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ hasTerm=_ht; }
     return bad.length?bad.join('; '):null; }},
  {v:'14.27',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
