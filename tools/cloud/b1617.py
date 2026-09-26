from gen import patch, fixture
patch(1617, [
("""      say('Knocked down. Extraction hold lost.');""",
"""      say('Knocked down. Extraction reset. Hold E to try again.');   // v16.17, his note: extraction hold meant nothing to him"""),
], "KNOCKED DOWN WHILE EXTRACTING SAYS WHAT HAPPENED. His note: extraction hold meant nothing to him. Knocked down while holding E to extract now says Knocked down. Extraction reset. Hold E to try again. Text only. Check 16.17 fails on v16.16",
"# KNOCKED DOWN WHILE EXTRACTING SAYS WHAT HAPPENED. His note of 2026-09-26. Text only.\n")
fixture(1617, r"""  {v:'16.17',what:'knocked down while extracting says what happened: Extraction reset. Hold E to try again, not the extraction hold line',
   run:function(){
     var src='', i;
     try{ var ss=document.getElementsByTagName('script'); for(i=0;i<ss.length;i++) src+=ss[i].textContent||''; }catch(e){ return 'SKIP: the build cannot read its own script'; }
     var cut=src.indexOf('window.__frame=function'); if(cut>0) src=src.slice(0,cut);
     if(src.length<100000) return 'SKIP: the build cannot read its own script';
     if(src.indexOf('Extraction hold lost')>=0) return 'the knocked down line still says Extraction hold lost';
     if(src.indexOf('Knocked down. Extraction reset. Hold E to try again.')<0) return 'the knocked down line does not say Extraction reset. Hold E to try again.';
     return null; }},
""")
