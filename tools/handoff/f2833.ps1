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

if ($s.Contains("  {v:'28.33',what:")) { throw "check 28.33 is in the fixture already" }

SubRx @'
  {v:'28.32',what:
'@ @'
  {v:'28.33',what:'his order 2026-10-15 (one score name): the running score tile of a CAREER raid reads RAID SCORE, the name the run card ledger and the leaderboard use, not CAREER SCORE',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof drawHUD!=='function'||typeof KEYS_ACTS==='undefined'||typeof keysBind!=='function') return 'SKIP: this fixture cannot stage the raid status';
     var bad=[], g=null, p=null, km0=null, kmv0, car0, cs0, bag0, i, hit=0, old=0, amt=0, L;
     function inL(){ return (typeof RSTAT==='object'&&RSTAT&&RSTAT.lines)||[]; }
     function kev(type,code,key,alt){ var e=new KeyboardEvent(type,{code:code,key:key||code,altKey:!!alt,bubbles:true,cancelable:true}); window.dispatchEvent(e); return e; }
     function clr(){ for(var z in keys) keys[z]=false; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0);
       km0=P.keymap?JSON.parse(JSON.stringify(P.keymap)):null; kmv0=P.keymapV;
       P.keymap={}; KEYS.inv=null; keysInv();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g&&g.player; if(!g||g.over||!p) return 'SKIP: no live raid';
       if(g.arcade) return 'SKIP: an arcade raid has its own score tile';
       g.paused=false; g.trade=null; g.bagOpen=false; g.mapOpen=false; p.downed=false; p.dying=false; p.iv=99; clr();
       car0=g.career; cs0=g.cs; bag0=g.bag.slice();
       g.career=true; g.cs={s:1234};
       kev('keydown','AltLeft','Alt',true);
       drawHUD();
       L=inL();
       for(i=0;i<L.length;i++){ if(/^RAID SCORE$/.test(L[i])) hit++; if(/^CAREER SCORE$/.test(L[i])) old++; if(/^\$1,234$/.test(L[i])) amt++; }
       if(!hit) bad.push('the career score tile does not read RAID SCORE ('+L.slice(0,8).join(' | ')+')');
       if(old) bad.push('the career score tile still reads CAREER SCORE');
       if(!amt) bad.push('the tile does not carry the score $1,234');
       kev('keyup','AltLeft','Alt',false);
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ if(g){ g.career=car0; g.cs=cs0; g.bagOpen=false; if(bag0) g.bag=bag0; } }catch(_g){}
       try{ if(km0) P.keymap=km0; else P.keymap={}; P.keymapV=kmv0; KEYS.inv=null; keysInv(); keysLegendApply(); }catch(_k){}
       try{ clr(); }catch(_c){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'28.32',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
