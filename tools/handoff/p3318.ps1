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

# A DAILY RAID ROW ON THE PRE-RAID PAGE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var pendSeed=null;

'@ @'
var pendSeed=null;
// v32.xx (cw-seedday), planner job 63, his round 3 answer 2.98 (seed of the day: before launch): THE DAILY RAID. One opt-in row on the pre-raid page; when it is on, the next
// career raid is built on a seed taken from today's date (UTC, so everyone gets the same raid that day, no server). No reward, no streak, no login prize (his 10-12
// no daily login rewards stands): just a best haul of its own in the profile (P.dailyRec, new fields, same storage key). Normal raids, the demo and the party seed never
// come here: the flag is armed only on that page, spent by the first raid that starts, and ignored in the demo and in a linked party.
var DAILY={on:0};
function dailyKey(t){ var d=new Date(t===undefined?Date.now():t), m=d.getUTCMonth()+1, n=d.getUTCDate(); return d.getUTCFullYear()+'-'+(m<10?'0':'')+m+'-'+(n<10?'0':'')+n; }
function dailySeedOf(k){ var h=2166136261, s='pillagers-daily-'+k, i; for(i=0;i<s.length;i++){ h^=s.charCodeAt(i); h=Math.imul(h,16777619)>>>0; } return h||1; }
function dailyArm(){
  if(!DAILY.on) return '';
  DAILY.on=0;
  if(typeof ARCADE==='object'&&ARCADE&&ARCADE.on) return '';
  if(typeof NET==='object'&&NET&&NET.on) return '';
  if(pendSeed!==null) return '';
  var k=dailyKey(); pendSeed=dailySeedOf(k); return k;
}
function dailyRecord(k,v){
  var r=P.dailyRec;
  if(!r||typeof r!=='object') r=P.dailyRec={d:'',t:0,b:0};
  if(r.d!==k){ r.d=k; r.t=0; }
  v=Math.max(0,(+v)|0);
  if(v>(r.t|0)) r.t=v;
  if(v>(r.b|0)) r.b=v;
  return r;
}

'@

SubRx @'
  G=buildRaid(false);

'@ @'
  var _dyk=''; try{ _dyk=dailyArm(); }catch(_dya){}   // v32.xx (cw-seedday): the daily raid takes today's seed
  G=buildRaid(false);
  if(G&&_dyk) G.daily=_dyk;

'@

SubRx @'
    if(_netHaul>P.best) P.best=_netHaul;

'@ @'
    if(_netHaul>P.best) P.best=_netHaul;
    if(G.daily){ try{ dailyRecord(G.daily,_netHaul); }catch(_dyr){} }   // v32.xx (cw-seedday): the daily raid keeps its own best haul

'@

SubRx @'
          <span id="condhint" style="display:none;font-size:14px"></span>

'@ @'
          <span id="condhint" style="display:none;font-size:14px"></span>
          <div class="srcap">SEED</div>
          <div class="srstack"><button class="srchip" id="conddaily" data-pan="c"><i class="srrd"></i>DAILY RAID<em id="srdl"></em></button></div>

'@

SubRx @'
  try{ syncSectorWx(); }catch(_sw2){}

'@ @'
  try{ syncSectorWx(); }catch(_sw2){}
  try{ syncSectorDaily(); }catch(_sdy){}

'@

SubRx @'
document.getElementById('closesector').onclick=function(){
  document.getElementById('sectormodal').classList.remove('on');
};

'@ @'
// v32.xx (cw-seedday): the daily raid row on the pre-raid page. It is a plain switch: on means the next ascent from this page is today's raid. Off in a linked party (the host's seed rules there).
function syncSectorDaily(){
  var b=document.getElementById('conddaily'), em=document.getElementById('srdl'), r=P.dailyRec, k=dailyKey(), off=false;
  if(!b) return;
  try{ off=srGuest()||!!(typeof NET==='object'&&NET&&NET.on); }catch(_dg){}
  if(off) DAILY.on=0;
  b.classList.toggle('on',!!DAILY.on); b.disabled=off;
  if(em) em.textContent=(r&&r.b>0)?('best $'+(r.b|0).toLocaleString()):k.slice(5);
}
document.getElementById('conddaily').onclick=function(){
  if(this.disabled) return;
  DAILY.on=DAILY.on?0:1; syncSectorDaily();
};
document.getElementById('closesector').onclick=function(){
  document.getElementById('sectormodal').classList.remove('on');
  DAILY.on=0;
};

'@

SubRx @'
var VER='33.17';
'@ @'
var VER='33.18';
'@

$pat = "(?m)^  now:'v33\.17:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.18: A DAILY RAID row sits under the surface and weather rows on the pre-raid page. Switch it on and the next ascent is today raid, the same for everyone. Its best haul shows on the row. Check 33.18 fails on v33.17',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
