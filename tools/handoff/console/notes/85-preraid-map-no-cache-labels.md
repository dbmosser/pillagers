# 85 shipped v33.42 (cw-nocachelbl)
- Two mapLabel calls (cache/looted, strongbox) now run only when mapFirstOn() is false. Rings and icons stay; all other labels stay. The m key map is unchanged.
- Check: forces 2 caches and 1 strongbox on seed 4242, draws the map with mapFirst 0 (control: words present) and 1 (0 cache, looted or strongbox words, extract words kept). Fingerprint held (ents 85/374, containers 165/593).
- Pictures not taken: the camera has no raid-start map screen (screen 22 is the m map). Adding one needs a question to him; critic not run.
