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

if ($s.Contains("  {v:'36.09',what:")) { throw "check 36.09 is in the fixture already" }

SubRx @'
  {v:'36.08',what:
'@ @'
  {v:'36.09',what:'overflowing feed details shorten before the name in both player windows; names shorten only when they cannot fit alone',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__forceSize&&window.__endRaid)) return 'SKIP: no raid staging';
     var bad=[], NK={}, k, g, oldRole=ARCADE.role, ri, si, f, R, z, pad, maxW, ln, pr, name='select a heal', sub;
     var sizes=[[1920,1080],[1600,900],[3840,2160]], roles=['host','join'];
     function line(segs,tag){ return {segs:segs,n:1,money:'',tag:tag||'',col:HUDC.text,mf:''}; }
     function audit(ln,width,label){
       var p=feedParts(ln,f,width), total=0, j;
       for(j=0;j<p.length;j++) total+=ctx.measureText(p[j].t).width;
       if(total>width+0.01||Math.abs(total-p.w)>0.01) bad.push(label+' exceeds its width or reports a wrong width');
       return p;
     }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile(); __pinDPR(1);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state();
       if(!g||!g.player||g.over) return 'SKIP: no live raid';
       for(k in NET) NK[k]=NET[k];
       for(si=0;si<sizes.length;si++) for(ri=0;ri<roles.length;ri++){
         __forceSize(sizes[si][0],sizes[si][1]); NET.role=roles[ri]; NET.seat=ri; ARCADE.role=ri?'p2':'host';
         f=feedFont(); ctx.font=f; R=feedRect(); z=Math.max(1,hudRes()); pad=Math.round(LH(7)*z);
         maxW=R.w-pad*3-Math.round(R.fp*0.95)-Math.round(pad*0.7);
         sub='  \u00b7  bandage, medkit or armour plate.';
         while(ctx.measureText(name+sub).width<=maxW) sub+=' bandage';
         ln=line([{t:name},{t:sub}]); pr=audit(ln,maxW,roles[ri]+' sub');
         if(!pr[0]||pr[0].t!==name) bad.push(roles[ri]+' cut the name before its detail');
         if(pr.length!==2||!/\.\.\.$/.test(pr[1].t)||pr[1].t===sub) bad.push(roles[ri]+' detail did not end with a cut mark');
         if(feedParts(ln,f,maxW)!==pr) bad.push('unchanged measurement was not cached');
         pr=audit(ln,ctx.measureText(name+sub).width+1,'widened');
         if(pr[0].t!==name||pr[1].t!==sub) bad.push('wider zone did not restore the original detail');
         ln=line([{t:name}],sub); pr=audit(ln,maxW,'tag');
         if(pr[0].t!==name||pr.length!==2||!/\.\.\.$/.test(pr[1].t)) bad.push('tag shortened the name or lost its cut mark');
         ln=line([{t:name},{t:sub}],sub); ln.n=3; ln.money='+50 sp'; pr=audit(ln,maxW,'many pieces');
         if(pr[0].t!==name||!/\.\.\.$/.test(pr[pr.length-1].t)) bad.push('many pieces did not preserve the name and mark the detail');
         ln=line([{t:name},{t:sub}]); pr=audit(ln,ctx.measureText(name).width,'name exactly fits');
         if(pr.length!==1||pr[0].t!==name) bad.push('name that fits alone was cut');
         ln=line([{t:name+sub}]); pr=audit(ln,ctx.measureText(name).width,'name too long');
         if(pr.length!==1||!/\.\.\.$/.test(pr[0].t)) bad.push('oversized name was not shortened with a mark');
         ln=line([{t:'bandage'},{t:'  x2'}]); pr=audit(ln,maxW,'short');
         if(pr.length!==2||pr[0].t!=='bandage'||pr[1].t!=='  x2') bad.push('short row changed');
       }
     }finally{
       for(k in NK) NET[k]=NK[k]; ARCADE.role=oldRole;
       try{ __endRaid('abandon'); }catch(_e){} __topClear(); __runPrep();
     }
     return bad.length?bad.slice(0,8).join('; '):null;
   }},
  {v:'36.08',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
