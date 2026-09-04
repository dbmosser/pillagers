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

# ==== v9.77's SECOND CONTROL WAS RESTING ON A MAP-WIDE TOTAL, and the town
# ==== square knocked it over. It reads "spared means GEOMETRY SURVIVED, not a
# ==== flag flipped" and proved it by requiring the whole mile to hold MORE
# ==== interior walls with the finer look on than off. On v10.80 it reads 280
# ==== against 285 and fails, while the finding it guards still passes and so
# ==== does the control that matters, the set of buildings holding unreachable
# ==== floor being identical.
# ====
# ==== WHY. The square changes the container count on the mile, 552 to 593, so
# ==== the seeded stream after map build differs, and furniture and interior
# ==== tagging land a few walls either way in EVERY building, spared or not. The
# ==== total is a proxy that anything can swamp; five walls of drift anywhere on
# ==== a map of 84 buildings decides the comparison.
# ====
# ==== THE HONEST MEASURE is the one the comment already names: did the buildings
# ==== that were SPARED keep their interiors. Walls carry ib, their building's
# ==== own id, so that set can be counted directly instead of guessed at from a
# ==== map-wide sum. This is the v9.79 lesson: measure a conserved quantity, and
# ==== do not let a control rest on a number the change moves for other reasons.
SubRx @'
       var stuck=[], demo=0, parts=0;
       for(i=0;i<W.length;i++) if(W[i].ib!==undefined&&!W[i].furn) parts++;
       for(var b=0;b<B.length;b++){
         var bb=B[b], un=0;
         if(bb.repaired) demo++;
'@ @'
       var stuck=[], demo=0, parts=0, per={}, dset={};
       for(i=0;i<W.length;i++) if(W[i].ib!==undefined&&!W[i].furn){ parts++;
         // v10.80: PER BUILDING as well as the total, so the control below can
         // ask about the buildings that were actually spared.
         per[W[i].ib]=(per[W[i].ib]||0)+1; }
       for(var b=0;b<B.length;b++){
         var bb=B[b], un=0;
         if(bb.repaired){ demo++; dset[b]=1; }
'@
SubRx @'
       return {buildings:B.length, demolished:demo, parts:parts, ents:g.ents.length, stuck:stuck.join(',')};
'@ @'
       return {buildings:B.length, demolished:demo, parts:parts, per:per, dset:dset, ents:g.ents.length, stuck:stuck.join(',')};
'@
SubRx @'
     // CONTROL TWO: spared means GEOMETRY SURVIVED, not a flag flipped.
     if(!(on.parts>off.parts))
       bad.push('the map keeps '+on.parts+' interior walls against '+off.parts+
                ', so nothing actually survived');
'@ @'
     // CONTROL TWO: spared means GEOMETRY SURVIVED, not a flag flipped. v10.80:
     // asked of the SPARED BUILDINGS rather than of the whole map. The map-wide
     // total drifts by a few walls whenever anything moves the stream, which is
     // how the town square made this read 280 against 285 while every building
     // it names kept its interior intact.
     var _sp=[], _spOn=0, _spOff=0, _bk;
     for(_bk in off.dset) if(!on.dset[_bk]){ _sp.push(_bk);
       _spOn+=(on.per[_bk]||0); _spOff+=(off.per[_bk]||0); }
     if(!_sp.length)
       bad.push('control: no building was spared at all, so there is no geometry to have survived');
     else if(!(_spOn>_spOff))
       bad.push('the '+_sp.length+' spared buildings keep '+_spOn+' interior walls with the finer look on '+
                'against '+_spOff+' with it off, so nothing actually survived');
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
