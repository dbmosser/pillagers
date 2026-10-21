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

# PIXEL KIND GUARD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function pixDropAll(){
'@ @'
// v28.xx (cw-cx-pixguard): "I want to do it all now before the party" (10-20). Three throwing attempts keep that kind in vector for this raid; the owner alone controls pixel look.
var PIXGUARD={raid:null,kinds:Object.create(null),active:'',serial:0};
function pixGuardKind(key){
  if(PIXGUARD.active) return PIXGUARD.active;
  var s=String(key||'sprite'), p=s.split('|');
  if(p[0]==='mach') return 'machine:'+p[1];
  if(/^(u|l|r|g|f|k|e|top|setmelee)$/.test(p[0])) return 'pillager';
  if(p[0]==='pwr') return 'power-up:'+p[1];
  if(s.indexOf('bx:')===0) return 'container:'+s.slice(3).replace(/[oc]$/,'');
  if(s.indexOf('wr:')===0) return 'wreck:'+s.slice(3).replace(/[v01oc]+$/,'');
  return s.split(/[|:]/)[0];
}
function pixGuardState(key){
  var g=(typeof G!=='undefined'&&G&&!G.over)?G:null, k=pixGuardKind(key);
  if(PIXGUARD.raid!==g){ PIXGUARD.raid=g; PIXGUARD.kinds=Object.create(null); }
  return PIXGUARD.kinds[k]||(PIXGUARD.kinds[k]={kind:k,n:0,line:0});
}
function pixGuardBlocked(key){ return pixGuardState(key).n>=3; }
function pixGuardFail(key,err){
  var s=pixGuardState(key), g=PIXGUARD.raid, msg=String(err&&err.message||err||'bake failed').slice(0,160);
  s.n++; PIXGUARD.serial++; PIX.errs++;
  if(g&&!g.drawErr){ g.drawErr='pixel '+s.kind+': '+msg; if(g.tel)g.tel.drawErr=g.drawErr; }
  if(s.n===3&&!s.line){
    s.line=1;
    if(g&&g.tel){ if(!g.tel.pixGuard)g.tel.pixGuard=[]; g.tel.pixGuard.push({kind:s.kind,t:Math.round(g.t||0),txt:'vector for this raid'}); }
  }
}
function pixDropAll(){
'@

SubRx @'
  var m=PIXSTORE.m[kind], e=m.get(key);
'@ @'
  if(pixGuardBlocked(key)) return null; // v28.xx (cw-cx-pixguard): a cached pose cannot bypass the raid guard
  var m=PIXSTORE.m[kind], e=m.get(key);
'@

SubRx @'
  var t0, e, dt;
  if(PIX.fB>=PIXSTORE.maxBuilds
'@ @'
  var t0, e, dt;
  if(pixGuardBlocked(key)) return null; // v28.xx (cw-cx-pixguard)
  if(PIX.fB>=PIXSTORE.maxBuilds
'@

SubRx @'
  try{ e=fn(); }catch(_pb){ PIX.errs++; return null; }
'@ @'
  try{ e=fn(); }catch(_pb){ PIX.fB++; PIX.fMs+=pixNow()-t0; pixGuardFail(key,_pb); return null; } // v28.xx (cw-cx-pixguard): failed work spends the same frame budget
'@

SubRx @'
  var e=pixGet(kind,key)||pixBuild(kind,key,fn,fam,pose)||pixNearest(kind,fam,pose);
'@ @'
  // v28.xx (cw-cx-pixguard): a throw draws this body in vector, even when a nearby pose exists.
  if(pixGuardBlocked(key)) return null;
  var serial=PIXGUARD.serial, e=pixGet(kind,key)||pixBuild(kind,key,fn,fam,pose);
  if(PIXGUARD.serial!==serial) return null;
  if(!e) e=pixNearest(kind,fam,pose);
'@

SubRx @'
  }catch(_pw){ PIX.errs++; return null; }
'@ @'
  }catch(_pw){ pixGuardFail(key,_pw); return null; } // v28.xx (cw-cx-pixguard)
'@

SubRx @'
  try{ return pixDrawOp(x,y,face,ph,coat,pk,muzzle,mode,iv,st); }
  catch(e){
    PIX.errs++; PIX.fall++;
'@ @'
  // v28.xx (cw-cx-pixguard): all component bakes share one pillager guard, restored after nested painters.
  var active=PIXGUARD.active, serial=PIXGUARD.serial, a=wc.globalAlpha, op=wc.globalCompositeOperation;
  PIXGUARD.active='pillager';
  if(pixGuardBlocked('pillager')){ PIXGUARD.active=active; return false; }
  try{ var ok=pixDrawOp(x,y,face,ph,coat,pk,muzzle,mode,iv,st); return PIXGUARD.serial===serial&&ok; }
  catch(e){
    pixGuardFail('pillager',e); PIX.fall++;
'@

SubRx @'
    if(typeof G!=='undefined'&&G&&!G.drawErr){ G.drawErr='pixel pillager: '+(e&&e.message||e); if(G.tel) G.tel.drawErr=G.drawErr; }
    return false;
  }
}
'@ @'
    return false;
  } finally { PIXGUARD.active=active; wc.globalAlpha=a; wc.globalCompositeOperation=op; }
}
'@

SubRx @'
    drawErr:T.drawErr||null,
'@ @'
    drawErr:T.drawErr||null,
    pixGuard:(T.pixGuard||[]).slice(), // v28.xx (cw-cx-pixguard): one entry per kind after the third throw
'@

SubRx @'
    if(r.drawErr) line+=' DRAWERR:'+r.drawErr;
'@ @'
    if(r.drawErr) line+=' DRAWERR:'+r.drawErr;
    if(r.pixGuard) r.pixGuard.forEach(function(q){ line+=' PIXGUARD:'+q.kind+' vector for this raid'; }); // v28.xx (cw-cx-pixguard)
'@

SubRx @'
var VER='33.92';
'@ @'
var VER='33.93';
'@

$pat = "(?m)^  now:'v33\.92:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.93: Throwing pixel kinds use their vector art for the rest of that raid, with one recorder entry. Check 33.93 fails on v33.92',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
