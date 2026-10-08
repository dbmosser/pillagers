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

if ($s.Contains("  {v:'19.20',what:")) { throw "check 19.20 is in the fixture already" }

SubRx @'
  {v:'19.19',what:
'@ @'
  {v:'19.20',what:'a FASHION click builds the racks once: wearing a different hat rebuilds the rack list one time, and the new hat shows as worn',
   run:function(){
     if(typeof renderAvatar!=='function'||typeof COSKEY==='undefined') return 'SKIP: no FASHION here';
     var ap=document.getElementById('appearmodal'), pk=document.getElementById('appavatarpicker'), bad=[], n=0, mo=null, k=COSKEY.hat||'cosHat', h0=P[k], ow0=cosOwned, was=ap&&ap.classList.contains('on'), el, tiles, i, id=null;
     if(!ap||!pk||typeof MutationObserver!=='function') return 'SKIP: no racks';
     try{
       cosOwned=function(c){ return true; };
       ap.classList.add('on'); P._avSlot=null;
       renderAvatar('appavatar','appavatarpicker');
       tiles=[].slice.call(pk.querySelectorAll('.costile[data-kind="hat"]'));
       for(i=0;i<tiles.length;i++) if(tiles[i].getAttribute('data-id')!==String(P[k])){ id=tiles[i].getAttribute('data-id'); break; }
       if(!id) return 'SKIP: no other hat to wear';
       el=pk.querySelector('.costile[data-id="'+id+'"]');
       mo=new MutationObserver(function(){}); mo.observe(pk,{childList:true});
       el.onclick();
       mo.takeRecords().forEach(function(m){ if(m.target===pk) n++; });
       if(n>1) bad.push('one click rebuilt the racks '+n+' times');
       if(n<1) bad.push('the racks were not rebuilt at all after the click');
       if(P[k]!==id) bad.push('the clicked hat is not worn');
       el=pk.querySelector('.costile[data-id="'+id+'"]');
       if(!el||!/WORN/.test(el.innerText||el.textContent||'')) bad.push('the clicked hat does not show as worn on the rack');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ if(mo) mo.disconnect(); cosOwned=ow0; if(h0===undefined) delete P[k]; else P[k]=h0; try{ saveProfile(); }catch(_s){} if(!was) ap.classList.remove('on'); __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.19',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
