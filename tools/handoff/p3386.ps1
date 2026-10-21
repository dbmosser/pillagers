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

# PIXEL PROPS FINISH (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
pixWrap('cd:'+CT.k,CT.k==='deer'?48:20,CT.k==='deer'?26:14,PIX_ENV,cdP
'@ @'
pixWrap('cd:'+CT.k,CT.k==='deer'?48:20,CT.k==='deer'?26:14,PIX_ACT,cdP
'@

SubRx @'
pixWrap('bd:'+(CT.st==='flee'?'f'+flap:'g'+pk)+(fl>0?'r':'l'),24,24,PIX_ENV,bdP
'@ @'
pixWrap('bd:'+(CT.st==='flee'?'f'+flap:'g'+pk)+(fl>0?'r':'l'),24,24,PIX_ACT,bdP
'@

SubRx @'
pixWrap('dr:'+(run?'r':'g')+gait+':'+(run?0:hbob)+(fl>0?'r':'l')+(CT.ant?'a':''),72,56,PIX_ENV,drP
'@ @'
pixWrap('dr:'+(run?'r':'g')+gait+':'+(run?0:hbob)+(fl>0?'r':'l')+(CT.ant?'a':''),72,56,PIX_ACT,drP
'@

SubRx @'
var flap=CT.st==='flee'?Math.round(Math.sin(CT.f)*2)*2.5:0,
'@ @'
var flap=CT.st==='flee'?(pixOn()?Math.round(Math.sin(CT.f)*2)*2.5:Math.sin(CT.f)*5):0,
'@

SubRx @'
var run=CT.st==='flee',gait=Math.round(Math.sin(CT.f)*(run?5:1.2)), hbob=Math.round(Math.sin(CT.f*0.8)*2);
'@ @'
// v28.xx (cw-cx-propsfinish): wildlife shares PIX_ACT with pillagers; only the pixel look quantizes its painted poses. Simulation stays unchanged.
        var run=CT.st==='flee',gait=pixOn()?Math.round(Math.sin(CT.f)*(run?5:1.2)):Math.sin(CT.f)*(run?5:1.2), hbob=pixOn()?Math.round(Math.sin(CT.f*0.8)*2):Math.sin(CT.f*0.8)*2;
'@

SubRx @'
    wc.fillStyle='#2b2f36'; wc.fillRect(_st2.x-7,_st2.y-26,14,28);
    wc.fillStyle='#9aa8b2'; wc.fillRect(_st2.x-5,_st2.y-24,10,3);
    wc.fillStyle='#ffc04a'; wc.fillRect(_st2.x-3,_st2.y-18,6,2);
'@ @'
    // v28.xx (cw-cx-propsfinish): the story desk is a cached scene body; its world shadow stays live.
    var stP=function(){
      wc.fillStyle='#2b2f36'; wc.fillRect(_st2.x-7,_st2.y-26,14,28);
      wc.fillStyle='#9aa8b2'; wc.fillRect(_st2.x-5,_st2.y-24,10,3);
      wc.fillStyle='#ffc04a'; wc.fillRect(_st2.x-3,_st2.y-18,6,2);
    };
    if(!(pixOn()&&pixWrap('story',24,36,PIX_ENV,stP,_st2.x,_st2.y,{up:30}))) stP();
'@

SubRx @'
      wc.textAlign='center'; wc.font=FS(TYPE.label);
      var _stw=wc.measureText('MERIDIAN STRONGBOX').width, _spx=wlPx();
      if(!wlUnder(ct.x-_stw/2,ct.y-lift-d2-26-_spx,_stw,_spx*1.3)){   // v31.xx (cw-trcol2): not over the corner column or the score plate
      wc.fillStyle=INK; wc.fillText('MERIDIAN STRONGBOX',ct.x+1,ct.y-lift-d2-25);
      wc.fillStyle='#ffc04a'; wc.fillText('MERIDIAN STRONGBOX',ct.x,ct.y-lift-d2-26);
      }
      wc.textAlign='left';
'@ @'
      // v28.xx (cw-cx-propsfinish): the strongbox name joins the existing GFXWT hand-off, above walls and fog.
      if(CACHETAGS.length<48) CACHETAGS.push({t:'meridian strongbox',x:ct.x,y:ct.y-lift-d2-26,f:TYPE.label,c:'#ffc04a'});
'@

SubRx @'
    if(!(pixOn()&&pixWrap('seal:'+(SW.done?'done':Math.round(pctQ*20)),64,72,PIX_ENV,swP,swx,swy,{up:54}))) swP();
    wc.textAlign='center'; wc.font=FS(TYPE.label);
    wc.fillStyle=INK; wc.fillText(SW.done?'SEAL BROKEN':('THE SEAL  '+Math.round(pctW*100)+'%'),swx+1,swy-59);
    wc.fillStyle=SW.done?'#ffc04a':'#8fd0ff';
    wc.fillText(SW.done?'SEAL BROKEN':('THE SEAL  '+Math.round(pctW*100)+'%'),swx,swy-60);
    wc.textAlign='left';
'@ @'
    if(!(pixOn()&&pixWrap('seal:'+(SW.done?'done':Math.round(pctQ*20)),64,72,PIX_ENV,swP,swx,swy,{up:54}))) swP();
    // v28.xx (cw-cx-propsfinish): the exact percentage stays live on the HUD canvas; only the slab fill is cached in steps.
    if(CACHETAGS.length<48) CACHETAGS.push({t:SW.done?'seal broken':('the seal  '+Math.round(pctW*100)+'%'),x:swx,y:swy-60,f:TYPE.label,c:SW.done?'#ffc04a':'#8fd0ff',always:1});
'@

SubRx @'
    wc.textAlign='center'; wc.font=FS(TYPE.label);
    var _ftw=wc.measureText(F.name||'THE FORGE').width, _fpx=wlPx();
    if(!G.nearForge&&!wlUnder(fx-_ftw/2,fy-84-_fpx,_ftw,_fpx*1.3)){   // v28.xx (cw-cx-forgefinish): the nearby prompt owns the station name.
    wc.fillStyle=INK; wc.fillText(F.name||'THE FORGE',fx+1,fy-83);
    wc.fillStyle=FORGE_GOLD; wc.fillText(F.name||'THE FORGE',fx,fy-84);
    }
    wc.textAlign='left';
'@ @'
    // v28.xx (cw-cx-propsfinish): the nearby prompt owns the forge name; otherwise GFXWT draws it sharply above the furnace.
    if(!G.nearForge&&CACHETAGS.length<48) CACHETAGS.push({t:F.name||'the forge',x:fx,y:fy-84,f:TYPE.label,c:FORGE_GOLD});
'@

SubRx @'
    for(var _cq=0;_cq<_ctq.length;_cq++){ var _cg=_ctq[_cq], _cw=wc.measureText(_cg.t).width; if(wlUnder(_cg.x-_cw/2,_cg.y-_cpx,_cw,_cpx*1.3)) continue; wc.fillStyle=INK; wc.fillText(_cg.t,_cg.x+1,_cg.y+1); wc.fillStyle='#e6b4ff'; wc.fillText(_cg.t,_cg.x,_cg.y); }   // v31.xx (cw-trcol2): not over the corner column or the score plate
'@ @'
    // v28.xx (cw-cx-propsfinish): cache and landmark names share the existing world-text queue and its HUD transform.
    for(var _cq=0;_cq<_ctq.length;_cq++){ var _cg=_ctq[_cq]; wc.font=FS(_cg.f||TYPE.head); var _cw=wc.measureText(_cg.t).width; if(!_cg.always&&wlUnder(_cg.x-_cw/2,_cg.y-_cpx,_cw,_cpx*1.3)) continue; wc.fillStyle=INK; wc.fillText(_cg.t,_cg.x+1,_cg.y+1); wc.fillStyle=_cg.c||'#e6b4ff'; wc.fillText(_cg.t,_cg.x,_cg.y); }
'@

SubRx @'
var VER='33.85';
'@ @'
var VER='33.86';
'@

$pat = "(?m)^  now:'v33\.85:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.86: Wildlife and the story desk use the pixel adapter. Strongbox, seal and forge labels stay sharp above the world. Check 33.86 fails on v33.85',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
