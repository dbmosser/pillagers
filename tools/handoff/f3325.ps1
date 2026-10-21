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

if ($s.Contains("  {v:'33.25',what:")) { throw "check 33.25 is in the fixture already" }

SubRx @'
  {v:'33.24',what:
'@ @'
  {v:'33.25',what:'space-aware gunfire: a shot indoors gets a short room tail, a shot outside a later, longer crack-then-thump tail that comes later the farther it is, the woods none, riding the shot own muffled path',
   run:function(){
     if(typeof gunTailSpec!=='function'||typeof gunTailMake!=='function'||typeof sndGunTail!=='function') return 'there is no space-aware gunfire (no gunTailSpec)';
     var bad=[], i, r, v, o, n, near, far, OFF, k0=SND_TAIL_AT, src;
     r=gunTailSpec('inside',0); v=gunTailSpec('vault',0); o=gunTailSpec('open',0); near=gunTailSpec('open',200); far=gunTailSpec('open',1400);
     if(!r||r.k!=='room'||r.dur>0.3||r.delay>0.03) bad.push('indoors is not a short room tail');
     if(!v||v.dur<=r.dur) bad.push('a vault tail is not longer than a room');
     if(!o||o.k!=='thump'||o.dur<=r.dur*1.5) bad.push('outside is not a longer thump');
     if(!(far.delay>near.delay&&near.delay>=o.delay)) bad.push('the thump does not come later with distance');
     if(!(far.g<near.g)) bad.push('a far shot tail is not quieter');
     if(gunTailSpec('woods',100)!==null) bad.push('the woods still echo');
     if(gunTailSpec('undercroft',0).k!=='room') bad.push('the undercroft is not a room');
     for(i=0;i<3;i++){ n=[r,o,far][i]; if(n.g>0.05||n.dur>0.45||n.delay>0.4) bad.push('a tail is too loud or too long'); }
     if(typeof OfflineAudioContext==='function'){
       OFF=new OfflineAudioContext(1,22050,22050);
       try{ if(!gunTailMake(OFF,OFF.destination,0,1,r)||!gunTailMake(OFF,OFF.destination,0,1,o)) bad.push('a tail made no sound'); }catch(e){ bad.push('a tail threw '+e); }
     }
     SND_TAIL_AT=-9;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||!G.map||!G.player) return bad.length?bad.join('; '):'SKIP: no raid';
       if(sndGunTail(null,null,5,0.05,0,null)!==false) bad.push('a faint shot still makes a tail');
     } finally { SND_TAIL_AT=k0; try{ __endRaid('abandon'); }catch(_e){} __topClear(); }
     src=String((typeof _realBlip==='function')?_realBlip:blip);
     if(src.indexOf('sndGun'+'Tail(')<0||src.indexOf('sndGun'+'Tail(')>src.indexOf('SNDA_'+'GEN[type]('))  bad.push('blip does not add the tail on the shot path before the sound is made');
     return bad.length?bad.join('; '):null;
   }},
  {v:'33.24',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
