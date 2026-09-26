# gen.py: writes pNNNN.ps1 and fNNNN.ps1 in the house format from Python data (ASCII only, whole-line anchors).
#   patch(NEW, edits=[(old,new),...], now='DEVNOW text', head='# comment lines')
#   fixture(NEW, check='  {v:...},\n', anchor="  {v:'PV',what:")
import os
H = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'handoff')
TOP = """$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\\claudecode\\dark raiders\\%s'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\\r?\\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}
"""
END = """
$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied%s"
"""
def v(t): t = str(t); return t[:2] + '.' + t[2:]
def sub(old, new): return "SubRx @'\n%s\n'@ @'\n%s\n'@\n\n" % (old.rstrip('\n'), new.rstrip('\n'))
def w(name, text):
    text.encode('ascii')
    open(os.path.join(H, name), 'w', encoding='ascii', newline='\n').write(text)
def patch(new, edits, now, head=''):
    pv, nv = v(new - 1), v(new)
    out = TOP % 'dark_raiders.html' + '\n' + head + '\n'
    for o, n_ in edits: out += sub(o, n_)
    out += sub("var VER='%s';" % pv, "var VER='%s';" % nv)
    assert "'" not in now and '"' not in now, 'DEVNOW now text must carry no quote marks'
    out += '$pat = "(?m)^  now:\'v%s:.*$"\n' % pv.replace('.', '\\.')
    out += '$c = ([regex]::Matches($s, $pat)).Count\nif ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }\n'
    out += '$new = "  now:\'v%s: %s\',"\n' % (nv, now)
    out += '$s = [regex]::Replace($s, $pat, { param($m) $new })\nif (([regex]::Matches($s, "(?m)^  now:\'")).Count -ne 1) { throw "more than one now key in DEVNOW" }\n$script:s = $s\n'
    w('p%d.ps1' % new, out + END % ' plus DEVNOW')
def fixture(new, check, anchor=None):
    anchor = anchor or "  {v:'%s',what:" % v(new - 1)
    out = TOP % 'tools\\mkfixture.ps1' + '\nif ($s.Contains("  {v:\'%s\',what:")) { throw "check %s is in the fixture already" }\n\n' % (v(new), v(new))
    out += sub(anchor, check.rstrip('\n') + '\n' + anchor)
    w('f%d.ps1' % new, out + END % '')
