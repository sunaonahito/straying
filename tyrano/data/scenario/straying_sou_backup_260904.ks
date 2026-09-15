; ========================================
; RNF Scenario Template
; ========================================

*entry

[cm]

; 作品開始シーンを記録
[eval exp="window.RNF.setScene(window.RNF.getProjectConfig().SCENES.S000)"]

; 匿名Participantを生成し、
; Sessionへ追加して現在参加者に選択
[eval exp="window.RNF.initializeAnonymousParticipant()"]

; SOU研究参加フローへ
[jump target="*consent"]


; ========================================
; 研究参加への同意
; ========================================

*consent

[cm]

; ここにConsent説明文を表示する
; 実際の英文は研究計画・同意文書確定後に入れる

Do you agree to participate in this study?[p]

[glink text="I agree" target="*consent_agree"]

[glink text="I do not agree" target="*consent_decline"]

[s]


; ========================================
; 同意した場合
; ========================================

*consent_agree

[cm]

; Consent記録 + Withdrawal Code発行
[eval exp="f.rnf_research_start=window.RNF.startResearchParticipation()"]

; Withdrawal Codeを一時変数へ保存
[eval exp="f.rnf_withdrawal_code=f.rnf_research_start.withdrawal ? f.rnf_research_start.withdrawal.withdrawalCode : ''"]

Your withdrawal code is: [emb exp="f.rnf_withdrawal_code"][p]

Please save this code if you may want to withdraw your participation later.[p]

[jump target="*start1"]


; ========================================
; 同意しない場合
; ========================================

*consent_decline

[cm]

Thank you. You have chosen not to participate in this study.[p]

[s]


; ========================================
; 0. オープニング
; ========================================

*start1

[cm]

[eval exp="window.RNF.setScene(window.RNF.getProjectConfig().SCENES.S001)"]

; TODO: オープニング本文

[jump target="*forest_start"]


; ========================================
; 1. 霧の森で迷子になる
; ========================================

*forest_start

[cm]

[eval exp="window.RNF.setScene(window.RNF.getProjectConfig().SCENES.S002)"]

You hear a faint sound somewhere in the fog.[p]

What do you do?[p]

[glink text="Walk toward the sound" target="*approach_child"]

[glink text="Stay where you are" target="*stay_still"]

[s]


; ========================================
; 選択1-A：声のする方へ歩く
; ========================================

*approach_child

[cm]

[eval exp="window.RNF.recordChoice(window.RNF.getProjectConfig().ANSWERS.Q001.QUESTION_ID,window.RNF.getProjectConfig().ANSWERS.Q001.CHOICES.C01,'Walk toward the sound')"]

You decide to walk toward the sound.[p]

[jump target="*see_child"]


; ========================================
; 選択1-B：その場にとどまる
; ========================================

*stay_still

[cm]

[eval exp="window.RNF.recordChoice(window.RNF.getProjectConfig().ANSWERS.Q001.QUESTION_ID,window.RNF.getProjectConfig().ANSWERS.Q001.CHOICES.C02,'Stay where you are')"]

You stay where you are for a moment.[p]

[jump target="*see_child"]


; ========================================
; 2. 子どもとの出会い
; ========================================

*see_child

[cm]

[eval exp="window.RNF.setScene(window.RNF.getProjectConfig().SCENES.S003)"]

Through the fog, you notice a child standing alone.[p]

What do you do?[p]

[glink text="Call out to the child" target="*call_out"]

[glink text="Do not call out" target="*dont_call"]

[s]


; ========================================
; Q002_C01：声をかける
; ========================================

*call_out

[cm]

[eval exp="window.RNF.recordChoice(window.RNF.getProjectConfig().ANSWERS.Q002.QUESTION_ID,window.RNF.getProjectConfig().ANSWERS.Q002.CHOICES.C01,'Call out to the child')"]

You decide to call out to the child.[p]

[jump target="*child_notices"]


; ========================================
; Q002_C02：声をかけない
; ========================================

*dont_call

[cm]

