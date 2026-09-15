; ========================================
; RNF 選択肢連携テスト
; ========================================

*start

[cm]

[eval exp="window.RNF.setScene('SC_RNF_TEST_001')"]
[eval exp="window.RNF.setRoute('ROUTE_TEST')"]

あなたが今、大切にしたいものは何ですか？[p]

[glink text="家族との時間" target="*choice_family" x="150" y="250" width="320"]
[glink text="自分自身の時間" target="*choice_myself" x="150" y="330" width="320"]
[glink text="仕事や学び" target="*choice_work" x="150" y="410" width="320"]

[s]

*choice_family

[cm]

[eval exp="window.RNF.recordChoice('Q001','C001','家族との時間')"]

「家族との時間」を選びました。[p]

[jump target="*finish"]


*choice_myself

[cm]

[eval exp="window.RNF.recordChoice('Q001','C002','自分自身の時間')"]

「自分自身の時間」を選びました。[p]

[jump target="*finish"]


*choice_work

[cm]

[eval exp="window.RNF.recordChoice('Q001','C003','仕事や学び')"]

「仕事や学び」を選びました。[p]

[jump target="*finish"]


*finish

[cm]

回答を記録しました。[p]

[s]