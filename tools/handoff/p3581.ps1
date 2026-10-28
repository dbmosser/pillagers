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

# CONDITION REWARD READABILITY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
<title>Pillagers</title>
'@ @'
<title>Pillagers</title>
<style id="cx-condition-ui">
/* v28.xx (cw-cx-condition-ui): critic round 1, readable condition rewards and one result hero. His chosen blue map and map-first proportions stay. */
#root #sectormodal #srkitcol{gap:24px}
#root #sectormodal #sectorpack{flex:0 1 auto;min-height:0;padding:16px 0;border-top:1px solid var(--ui-line);border-bottom:1px solid var(--ui-line)}
#root #sectormodal .srplist:empty{display:none}
#root #sectormodal #sectorkit{margin-top:auto!important}
#root #sectormodal .srcap{font-size:18px;letter-spacing:.04em}
#root #sectormodal .srchip em{font-size:18px}
#root #sectormodal .srstack{padding-bottom:10px;border-bottom:1px solid var(--ui-line)}
#root #sectormodal .srchip.on,#root #sectormodal .kitb.on{box-shadow:none}
#root #sectormodal .srchip:focus-visible,#root #sectormodal .kitb:focus-visible,#root #sectormodal .padfocus{outline:2px solid var(--acc)!important;outline-offset:2px}
#root #sectormodal .kitb .kd{font-size:16px;line-height:1.25}
#root #sectormodal .pkb{font-size:16px;background:transparent}
#root #sectormodal .srcore{font-size:16px}
#root #sectormodal .srcore .cb{width:32px;height:32px;flex:none}
#root #sectormodal .srcore.on .cb::after{left:10px;top:5px}
#root #termsmodal{justify-content:flex-start!important;padding-top:112px!important;padding-bottom:112px!important;gap:0}
#root #termsmodal h3{width:100%;max-width:1400px!important;align-self:center;text-align:left;font:700 32px/56px var(--f-cond)!important;margin:0 0 24px!important;padding:0 0 8px;border-bottom:1px solid var(--ui-line)}
#root #termsmodal #termslist{border-color:var(--ui-line-hi)!important}
#root #termsmodal #termslist .row{min-height:88px;padding:16px 24px;gap:16px;background:var(--ui-panel);border-color:var(--ui-line)}
#root #termsmodal #termslist .row.signed{background:var(--ui-raised)}
#root #termsmodal #termslist .nm{font-size:20px}
#root #termsmodal #termslist .nm div{font-size:16px!important;color:var(--tx-2)!important}
#root #termsmodal #termslist .vl{font:600 20px var(--f-cond)!important;color:var(--tx-2)!important;min-width:90px}
#root #termsmodal #termslist .row.signed .vl{color:var(--acc)!important}
#root #termsmodal #termslist button{width:120px;min-width:104px;min-height:48px;color:var(--tx-1)!important;background:transparent;border:1px solid var(--ui-line-hi)!important}
#root #termsmodal #termslist button[aria-pressed="true"]{color:var(--acc-ink)!important;background:var(--acc);border-color:var(--acc)!important}
#root #termsmodal #termslist .row:focus-within{box-shadow:inset 3px 0 var(--acc);background:var(--ui-raised)}
#root #termsmodal button:focus-visible,#root #termsmodal .padfocus{outline:2px solid var(--acc)!important;outline-offset:3px}
#root #termsmodal #termstotal{margin-top:24px!important;min-height:24px;text-align:right;font:600 20px var(--f-cond)}
#root #termsmodal #termstotal span{color:var(--acc)!important}
#root #termsmodal .ui-foot{margin-top:auto!important;min-height:72px;align-items:center}
#root .ocwin.condition-ui{padding:24px 32px 0;max-height:calc(100vh - 64px);overflow-y:auto}
#root .ocwin.condition-ui #oc_sub{position:absolute;width:1px;height:1px;overflow:hidden;clip-path:inset(50%)}
#root .ocwin.condition-ui #oc_manifest{margin:16px 0;font-size:16px;line-height:1.4;color:var(--tx-1)}
#root .lg{width:100%;max-width:none;margin:0;letter-spacing:.04em}
#root .lg .lgcols{gap:16px}
#root .lg .lgp{--lgc:var(--tx-1);padding:16px;background:var(--ui-panel);border:1px solid var(--ui-line-hi);border-top:1px solid var(--ui-line-hi);border-radius:4px}
#root .lg .lgh{font-size:16px;letter-spacing:.04em;color:var(--tx-2);gap:8px;flex-wrap:wrap;height:auto;min-height:24px}
#root .lg .lgh .lgpb{font-size:16px;letter-spacing:.02em;background:none;color:var(--tx-1);clip-path:none;padding:0;border-bottom:3px solid var(--r-gold,#ffc72e)}
#root .lg .lgp .lgr{font-size:16px;padding:4px 0;letter-spacing:.02em}
#root .lg .lgp .lgr .lgl{color:var(--tx-2);font-weight:600}
#root .lg .lgp .lgr b{font-size:20px;color:var(--tx-1);font-weight:700}
#root .lg .lgp .lgr.sc,#root .lg .lgp .lgr.tot{border-top:1px solid var(--ui-line-hi);margin-top:8px;padding-top:12px;color:var(--tx-1)}
#root .lg .lgps .lgr.sc{display:flex;flex-wrap:wrap;gap:4px;justify-content:space-between}
#root .lg .lgps .lgr.sc b{font:800 56px/1.1 var(--f-cond);letter-spacing:0;color:var(--acc);white-space:nowrap}
#root .lg .lgpm .lgr.tot b{font:700 32px/1.2 var(--f-cond);letter-spacing:0;color:var(--tx-1)}
#root .lg .lgstrip{margin:16px 0}
#root .lg .lgitemlabel{display:block;font-size:16px;color:var(--tx-2);margin:8px 0 0;text-align:center}
#root .lg .lgst{display:grid;grid-template-columns:repeat(4,minmax(0,1fr));gap:8px;margin:16px 0}
#root .lg .lgti{padding:8px 4px;background:var(--ui-panel);border:1px solid var(--ui-line);border-radius:4px}
#root .lg .lgti b{font-size:24px;color:var(--tx-1)}
#root .lg .lgti span{font-size:16px;letter-spacing:.04em;color:var(--tx-2)}
#root .lg .lgem{gap:16px;margin:16px 0}
#root .lg .lgeb{border-bottom:3px solid var(--r-gold,#ffc72e);padding-bottom:4px}
#root .lg .lgeb svg{width:40px;height:40px;filter:none}
#root .lg .lgeb svg polygon{fill:var(--ui-panel);stroke:var(--ui-line-hi)}
#root .lg .lgeb svg g path{stroke:var(--tx-1)}
#root .lg .lgeb i{font:600 16px var(--f-cond);letter-spacing:.04em;color:var(--tx-1)}
#root .ocwin.condition-ui #oc_manifest>span:not(.ocsr){font-size:16px!important;color:var(--tx-1)!important}
#root .ocwin.condition-ui .fbhead{font:600 16px var(--f-cond);min-height:48px!important;padding:0 8px;margin-top:0;border:0;background:none;color:var(--tx-2)}
#root .ocwin.condition-ui #oc_btn{margin-top:16px}
</style>
'@

