; ========================================
; RNF Scenario Template
; ========================================

*entry

[cm]

; 作品開始シーンを記録
[eval exp="window.RNF.setScene(window.RNF.getProjectConfig().SCENES.ENTRY)"]

; ========================================
; 導入
; ========================================

; ここに導入テキストを書く

[jump target="*main_choice"]


; ========================================
; 選択式質問
; ========================================

*main_choice

[cm]

[eval exp="window.RNF.setScene(window.RNF.getProjectConfig().SCENES.START)"]

[eval exp="window.RNF.setRoute(window.RNF.getProjectConfig().ROUTES.MAIN)"]

; ここに質問文を書く

; 例：
; あなたはどうしますか？[p]

; ここに選択肢を書く
;
; 例：
;
; [glink text="選択肢A" target="*choice_a" x=160 y=260 width=420 cm=false]
; [glink text="選択肢B" target="*choice_b" x=160 y=360 width=420 cm=false]

[s]


; ========================================
; 選択肢A
; ========================================

*choice_a

; 選択回答を記録
;
; [eval exp="window.RNF.recordChoice(
;   window.RNF.getProjectConfig().ANSWERS.MAIN_CHOICE.QUESTION_ID,
;   window.RNF.getProjectConfig().ANSWERS.MAIN_CHOICE.CHOICES.A,
;   '選択肢A'
; )"]

; 必要に応じて回答表示用変数へ保存
;
; [eval exp="f.rnf_choice_text='選択肢A'"]

[jump target="*text_question"]


; ========================================
; 選択肢B
; ========================================

*choice_b

; 選択回答を記録

[jump target="*text_question"]


; ========================================
; 自由記述
; ========================================

*text_question

[cm]

[eval exp="window.RNF.setScene(window.RNF.getProjectConfig().SCENES.TEXT)"]

; ここに自由記述質問を書く

; 例：
; その理由を自由に入力してください。[p]

; 例：
; [edit name="f.rnf_text_answer" left=120 top=250 width=500 height=50 maxchars=200]

; 例：
; [glink text="回答を決定する" target="*submit_text" x=240 y=350 width=300 cm=false]

[s]


; ========================================
; 自由記述回答を記録
; ========================================

*submit_text

[commit]

; 例：
;
; [eval exp="window.RNF.recordTextInput(
;   window.RNF.getProjectConfig().ANSWERS.MAIN_TEXT.INPUT_ID,
;   f.rnf_text_answer
; )"]

[jump target="*reflection"]


; ========================================
; 振り返り
; ========================================

*reflection

[cm]

[eval exp="window.RNF.setScene(window.RNF.getProjectConfig().SCENES.REFLECTION)"]

; ここに振り返り画面を書く

; 必要に応じて
;
; window.RNF.getCurrentAnswers()
; window.RNF.getPreviousPlayAnswers()
;
; などを使用する

[jump target="*finish"]


; ========================================
; 終了
; ========================================

*finish

[cm]

; ここに作品終了時の処理を書く
;
; 例：
; ・研究データ送信
; ・次の参加者への移行
; ・終了メッセージ
; ・別シナリオへのjump

[s]