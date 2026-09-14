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
  {v:'14.69',what:
'@ @'
  {v:'14.70',what:'a saved look is worn whole: a look saved with no outfit, worn over a suit, puts on the hat it names and takes the suit off (wardrobe audit finding 4)',
   run:function(){
     if(typeof lookWear!=='function'||typeof COSDEF==='undefined'||typeof COSKEY==='undefined') return 'SKIP: no saved looks in this build';
     var suit=null, hat=null;
     for(var i=0;i<COSMETICS.length;i++){ var c=COSMETICS[i]; if(!suit&&c.kind==='outfit'&&c.id!==COSDEF.outfit) suit=c.id; if(!hat&&c.kind==='hat'&&c.id!==COSDEF.hat) hat=c.id; }
     if(!suit||!hat) return 'SKIP: no suit and hat to wear';
     var bad=[], prof=null, keepAll=null;
     try{
       __topClear(); __cleanProfile(); prof=__P(); keepAll=prof.cosAll;
       prof.cosAll=true; prof[COSKEY.outfit]=suit; prof[COSKEY.hat]=COSDEF.hat;
       lookWear({hat:hat});   // saved before outfits existed: it has no outfit key
       // CONTROL: the hat the look names is on.
       if(prof[COSKEY.hat]!==hat) return 'SKIP: wearing the look did not put its hat on here';
       if(prof[COSKEY.outfit]===suit) bad.push('a look saved with no outfit, worn over the '+suit+' suit, left the suit on over it');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(prof) prof.cosAll=keepAll; }catch(_a){} try{ __topClear(); __cleanProfile(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'14.69',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
