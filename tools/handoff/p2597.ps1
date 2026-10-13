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

# MAGAZINE BAR, RESERVE NUMBER, G KEYCAP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    count:(A.mag===0?null:Aam),c:A.tint||'#ffd48a'}];
'@ @'
    count:(A.mag===0?null:Aam),c:A.tint||'#ffd48a',mag:A.mag}];   // v25.xx (belt6b): mag, for the bar
'@

SubRx @'
    count:(B.mag===0?null:Bam),c:B.tint||'#ffd48a'});
'@ @'
    count:(B.mag===0?null:Bam),c:B.tint||'#ffd48a',mag:B.mag});
'@

SubRx @'
count:(_eq.w.mag===0?null:_eq.am),c:_eq.w.tint||'#ffd48a',assigned:1,itemKey:akey,equipped:1,
'@ @'
count:(_eq.w.mag===0?null:_eq.am),c:_eq.w.tint||'#ffd48a',assigned:1,itemKey:akey,equipped:1,mag:_eq.w.mag,
'@

SubRx @'
:Math.ceil(_gsm/2); }
'@ @'
:Math.ceil(_gsm/2); out[aix].mag=_gsm; }
'@

SubRx @'
count:Math.ceil(_fpm/2),c:_fpi.c||'#cdd6dd',itemKey:_fpk,floorGun:1};
'@ @'
count:Math.ceil(_fpm/2),c:_fpi.c||'#cdd6dd',itemKey:_fpk,floorGun:1,mag:_fpm};
'@

SubRx @'
      if(S.count!==null&&S.count!==undefined&&S.kind!=='empty'){   // v19.01: no count on an empty key
'@ @'
      // v25.xx (belt6b), HIS ANSWER Q7 2026-10-13: "bar for magazine, number for reserve addtnl rounds". A gun key shows its magazine as a fill bar
      // along its foot (light above half, amber to a quarter, red below) and the rounds he carries in reserve as the number; the floor belt has no
      // reserve, so it shows the bar alone. A gun with no magazine (melee) keeps its old look. The half-grey states above are unchanged.
      var _gunReal=!!(S.kind==='gun'&&!S.vacant&&S.icon&&S.icon!=='fists'&&S.count!==null&&S.count!==undefined&&S.mag>0);
      if(state!=='hub'&&S.kind==='throw'&&S.icon&&S.icon===_gSel){   // the G keycap on the throwable key G throws
        var _gs=Math.round(bw*0.2), _gkx=bx+LH(4), _gky=hy+bw-LH(5)-_gs;
        ctx.fillStyle='#ffc04a'; ctx.beginPath(); if(ctx.roundRect) ctx.roundRect(_gkx,_gky,_gs,_gs,Math.max(2,_gs*0.2)); else ctx.rect(_gkx,_gky,_gs,_gs); ctx.fill();
        ctx.font=beltFS(bw,0.13); ctx.fillStyle='#1a1408'; ctx.textAlign='center'; ctx.fillText(String(keyLabel('KeyG','G')).slice(0,2),_gkx+_gs/2,_gky+_gs*0.76); ctx.textAlign='left';
      }
      if(_gunReal){
        var _mh=Math.max(3,Math.round(bw*0.05)), _mx=bx+LH(5), _mw=bw-LH(10), _my=hy+bw-LH(4)-_mh, _mf=clamp((S.count|0)/S.mag,0,1);
        ctx.fillStyle='rgba(255,255,255,.14)'; ctx.fillRect(_mx,_my,_mw,_mh);
        ctx.globalAlpha=_bgDim?.5:1;
        ctx.fillStyle=_mf>0.5?'#e6f0f6':(_mf>0.25?'#ffc04a':'#e0483a'); ctx.fillRect(_mx,_my,Math.round(_mw*_mf),_mh);
        ctx.globalAlpha=1;
        if(G.player&&!G.hubFloor){
          ctx.font=beltFS(bw,0.16); ctx.fillStyle=_bgDim?'#7a5040':(_bgHalf?'#ffc04a':'#FFF6DC');
          ctx.textAlign='right'; ctx.fillText(String(Math.max(0,G.player.reserve|0)),bx+bw-LH(4),_my-LH(3)); ctx.textAlign='left';
        }
      }
      else if(S.count!==null&&S.count!==undefined&&S.kind!=='empty'){   // v19.01: no count on an empty key
'@

SubRx @'
    var _gx=[0], _gp, _pp=LH(4), _gg, _gf, _gl, _gq2;
'@ @'
    var _gSel=null, _gTs=[], _gti;   // v25.xx (belt6b): the kind G throws: the kind U chose when a throwable key shows it, else the first throwable key
    for(_gti=GUNKEYS;_gti<sl.length;_gti++) if(BELT_CLASS[_gti]==='throw'&&sl[_gti]&&sl[_gti].kind==='throw'&&sl[_gti].icon&&(sl[_gti].count|0)>0) _gTs.push(sl[_gti].icon);
    if(_gTs.length) _gSel=(_gTs.indexOf(THROWKEYS[G.tsel])>=0)?THROWKEYS[G.tsel]:_gTs[0];
    var _gx=[0], _gp, _pp=LH(4), _gg, _gf, _gl, _gq2;
'@

SubRx @'
val:(v>0)?('$'+v.toLocaleString()):'', keys:[[String(keyLabel('Digit'+(c.i+1),String(c.i+1))),'SELECT'],['FIRE','USE']]};
'@ @'
val:(v>0)?('$'+v.toLocaleString()):'', keys:[[String(keyLabel('Digit'+(c.i+1),String(c.i+1))),'SELECT'],['FIRE','USE']]};
  if(!padOn()){   // v25.xx (belt6b): and the key of its class
    if(it.use==='throw') o.keys.push([String(keyLabel('KeyG','G')),'THROW']);
    else if(it.use==='heal') o.keys.push([String(keyLabel('KeyH','H')),'HEAL']);
    else if(it.use==='armor') o.keys.push(['HOLD '+String(keyLabel('KeyH','H')),'PLATE']);
  }
'@

SubRx @'
  return {w:Math.round(fp*18), h:pad*2+Math.round(hp*1.1)+rh*(1+o.rows.length+(o.val?1:0))+Math.round(rh*1.35)};
'@ @'
  return {w:Math.round(fp*(o.keys&&o.keys.length>2?23:18)), h:pad*2+Math.round(hp*1.1)+rh*(1+o.rows.length+(o.val?1:0))+Math.round(rh*1.35)};   // v25.xx (belt6b): wider with a third key
'@

SubRx @'
var VER='25.96';
'@ @'
var VER='25.97';
'@

$pat = "(?m)^  now:'v25\.96:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.97: Gun keys now show the magazine as a bar and the reserve as the number; the G key shows on the throwable it throws. Check 25.97 fails on v25.96',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
