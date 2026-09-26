import os, gen
from gen import patch, fixture
patch(1618, [
("""      say('Knocked down. Extraction reset. Hold E to try again.');   // v16.17, his note: extraction hold meant nothing to him""",
"""      say('Knocked down. Extraction attempt reset. Hold E to try again.');   // v16.17, his note: extraction hold meant nothing to him; v16.18: his words, Extraction attempt reset"""),
], "HIS WORDS: EXTRACTION ATTEMPT RESET. Knocked down while holding E to extract now says Knocked down. Extraction attempt reset. Hold E to try again. Text only. Check 16.18 fails on v16.17",
"# HIS WORDS: EXTRACTION ATTEMPT RESET (2026-09-26). Text only.\n")
fixture(1618, r"""  {v:'16.18',what:'his words: knocked down while extracting says Extraction attempt reset',
   run:function(){
     var src='', i;
     try{ var ss=document.getElementsByTagName('script'); for(i=0;i<ss.length;i++) src+=ss[i].textContent||''; }catch(e){ return 'SKIP: the build cannot read its own script'; }
     var cut=src.indexOf('window.__frame=function'); if(cut>0) src=src.slice(0,cut);
     if(src.length<100000) return 'SKIP: the build cannot read its own script';
     if(src.indexOf('Knocked down. Extraction attempt reset. Hold E to try again.')<0) return 'the knocked down line does not say Extraction attempt reset';
     return null; }},
""")
_p = os.path.join(gen.H, 'f1618.ps1'); _t = open(_p, encoding='ascii').read()
MK = open(os.path.join(gen.H, '..', 'mkfixture.ps1'), encoding='utf-8').read().split('\n')
a = "if(src.indexOf('Knocked down. Extraction reset. Hold E to try again.')<0) return 'the knocked down line does not say Extraction reset. Hold E to try again.';"
ln = [x for x in MK if a in x]; assert len(ln) == 1
extra = gen.sub(ln[0], ln[0].replace("'Knocked down. Extraction reset. Hold E to try again.'", "'Knocked down. Extraction attempt reset. Hold E to try again.'").replace("does not say Extraction reset.", "does not say Extraction attempt reset."))
_t = _t.replace("\n$src = [IO.File]", "\n" + extra + "$src = [IO.File]", 1)
open(_p, 'w', encoding='ascii', newline='\n').write(_t)
