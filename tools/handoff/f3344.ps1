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

if ($s.Contains("  {v:'33.44',what:")) { throw "check 33.44 is in the fixture already" }

SubRx @'
  {v:'33.43',what:
'@ @'
  {v:'33.44',what:'the pre-raid pack rows carry a buy control: a sold item shows the counter price, one press takes exactly that from P.credits and adds one to the stash, a gun the counter never sells has none, and too few credits changes nothing',
   run:function(){
     if(!(window.__hubEnter&&window.__P&&window.__applyLoaded)||typeof renderSector!=='function'||typeof packBuyHtml!=='function') return 'there is no pack buy control (no packBuyHtml)';
     var bad=[], snap=null, q, sm=document.getElementById('sectormodal'), pr=0, b, c0, n0, i;
     function shut(){ var mo=document.querySelectorAll('.modal.on'); for(var j=0;j<mo.length;j++) mo[j].classList.remove('on'); }
     function cnt(k){ var n=0, j; for(j=0;j<P.stash.length;j++) if(P.stash[j]===k) n++; return n; }
     function row(k){ return sm.querySelector('#sectorpack [data-pk="'+k+'"]'); }
     try{
       snap=JSON.parse(JSON.stringify(__P()));
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       q=__P(); q.freeKit=0; q.kitPick='mine'; q.stash=['bandage','gun_carbine','gun_smg']; q.kit=[]; q.equipped='fists'; q.credits=5000;
       for(i=0;i<SHOP.length;i++) if(SHOP[i].k==='bandage') pr=SHOP[i].price;
       __hubEnter(); shut(); renderSector(); openModal('sectormodal');
       if(!row('bandage')) return 'the bandage row is not drawn';
       b=row('bandage').querySelector('[data-pb]');
       if(!b) bad.push('a sold item (bandage) has no buy control');
       else{
         if(b.textContent.replace(/\s/g,'')!=='$'+pr.toLocaleString()) bad.push('the control says '+b.textContent+', not the counter price $'+pr);
         c0=P.credits; n0=cnt('bandage'); b.click();
         if(P.credits!==c0-pr) bad.push('one press took '+(c0-P.credits)+' not '+pr);
         if(cnt('bandage')!==n0+1) bad.push('one press added '+(cnt('bandage')-n0)+' to the stash, not 1');
       }
       if(row('gun_carbine')&&row('gun_carbine').querySelector('[data-pb]')) bad.push('the burst carbine, which the counter never sells, has a buy control');
       if(row('gun_smg')&&!row('gun_smg').querySelector('[data-pb]')) bad.push('the compact smg, which the counter sells, has no buy control');
       P.credits=pr-1; renderSector(); b=row('bandage')&&row('bandage').querySelector('[data-pb]');
       if(!b) bad.push('the control is gone when credits run short, it should stay dim');
       else{
         if(!b.classList.contains('dis')) bad.push('too few credits and the control is not dim');
         c0=P.credits; n0=cnt('bandage'); b.click();
         if(P.credits!==c0||cnt('bandage')!==n0) bad.push('a press with too few credits changed the credits or the stash');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ shut(); }catch(_s){} try{ if(snap) __applyLoaded(snap); }catch(_a){} try{ __cleanProfile(); }catch(_c){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'33.43',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