[eval exp="window.RNF.recordChoice(window.RNF.getProjectConfig().ANSWERS.Q002.QUESTION_ID,window.RNF.getProjectConfig().ANSWERS.Q002.CHOICES.C02,'Do not call out')"]

You decide not to call out.[p]

[jump target="*child_notices"]


; ========================================
; 3. 一緒に探す
; ========================================

*child_notices

[cm]

[eval exp="window.RNF.setScene(window.RNF.getProjectConfig().SCENES.S004)"]

; TODO: 選択3
; お金
; 学生証
; スマホ

[jump target="*pocket_money"]


*pocket_money

; TODO: 選択3-A本文

[jump target="*after_pocket"]


*pocket_id

; TODO: 選択3-B本文

[jump target="*after_pocket"]


*pocket_phone

; TODO: 選択3-C本文

[jump target="*after_pocket"]


*after_pocket

; TODO: 共通本文

[jump target="*ask_name"]


; ========================================
; 4. 名前をつける
; ========================================

*ask_name

[cm]

[eval exp="window.RNF.setScene(window.RNF.getProjectConfig().SCENES.S005)"]

; TODO: プレイヤー名入力

[jump target="*check_name"]


*check_name

; TODO:
; 入力チェック
; プレイヤー名を本文で使用

[jump target="*walk_together"]


; ========================================
; 5. 森を歩きながらの対話
; ========================================

*walk_together

[cm]

[eval exp="window.RNF.setScene(window.RNF.getProjectConfig().SCENES.S006)"]

; TODO: 本文

[jump target="*treasure_category"]


; ========================================
; 6. 大切なもの
; ========================================

*treasure_category

[cm]

[eval exp="window.RNF.setScene(window.RNF.getProjectConfig().SCENES.S007)"]

; TODO: カテゴリ選択
; 大切な人
; 贈りもの
; 言葉
; 宝物
; 目標
; 思い出の場所

[jump target="*cat_person"]


*cat_person

; TODO: 大切な人

[jump target="*treasure_freewrite"]


*cat_gift

; TODO: 贈りもの

[jump target="*treasure_freewrite"]


*cat_words

; TODO: 言葉

[jump target="*treasure_freewrite"]


*cat_treasure

; TODO: 宝物

[jump target="*treasure_freewrite"]


*cat_goal

; TODO: 目標

[jump target="*treasure_freewrite"]


*cat_place

; TODO: 思い出の場所

[jump target="*treasure_freewrite"]


*treasure_freewrite

; TODO: 大切なもの自由記述

[jump target="*check_treasure"]


*check_treasure

; TODO:
; 自由記述内容の表示
; 「もう少し話したい / もう十分な気がする」

[jump target="*self_question"]


; ========================================
; 7. 自分のことが好き？
; ========================================

*self_question

[cm]

[eval exp="window.RNF.setScene(window.RNF.getProjectConfig().SCENES.S008)"]

; TODO: 選択6
; 好き
; 悪くない
; 今より好きになりたい

[jump target="*self_like"]


*self_like

; TODO: 「好き」本文

[jump target="*deepen"]


*self_okay

; TODO: 「悪くない」本文

[jump target="*deepen"]


*self_want

; TODO: 「今より好きになりたい」本文

[jump target="*deepen"]


; ========================================
; 8. 深まる対話
; ========================================

*deepen

[cm]

[eval exp="window.RNF.setScene(window.RNF.getProjectConfig().SCENES.S009)"]

; TODO: 本文

[jump target="*climax_elder"]


; ========================================
; 9. クライマックス
; ========================================

*climax_elder

[cm]

[eval exp="window.RNF.setScene(window.RNF.getProjectConfig().SCENES.S010)"]

; TODO:
; 子どもから老人への変化
; 大切なものカテゴリに応じた一部台詞分岐

[jump target="*wake_transition"]


; ========================================
; 10. エンディング
; ========================================

*wake_transition

[cm]

[eval exp="window.RNF.setScene(window.RNF.getProjectConfig().SCENES.S011)"]

; TODO: 夢から目覚める本文

[jump target="*ending"]


*ending

[cm]

Straying prototype flow completed.[p]

[s]