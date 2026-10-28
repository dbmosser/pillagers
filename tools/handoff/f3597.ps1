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

if ($s.Contains("  {v:'35.97',what:")) { throw "check 35.97 is in the fixture already" }

SubRx @'
  {v:'35.96',what:
'@ @'
  {v:'35.97',what:'menus master pass 2026-10-28: on Wirt the limited time offer column fits a short panel (his 4K screen ran it 37px over): the offer picture tile gives up height (192 down to 96) so the buy button and its need more line stay inside the panel; with room the tile stays 192',
   run:function(){
     if(typeof renderGamble!=='function'||typeof WIRT_LOT_PRICE!=='number'||typeof P!=='object'||!P) return 'SKIP: no gambler here';
     var bad=[], gm=document.getElementById('gamblemodal'), was=gm&&gm.classList.contains('on'), c0=P.credits, sec, lot, tile, txt, btn, h0, z, sb, pb, tb, r, ib;
     if(!gm) return 'no Wirt card';
     try{
       P.credits=900;
       renderGamble(); gm.classList.add('on');
       sec=document.getElementById('wirtsec_offer'); lot=document.getElementById('wirtlot');
       tile=lot&&lot.querySelector('span[title]'); btn=document.getElementById('wirtlotbtn');
       txt=lot&&lot.querySelector('span:not([title])');
       if(!sec||!tile||!btn||!txt) return 'the offer panel is not built ('+[!!sec,!!tile,!!btn,!!txt].join(',')+')';
       if(!(sec.offsetHeight>0)) return 'SKIP: the Wirt card does not lay out here';
       if(!btn.getAttribute('data-need')) bad.push('no need more line on the buy button at $900');
       z=btn.getBoundingClientRect().height/(btn.offsetHeight||1);
       // with room: the tile keeps its full 192
       sec.style.alignSelf='start'; txt.style.flexGrow='0';
       if(Math.abs(tile.offsetHeight-192)>1) bad.push('with room the offer picture is '+tile.offsetHeight+'px tall, not 192');
       h0=sec.offsetHeight;
       // short panel: 40px less than its content wants, as on his 4K screen (37 over)
       sec.style.height=(h0-40)+'px';
       sb=sec.getBoundingClientRect(); pb=parseFloat(getComputedStyle(sec).paddingBottom)||0;
       r=btn.getBoundingClientRect(); tb=tile.getBoundingClientRect();
       if(!(r.bottom+30*z<=sb.bottom-pb*z+1)) bad.push('in a short panel the buy button and its need line run '+Math.round((r.bottom+30*z-(sb.bottom-pb*z))/z)+'px past the panel floor');
       if(!(tile.offsetHeight<192&&tile.offsetHeight>=96)) bad.push('in a short panel the offer picture stays '+tile.offsetHeight+'px tall (it should give up height, down to 96)');
       ib=tile.querySelector('img'); ib=ib&&ib.getBoundingClientRect();
       if(!ib||ib.height<1||ib.top<tb.top-1||ib.bottom>tb.bottom+1) bad.push('the offer picture does not fit its tile ('+(ib?[ib.top,ib.bottom,tb.top,tb.bottom].map(Math.round).join(','):'no img')+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(sec){ sec.style.height=''; sec.style.alignSelf=''; } if(txt) txt.style.flexGrow=''; }catch(_s){}
       P.credits=c0;
       if(!was) gm.classList.remove('on');
       try{ renderGamble(); }catch(_r){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'35.96',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