SubRx @'
    var on=hasTerm(T.id);
    var row=document.createElement('div'); row.className='row';
'@ @'
    var on=hasTerm(T.id);
    var row=document.createElement('div'); row.className=on?'row signed':'row';
'@

SubRx @'
  try{ var _fbw=document.querySelector('#outcome .ocwin'); if(_fbw) _fbw.classList.remove('fbopen'); }catch(_fbo){}   // v27.xx (uic2): every card comes up with the tags shut
'@ @'
  // v28.xx (cw-cx-condition-ui): set a direct style class once per card, rather than matching descendants during every layout.
  try{ var _fbw=document.querySelector('#outcome .ocwin'); if(_fbw){ _fbw.classList.remove('fbopen'); _fbw.classList.toggle('condition-ui',!!(G&&G.career&&!G.sim&&G.cs)); } }catch(_fbo){}
'@

SubRx @'
    b.onclick=function(){ toggleTerm(T.id); renderTerms(); renderHub(); };
'@ @'
    b.onclick=function(){ toggleTerm(T.id); renderTerms(); renderHub(); };
    // v28.xx (cw-cx-condition-ui): selection is explicit and exposed to keyboard/pad and assistive readers.
    b.setAttribute('aria-pressed',on?'true':'false');
'@

SubRx @'
    b.textContent=on?'Signed':'Sign';
