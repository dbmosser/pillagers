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

# DEATH RECAP ON THE KIA AND EXTRACTED CARDS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
                       hp:Math.max(0,Math.round(left))});
'@ @'
                       hp:Math.max(0,Math.round(left)),k:src,w:recapWeapon(src,srcName)});   // v23.xx (feat3a): what hit you, and with what (cosmetic: live play only, below the sim guard)
'@

SubRx @'
var DEATH_FEED_HTML='';
'@ @'
// v23.xx (feat3a), HIS #29 and his answer 33 (2026-10-12): "death recap", and "should be at the KIA/extracted screen". THE RECAP.
// Each hit in the run log (G.tel.hitLog, live play only) now carries what hit you (k) and what with (w): a pillager by the gun he is
// carrying, a machine by its weapon, your own charge, the storm. deathRecap reads the log: the killer and his weapon (the last hit),
// the last hits grouped, and the damage by source, largest first. The KILLED IN ACTION card says KILLED BY <WHO>  WITH <WHAT>, and the
// KIA and EXTRACTED cards both list DAMAGE TAKEN: the four sources that took the most, with the damage and the number of hits.
var RECAP_WEP={crawler:'CLAWS',sentry:'AUTOCANNON',howler:'SHELLS',warden:'HEAVY CANNON',bulwark:'SHIELD GUN',choir:'PILLBOX',listener:'PULSE',
               yourself:'YOUR OWN CHARGE',lightning:'THE STORM'};
function recapWeapon(src,name){
  var i, e, E=(G&&G.ents)||[];
  if(name) for(i=0;i<E.length;i++){ e=E[i]; if(e&&e.kind===src&&e.name===name&&e.wep&&e.wep.name) return String(e.wep.name).toUpperCase(); }
  if(name&&(/CHARGE$/).test(String(name))&&src!=='yourself') return 'FRAG CHARGE';
  return RECAP_WEP[src]||'';
}
function deathRecap(T){
  var L=(T&&T.hitLog)||[], by={}, arr=[], g=[], i, e, gp, last=L.length?L[L.length-1]:null;
  for(i=0;i<L.length;i++){
    e=L[i];
    if(!by[e.n]){ by[e.n]={n:e.n,w:'',a:0,c:0}; arr.push(by[e.n]); }
    by[e.n].a+=e.a; by[e.n].c++; if(e.w) by[e.n].w=e.w;
    gp=g[g.length-1];
    if(gp&&gp.n===e.n){ gp.a+=e.a; gp.c++; gp.hp=e.hp; } else g.push({t:e.t,n:e.n,w:e.w||'',a:e.a,hp:e.hp,c:1});
  }
  arr.sort(function(a,b){ return b.a-a.a; });
  return {killer:last?last.n:'',weapon:last?(last.w||''):'',hits:g.slice(-6),bySrc:arr};
}
function recapHtml(T){
  var R=deathRecap(T), Lr=R.bySrc.slice(0,4), h, i, e;
  if(!Lr.length) return '';
  h='<div style="margin-top:12px;border-top:1px solid var(--steel-hi);padding-top:9px">'+
    '<div style="font-size:12.5px;letter-spacing:.2em;color:var(--ash);margin-bottom:6px">DAMAGE TAKEN</div>';
  for(i=0;i<Lr.length;i++){
    e=Lr[i];
    h+='<div style="display:flex;gap:10px;font-size:11.5px;padding:2px 0;color:var(--ash)">'+
       '<span style="flex:1">'+escHtml(String(e.n).toUpperCase())+(e.w?('<span style="opacity:.65">   \u00b7   '+escHtml(e.w)+'</span>'):'')+'</span>'+
       '<span style="width:52px;text-align:right;color:var(--hazard)">-'+e.a+'</span>'+
       '<span style="width:70px;text-align:right;opacity:.8">'+e.c+(e.c>1?' HITS':' HIT')+'</span></div>';
  }
  return h+'</div>';
}
var DEATH_FEED_HTML='';
'@

SubRx @'
    s.textContent='KILLED BY '+kn+(T.deathDistExtract?',  '+metres(T.deathDistExtract)+'M FROM EXTRACTION':'');
'@ @'
    var _rcW=(T.deathKiller!=='timer'&&T.hitLog&&T.hitLog.length&&T.hitLog[T.hitLog.length-1].n===kn)?(T.hitLog[T.hitLog.length-1].w||''):'';   // v23.xx (feat3a)
    s.textContent='KILLED BY '+kn+(_rcW?('   \u00b7   WITH '+_rcW):'')+(T.deathDistExtract?',  '+metres(T.deathDistExtract)+'M FROM EXTRACTION':'');
'@

SubRx @'
      DEATH_FEED_HTML=h;
    })();
'@ @'
      DEATH_FEED_HTML=h;
    })();
    DEATH_FEED_HTML=(DEATH_FEED_HTML||'')+recapHtml(T);   // v23.xx (feat3a): DAMAGE TAKEN
'@

SubRx @'
    s.textContent=(_fcE===null||_fcE===undefined)?'OUT CLEAN   \u00b7   NEVER SPOTTED':'';
'@ @'
    s.textContent=(_fcE===null||_fcE===undefined)?'OUT CLEAN   \u00b7   NEVER SPOTTED':'';
    DEATH_FEED_HTML=recapHtml(T);   // v23.xx (feat3a): DAMAGE TAKEN, when anything hit you
'@

SubRx @'
var VER='23.86';
'@ @'
var VER='23.87';
'@

$pat = "(?m)^  now:'v23\.86:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.87: The KIA card now says what killed you and with what, and both end cards list the damage you took by source. Check 23.87 fails on v23.86',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
