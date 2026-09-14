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
  {v:'14.98',what:
'@ @'
  {v:'14.99',what:'the Data Core price on the Mainframe is the price it sells for: on a loot value setting that scales it, with a core in the stash the line names that price, and with none the line still matches his baked key (copies audit finding 3)',
   run:function(){
     if(typeof renderMainframe!=='function'||typeof ival!=='function'||!ITEMS.core||!document.getElementById('mfslothint')||!window.__applyLoaded) return 'SKIP: no Mainframe core line in this build';
     var bad=[], snap=null, keepLoot=CFG.lootMult, NONE='Spend a Data Core ($520 on the shelf) and your next raid deploys knowing things: every locked-room key location and every elite, live on the M map. None in the stash right now.';
     function line(){ renderMainframe(); return String(document.getElementById('mfslothint').textContent||''); }
     try{
       __topClear(); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       var q=__P(); q.intel=0; CFG.lootMult=1.35;
       var price=ival('core');
       // CONTROL: the setting moves the core's sell value off 520.
       if(price===520) return 'SKIP: the loot value setting does not move the Data Core value here';
       q.stash=['core'];
       var withCore=line();
       if(withCore.indexOf('$'+price.toLocaleString())<0) bad.push('with a core in the stash worth $'+price+' the Mainframe line reads: '+withCore.slice(0,60));
       q.stash=[];
       var none=line();
       if(none!==NONE&&!(typeof TXSHIP!=='undefined'&&TXSHIP&&none===TXSHIP[NONE])) bad.push('with no core the line no longer matches his baked key: '+none.slice(0,60));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ CFG.lootMult=keepLoot; try{ if(snap) __applyLoaded(snap); }catch(_r){} try{ __topClear(); __cleanProfile(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'14.98',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
