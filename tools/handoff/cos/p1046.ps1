$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# ============ HIS NOTE, 2026-09-03 about 14:10, and the Reach research: the
# ============ Haunted helmet cost one credit and needed every other helmet
# ============ owned. A capstone, the piece that says the rack is finished.
#
# A gate that reads the rack itself: rack:<kind> is earned when every other
# piece of that kind is owned. The first capstone is Platinum on the hair
# rack, the pale metal that only shows up on a finished rack. The next-piece
# line counts it in pieces still to collect.

SubRx @'
  {id:'violet', name:'Violet',         how:'level:3',     kind:'hair'},
'@ @'
  {id:'violet', name:'Violet',         how:'level:3',     kind:'hair'},
  {id:'platinum', name:'Platinum',     how:'rack:hair',   kind:'hair'},   // v10.46: the capstone, every other hair first
'@

SubRx @'
             violet:['#4b2f63','#6d4790','#9b6fc4']};
'@ @'
             violet:['#4b2f63','#6d4790','#9b6fc4'],
             platinum:['#a9a49a','#cfcabf','#f1eee6']};   // v10.46
'@

SubRx @'
  if(k==='streak')   return (P.bestStreak||0)>=v;
  return false;
}
'@ @'
  if(k==='streak')   return (P.bestStreak||0)>=v;
  if(k==='rack')     return cosRackComplete(bits[1],c.id);   // v10.46: the capstone
  return false;
}
// v10.46: a rack is complete when every piece of that kind that is not itself a
// capstone is owned. Capstones do not gate each other.
function cosRackComplete(kind,self){
  for(var i=0;i<COSMETICS.length;i++){
    var c=COSMETICS[i];
    if(c.kind!==kind||c.id===self||String(c.how).indexOf('rack:')===0) continue;
    if(!cosOwned(c)) return false;
  }
  return true;
}
'@

SubRx @'
  if(k==='streak')   return v+' extractions in a row';
  return '';
}
'@ @'
  if(k==='streak')   return v+' extractions in a row';
  if(k==='rack')     return 'every other piece on this rack';   // v10.46
  return '';
}
'@

SubRx @'
  if(k==='streak')   return {k:k,cur:P.extStreak||0,need:v,unit:'extraction in a row'};
  return null;
}
'@ @'
  if(k==='streak')   return {k:k,cur:P.extStreak||0,need:v,unit:'extraction in a row'};
  if(k==='rack'){   // v10.46: pieces of the rack still to collect
    var tot=0,have=0;
    for(var i=0;i<COSMETICS.length;i++){ var o=COSMETICS[i]; if(o.kind!==bits[1]||o.id===c.id||String(o.how).indexOf('rack:')===0) continue; tot++; if(cosOwned(o)) have++; }
    return {k:k,cur:have,need:tot,unit:'piece'};
  }
  return null;
}
'@

SubRx @'
  if(d.k==='level') what='LEVEL '+d.need+' ('+left+' TO GO)';
  else if(d.k==='board') what=left+' MORE BOARD REWARD'+(left===1?'':'S');
'@ @'
  if(d.k==='level') what='LEVEL '+d.need+' ('+left+' TO GO)';
  else if(d.k==='board') what=left+' MORE BOARD REWARD'+(left===1?'':'S');
  else if(d.k==='rack') what=left+' MORE PIECE'+(left===1?'':'S')+' ON ITS RACK';   // v10.46
'@

SubRx @'
var VER='10.45';
'@ @'
var VER='10.46';
'@
SubRx @'
  now:'v10.45: three gates that read how you play: kills, extractions in the dark, extractions in a row. Three patches hang on them: Night Owl, Headhunter, Unbroken.',
'@ @'
  now:'v10.46: the first capstone. Platinum hair is earned by owning every other colour on the hair rack; a rack can be finished now, and says so.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
