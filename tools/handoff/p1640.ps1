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

# END OF RAID PARTY SUMMARY (his pick, co-op list item 6).

SubRx @'
  <div class="manifest" id="oc_manifest"></div>
'@ @'
  <div class="manifest" id="oc_manifest"></div>
  <div class="manifest" id="oc_party" style="display:none;margin-top:12px"></div>
'@

SubRx @'
  document.getElementById('outcome').classList.add('on');
'@ @'
  if(NET.on&&!G.sim){ try{ netSumSend(how,(how==='extract')?haul:0); }catch(_ns){} }   // v16.40: the party summary
  document.getElementById('outcome').classList.add('on');
'@

SubRx @'
  NET.up=[]; NET.upAcc=0; NET.upN=0; NET.upSeed=m.seed; NET.upFp=m.fp;
'@ @'
  NET.up=[]; NET.upAcc=0; NET.upN=0; NET.upSeed=m.seed; NET.upFp=m.fp; NET.sum={};
'@

SubRx @'
  NET.up=[]; NET.upAcc=0; NET.upN=0; NET.upSeed=seed; NET.upFp=fp;
'@ @'
  NET.up=[]; NET.upAcc=0; NET.upN=0; NET.upSeed=seed; NET.upFp=fp; NET.sum={};
'@

SubRx @'
  if(m.t==='kitask'||m.t==='kitok') return netKitTake(peer,m);   // v16.37: every player chooses a kit
'@ @'
  if(m.t==='kitask'||m.t==='kitok') return netKitTake(peer,m);   // v16.37: every player chooses a kit
  if(m.t==='sum') return netSumTake(peer,m);   // v16.40: a teammate's raid result, for the party summary
'@

SubRx @'
var NET_KIT_WAIT=15;
'@ @'
var NET_KIT_WAIT=15;
// v16.40, HIS PICK (co-op list item 6): AN END OF RAID PARTY SUMMARY. Each window, as its raid ends, tells the party how it ended,
// its kills and what it brought out (nothing on a death or an abandon, which come back empty). The run card lists every player:
// EXTRACTED, KILLED, ABANDONED or STILL UP TOP, with kills and haul, and fills in as the others finish.
function netSumTake(peer,m){
  var s, e, i;
  if(!peer||peer.state!=='in') return 'ignored';
  if(NET.role==='host') s=peer.seat;
  else if(NET.role==='join'){ s=(m.s===undefined)?0:m.s; if(typeof s!=='number'||s!==(s|0)) return 'bad'; }
  else return 'off';
  if(s<0||s>=NET.max||s===NET.seat) return 'ignored';
  e={how:netClean(m.how,12),k:Math.max(0,m.k|0),v:Math.max(0,Math.round(+m.v||0))};
  if(!NET.sum) NET.sum={};
  NET.sum[s]=e;
  if(NET.role==='host') for(i=0;i<NET.peers.length;i++) if(NET.peers[i]!==peer&&NET.peers[i].state==='in') netSend(NET.peers[i],{t:'sum',s:s,how:e.how,k:e.k,v:e.v});
  netSumDraw();
  return 'sum';
}
function netSumSend(how,v){
  var k=0, q, K=(G&&G.tel&&G.tel.kills)||null, e;
  if(!NET.on) return false;
  if(K) for(q in K) if(Object.prototype.hasOwnProperty.call(K,q)) k+=(K[q]|0);
  e={how:netClean(how,12),k:k,v:Math.max(0,Math.round(v||0))};
  if(!NET.sum) NET.sum={};
  NET.sum[NET.seat]=e;
  netBroadcast({t:'sum',how:e.how,k:e.k,v:e.v});
  netSumDraw();
  return true;
}
function netSumDraw(){
  var el=document.getElementById('oc_party'), r=NET.roster||[], h='', i, e, st, c;
  if(!el) return false;
  if(!NET.on||r.length<2||!NET.sum){ el.style.display='none'; el.innerHTML=''; return false; }
  h='<div style="font-size:10.5px;color:var(--ash);letter-spacing:.2em;margin-bottom:4px">YOUR PARTY</div>';
  for(i=0;i<r.length;i++){
    e=NET.sum[r[i].seat];
    if(!e){ st='STILL UP TOP'; c='var(--amber)'; }
    else if(e.how==='extract'){ st='EXTRACTED'; c='var(--bone)'; }
    else if(e.how==='dead'){ st='KILLED'; c='var(--rust)'; }
    else { st='ABANDONED'; c='var(--ash)'; }
    h+='<div style="display:flex;gap:14px;justify-content:center;font-size:13px">'+
       '<span style="width:150px;text-align:right">'+escHtml(r[i].seat===NET.seat?'YOU':r[i].name)+'</span>'+
       '<span style="width:110px;color:'+c+'">'+st+'</span>'+
       '<span style="width:80px">'+(e?(e.k+(e.k===1?' kill':' kills')):'')+'</span>'+
       '<span style="width:90px;text-align:right">'+(e?(e.v.toLocaleString()+'c'):'')+'</span></div>';
  }
  el.innerHTML=h; el.style.display='';
  return true;
}
'@

SubRx @'
var VER='16.39';
'@ @'
var VER='16.40';
'@

$pat = "(?m)^  now:'v16\.39:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.40: END OF RAID PARTY SUMMARY. His pick from the co-op list (item 6). Each window, as its raid ends, tells the party how it ended, its kills and what it brought out (nothing on a death or an abandon). The run card lists every player as EXTRACTED, KILLED, ABANDONED or STILL UP TOP with kills and haul, and fills in as the others finish. Check 16.40 fails on v16.39',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
