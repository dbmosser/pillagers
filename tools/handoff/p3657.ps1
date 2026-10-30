$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
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

# CONDITION REWARD SPACING (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root .ocwin.condition-ui #oc_btn{margin-top:16px}
'@ @'
#root .ocwin.condition-ui #oc_btn{margin-top:16px}
/* v28.xx (cw-cx-condition-ui2): critic round 2, single-line bonuses, a fitted Terms footer and larger belt targets. */
#root #sectormodal #srmap{grid-template-columns:minmax(0,1fr) 208px}
#root #sectormodal #srside>div>.srcap:first-child>span:first-child{display:none}
#root #sectormodal #srhost:empty{display:none}
#root #sectormodal .srchip{gap:6px;padding:0 8px;white-space:nowrap}
#root #sectormodal .srchip em{font-size:16px;white-space:nowrap;flex-shrink:0;text-align:right}
#root #sectormodal .srchip.on,#root #sectormodal .kitb.on{box-shadow:none!important;border-color:var(--ui-line-hi)!important}
#root #sectormodal .srchip:focus,#root #sectormodal .kitb:focus,#root #sectormodal .padfocus{outline:2px solid var(--acc)!important;outline-offset:2px;box-shadow:none!important}
#root #sectormodal #sectorkit{margin-top:0!important}
#root #sectormodal .srplate{margin-top:auto}
#root #sectormodal #sectorkit .wn b{font-size:18px!important;color:var(--warn)}
#root #sectormodal .srcore .nm{text-align:left!important;justify-content:flex-start!important}
#root #sectormodal .srcore .held{letter-spacing:.02em;font-size:16px}
#root #sectormodal #sectorplan>div{width:100%;box-sizing:border-box}
#root #sectormodal #sectorplan div[style*="gap:4px"]{display:grid!important;grid-template-columns:repeat(5,48px);justify-content:space-between;gap:8px!important;width:100%}
#root #sectormodal #sectorplan [data-plan]{width:48px!important;height:48px!important;min-width:48px;min-height:48px;box-sizing:border-box}
#root #sectormodal #sectorplan [data-plan] span{font-size:16px!important}
#root #termsmodal h3,#root #termsmodal #termslist,#root #termsmodal.modal>.ui-foot[class]{width:calc(100% - 96px)!important;max-width:1632px!important}
#root #termsmodal #termslist .row{min-height:100px;padding:16px 24px}
#root #termsmodal #termslist .nm div{font-size:16px!important;font-weight:500;color:var(--tx-2)!important}
#root #termsmodal #termslist button{border-width:2px!important;font-size:20px}
#root #termsmodal #termslist .row.signed .vl{color:var(--tx-1)!important}
#root #termsmodal button:focus,#root #termsmodal .padfocus{outline:3px solid var(--acc-hover)!important;outline-offset:2px;box-shadow:none!important}
#root #termsmodal.modal>.ui-foot[class]{margin-top:auto!important;min-height:96px;justify-content:space-between;align-items:center;padding:16px 0 0}
#root #termsmodal #termstotal{margin:0!important;max-width:none!important;width:auto!important;flex:0 0 auto;text-align:right}
#root #termsmodal #termstotal span{display:block;font:600 16px var(--f-cond);color:var(--tx-2)!important}
#root #termsmodal #termstotal b{display:block;font:800 56px/1 var(--f-cond);color:var(--acc);letter-spacing:0}
'@

SubRx @'
desc:'40% more sentries, crawlers, criers and pillagers.'
'@ @'
desc:'sentries, crawlers, criers, pillagers +40%'
'@

SubRx @'
desc:'+1 listener. hearing +50%'
'@ @'
desc:'+1 listener, hearing +50%'
'@

SubRx @'
     return 'raid clock -33%: '+Math.round(full*0.66)+'s';   // v28.xx (cw-cx-condition-ui): short, computed condition summary
'@ @'
     return 'raid clock -33%';   // v28.xx (cw-cx-condition-ui2): only the modifier, no repeated clock total
'@

