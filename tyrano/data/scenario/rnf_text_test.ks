; ========================================
; RNF 自由入力連携テスト
; ========================================

*start

[cm]

[eval exp="window.RNF.setScene('SC_RNF_TEXT_001')"]
[eval exp="window.RNF.setRoute('ROUTE_TEST')"]

今、あなたが大切にしたいことを自由に入力してください。[p]

[edit name="f.rnf_text_answer" left=120 top=250 width=500 height=50 maxchars=200]

[glink text="回答を決定する" target="*submit" x=240 y=350 width=300 cm=false]

[s]


*submit

[commit]

[eval exp="window.RNF.recordTextInput('I001', f.rnf_text_answer)"]

[cm]

回答を記録しました。[p]

入力内容：[emb exp="f.rnf_text_answer"][p]

[s]