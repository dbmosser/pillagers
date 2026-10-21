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

if ($s.Contains("  {v:'33.21',what:")) { throw "check 33.21 is in the fixture already" }

SubRx @'
  {v:'33.20',what:
'@ @'
  {v:'33.21',what:'all 28 experimental choices hold for the raid, the guest follows the host including glow and haul, and all-off keeps both seed-4242 map fingerprints (affix properties and barrel lists do not move them)',
   run:function(){
     if(typeof xfSnap!=='function'||typeof netUpStart!=='function'||typeof netUpFp!=='function') return 'experimental raid settings are missing';
     var bad=[], i, mi, value, g, fp, base=[], word, got, n, oldNeed=needItems, w=null, oldHtml='', made=false, oldRev=HAUL_REV;
     function down(){
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ netReset(); }catch(_n){}
       __topClear();
     }
     function prep(v){
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       for(var j=0;j<XF_KEYS.length;j++) CFG[XF_KEYS[j]]=v;
     }
     function probe(v,tag){
       var j, k;
       for(j=0;j<XF_KEYS.length;j++){
         k=XF_KEYS[j];
         if(XF[k]!==v||xf(k)!==!!v||xfL(k)!==!!v) bad.push(tag+': '+k+' did not hold '+v);
       }
       needItems=function(){ return {bandage:1}; };
       n=needRefresh();
       if(n!==(v?1:0)||g.needN!==(v?1:0)) bad.push(tag+': needed-item glow changed with live preferences');
       needItems=oldNeed;
       // The result card is drawn after the raid ends. Its choice still belongs to this raid.
       w=document.getElementById('oc_manifest'); made=!w;
       if(!w){ w=document.createElement('div'); w.id='oc_manifest'; document.body.appendChild(w); }
       oldHtml=w.innerHTML;
       w.innerHTML='<div class="haulstrip"><span class="haulit" data-r="common" data-v="10"></span><span class="haulit" data-r="common" data-v="20"></span></div>';
       g.over=true;
       try{ got=haulRevealStart(); if(got!==(v?2:0)||!!HAUL_REV!==!!v) bad.push(tag+': result haul used the next raid preference'); }
       finally{ g.over=false; HAUL_REV=null; w.innerHTML=oldHtml; if(made&&w.parentNode) w.parentNode.removeChild(w); w=null; }
     }
     try{
       down();
       if(XF_KEYS.length!==28) return 'expected the 28 surviving experimental switches, got '+XF_KEYS.length;
       // Both sectors, all on then all off. Compare complete fingerprints, not only population counts.
       for(value=1;value>=0;value--) for(mi=0;mi<2;mi++){
         prep(value);
         __deploy({kit:[],safe:null,mapIx:mi,seed:4242});
         g=__state();
         if(!g||g.over||!g.player) return 'cannot stage sector '+mi+' with switches '+value;
         fp=netUpFp(g);
         if(!fp||fp.e!==[85,374][mi]||fp.c!==[165,593][mi]) bad.push('sector '+mi+', switches '+value+': '+netUpFpText(fp));
         if(value===1) base[mi]=fp;
         else if(!netUpFpSame(base[mi],fp)) bad.push('all-off changes map building on sector '+mi+': '+netUpFpText(fp));
         // Build the actual host word before preferences change. The guest will take it with opposite preferences.
         if(mi===0) word={t:'raid',seed:4242,mapIx:0,cond:P.cond,wx:g.wx.id,iss:g.issDraw?1:0,terms:[],merc:'',cfg:netUpCfgDiff(),fp:fp};
         for(i=0;i<XF_KEYS.length;i++) CFG[XF_KEYS[i]]=1-value;
         probe(value,'solo '+value+' sector '+mi);
         down();
       }
       // The last host word was all off. Repeat with all on to cover an omitted (default-on) wire value too.
       for(value=0;value<=1;value++){
         if(value===1){
           prep(1); __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state();
           word={t:'raid',seed:4242,mapIx:0,cond:P.cond,wx:g.wx.id,iss:g.issDraw?1:0,terms:[],merc:'',cfg:netUpCfgDiff(),fp:netUpFp(g)};
           down();
         }
         prep(1-value); NET.on=true; NET.role='join'; NET.seat=1; NET.peers=[];
         got=netUpStart(word); g=__state();
         if(got!=='up'||!g||g.over) return 'guest could not take host word '+value+': '+got+' '+NET.err;
         for(i=0;i<XF_KEYS.length;i++) if(CFG[XF_KEYS[i]]!==1-value) bad.push('guest preference was overwritten: '+XF_KEYS[i]);
         probe(value,'guest '+value);
         down();
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       needItems=oldNeed; HAUL_REV=oldRev;
       if(w){ w.innerHTML=oldHtml; if(made&&w.parentNode) w.parentNode.removeChild(w); }
       down(); __resetCfg(); __cleanProfile(); xfSnap();
     }
     return bad.length?bad.join('; '):null;
   }},
  {v:'33.20',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
