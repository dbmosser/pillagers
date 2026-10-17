# 01-corpus-triage notes (in progress)
- Corpus file has 72 failures in ranges [120..2006) plus 5 more on line 1 (range [0,120): v9.03 x2, v9.31, v11.60, v28.68). Reasons in the corpus are cut at 400 chars.
- Plan: rerun every failing version alone with runchk.sh (list: notes/triage-list.txt, out: notes/triage-out.txt) to get full reasons and spot FLAKY ones, then classify.
