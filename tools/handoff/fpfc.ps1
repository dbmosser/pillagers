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

if ($s.Contains("  {v:'30.26',what:")) { throw "check 30.26 is in the fixture already" }

SubRx @'
  {v:'30.25',what:
'@ @'
  {v:'30.26',what:'each pillager role is worn gear drawn on the body (rush pauldrons, flank scarf, supp bandolier, mark hood, shield plate): nothing floats over the head, every piece touches the body, and it moves with the crouch',
   run:function(){
     if(typeof drawRoleMark!=='function'||typeof drawOp!=='function'||typeof PROLE==='undefined') return 'SKIP: no role gear here';
     var keepOut=P.cosOutfit, bad=[], kw=wc, SC=360, roles=['rush','flank','supp','mark','shield'], fi, ri, faces=[0,Math.PI];
     function mk(){ return {hero:0,build:'lean',pack:'packbrown',boots:'bootblack',hair:'dark',cut:'crop',skin:'fair',fit:'slate',eyes:'eyebrown',hat:'none',scheme:'schember'}; }
     function paint(fn){
       var cv2=document.createElement('canvas'), x2;
       cv2.width=SC; cv2.height=SC; x2=cv2.getContext('2d'); wc=x2;
       try{ x2.translate(180,280); x2.scale(4,4); fn(); } finally { wc=kw; }
       return x2.getImageData(0,0,SC,SC).data;
     }
     function topRow(d){ var i, n=SC*SC; for(i=0;i<n;i++) if(d[i*4+3]>100) return Math.floor(i/SC); return -1; }
     function count(d){ var i, n=0; for(i=3;i<d.length;i+=4) if(d[i]>100) n++; return n; }
     function accent(d,hex){ var r=parseInt(hex.slice(1,3),16), g=parseInt(hex.slice(3,5),16), b=parseInt(hex.slice(5,7),16), i, n=0; for(i=0;i<d.length;i+=4) if(d[i+3]>200&&Math.abs(d[i]-r)<=12&&Math.abs(d[i+1]-g)<=12&&Math.abs(d[i+2]-b)<=12) n++; return n; }
     function floating(gear,body){
       var seen=new Uint8Array(SC*SC), st=[], i, j, comp, touch, x, y, dx, dy, nx, ny, bad2=0;
       for(i=0;i<SC*SC;i++){
         if(seen[i]||gear[i*4+3]<=100) continue;
         comp=0; touch=false; st.length=0; st.push(i); seen[i]=1;
         while(st.length){
           j=st.pop(); comp++; x=j%SC; y=(j-x)/SC;
           if(!touch){ for(dy=-3;dy<=3&&!touch;dy++) for(dx=-3;dx<=3;dx++){ nx=x+dx; ny=y+dy; if(nx>=0&&ny>=0&&nx<SC&&ny<SC&&body[(ny*SC+nx)*4+3]>200){ touch=true; break; } } }
           if(x>0&&!seen[j-1]&&gear[(j-1)*4+3]>100){ seen[j-1]=1; st.push(j-1); }
           if(x<SC-1&&!seen[j+1]&&gear[(j+1)*4+3]>100){ seen[j+1]=1; st.push(j+1); }
           if(y>0&&!seen[j-SC]&&gear[(j-SC)*4+3]>100){ seen[j-SC]=1; st.push(j-SC); }
           if(y<SC-1&&!seen[j+SC]&&gear[(j+SC)*4+3]>100){ seen[j+SC]=1; st.push(j+SC); }
         }
         if(comp>=20&&!touch) bad2++;
       }
       return bad2;
     }
     try{
       P.cosOutfit='outnone';
       for(fi=0;fi<faces.length;fi++){
         var fc=faces[fi];
         var body=paint(function(){ drawOp(0,0,fc,0,'#242832',0,0,'none',0,mk()); });
         for(ri=0;ri<roles.length;ri++){
           var role=roles[ri], tag=role+(fi?' facing left':'');
           var mkE=function(pin){ return {kind:'raider',prole:role,x:0,y:0,face:fc,hp:50,maxhp:50,state:'loot',step:0,moving:false,build:'lean',pinT:pin?1:0}; };
           var gear=paint(function(){ drawRoleMark(mkE(false)); });
           var low=paint(function(){ drawRoleMark(mkE(true)); });
           var n=count(gear), top=topRow(gear), top2=topRow(low), nAcc=accent(gear,PROLE[role].c), fl=floating(gear,body);
           if(n<400) bad.push(tag+' gear is only '+n+' pixels (want 400 or more)');
           if(nAcc<120) bad.push(tag+' shows only '+nAcc+' pixels in its role colour (want 120 or more)');
           if(top>=0&&top<108) bad.push(tag+' rises to '+((280-top)/4).toFixed(1)+' above his feet, over the head (limit 43)');
           if(fl>0) bad.push(tag+' has '+fl+' piece(s) floating clear of the body');
           if(top2-top<16) bad.push(tag+' does not sink with a crouch (moved '+((top2-top)/4).toFixed(1)+', want 4 or more)');
         }
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ wc=kw; if(keepOut===undefined) delete P.cosOutfit; else P.cosOutfit=keepOut; }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'30.25',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
