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

# THE SURVIVOR (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  outpeddler: {coat:'#7a5a3a',trs:'#3a3026',boots:['#2a2018','#3a2c20'],skin:null,hands:'#6a4a2e',cut:'crop',hair:'dark',hat:'none',beard:'stubble',mark:'peddler',cloth:1,norig:1}
};
'@ @'
  outpeddler: {coat:'#7a5a3a',trs:'#3a3026',boots:['#2a2018','#3a2c20'],skin:null,hands:'#6a4a2e',cut:'crop',hair:'dark',hat:'none',beard:'stubble',mark:'peddler',cloth:1,norig:1},
  // v23.xx (spr21): the Survivor's own clothes, never sold: a washed out civilian jacket, no rig, no pack (nopack), no gun.
  outsurvivor:{coat:'#8a8578',trs:'#56534a',boots:['#3a342c','#4a4238'],skin:null,hands:null,cut:'crop',hair:'dark',hat:'none',beard:'stubble',mark:'survivor',cloth:1,norig:1,nopack:1}
};
'@

SubRx @'
  wc.fillStyle=INK; rrF(x-fl*9-pw/2+leanX-1,ty-22,pw+2,11,3);
  wc.fillStyle=PACKCOL[st.hero?cosWorn('pack'):(st.pack||'packbrown')]||PACKCOL.packbrown;   // v10.34
  rrF(x-fl*9-pw/2+leanX,ty-21,pw,9,2);
'@ @'
  if(!(OUTF&&OUTF.nopack)){   // v23.xx (spr21): the Survivor has no pack
  wc.fillStyle=INK; rrF(x-fl*9-pw/2+leanX-1,ty-22,pw+2,11,3);
  wc.fillStyle=PACKCOL[st.hero?cosWorn('pack'):(st.pack||'packbrown')]||PACKCOL.packbrown;   // v10.34
  rrF(x-fl*9-pw/2+leanX,ty-21,pw,9,2);
  }
'@

SubRx @'
    } else if(_om==='poet'){
'@ @'
    } else if(_om==='survivor'){
      // v23.xx (spr21): THE SURVIVOR. A torn civilian jacket (notches in the hem, a darker patch), a bandage round the head with a
      // spot of blood, and when you are near and he has not been helped, one arm raised with the open hand: unarmed, asking.
      var _sT=OUTF.trs||darkHex(cc,.5), _n;
      wc.fillStyle=_sT;
      for(_n=0;_n<3;_n++){ var _nx=_ox-3.6+_n*3.2; wc.beginPath(); wc.moveTo(_nx,ty-10.9); wc.lineTo(_nx+1.6,ty-10.9); wc.lineTo(_nx+0.8,ty-12.6); wc.closePath(); wc.fill(); }
      wc.fillStyle=darkHex(cc,.22); wc.fillRect(_ox+1.0,ty-19.6,3.0,2.8);
      wc.fillStyle=litHex(cc,.30); wc.fillRect(_ox+1.4,ty-19.2,0.6,0.6); wc.fillRect(_ox+3.0,ty-17.4,0.6,0.6);
      wc.fillStyle=darkHex(cc,.40); wc.beginPath(); wc.moveTo(_ox-2.6,ty-22); wc.lineTo(_ox+2.6,ty-22); wc.lineTo(_ox,ty-18.6); wc.closePath(); wc.fill();
      wc.fillStyle=INK; wc.fillRect(hx2-8.1,ty-36.8,16.2,3.0);
      wc.fillStyle='#ece6d8'; wc.fillRect(hx2-7.6,ty-36.4,15.2,2.2);
      wc.fillStyle='#d8d0c0'; wc.beginPath(); wc.moveTo(hx2-4.2,ty-38.0); wc.lineTo(hx2-1.4,ty-38.0); wc.lineTo(hx2+5.6,ty-34.6); wc.lineTo(hx2+3.4,ty-34.2); wc.closePath(); wc.fill();
      wc.fillStyle='#9a2a20'; wc.fillRect(hx2+3.0,ty-36.2,1.6,1.3);
      if(st.wave){
        var _wv=Math.sin(((typeof G!=='undefined'&&G&&G.t)||0)*6.5)*1.3, _sx=_ox-fl*6.6, _hx=_ox-fl*10.0+_wv, _hy=ty-33.6;
        wc.lineCap='round';
        wc.strokeStyle=INK; wc.lineWidth=4.6; wc.beginPath(); wc.moveTo(_sx,ty-20.4); wc.lineTo(_hx,_hy+3.0); wc.stroke();
        wc.strokeStyle=cc; wc.lineWidth=3.0; wc.beginPath(); wc.moveTo(_sx,ty-20.4); wc.lineTo(_hx,_hy+3.0); wc.stroke();
        wc.lineCap='butt';
        var _hc=handColour(st);
        wc.fillStyle=INK; rrF(_hx-2.6,_hy-2.8,5.2,5.6,1.8);
        wc.fillStyle=_hc; rrF(_hx-2.0,_hy-2.2,4.0,4.4,1.4);
        wc.fillRect(_hx-1.9,_hy-4.0,0.9,2.2); wc.fillRect(_hx-0.6,_hy-4.4,0.9,2.4); wc.fillRect(_hx+0.7,_hy-4.0,0.9,2.2); wc.fillRect(_hx+fl*2.2-0.4,_hy-1.4,0.9,1.8);
      }
    } else if(_om==='poet'){
'@

SubRx @'
        drawOp(e2.x,e2.y,e2.face,0,e2.coat,0,0,'crouchnone',0,
          {moving:false,sprint:false,ads:false,hurt:e2.hitT,bulk:0});
'@ @'
        // v23.xx (spr21), HIS ORDER (2026-10-12) "make them all look better": the Survivor was a pillager in green with a faint halo;
        // without the halo (helped, or at night) he read as hostile. He wears his own civilian clothes now (outsurvivor: no rig, no
        // pack, no gun, a head bandage), raises an open hand when you come near while he still needs help, and stands up once helped.
        var _swv=(!e2.helped&&G&&G.player&&!G.player.dead&&Math.hypot(G.player.x-e2.x,G.player.y-e2.y)<110)?1:0;
        drawOp(e2.x,e2.y,e2.face,0,e2.coat,0,0,e2.helped?'none':'crouchnone',0,
          {moving:false,sprint:false,ads:false,hurt:e2.hitT,bulk:0,outfit:'outsurvivor',wave:_swv});
'@

SubRx @'
var VER='24.32';
'@ @'
var VER='24.33';
'@

$pat = "(?m)^  now:'v24\.32:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.33: The Survivor looks like a wounded civilian now, raises a hand when you come near, and stands once helped. Check 24.33 fails on v24.32',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
