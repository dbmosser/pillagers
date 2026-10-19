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

if ($s.Contains("  {v:'31.58',what:")) { throw "check 31.58 is in the fixture already" }

SubRx @'
  {v:'31.57',what:
'@ @'
  {v:'31.58',what:'a haul tile not yet shown is a plain grey slot with no rarity bar, and the strip wraps balanced (the critic on 76: nine empty boxes with coloured bars)',
   run:function(){
     if(!(window.__deploy&&window.__endRaid&&window.__state&&window.__P)) return 'SKIP: this build cannot end a raid';
     var bad=[], P2=__P(), keepAE=P2.autoExport, oc=document.getElementById('outcome'), g, st, its, h, cs, line, hi;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       P2.autoExport=false;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); g.bag.push('core','core','scrap','wire','cell');
       __endRaid('extract');
       if(!oc.classList.contains('on')) return 'the extracted card did not open';
       st=oc.querySelector('.haulstrip'); its=st?st.querySelectorAll('.haulit'):[];
       if(its.length<2) return 'the haul strip has '+its.length+' tiles in the check';
       h=its[0]; h.classList.add('hid');
       cs=getComputedStyle(h); line=getComputedStyle(document.documentElement).getPropertyValue('--ui-line').trim();
       hi=document.createElement('span'); hi.style.color=line; document.body.appendChild(hi); line=getComputedStyle(hi).color; hi.remove();
       if(cs.borderBottomColor!==line) bad.push('a tile not yet shown has a '+cs.borderBottomColor+' bar, not the plain slot colour '+line);
       if(getComputedStyle(st).textWrap!=='balance') bad.push('the haul strip does not wrap balanced (text-wrap '+getComputedStyle(st).textWrap+')');
       h.classList.remove('hid');
       return bad.length?bad.join('; '):null;
     } finally {
       P2.autoExport=keepAE;
       try{ oc.classList.remove('on'); }catch(_e){}
       __topClear(); try{ __cleanProfile(); }catch(_e2){}
     } }},
  {v:'31.57',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
