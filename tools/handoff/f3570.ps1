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

if ($s.Contains("  {v:'35.70',what:")) { throw "check 35.70 is in the fixture already" }

SubRx @'
  {v:'35.69',what:
'@ @'
  {v:'35.70',what:'cw-dmulfix, from the pictures of v35.69: the demo run over card shows its settings x line as a heading line under extracted x2 (it sat in a player row, which the restyled card hides), and the Settings score value stands centred in the value column as the other values do',
   run:function(){
     if(!(window.__runPrep&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile)) return 'SKIP: this fixture cannot stage';
     if(typeof diffMul!=='function'||typeof dmulRowHtml!=='function'||typeof arcadeOverSync!=='function'||typeof openSettings!=='function') return 'SKIP: no score multiplier display here';
     var bad=[], d0=DMUL_ON, K=['superhot','nRaider','eDmg'], sv={}, i, el, b, r1, r2, aOn=ARCADE.on, aOv=ARCADE.over, aSo=ARCADE.solo, c, ln=null, kids, m;
     for(i=0;i<K.length;i++) sv[K[i]]=CFG[K[i]];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       DMUL_ON=1; CFG.superhot=0; CFG.nRaider=15; CFG.eDmg=1.4;
       // ONE: Settings, the value in the value column
       openSettings(); m=document.getElementById('settingsmodal');
       el=document.getElementById('set_dmul'); b=document.getElementById('go_superhot')||document.getElementById('go_raiders');
       if(!el||!b) bad.push('staging: no score value or no value button ('+!!el+', '+!!b+')');
       else {
         r1=el.getBoundingClientRect(); r2=b.getBoundingClientRect();
         if(!(r2.width>0)) bad.push('staging: the Settings list has no layout');
         else { if(Math.abs((r1.left+r1.width/2)-(r2.left+r2.width/2))>4) bad.push('the score value is centred at '+Math.round(r1.left+r1.width/2)+', the value column at '+Math.round(r2.left+r2.width/2)); if(Math.abs(r1.width-r2.width)>4) bad.push('the score value box is '+Math.round(r1.width)+' px wide, a value button '+Math.round(r2.width)); }
       }
       try{ if(m) m.classList.remove('on'); }catch(_m){}
       // TWO: the demo run over card, a heading line that shows
       ARCADE.on=1; ARCADE.solo=1; ARCADE.over={at:Date.now(),why:'extract',team:2000,p1:{s:2000,k:3,x:1,d:0},p2:null,dm:1.22};
       try{ arcadeOverSync(); }catch(e3){ bad.push('arcadeOverSync threw '+e3.message); }
       c=document.querySelector('#attract .arcover');
       if(!c) bad.push('staging: no run over card');
       else {
         kids=c.children;
         for(i=0;i<kids.length;i++) if(/^settings x1\.22$/i.test(String(kids[i].textContent).trim())) ln=kids[i];
         if(!ln) bad.push('the demo run over card has no settings x1.22 line');
         else {
           if(getComputedStyle(ln).display==='none') bad.push('the settings line on the demo run over card is hidden');
           if(!ln.classList.contains('aoh')||!(ln.previousElementSibling&&/extracted/i.test(ln.previousElementSibling.textContent))) bad.push('the settings line does not stand under extracted x2');
         }
       }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       DMUL_ON=d0; ARCADE.over=aOv; ARCADE.solo=aSo; ARCADE.on=aOn;
       try{ arcadeOverSync(); }catch(_s){} try{ var _c=document.querySelector('#attract .arcover'); if(_c) _c.style.display='none'; }catch(_c2){}
       try{ var _m=document.getElementById('settingsmodal'); if(_m) _m.classList.remove('on'); }catch(_m2){}
       for(i=0;i<K.length;i++) CFG[K[i]]=sv[K[i]];
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'35.69',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
