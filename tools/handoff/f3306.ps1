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

if ($s.Contains("  {v:'33.06',what:")) { throw "check 33.06 is in the fixture already" }

SubRx @'
  {v:'33.05',what:
'@ @'
  {v:'33.06',what:'the experimental page switches the party seed: on, a party record locks the seed, the sector and a code and the operator card names the seed; off, none of them and the card says no seed',
   run:function(){
     if(typeof arcadePartySeed!=='function'||typeof arcadePartyCode!=='function'||typeof arcadeOpOpen!=='function'||typeof arcadeOpPick!=='function'||typeof xfSnap!=='function') return 'SKIP: no party seed here';
     var bad=[], was=ARCADE.on, old=null, i, b, n1, n2;
     function setK(key,v){ CFG[key]=v; xfSnap(); }
     try{
       old=localStorage.getItem(ARCADE_PARTY_KEY);
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       SETSUB='exp'; renderSettings();
       b=document.getElementById('go_xfSeed'); if(!b) bad.push('ONE: no row for xfSeed'); else if(String(b.textContent).toLowerCase()!=='on'||CFG.xfSeed!==1) bad.push('ONE: xfSeed does not start on');
       SETSUB=''; renderSettings();
       localStorage.setItem(ARCADE_PARTY_KEY,JSON.stringify({t:Date.now(),s:123456789,m:0}));
       setK('xfSeed',1);
       if(arcadePartySeed()!==123456789||!arcadePartyCode()||arcadePartyMap()!==0) bad.push('SEED on: the party record did not lock a seed, a code and a sector');
       setK('xfSeed',0);
       if(arcadePartySeed()!==0||arcadePartyCode()!==''||arcadePartyMap()!==-1) bad.push('SEED off: the party record still locked a seed, a code or a sector');
       // the operator card notes: armed, then cleared
       [1,0].forEach(function(v){
         setK('xfSeed',v); ARCADE.on=true;
         if(!arcadeOpOpen()){ bad.push('SEED: the operator card did not open'); return; }
         arcadeOpPick(0); n1=String(ARCOP.note||'').toLowerCase();
         arcadeOpPick(0); n2=String(ARCOP.note||'').toLowerCase();
         try{ arcadeOpClose(); }catch(_c){}
         if(v===1&&(n1.indexOf('new seed')<0||n2.indexOf('seed ')<0)) bad.push('SEED on: the operator notes do not name the seed ('+n1+' / '+n2+')');
         if(v===0&&(n1.indexOf('seed')>=0||n2.indexOf('seed')>=0)) bad.push('SEED off: the operator notes still name a seed ('+n1+' / '+n2+')');
         if(v===0&&n2.indexOf('board cleared')<0) bad.push('SEED off: the cleared note is missing ('+n2+')');
       });
     } catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ arcadeOpClose(); }catch(_c2){}
       ARCADE.on=was; SETSUB='';
       try{ if(P.gameOpts) delete P.gameOpts.xfSeed; }catch(_d){}
       try{ if(old===null) localStorage.removeItem(ARCADE_PARTY_KEY); else localStorage.setItem(ARCADE_PARTY_KEY,old); }catch(_r){}
       __topClear(); __resetCfg(); xfSnap(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'33.05',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