'@ @'
    b.textContent=on?'\u2713 signed':'sign';   // v28.xx (cw-cx-condition-ui): a check distinguishes the signed state
'@

SubRx @'
40% more machines, pillager bots and criers.
'@ @'
40% more machines, pillagers and criers.
'@

SubRx @'
<span class="held">BURNS ON ASCENT</span>
'@ @'
<span class="held">burn for intel</span>
'@

SubRx @'
Every pillager bot is hostile and already searching for you.
'@ @'
all pillagers hostile and searching
'@

SubRx @'
desc:'Every lamp on the map stays dark.'
'@ @'
desc:'all lamps off'
'@

SubRx @'
desc:'One extra Listener. All Listeners hear 50% farther.'
'@ @'
desc:'+1 listener. hearing +50%'
'@

SubRx @'
     return 'The whole raid clock is cut by a third: about '+Math.round(full*0.66)+
            ' seconds instead of '+full+'.';
'@ @'
     return 'raid clock -33%: '+Math.round(full*0.66)+'s';   // v28.xx (cw-cx-condition-ui): short, computed condition summary
'@

SubRx @'
parts=[['COMBAT','KILLS',b.kill|0]
'@ @'
parts=[['COMBAT','KILLS ('+((c.k||0)|0)+')',b.kill|0]
'@

SubRx @'
tiles=[[kn,'KILLS'],[(x.acc|0)+'%','ACCURACY'],[T.containers|0,'CONTAINERS'],[fmtClock(x.sec|0),'TIME'],[ex?(x.hp|0):0,'HEALTH']];
'@ @'
tiles=[[(x.acc|0)+'%','ACCURACY'],[T.containers|0,'CONTAINERS'],[fmtClock(x.sec|0),'TIME'],[ex?(x.hp|0):0,'HEALTH']];   // v28.xx (cw-cx-condition-ui): kill count is on its combat row; four guide-sized stats
'@

SubRx @'
  if(ex&&strip){ h+='<div class="lgstrip" style="--i:'+idx+'">'+strip+'</div>'; idx++; }
'@ @'
  // v28.xx (cw-cx-condition-ui): name the secured item below its tile instead of leaving an unexplained icon.
  if(ex&&strip){
    var ik=G.bag&&G.bag[0], itemName=(ik&&ITEMS[ik])?ITEMS[ik].name:'secured loot';
    if(G.bag&&G.bag.length>1) itemName+=' +'+(G.bag.length-1);
    h+='<div class="lgstrip" style="--i:'+idx+'">'+strip+'<span class="lgitemlabel">'+escHtml(itemName)+'</span></div>'; idx++;
  }
'@

SubRx @'
  function put(s,x,y){ var tw=c.measureText(String(s)).width, tx=(c.textAlign==='right')?x-tw:((c.textAlign==='center')?x-tw/2:x), fh=parseInt((c.font.match(/(\d+)px/)||[0,16])[1],10), f0=c.fillStyle; c.fillStyle='rgba(11,12,13,.78)'; c.fillRect(tx-5,y-fh+2,tw+10,fh+5); c.fillStyle=f0; c.fillText(s,x,y); }
'@ @'
  // v28.xx (cw-cx-condition-ui): a narrow halo keeps map names readable without black label plates.
  function put(s,x,y){ var os=c.strokeStyle, ow=c.lineWidth; c.strokeStyle='#0b0c0d'; c.lineWidth=3; c.strokeText(s,x,y); c.fillText(s,x,y); c.strokeStyle=os; c.lineWidth=ow; }
'@

SubRx @'
c.font='600 18px '+FF; c.textAlign='right';
'@ @'
c.font='600 22px '+FF; c.textAlign='right';
'@

SubRx @'
var zw=Math.max(10,z.w*sc-6), fs=20,
'@ @'
var zw=Math.max(10,z.w*sc-6), fs=24,
'@

SubRx @'
while(fs>14&&c.measureText(nm).width>zw)
'@ @'
while(fs>20&&c.measureText(nm).width>zw)
'@

SubRx @'
c.font='600 18px '+FF; c.textAlign='center'; c.fillStyle='#47d8c6';
'@ @'
c.font='600 22px '+FF; c.textAlign='center'; c.fillStyle='#47d8c6';
'@

SubRx @'
      function hits(y,hh,hw){ var j,e2,rx,ry,r2,nx,ny; if(!EX) return false; for(j=0;j<EX.length;j++){ e2=EX[j]; if(!e2) continue; rx=ox+e2.x*sc; ry=oy+e2.y*sc; r2=R+2; nx=Math.max(cx-hw,Math.min(rx,cx+hw)); ny=Math.max(y-hh,Math.min(ry,y+hh)); if((nx-rx)*(nx-rx)+(ny-ry)*(ny-ry)<r2*r2) return true; } return false; }
'@ @'
      // v28.xx (cw-cx-condition-ui): cache room and label bounds once per name; candidate positions only compare rectangles.
      var labelObstacles=null;
      function hits(y,hh,hw){
        var j,e2,rx,ry,r2,nx,ny,O,ob,left,top,right,bottom;
        if(EX) for(j=0;j<EX.length;j++){ e2=EX[j]; if(!e2) continue; rx=ox+e2.x*sc; ry=oy+e2.y*sc; r2=R+2; nx=Math.max(cx-hw,Math.min(rx,cx+hw)); ny=Math.max(y-hh,Math.min(ry,y+hh)); if((nx-rx)*(nx-rx)+(ny-ry)*(ny-ry)<r2*r2) return true; }
        if(!labelObstacles){
          labelObstacles=[];O=(M.buildings||[]).concat(M.locked||[]);
          for(j=0;j<O.length;j++){ob=O[j];left=ox+ob.x*sc-8;top=oy+ob.y*sc-8;labelObstacles.push([left,top,left+ob.w*sc+16,top+ob.h*sc+16]);}
          O=M.locked||[];for(j=0;j<O.length;j++){ob=O[j];right=ox+ob.x*sc-8;left=right-c.measureText(TX(String(ob.name||''))).width-8;top=oy+(ob.y+ob.h/2)*sc-24;labelObstacles.push([left,top,right,top+36]);}
        }
        for(j=0;j<labelObstacles.length;j++){ob=labelObstacles[j];if(cx+hw>ob[0]&&cx-hw<ob[2]&&y+hh>ob[1]&&y-hh<ob[3])return true;}
        return false;
      }
'@

SubRx @'
cand=[cy], j, e2, ry, r2, k, y, best=null;
'@ @'
cand=[cy,top,bot,cy-hh*2-8,cy+hh*2+8], j, e2, ry, r2, k, y, best=null;
'@

SubRx @'
var VER='35.80';
'@ @'
var VER='35.81';
'@

$pat = "(?m)^  now:'v35\.80:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.81: Terms use 20px bonuses, 88px rows, a 32px aligned title and a visible check on signed conditions. Descriptions are short and call humans pillagers. Pre-raid pack space collapses when empty, condition labels grow to 18px, and selection uses one check with a separate focus ring. Map names grow and avoid rooms; the owner chosen blue map and its width remain. The career result uses one 56px SP hero, neutral money at 32px, four 16px-label stats, a named item tile and quiet medal outlines. Kill count moves into its score row. Feedback stays available as a text control. Watch: check the largest condition stacks at 1080p for scrolling or clipping; signed Terms, pad focus, score and money must stay easy to tell apart. Check 35.81 fails on v35.80',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
