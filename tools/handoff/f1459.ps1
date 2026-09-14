$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  {v:'14.58',what:
'@ @'
  {v:'14.59',what:'up and down reach every backpack stack: with six stacks and twelve columns, six presses of down visit all six stacks and so do six presses of up (backpack audit finding 4)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof raidKey!=='function'||typeof bagStacks!=='function') return 'SKIP: no backpack browsing in this build';
     var bad=[], g0=null, six=[];
     for(var k in ITEMS){ if(six.length>=6) break; var I=ITEMS[k]; if(!I||I.use==='gun'||k.indexOf('gun_')===0) continue; six.push(k); }
     if(six.length<6) return 'SKIP: fewer than six plain items to stack';
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g&&g.player; if(!g||!p) return 'SKIP: no live raid';
       g0=g; p.iv=99;
       g.bag=six.slice(); g.hotAssign={}; g.bagOpen=true; g.bagCols=12; g.bagSel=0;
       if(bagStacks().length!==6) return 'SKIP: six distinct items made '+bagStacks().length+' stacks here';
       // CONTROL: right steps one stack.
       raidKey('ArrowRight',false,null);
       if(g.bagSel!==1) return 'SKIP: ArrowRight did not step to the next stack here ('+g.bagSel+')';
       var walk=function(code){ g.bagSel=0; var seen={0:1}; for(var i=0;i<6;i++){ raidKey(code,false,null); seen[g.bagSel]=1; } return Object.keys(seen).length; };
       var down=walk('ArrowDown'), up=walk('ArrowUp');
       if(down<6) bad.push('six presses of down over six stacks and twelve columns visited '+down+' stack'+(down>1?'s':'')+', so a controller cannot reach the rest');
       if(up<6) bad.push('six presses of up visited '+up+' stack'+(up>1?'s':''));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(g0){ g0.bagOpen=false; g0.bag=[]; g0.bagSel=0; if(g0.player) g0.player.iv=0; if(!g0.over) __endRaid('abandon'); } }catch(_e){}
       try{ var K3=__keysRef(); for(var k3 in K3) K3[k3]=false; }catch(_k){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'14.58',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
