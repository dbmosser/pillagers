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
  {v:'14.90',what:
'@ @'
  {v:'14.91',what:'clearing a baked line in the words editor brings the original back: a line baked into the file shows its baked words, and an empty edit on it shows the original (words audit finding 3)',
   run:function(){
     if(typeof txSet!=='function'||typeof TX!=='function'||typeof TXSHIP==='undefined'||!TXSHIP) return 'SKIP: no baked words in this build';
     var k=null; for(var s0 in TXSHIP) if(typeof TXSHIP[s0]==='string'&&TXSHIP[s0]!==''&&TXSHIP[s0]!==s0&&!(/\d/).test(s0)){ k=s0; break; }
     if(!k) return 'SKIP: no baked line without numbers';
     var bad=[], P0=__P(), keepTxt=JSON.stringify(P0.txt||null), keepTxp=JSON.stringify(P0.txp||null);
     try{
       if(P0.txt) delete P0.txt[k];
       // CONTROL: with no entry of his, the baked words show.
       if(TX(k)!==TXSHIP[k]) return 'SKIP: the baked line does not show its baked words here';
       txSet(k,'');
       if(TX(k)!==k) bad.push('an empty edit on the baked line left it reading '+String(TX(k)).slice(0,60)+' instead of its original');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ P0.txt=JSON.parse(keepTxt); if(P0.txt===null) delete P0.txt; P0.txp=JSON.parse(keepTxp); if(P0.txp===null) delete P0.txp; }catch(_r){} }
     return bad.length?bad.join('; '):null; }},
  {v:'14.90',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
