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

if ($s.Contains("  {v:'30.81',what:")) { throw "check 30.81 is in the fixture already" }

SubRx @'
  {v:'30.80',what:
'@ @'
  {v:'30.81',what:'cw-nomult, his order (2026-10-18) i do not like the multiplier next to the reticule: a live chain draws its ring at the cursor and no number or plate beside it, with the TEAM ring up too',
   run:function(){
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object'||typeof styleDraw!=='function') return 'SKIP: no arcade here';
     var bad=[], g=null, p, own=false, rs=say, oSolo, proto, oFt, oArc, oFill, oRect, st, i;
     function grab(){
       var o={t:[],a:[],f:0};
       proto.fillText=function(){ o.t.push(String(arguments[0])); return oFt.apply(this,arguments); };
       proto.arc=function(){ o.a.push([arguments[0],arguments[1],arguments[2]]); return oArc.apply(this,arguments); };
       proto.fill=function(){ o.f++; return oFill.apply(this,arguments); };
       proto.fillRect=function(){ o.f++; return oRect.apply(this,arguments); };
       try{ styleDraw(ctx,p,640,360); } finally { proto.fillText=oFt; proto.arc=oArc; proto.fill=oFill; proto.fillRect=oRect; }
       return o;
     }
     function ring(o){ var n=0; for(var k=0;k<o.a.length;k++) if(Math.abs(o.a[k][0]-640)<0.5&&Math.abs(o.a[k][1]-360)<0.5&&o.a[k][2]>4) n++; return n; }
     function num(o){ for(var k=0;k<o.t.length;k++) if(/^x\d/.test(o.t[k])) return o.t[k]; return ''; }
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; keys={}; say=function(){}; own=true; ARCADE.holdT=0; oSolo=ARCADE.solo; ARCADE.solo=0;
       proto=CanvasRenderingContext2D.prototype; oFt=proto.fillText; oArc=proto.arc; oFill=proto.fill; oRect=proto.fillRect;
       var cases=[['a chain of 3',3,1,null],['a chain of 5 that just grew',5,0.05,null],['a chain of 3 with the TEAM ring up',3,1,{n:2,at:Date.now()-200}]];
       for(i=0;i<cases.length;i++){
         ARCADE.streak={n:cases[i][1],t:g.t-cases[i][2]}; ARCADE.team=cases[i][3];
         st=grab();
         if(num(st)) bad.push(cases[i][0]+': the multiplier '+num(st)+' is still drawn beside the ring');
         if(st.f) bad.push(cases[i][0]+': a plate is still filled beside the ring ('+st.f+' fills)');
         if(ring(st)<3) bad.push(cases[i][0]+': the ring at the cursor drew '+ring(st)+' arcs, not its underlay, track and sweep');
       }
       ARCADE.streak=null; ARCADE.team=null; st=grab();
       if(ring(st)) bad.push('with no chain a ring is still drawn ('+ring(st)+' arcs)');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(own) say=rs;
       try{ if(proto&&oFt){ proto.fillText=oFt; proto.arc=oArc; proto.fill=oFill; proto.fillRect=oRect; } }catch(_p){}
       keys={};
       try{ if(typeof ARCADE==='object'){ ARCADE.solo=oSolo; ARCADE.team=null; ARCADE.streak=null; if(ARCADE.on) arcadeLeave(); } }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.waveT=0; ARCADE.holdT=0; } }catch(_h){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'30.80',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
