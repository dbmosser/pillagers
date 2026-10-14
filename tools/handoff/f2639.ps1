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

if ($s.Contains("  {v:'26.39',what:")) { throw "check 26.39 is in the fixture already" }

SubRx @'
  {v:'26.38',what:
'@ @'
  {v:'26.39',what:'his order (2026-10-14), the four starter guns are in no table at all: the class keys (GUN_CLASS_OF) name none of them, and nothing in the game script names one as a table key or a quoted gun id, so a table added later cannot bring one back',
   run:function(){
     if(typeof GUN_CLASS_OF!=='object'||!GUN_CLASS_OF) return 'SKIP: this build has no class key table';
     var NM=['tac'+'ker','sput'+'ter','chat'+'ter','scut'+'tle'], bad=[], i, txt='', scs=[].slice.call(document.scripts), need='var GUN_CLASS'+'_OF=', re1, re2, m, hits=[];
     for(i=0;i<NM.length;i++) if(GUN_CLASS_OF[NM[i]]!==undefined) bad.push('the class keys still name '+NM[i]);
     for(i=0;i<scs.length;i++) if((scs[i].textContent||'').indexOf(need)>=0){ txt=scs[i].textContent; break; }
     if(!txt) return bad.length?bad.join('; '):'SKIP: the game script is not in the page as text';
     re1=new RegExp('[\'"](' +NM.join('|')+ ')[\'"]','g');
     re2=new RegExp('[{,]\\s*(' +NM.join('|')+ ')\\s*:','g');
     while((m=re1.exec(txt))&&hits.length<4) hits.push(txt.slice(Math.max(0,m.index-30),m.index+40).replace(/\s+/g,' '));
     while((m=re2.exec(txt))&&hits.length<4) hits.push(txt.slice(Math.max(0,m.index-30),m.index+40).replace(/\s+/g,' '));
     if(hits.length) bad.push('the game script still names a starter gun: '+hits.join(' | '));
     return bad.length?bad.join('; '):null; }},
  {v:'26.38',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
