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

if ($s.Contains("  {v:'24.19',what:")) { throw "check 24.19 is in the fixture already" }

SubRx @'
  {v:'24.18',what:
'@ @'
  {v:'24.19',what:'his #50 (UI redesign ui5): the shared components: in a window a primary button is a flat amber fill, square cut (2px) and 44px tall, a secondary button is square cut, a disabled one is not see-through, the chosen tab has an amber underline, the pad focus and the keyboard focus are one amber rule, and the UIICON glyph set draws in the DOM and on a canvas',
   run:function(){
     var bad=[], m=document.getElementById('settingsmodal'), box=document.createElement('div'), d, b, x, t, s, acc, k, n=0, svg, found=false, fv='focus'+'-visible', pf='.pad'+'focus';
     if(!m) return 'SKIP: no settings window here';
     function hex(h){ var q=parseInt(String(h).trim().replace('#',''),16); return 'rgb('+((q>>16)&255)+', '+((q>>8)&255)+', '+(q&255)+')'; }
     try{
       acc=hex(getComputedStyle(document.documentElement).getPropertyValue('--acc'));
       box.innerHTML='<button class="deploy">ZQ GO</button><button>ZQ BACK</button><button disabled>ZQ DEAD</button><div class="invtab on">ZQ TAB</div>';
       m.appendChild(box); d=box.children[0]; b=box.children[1]; x=box.children[2]; t=box.children[3];
       s=getComputedStyle(d);
       if(!(parseFloat(s.borderTopLeftRadius)<=3)) bad.push('the primary button corners are '+s.borderTopLeftRadius);
       if(!(parseFloat(s.minHeight)>=44)) bad.push('the primary button is '+s.minHeight+' at least, not 44px');
       if(s.backgroundColor!==acc||(/gradient/).test(s.backgroundImage)) bad.push('the primary is not a flat accent fill ('+s.backgroundColor+', '+String(s.backgroundImage).slice(0,30)+')');
       s=getComputedStyle(b);
       if(!(parseFloat(s.borderTopLeftRadius)<=3)) bad.push('a secondary button has corners of '+s.borderTopLeftRadius);
       if(!(parseFloat(s.minHeight)>=40)) bad.push('a secondary button is only '+s.minHeight+' tall at least');
       s=getComputedStyle(x); if(parseFloat(s.opacity)<1) bad.push('a disabled button is see-through ('+s.opacity+')');
       s=getComputedStyle(t);
       if(s.borderBottomColor!==acc) bad.push('the chosen tab has no amber underline ('+s.borderBottomColor+')');
       if(parseFloat(s.borderTopLeftRadius)>3) bad.push('the tab is rounded ('+s.borderTopLeftRadius+')');
       b.classList.add('padfocus'); s=getComputedStyle(b);
       if(s.outlineColor!==acc) bad.push('the pad focus outline is '+s.outlineColor+', not the accent');
       (function walk(rules){ for(var i=0;rules&&i<rules.length&&!found;i++){ var r=rules[i], st=r.selectorText||'';
         if(r.cssRules&&r.cssRules.length&&!r.style){ walk(r.cssRules); continue; }
         if(st.indexOf(':'+fv)>=0&&st.indexOf(pf)>=0&&r.style&&String(r.style.cssText).indexOf('var(--acc)')>=0) found=true; } })(document.getElementsByTagName('style')[0].sheet.cssRules);
       if(!found) bad.push('the keyboard focus and the pad focus are not one rule');
       if(typeof UIICON!=='object'||!UIICON) bad.push('no UIICON glyph set');
       else {
         for(k in UIICON){ if(Object.prototype.hasOwnProperty.call(UIICON,k)){ n++; if(typeof UIICON[k]!=='string'||!(/^M/).test(UIICON[k])) bad.push('UIICON.'+k+' is not path data'); } }
         if(typeof UIICON.lock!=='string') bad.push('UIICON has no lock');
         if(n<30) bad.push('UIICON holds '+n+' glyphs, not the set of 2.7');
         svg=(typeof uiIcon==='function')?uiIcon('lock',20):'';
         if(svg.indexOf('<svg')!==0||svg.indexOf(UIICON.lock)<0) bad.push('uiIcon does not draw the lock');
         if(typeof Path2D!=='undefined'&&!(typeof uiIconPath==='function'&&uiIconPath('check') instanceof Path2D)) bad.push('uiIconPath gives no Path2D for the canvas');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ m.removeChild(box); }catch(_r){} }
     return bad.length?bad.join('; '):null; }},
  {v:'24.18',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