SubRx @'
  tt.innerHTML=tp>0
    ? '<span style="color:#ffc04a">sp x'+Math.pow(1.05,termsOn().length).toFixed(2)+'</span>'
    : '<span style="color:var(--ash)">no terms signed</span>';
'@ @'
  // v28.xx (cw-cx-condition-ui2): keep the total with the existing clear action in the one footer.
  tt.innerHTML='<span>score bonus</span><b>sp x'+Math.pow(1.05,termsOn().length).toFixed(2)+'</b>';
  var foot=document.querySelector('#termsmodal .ui-foot');
  if(foot&&tt.parentElement!==foot) foot.appendChild(tt);
'@

SubRx @'
      function place(hh,hw){ var top=oy+z.y*sc+hh+1, bot=oy+(z.y+z.h)*sc-hh-1, cand=[cy,top,bot,cy-hh*2-8,cy+hh*2+8], j, e2, ry, r2, k, y, best=null; if(EX) for(j=0;j<EX.length;j++){ e2=EX[j]; if(!e2) continue; ry=oy+e2.y*sc; r2=R+2; cand.push(ry-r2-hh-1,ry+r2+hh+1); } for(k=0;k<cand.length;k++){ y=cand[k]; if(y<top||y>bot||hits(y,hh,hw)) continue; if(best===null||Math.abs(y-cy)<Math.abs(best-cy)) best=y; } return best===null?cy:best; }
'@ @'
      // v28.xx (cw-cx-condition-ui2): search nearby clear spots in both axes; bounds are cached by hits.
      function place(hh,hw){
        var startX=cx,top=oy+z.y*sc+hh+8,bot=oy+(z.y+z.h)*sc-hh-8,left=ox+z.x*sc+hw+8,right=ox+(z.x+z.w)*sc-hw-8;
        var xs=[startX,left,right,startX-40,startX+40,startX-80,startX+80,startX-120,startX+120],ys=[cy,top,bot,cy-36,cy+36,cy-72,cy+72],best=null,score=1e9,xx,yy,j,k,d;
        for(j=0;j<xs.length;j++){xx=xs[j];if(xx<left||xx>right)continue;cx=xx;
          for(k=0;k<ys.length;k++){yy=ys[k];if(yy<top||yy>bot)continue;d=(xx-startX)*(xx-startX)+(yy-cy)*(yy-cy);if(d>=score||hits(yy,hh,hw))continue;score=d;best={x:xx,y:yy};if(d===0)return cy;}
        }
        cx=best?best.x:startX;return best?best.y:cy;
      }
'@

SubRx @'
    c.font='600 18px '+FF; c.textAlign='center'; c.fillStyle='#47d8c6'; put(TX('exit '+String.fromCharCode(97+i)),ox+e.x*sc,oy+e.y*sc+R+22); n++; }
'@ @'
    c.font='600 18px '+FF; c.textAlign='center'; c.fillStyle='#47d8c6'; put(TX('exit '+String.fromCharCode(97+i)),ox+e.x*sc,oy+e.y*sc+R+22); n++; }
  // v28.xx (cw-cx-condition-ui2): the purple dashed marker has a compact key on the map itself.
  if(M.locked&&M.locked.length){c.strokeStyle='#a866e0';c.lineWidth=2;c.setLineDash([4,3]);c.strokeRect(ox+16,oy+M.h*sc-32,16,16);c.setLineDash([]);c.font='600 20px '+FF;c.textAlign='left';c.fillStyle='#e6f1fb';put(TX('keyed'),ox+40,oy+M.h*sc-16);}
'@

SubRx @'
var VER='36.56';
'@ @'
var VER='36.57';
'@

$pat = "(?m)^  now:'v36\.56:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.57: Pre-raid conditions have 24px more width and keep the 5% SP value on one line. Belt cells are 48px in two rows and the armour warning follows the pack. Terms rows are 100px, the total is a 56px figure in the existing footer, idle buttons have a 2px border, and focus uses one outline. Descriptions are short. Map names can move sideways as well as up and down; a keyed-room legend names the purple marker. The approved blue map remains. Watch for full backpacks, keyboard and pad focus, and 1080p footer clipping. Reward formulas and feel do not change. Check 36.57 fails on v36.56',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
