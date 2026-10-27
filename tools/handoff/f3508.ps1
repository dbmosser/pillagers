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

if ($s.Contains("  {v:'35.08',what:")) { throw "check 35.08 is in the fixture already" }

SubRx @'
  {v:'35.07',what:
'@ @'
  {v:'35.08',what:'cw-hotitems (his order of 10-27): a medkit dragged onto the key of the gun in hand stays there, the gun moves to a free key, and the key uses the medkit with the gun still in hand',
   run:function(){
     var bad=[];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       if(beltDropRefusal('frag',2)!=='') bad.push('a frag is refused on key 3');
       if(beltDropRefusal('medkit',0)!=='') bad.push('a medkit is refused on key 1');
       __deploy({kit:['gun_carbine','medkit','medkit','bandage','frag'],safe:null,mapIx:0,seed:4242});
       if(state!=='raid'||!G||G.over) throw new Error('no live raid to test on');
       G.mapFirst=0; G.mapOpen=false; if(pauseOpen) togglePauseBox(false); syncPause();
       var p=G.player, w0=p.wep&&p.wep.id, sl0=hotbarSlots(), k0=-1, k1=-1, i;
       for(i=0;i<sl0.length;i++) if(sl0[i]&&sl0[i].kind==='gun'&&sl0[i].inHand&&sl0[i].icon===w0){ k0=i; break; }
       if(k0<0) throw new Error('the gun in hand shows on no key before the drop');
       G.hotAssign=G.hotAssign||{}; G.hotAssign[k0]='medkit'; if(G.hotAuto) delete G.hotAuto[k0]; classKeysSettle();
       if(G.hotAssign[k0]!=='medkit') bad.push('the medkit on key '+slotKeyName(k0)+' was pruned');
       var sl=hotbarSlots();
       if(!sl[k0]||sl[k0].kind!=='heal') bad.push('key '+slotKeyName(k0)+' shows '+(sl[k0]&&sl[k0].kind));
       for(i=0;i<sl.length;i++) if(i!==k0&&sl[i]&&sl[i].kind==='gun'&&sl[i].inHand&&sl[i].icon===w0) k1=i;
       if(k1<0) bad.push('the gun in hand lost its key');
       var cnt=function(){ return G.bag.filter(function(k){ return k==='medkit'; }).length; }, n0=cnt();
       p.hp=Math.max(1,Math.round(p.maxhp*0.3));
       if(!beltInstant(k0)) bad.push('key '+slotKeyName(k0)+' did not use the medkit');
       if(cnt()>=n0&&!p.prep) bad.push('no medkit was spent');
       if((p.wep&&p.wep.id)!==w0) bad.push('the gun in hand changed');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(pauseOpen) togglePauseBox(false); }catch(_p){}
       try{ var K2=__keys(); for(var q2 in K2) delete K2[q2]; }catch(_k){}
       try{ if(state==='raid'&&G&&!G.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'35.07',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
