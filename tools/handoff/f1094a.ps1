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

# ==== HIS NOTE 15: weird eye collisions on Undercroft faces, in SOME instances.
# ==== "Some instances" cannot be answered by looking at the crowd, because the
# ==== crowd is eight people out of tens of thousands of possible looks. It has
# ==== to be answered by enumeration, and enumeration needs one face at a time,
# ==== large, in a known place. This draws exactly that.
SubRx @'
// v10.83: open the map screen, draw it, and hand back the projection so a check
'@ @'
// v10.94: ONE operator, alone, on a flat ground, drawn as large as asked, so a
// check can enumerate looks instead of hunting for a face in a moving crowd.
// Takes the look fields drawOp reads and hands back where it was drawn.
window.__opShot=function(look,face,zoom){
  if(!wc||!(W>0)) return null;
  var z=zoom||9, cx=Math.round(W/2), cy=Math.round(H*0.78);
  wc.setTransform(DPR,0,0,DPR,0,0);
  wc.fillStyle='#101418'; wc.fillRect(0,0,W,H);
  wc.save(); wc.translate(cx,cy); wc.scale(z,z);
  var st={hero:0,moving:false,sprint:false,ads:false,hurt:0,rl:0};
  if(look) for(var k in look) st[k]=look[k];
  var thrown=null;
  try{ drawOp(0,0,face===undefined?0:face,0,'#242832',0,0,'none',0,st); }
  catch(e){ thrown=String(e&&e.message||e); }
  wc.restore();
  return {cx:cx,cy:cy,z:z,thrown:thrown};
};
// The look rolls the Undercroft crowd actually uses, so a check enumerates the
// real population rather than one it invented.
window.__crowdLook=function(){ return hubRollLook(); };
window.__cosOf=function(kind){
  var out=[];
  if(typeof COSMETICS==='undefined') return out;
  for(var i=0;i<COSMETICS.length;i++) if(COSMETICS[i].kind===kind) out.push(COSMETICS[i].id);
  return out;
};
// v10.83: open the map screen, draw it, and hand back the projection so a check
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
