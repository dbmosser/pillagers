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

if ($s.Contains("  {v:'18.44',what:")) { throw "check 18.44 is in the fixture already" }

SubRx @'
  {v:'18.43',what:
'@ @'
  {v:'18.44',what:'the parts and salvage are painted like objects: every part and salvage icon draws at 96 px with at least 12 distinct solid colours and fills a fair part of its box',
   run:function(){
     if(typeof partIcon!=='function') return 'the parts and salvage are flat';
     var bad=[], ks=['scrap','wire','coil','cell','board','relay','optic','servo','comp','core','wcore','titan','ledger','codex','blackbox','reactor','bloom','meat'], i, cv2, c, d, p, cols, solid, k, n=0;
     for(i=0;i<ks.length;i++){
       k=ks[i]; if(!ITEMS[k]) continue; n++;
       cv2=document.createElement('canvas'); cv2.width=96; cv2.height=96; c=cv2.getContext('2d');
       try{ drawItemIcon(c,k,48,48,96*0.82); }catch(e){ bad.push(k+' threw: '+(e&&e.message||e)); continue; }
       d=c.getImageData(0,0,96,96).data; cols={}; solid=0;
       for(p=0;p<d.length;p+=4){ if(d[p+3]>220){ solid++; cols[(d[p]>>3)+','+(d[p+1]>>3)+','+(d[p+2]>>3)]=1; } }
       if(Object.keys(cols).length<12) bad.push(k+' has only '+Object.keys(cols).length+' colours');
       if(solid<96*96*0.12) bad.push(k+' fills only '+solid+' pixels');
     }
     if(n<10) bad.push('control: only '+n+' parts found');
     return bad.length?bad.join('; '):null; }},
  {v:'18.43',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
