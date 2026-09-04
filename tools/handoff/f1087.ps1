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
  {v:'10.86',what:'the ambient bed ducks when the pause box opens and comes back when you resume, once each time and not every frame',
'@ @'
  {v:'10.87',what:'sprint follows the SHIFT key: let go and you stop running, while crouch is still a toggle and the out-of-breath rule still needs a fresh press',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__loop&&window.__keysRef)) return 'SKIP: this fixture cannot drive keys through a raid';
     var bad=[];
     __runPrep(); __resetCfg(); __pinDefaults(0);
     __deploy({kit:[],safe:null,mapIx:0,seed:4242});
     var g=__state(), p=g.player, K=__keysRef();
     // A LATCHED KEY FROM AN EARLIER CHECK MADE THIS LOOK BROKEN TWICE BEFORE.
     for(var k in K) delete K[k];
     g.ents.length=0; p.stam=100; p.stamLock=0; p.stamRelease=0; p.ads=0; p.downed=0;
     var t0=performance.now(), f=0;
     function step(n){ for(var i=0;i<n;i++) __loop(t0+(f++)*16.7); }
     function down(code){ try{ window.dispatchEvent(new KeyboardEvent('keydown',{code:code})); }catch(e){} K[code]=1; }
     function up(code){ try{ window.dispatchEvent(new KeyboardEvent('keyup',{code:code})); }catch(e){} delete K[code]; }
     K['KeyW']=1;                       // sprint is refused when standing still
     step(4);
     if(g.sprinting) bad.push('control: the operator is already sprinting before SHIFT was touched');
     // 1. HELD IS RUNNING.
     down('ShiftLeft'); step(4);
     if(!g.sprinting) bad.push('holding SHIFT does not sprint at all');
     // 2. AND LETTING GO STOPS. This is his note: it used to keep running.
     up('ShiftLeft'); step(8);
     if(g.sprinting) bad.push('the operator is still sprinting eight frames after SHIFT was released, so sprint is a toggle rather than a hold');
     // 3. THE RIGHT-HAND KEY DOES THE SAME, or half the keyboard is a toggle.
     down('ShiftRight'); step(4);
     if(!g.sprinting) bad.push('the right SHIFT does not sprint');
     up('ShiftRight'); step(8);
     if(g.sprinting) bad.push('the right SHIFT is still sprinting after release');
     // 4. CROUCH IS STILL A TOGGLE, which is his answer 33 and is NOT changed.
     var wasCrouch=!!g.crouchTog;
     down('KeyC'); up('KeyC'); step(2);
     if(!!g.crouchTog===wasCrouch) bad.push('control: pressing C did not toggle crouch, so this fixture is not driving keys at all');
     var heldCrouch=!!g.crouchTog;
     step(20);
     if(!!g.crouchTog!==heldCrouch) bad.push('crouch stopped being a toggle: it changed on its own twenty frames after the press');
     down('KeyC'); up('KeyC'); step(2);
     if(!!g.crouchTog!==wasCrouch) bad.push('crouch did not toggle back on a second press');
     // 5. OUT OF BREATH STILL NEEDS A FRESH PRESS. v8.73 found a held key sawing
     //    sprint on and off 25 times in 20 seconds when stamina ran out; the
     //    cure was that you must release and press again, and a real hold must
     //    not have quietly undone it.
     p.stam=1; p.stamLock=1; p.stamRelease=1;
     down('ShiftLeft'); step(6);
     if(g.sprinting) bad.push('an exhausted operator sprints again while SHIFT is simply held down, which is the v8.73 sawtooth');
     p.stam=100; p.stamLock=0;
     step(6);
     if(g.sprinting) bad.push('a held SHIFT resumed sprinting the moment breath came back, without being released first');
     up('ShiftLeft'); step(2); down('ShiftLeft'); step(4);
     if(!g.sprinting) bad.push('releasing and pressing SHIFT again does not sprint after getting your breath back');
     up('ShiftLeft'); step(2);
     for(var k2 in K) delete K[k2];
     return bad.length?bad.join('; '):null; }},
  {v:'10.86',what:'the ambient bed ducks when the pause box opens and comes back when you resume, once each time and not every frame',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
