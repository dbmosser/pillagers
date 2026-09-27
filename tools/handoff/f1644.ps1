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

if ($s.Contains("  {v:'16.44',what:")) { throw "check 16.44 is in the fixture already" }

SubRx @'
  {v:'16.43',what:
'@ @'
  {v:'16.44',what:'kid mode: player 2 takes the chosen fraction of every hit, the lower of its own and the host setting; player 1 is never changed',
   run:function(){
     if(typeof netKidMul!=='function'||typeof kidCycle!=='function'||typeof kidRowHtml!=='function') return 'this build has no kid mode';
     var keep={k:P.kidDmg,h:NET.kidHost}, bad=[], seen=[], i;
     try{
       P.kidDmg=1; NET.kidHost=undefined;
       for(i=0;i<5;i++) seen.push(kidCycle());
       if(seen.join(',')!=='0.5,0.25,0.2,0.1,1') bad.push('the row cycles '+seen.join(','));
       P.kidDmg=0.25; NET.kidHost=0.5; if(netKidMul()!==0.25) bad.push('own 1/4 against host 1/2 gives '+netKidMul());
       P.kidDmg=1; NET.kidHost=0.1; if(netKidMul()!==0.1) bad.push('host 1/10 does not reach player 2 ('+netKidMul()+')');
       if(kidRowHtml().indexOf('Kid mode')<0) bad.push('no Kid mode row');
     } finally { P.kidDmg=keep.k; NET.kidHost=keep.h; }
     var src='';
     try{ var ss=document.getElementsByTagName('script'); for(i=0;i<ss.length;i++) src+=ss[i].textContent||''; }catch(e){ return 'SKIP: the build cannot read its own script'; }
     var cut=src.indexOf('window.__frame=function'); if(cut>0) src=src.slice(0,cut);
     if(src.indexOf("if(typeof NET==='object'&&NET&&NET.on&&NET.role==='join'&&isFinite(amt)) amt*=netKidMul();")<0) bad.push('damage to player 2 is not scaled');
     return bad.length?bad.join('; '):null; }},
  {v:'16.43',what:
'@


$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
