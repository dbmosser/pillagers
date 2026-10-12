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

if ($s.Contains("  {v:'23.82',what:")) { throw "check 23.82 is in the fixture already" }

SubRx @'
  {v:'23.81',what:
'@ @'
  {v:'23.82',what:'his #50 and #20 (UI redesign ui2): the graphite colour tokens, the old navy names re-pointed, no navy or periwinkle left in the stylesheet, rarity classes on the rarity tokens, and the HUD colours read from the UIC mirror',
   run:function(){
     var bad=[], root=document.documentElement, rt=document.getElementById('root')||root, cs, rs, k, v, n=0, sp=null, cl=null, sh, hits=[];
     try{
       if(typeof UIC!=='object'||!UIC) return 'there is no UIC colour mirror';
       cs=getComputedStyle(root); rs=getComputedStyle(rt);
       if(cs.getPropertyValue('--ui-panel').trim()!=='#16191b') bad.push('--ui-panel at the root is '+JSON.stringify(cs.getPropertyValue('--ui-panel').trim())+', not #16191b');
       for(k in UIC){ if(!Object.prototype.hasOwnProperty.call(UIC,k)) continue; n++;
         v=cs.getPropertyValue('--'+k.replace(/_/g,'-')).trim();
         if(v!==UIC[k]) bad.push('--'+k.replace(/_/g,'-')+' is '+JSON.stringify(v)+' in the stylesheet but '+UIC[k]+' in UIC'); }
       if(n<31) bad.push('UIC holds '+n+' colours, not the 31 tokens');
       if(rs.getPropertyValue('--win-top').trim()==='#1c2a63') bad.push('#root still paints windows in the Chrono navy #1c2a63');
       [['--void','ui_void'],['--steel','ui_line'],['--steel-hi','ui_line_hi'],['--win-top','ui_panel'],['--win-bot','ui_bg'],['--ash','tx_2'],['--bone','tx_1'],
        ['--amber','acc'],['--coolant','extract'],['--hazard','danger'],['--gain','ok'],['--rust','danger']].forEach(function(q){
         [cs,rs].forEach(function(st,ix){ var w=st.getPropertyValue(q[0]).trim(); if(w!==UIC[q[1]]) bad.push(q[0]+(ix?' on #root':' at the root')+' is '+JSON.stringify(w)+', not re-pointed to '+UIC[q[1]]); }); });
       if(typeof HUDC!=='object'||!HUDC) bad.push('no HUDC');
       else { if(HUDC.danger!==UIC.danger) bad.push('HUDC.danger is not UIC.danger'); if(HUDC.extract!==UIC.extract) bad.push('HUDC.extract is not UIC.extract');
         if(HUDC.text!==UIC.tx_1) bad.push('HUDC.text is not UIC.tx_1'); if(HUDC.ally!==UIC.ally) bad.push('HUDC.ally is not UIC.ally'); }
       sp=document.createElement('span'); sp.className='r-rare'; sp.textContent='x'; rt.appendChild(sp);
       if(getComputedStyle(sp).color!=='rgb(63, 157, 233)') bad.push('.r-rare text is '+getComputedStyle(sp).color+', not the rare token');
       cl=document.createElement('div'); cl.className='cell c-gold'; rt.appendChild(cl);
       if(getComputedStyle(cl).borderTopColor!=='rgb(240, 143, 46)') bad.push('.cell.c-gold border is '+getComputedStyle(cl).borderTopColor+', not the gold token');
       sh=document.getElementsByTagName('style')[0]; sh=sh&&sh.sheet;
       (function walk(rules){ for(var i=0;rules&&i<rules.length;i++){ var r=rules[i], t=r.cssText||'';
         if(r.cssRules&&r.cssRules.length&&!r.style){ walk(r.cssRules); continue; }
         if((/rgba?\((127, 146, 216|28, 42, 99|13, 20, 53|9, 14, 40|16, 26, 66|8, 12, 32)[,)]/).test(t)&&hits.length<4) hits.push(t.slice(0,90)); } })(sh?sh.cssRules:null);
       if(!sh) bad.push('no stylesheet to read');
       if(hits.length) bad.push('navy or periwinkle left in the stylesheet: '+hits.join(' | '));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(sp&&sp.parentNode) sp.parentNode.removeChild(sp); if(cl&&cl.parentNode) cl.parentNode.removeChild(cl); }catch(_r){} try{ __topClear(); }catch(_t){} }
     return bad.length?bad.join('; '):null; }},
  {v:'23.81',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
