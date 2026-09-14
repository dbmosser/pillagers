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
  {v:'14.70',what:
'@ @'
  {v:'14.71',what:'SURPRISE ME takes a worn suit off: with no suit on a random look puts none on, and with a suit on a random look leaves no suit (wardrobe audit finding 3)',
   run:function(){
     if(typeof lookRandom!=='function'||typeof COSDEF==='undefined'||typeof COSKEY==='undefined') return 'SKIP: no random look in this build';
     var suit=null; for(var i=0;i<COSMETICS.length;i++){ var c=COSMETICS[i]; if(c.kind==='outfit'&&c.id!==COSDEF.outfit){ suit=c.id; break; } }
     if(!suit) return 'SKIP: no suit to wear';
     var bad=[], prof=null, keepAll=null;
     try{
       __topClear(); __cleanProfile(); prof=__P(); keepAll=prof.cosAll;
       prof.cosAll=true;
       // CONTROL: with no suit on, a random look puts none on.
       prof[COSKEY.outfit]=COSDEF.outfit; lookRandom();
       if(prof[COSKEY.outfit]!==COSDEF.outfit) return 'SKIP: a random look put a suit on here';
       // THE FIX: a suit on, then SURPRISE ME.
       prof[COSKEY.outfit]=suit; lookRandom();
       if(prof[COSKEY.outfit]===suit) bad.push('SURPRISE ME left the '+suit+' suit on, hiding every piece it rolled');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(prof) prof.cosAll=keepAll; }catch(_a){} try{ __topClear(); __cleanProfile(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'14.70',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
