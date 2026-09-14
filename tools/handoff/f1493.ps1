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
  {v:'14.92',what:
'@ @'
  {v:'14.93',what:'his own pattern beats a baked exact line: with his rewording of a baked number line saved as a pattern, the line at the baked number shows his words (words audit finding 6)',
   run:function(){
     if(typeof TX!=='function'||typeof txSplit!=='function'||typeof TXSHIP==='undefined'||!TXSHIP||typeof TXPANY==='undefined') return 'SKIP: no baked words or patterns in this build';
     var k=null; for(var s0 in TXSHIP) if(typeof TXSHIP[s0]==='string'&&(/\d/).test(s0)&&s0.indexOf('test robot extracts')<0&&txSplit(s0).nums.length){ k=s0; break; }
     if(!k) return 'SKIP: no baked line with numbers';
     var bad=[], P0=__P(), keepTxt=JSON.stringify(P0.txt||null), keepTxp=JSON.stringify(P0.txp||null), keepAny=TXPANY;
     try{
       if(P0.txt) delete P0.txt[k];
       if(P0.txp) delete P0.txp[txSplit(k).pat];
       // CONTROL: with no edit of his, the baked words show.
       if(TX(k)!==TXSHIP[k]) return 'SKIP: the baked line does not show its baked words here';
       var sp=txSplit(k);
       P0.txt=P0.txt||{}; P0.txp=P0.txp||{}; P0.txp[sp.pat]='ZQXP '+sp.pat; TXPANY=1;
       var got=String(TX(k));
       if(got.indexOf('ZQXP ')!==0) bad.push('his own pattern for the line '+k.slice(0,40)+' lost to the baked words: '+got.slice(0,60));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ TXPANY=keepAny; P0.txt=JSON.parse(keepTxt); if(P0.txt===null) delete P0.txt; P0.txp=JSON.parse(keepTxp); if(P0.txp===null) delete P0.txp; }catch(_r){} }
     return bad.length?bad.join('; '):null; }},
  {v:'14.92',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
