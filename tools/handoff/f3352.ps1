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

if ($s.Contains("  {v:'33.52',what:")) { throw "check 33.52 is in the fixture already" }

SubRx @'
  {v:'33.51',what:
'@ @'
  {v:'33.52',what:'cw-pixlook (86a): all 145 racks resolve to a kept pixel pick, ten fixed looks resolve per the cut table, resolving writes nothing to the profile, and a profile with only The Machine owns the trooper',
   run:function(){
     if(typeof pixLook!=='function'||typeof pixOwned!=='function') return 'no pixel look map (pixLook, pixOwned)';
     var bad=[], H={short:1,long:1,hood:1}, S={fair:1,tan:1,umber:1}, C={scav:1,recon:1,heavy:1}, T={none:1,skeleton:1,trooper:1,android:1}, n=0, i, c, lk, r, k, s0, s1, s2, pk, had, oldKills, oldAll;
     function base(){ var o={}, q; for(q=0;q<NET_LOOK.length;q++) o[NET_LOOK[q]]=COSDEF[NET_LOOK[q]]; return o; }
     function want(tag,over,h,sk,cl,se){
       var l=base(), q, r2; for(q in over) l[q]=over[q]; r2=pixLook(l);
       if(r2.head!==h||r2.skin!==sk||r2.clothes!==cl||r2.set!==se) bad.push(tag+': got '+JSON.stringify(r2)+', wanted '+[h,sk,cl,se].join('/'));
     }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       s0=JSON.stringify(P);
       r=pixLook(base()); if(r.head!=='short'||r.skin!=='fair'||r.clothes!=='scav'||r.set!=='none') bad.push('the default look resolves to '+JSON.stringify(r));
       // every rack id, worn in its own slot over the default look, lands on a kept pick
       for(i=0;i<COSMETICS.length+COSSETS.length;i++){
         c=i<COSMETICS.length?COSMETICS[i]:COSSETS[i-COSMETICS.length]; n++; lk=base(); if(c.kind in lk) lk[c.kind]=c.id; r=pixLook(lk);
         if(!H[r.head]||!S[r.skin]||!C[r.clothes]||!T[r.set]) bad.push(c.id+' resolves to '+JSON.stringify(r));
       }
       if(n<145) bad.push('only '+n+' rack ids were walked, wanted 145 or more');
       want('skeleton',{outfit:'outskeleton'},'short','fair','scav','skeleton');
       want('the machine',{outfit:'outrobot'},'short','fair','scav','trooper');
       want('trooper',{outfit:'outtrooper'},'short','fair','scav','trooper');
       want('android',{outfit:'outandroid'},'short','fair','scav','android');
       want('explorer',{outfit:'outexplorer'},'long','fair','recon','none');
       want('poet',{outfit:'outpoet'},'hood','fair','heavy','none');
       want('baller',{outfit:'outballer'},'short','fair','scav','none');
       want('crown',{hat:'crown'},'hood','fair','scav','none');
       want('spartan',{hat:'spartan'},'hood','fair','scav','none');
       want('ghost mask',{hat:'ghostmask'},'hood','fair','scav','none');
       want('long cut',{cut:'bun'},'long','fair','scav','none');
       want('mohawk',{cut:'mohawk'},'short','fair','scav','none');
       want('ebony',{skin:'ebony'},'short','umber','scav','none');
       want('bronze',{skin:'bronze'},'short','tan','scav','none');
       want('drab',{scheme:'schdrab'},'short','fair','recon','none');
       want('indigo',{scheme:'schindigo'},'short','fair','heavy','none');
       want('nightshade',{scheme:'schnight'},'short','fair','heavy','none');
       want('rust',{scheme:'schrust'},'short','fair','scav','none');
       want('gilded',{scheme:'schgilded'},'short','fair','scav','none');
       want('an old fit',{scheme:undefined,fit:'moss'},'short','fair','recon','none');
       // resolving writes nothing
       k=0; for(i=0;i<COSMETICS.length;i++){ lk=base(); lk[COSMETICS[i].kind]=COSMETICS[i].id; pixLook(lk); k++; }
       pixLook(netLook()); pixOwned();
       s1=JSON.stringify(P); if(s1!==s0) bad.push('resolving changed the profile');
       saveProfile(); s2=JSON.stringify(P); if(s2!==s0) bad.push('after a save the profile differs from the one loaded');
       __loadProfile(); if(JSON.stringify(P)!==s0) bad.push('after a load the profile differs');
       // ownership: a set is owned by its own rule or by an old item that maps to it
       had=P.kills; oldAll=P.cosAll; delete P.cosAll;
       P.kills={warden:0}; P.runs=0; P.ext=0; P.xpLevel=1;
       if(pixOwned('trooper')||pixOwned('skeleton')||pixOwned('android')) bad.push('a fresh profile owns a set');
       if(!pixOwned('short')||!pixOwned('hood')||!pixOwned('tan')||!pixOwned('umber')||!pixOwned('heavy')||!pixOwned('recon')||!pixOwned('none')) bad.push('a head, a skin or a clothes pick is not always owned');
       P.kills={warden:3}; pk=pixOwned();
       if(!pixOwned('trooper')||!pk.set.trooper) bad.push('a profile with only The Machine does not own the trooper');
       if(pixOwned('skeleton')||pixOwned('android')) bad.push('The Machine also granted another set');
       P.kills={warden:0}; P.ext=12; if(!pixOwned('skeleton')||pixOwned('trooper')) bad.push('12 extractions do not own just the skeleton');
       P.ext=0; P.runs=30; if(!pixOwned('android')) bad.push('30 runs do not own the android');
       P.runs=0; P.xpLevel=8; if(!pixOwned('trooper')) bad.push('level 8 does not own the trooper');
       P.kills=had; if(oldAll!==undefined) P.cosAll=oldAll;
       return bad.length?bad.join('; '):null;
     } catch(err){
       return 'pixel look check: '+String(err&&err.message||err);
     } finally {
       __cleanProfile(); __topClear();
     } }},
  {v:'33.51',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
