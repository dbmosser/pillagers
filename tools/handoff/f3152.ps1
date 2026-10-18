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

if ($s.Contains("  {v:'31.52',what:")) { throw "check 31.52 is in the fixture already" }

SubRx @'
  {v:'31.51',what:
'@ @'
  {v:'31.52',what:'the end cards have a 48px close X top right that leaves like the primary, copy report is off the card, and a haul tile not yet shown stays an empty slot (his Q43, the critic on 35 38 60 76 77)',
   run:function(){
     if(!(window.__deploy&&window.__endRaid&&window.__state&&window.__P)) return 'SKIP: this build cannot end a raid';
     var bad=[], P2=__P(), keepAE=P2.autoExport, oc=document.getElementById('outcome'), x, w, xr, wr, cp, g, st, its, h, cs, cc;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       P2.autoExport=false;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); g.bag.push('core','core','scrap','wire','cell');
       __endRaid('extract');
       if(!oc.classList.contains('on')) return 'the extracted card did not open';
       x=document.getElementById('oc_x'); w=oc.querySelector('.ocwin');
       if(!x) return 'the end card has no close X (oc_x)';
       xr=x.getBoundingClientRect(); wr=w.getBoundingClientRect();
       if(xr.width<40||xr.height<40) bad.push('the X is '+Math.round(xr.width)+'x'+Math.round(xr.height)+', under the 48px button size (scaled)');
       if(wr.right-xr.right>40||wr.right-xr.right<4||xr.top-wr.top>40||xr.top<wr.top) bad.push('the X is not in the top right corner of the card');
       cp=document.getElementById('oc_copy');
       if(cp&&getComputedStyle(cp).display!=='none') bad.push('copy report is still on the end card');
       st=oc.querySelector('.haulstrip'); its=st?st.querySelectorAll('.haulit'):[];
       if(its.length<2) bad.push('the haul strip has '+its.length+' tiles in the check');
       else {
         h=its[0]; h.classList.add('hid');
         cs=getComputedStyle(h); cc=getComputedStyle(h.firstElementChild);
         if(+cs.opacity<0.99) bad.push('a tile not yet shown vanishes (opacity '+cs.opacity+'), so the strip jumps as tiles arrive');
         if(+cc.opacity>0.01) bad.push('a tile not yet shown still shows its picture');
         h.classList.remove('hid');
       }
       x.click();
       if(oc.classList.contains('on')) bad.push('the X did not leave the card');
       return bad.length?bad.join('; '):null;
     } finally {
       P2.autoExport=keepAE;
       try{ oc.classList.remove('on'); }catch(_e){}
       __topClear(); try{ __cleanProfile(); }catch(_e2){}
     } }},
  {v:'31.51',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
