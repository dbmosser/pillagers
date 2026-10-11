$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
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

# TWO CONTRACTS DONE TOGETHER BOTH SHOW (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if(!G.sim) say('CONTRACT DONE','obj',{sub:contractDesc(c)+'. Complete contract at mainframe.'});
'@ @'
    if(!G.sim) say('CONTRACT DONE','obj',{sub:contractDesc(c)+'. Complete contract at mainframe.',key:'cdone'+((P&&P.contracts)?P.contracts.indexOf(c):0)});   // v23.xx (tr9fixk): a key per contract, so two that finish together both show
'@

SubRx @'
  for(i=0;i<q.length;i++) if(q[i]===m||(key&&qm[i]&&qm[i].o&&qm[i].o.key===key)) return i;
'@ @'
  for(i=0;i<q.length;i++) if((q[i]===m&&!msgDiffKey(qm[i]&&qm[i].o&&qm[i].o.key,key))||(key&&qm[i]&&qm[i].o&&qm[i].o.key===key)) return i;   // v23.xx (tr9fixk): two keyed lines with one headline are two lines
'@

SubRx @'
function msgQFind(m,key){
'@ @'
// v23.xx, the raid text rewrite (fix after batch 9, tr9fixk): TWO KEYED LINES WITH ONE HEADLINE ARE TWO LINES. Since R53 every
// finished contract says the same headline, CONTRACT DONE, with its own words as the detail. A row was the same line as another
// when its headline matched, so when one crate finished an open contract and a district contract in the same frame, the second
// line refreshed the first in place and wrote its detail over it: the first contract was never named in the raid. Now two lines
// that both carry a key (o.key) and whose keys differ are two lines even when the headline is the same, in the feed rows, in the
// queue and in sayWhenFree. Each contract says its line under a key of its own. A line with no key, or with the same key, is the
// same line exactly as before.
function msgDiffKey(a,b){ return !!a&&!!b&&a!==b; }
function msgQFind(m,key){
'@

SubRx @'
  if(!(f&&f.T>0&&f.m&&f.m!==G.msg)) return true;
'@ @'
  if(!(f&&f.T>0&&f.m&&(f.m!==G.msg||msgDiffKey(f.key,G.msgKey)))) return true;   // v23.xx (tr9fixk): two keyed lines with one headline are two lines
'@

SubRx @'
  r.push({m:G.msg,k:G.msgK||'info',key:G.msgKey||''});
  if(f&&f.T>0&&f.m&&f.m!==G.msg) r.push(f);
'@ @'
  r.push({m:G.msg,k:G.msgK||'info',key:G.msgKey||''});
  if(f&&f.T>0&&f.m&&(f.m!==G.msg||msgDiffKey(f.key,G.msgKey))) r.push(f);   // v23.xx (tr9fixk): two keyed lines with one headline are two lines
'@

SubRx @'
  r.push({m:G.msg,k:G.msgK||'info',sub:G.msgSub||'',T:G.msgT});
  f=G.feed&&G.feed[1];
  if(f&&f.T>0&&f.m&&f.m!==G.msg) r.push(f);
'@ @'
  r.push({m:G.msg,k:G.msgK||'info',sub:G.msgSub||'',T:G.msgT});
  f=G.feed&&G.feed[1];
  if(f&&f.T>0&&f.m&&(f.m!==G.msg||msgDiffKey(f.key,G.msgKey))) r.push(f);   // v23.xx (tr9fixk): two keyed lines with one headline are two lines
'@

SubRx @'
      if(up[i].m===m||(key&&up[i].key===key)) shown=true;
'@ @'
      if((up[i].m===m&&!msgDiffKey(up[i].key,key))||(key&&up[i].key===key)) shown=true;   // v23.xx (tr9fixk): two keyed lines with one headline are two lines
'@

SubRx @'
    var f=(G.feed=G.feed||[]), now=G.t||0, key=(o&&o.key)||'', hv=!!(G.msgT>0&&G.msg), same=hv&&(G.msg===m||(!!key&&G.msgKey===key)),
'@ @'
    var f=(G.feed=G.feed||[]), now=G.t||0, key=(o&&o.key)||'', hv=!!(G.msgT>0&&G.msg), same=hv&&((G.msg===m&&!msgDiffKey(G.msgKey,key))||(!!key&&G.msgKey===key)),   // v23.xx (tr9fixk): two keyed lines with one headline are two lines
'@

SubRx @'
        r1=(hv&&f[1]&&f[1].T>0&&f[1].m&&f[1].m!==G.msg)?f[1]:null, hd, v;
'@ @'
        r1=(hv&&f[1]&&f[1].T>0&&f[1].m&&(f[1].m!==G.msg||msgDiffKey(f[1].key,G.msgKey)))?f[1]:null, hd, v;   // v23.xx (tr9fixk): two keyed lines with one headline are two lines
'@

SubRx @'
    if(!same&&r1&&(r1.m===m||(key&&r1.key===key))){ r1.m=m; r1.k=k; r1.sub=(o&&o.sub)||''; r1.T=3.2; if(G.msgQ&&G.msgQ.length) msgQDrop(m,key); return; }
'@ @'
    if(!same&&r1&&((r1.m===m&&!msgDiffKey(r1.key,key))||(key&&r1.key===key))){ r1.m=m; r1.k=k; r1.sub=(o&&o.sub)||''; r1.T=3.2; if(G.msgQ&&G.msgQ.length) msgQDrop(m,key); return; }
'@

SubRx @'
var VER='23.09';
'@ @'
var VER='23.10';
'@

$pat = "(?m)^  now:'v23\.09:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.10: Two contracts that finish on the same box each show their own CONTRACT DONE line. Check 23.10 fails on v23.09',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
