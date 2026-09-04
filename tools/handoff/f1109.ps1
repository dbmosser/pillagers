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
  {v:'11.08',what:'the sound key teaches the colours
'@ @'
  {v:'11.09',what:'every menu in the document is set in the game font, measured on what the browser computes rather than on what the stylesheet says',
   run:function(){
     if(!__vpAlive()) return 'SKIP: the pane has no layout, nothing computes a font';
     var bad=[], i;
     // WHAT THE BROWSER ACTUALLY RESOLVES, not what the stylesheet asks for. A
     // rule can be overridden, a class can be missing, and an inline style beats
     // both; the only honest question is what the element ends up in.
     function famOf(el){
       var f='';
       try{ f=window.getComputedStyle(el).fontFamily||''; }catch(e){ return ''; }
       return String(f).split(',')[0].replace(/["']/g,'').trim().toLowerCase();
     }
     // The two deliberate exceptions, and they are named rather than pattern
     // matched: the game's own name is a wordmark, and the dev text editor is
     // monospace because it is a text editor.
     function allowed(el){
       if(!el) return false;
       if(el.id==='titlefs') return false;
       var c=el.className;
       if(typeof c==='string'&&c.indexOf('brand')>=0) return true;
       // the wordmark itself carries no class, so it is found by what it says
       var t=(el.textContent||'').trim();
       if(t==='PILLAGERS'&&el.children.length===0) return true;
       return false;
     }
     var all=document.querySelectorAll('body *'), seen={}, offenders=[];
     for(i=0;i<all.length;i++){
       var el=all[i];
       if(el.tagName==='SCRIPT'||el.tagName==='STYLE'||el.tagName==='CANVAS') continue;
       var fam=famOf(el);
       if(!fam) continue;
       seen[fam]=(seen[fam]||0)+1;
       if(fam==='rubik') continue;
       if(allowed(el)) continue;
       if(offenders.length<6) offenders.push((el.id||el.tagName)+' is in '+fam);
     }
     if(offenders.length) bad.push('the menus are not all in one font: '+offenders.join('; '));
     // CONTROL ONE: the sweep has to have looked at a real document. A page that
     // failed to build would pass every line above by having nothing to fail.
     var total=0, k;
     for(k in seen) total+=seen[k];
     if(total<120) bad.push('control: only '+total+' elements were read, so this is not the whole document');
     if(!seen.rubik||seen.rubik<100) bad.push('control: only '+(seen.rubik||0)+' elements are in the game font, so the font is not loading and everything is falling back');
     // CONTROL TWO: and the sweep can SEE a second family. An element in another
     // face is planted, caught, and removed; without this the clean result above
     // would prove nothing.
     var probe=document.createElement('div');
     probe.style.fontFamily='"Comic Sans MS", cursive';
     probe.textContent='zqx font control';
     document.body.appendChild(probe);
     var caught=(famOf(probe)==='comic sans ms');
     document.body.removeChild(probe);
     if(!caught) bad.push('control: an element planted in another face was not noticed, so this check cannot see a second font');
     return bad.length?bad.join('; '):null; }},
  {v:'11.08',what:'the sound key teaches the colours
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
