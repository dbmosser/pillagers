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

if ($s.Contains("  {v:'20.67',what:")) { throw "check 20.67 is in the fixture already" }

SubRx @'
  {v:'20.66',what:
'@ @'
  {v:'20.67',what:'stash SORT RARITY ranks each thing by the rarity colour its cell shows, so a gun wearing a higher colour than its item row sorts by that colour and every cell runs from the highest colour down',
   run:function(){
     if(typeof stashSortKeys!=='function'||typeof dispR!=='function'||typeof _RRANK!=='object'||!_RRANK||typeof P!=='object'||!P) return 'SKIP: no stash sort here';
     var bad=[], s0=P.stashSort, had=Object.prototype.hasOwnProperty.call(P,'stashSort'), ks=Object.keys(ITEMS), a=null, b=null, i, j, o;
     function rk(k){ return _RRANK[dispR(k)]||0; }
     function rw(k){ return _RRANK[(ITEMS[k]||{}).r]||0; }
     function nm(k){ return (ITEMS[k]&&ITEMS[k].name)||k; }
     for(i=0;i<ks.length&&!a;i++){
       if(!(ITEMS[ks[i]]&&ITEMS[ks[i]].use==='gun')) continue;
       for(j=0;j<ks.length;j++) if(rk(ks[i])>rk(ks[j])&&rw(ks[i])<rw(ks[j])){ a=ks[i]; b=ks[j]; break; }
     }
     if(!a) return 'SKIP: every gun here wears the rarity of its item row';
     try{
       P.stashSort='rarity';
       o=stashSortKeys([b,a],{});
       if(o[0]!==a) bad.push(nm(a)+' wears '+dispR(a)+' but sorts below '+nm(b)+', which wears '+dispR(b));
       o=stashSortKeys(ks.slice(),{});
       for(i=1;i<o.length;i++) if(rk(o[i])>rk(o[i-1])){ bad.push(nm(o[i])+' ('+dispR(o[i])+') sorts below '+nm(o[i-1])+' ('+dispR(o[i-1])+')'); break; }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ if(had) P.stashSort=s0; else delete P.stashSort; }
     return bad.length?bad.join('; '):null; }},
  {v:'20.66',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
