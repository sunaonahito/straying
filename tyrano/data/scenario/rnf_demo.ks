; ========================================
; RNF 統合デモシナリオ
; ========================================

*entry

[cm]

[eval exp="f.rnf_resume_save=window.RNF.restoreCurrentPlay()"]

[if exp="f.rnf_resume_save"]

[eval exp="f.rnf_play_mode=f.rnf_resume_save.playMode || ''; f.rnf_choice_text=f.rnf_resume_save.choiceText || ''; f.rnf_text_answer=f.rnf_resume_save.textAnswer || ''"]

[if exp="f.rnf_resume_save.currentStep == 'play_mode_menu'"]

[jump target="*play_mode_menu"]

[elsif exp="f.rnf_resume_save.currentStep == 'participant_menu'"]

[jump target="*participant_menu"]

[elsif exp="f.rnf_resume_save.currentStep == 'participant_input'"]

[jump target="*participant_input"]

[elsif exp="f.rnf_resume_save.currentStep == 'choice'"]

[jump target="*start"]

[elsif exp="f.rnf_resume_save.currentStep == 'text_question'"]

[jump target="*text_question"]

[elsif exp="f.rnf_resume_save.currentStep == 'reflection'"]

[jump target="*reflection"]

[elsif exp="f.rnf_resume_save.currentStep == 'participant_handoff'"]

[jump target="*participant_handoff"]

[else]

[eval exp="window.RNF.clearCurrentPlaySave()"]

[endif]

[endif]

[eval exp="window.RNF.setScene(window.RNF.getProjectConfig().SCENES.ENTRY)"]

RNF統合デモへようこそ。[p]

「新しいプレイを始める」を押すと、新しいプレイ記録を開始します。[p]

[glink text="新しいプレイを始める" target="*new_play" x="190" y="350" width="400"]

[s]


*new_play

[cm]

[eval exp="window.RNF.startNewSession(); f.rnf_play_mode=''; f.rnf_choice_text=''; f.rnf_text_answer=''; f.rnf_participant_name=''"]

[eval exp="window.RNF.saveCurrentPlay({currentStep:'play_mode_menu', playMode:'', choiceText:'', textAnswer:''})"]

[jump target="*play_mode_menu"]

*play_mode_menu

[cm]

[eval exp="window.RNF.setScene(window.RNF.getProjectConfig().SCENES.PLAY_MODE_MENU)"]

[eval exp="window.RNF.saveCurrentPlay({currentStep:'play_mode_menu', playMode:'', choiceText:'', textAnswer:''})"]

どのようにプレイしますか？[r]
プレイ形式を選んでください。[r]

[glink text="1人でプレイする" target="*select_solo_mode" x=160 y=260 width=420 cm=false]

[glink text="大切な人と一緒にプレイする" target="*select_group_mode" x=160 y=380 width=420 cm=false]

[s]


*select_solo_mode

[cm]

[eval exp="f.rnf_play_mode='solo'"]

[eval exp="window.RNF.saveCurrentPlay({currentStep:'participant_menu', playMode:f.rnf_play_mode, choiceText:'', textAnswer:''})"]

[jump target="*participant_menu"]


*select_group_mode

[cm]

[eval exp="f.rnf_play_mode='group'"]

[eval exp="window.RNF.saveCurrentPlay({currentStep:'participant_menu', playMode:f.rnf_play_mode, choiceText:'', textAnswer:''})"]

[jump target="*participant_menu"]

*participant_menu

[cm]

[eval exp="window.RNF.getProjectConfig().SCENES.PARTICIPANT_MENU"]

[eval exp="window.RNF.saveCurrentPlay({currentStep:'participant_menu', playMode:f.rnf_play_mode, choiceText:'', textAnswer:''})"]

[eval exp="f.rnf_registered_participants=window.RNF.getRegisteredParticipants(); f.rnf_registered_count=f.rnf_registered_participants.length; f.rnf_registered_1=f.rnf_registered_count>0 ? f.rnf_registered_participants[0] : null; f.rnf_registered_2=f.rnf_registered_count>1 ? f.rnf_registered_participants[1] : null; f.rnf_registered_3=f.rnf_registered_count>2 ? f.rnf_registered_participants[2] : null; f.rnf_registered_button_1=f.rnf_registered_1 ? '「'+f.rnf_registered_1.displayName+'」を追加' : ''; f.rnf_registered_button_2=f.rnf_registered_2 ? '「'+f.rnf_registered_2.displayName+'」を追加' : ''; f.rnf_registered_button_3=f.rnf_registered_3 ? '「'+f.rnf_registered_3.displayName+'」を追加' : ''"]

[eval exp="f.rnf_session_participants=window.RNF.getSessionParticipants(); f.rnf_session_count=f.rnf_session_participants.length; f.rnf_session_1=f.rnf_session_count>0 ? f.rnf_session_participants[0] : null; f.rnf_session_2=f.rnf_session_count>1 ? f.rnf_session_participants[1] : null; f.rnf_session_3=f.rnf_session_count>2 ? f.rnf_session_participants[2] : null"]

[if exp="f.rnf_play_mode == 'solo'"]

今回、回答する方を1人選んでください。[p]

[else]

今回、一緒に回答する方を選んでください。[p]

[endif]

[if exp="f.rnf_session_count > 0"]

今回の参加者：[r]

[if exp="f.rnf_session_1"]

・[emb exp="f.rnf_session_1.displayName"][r]

[endif]

[if exp="f.rnf_session_2"]

・[emb exp="f.rnf_session_2.displayName"][r]

[endif]

[if exp="f.rnf_session_3"]

・[emb exp="f.rnf_session_3.displayName"][r]

[endif]

[else]

今回の参加者は、まだ選ばれていません。[p]

[endif]

[if exp="f.rnf_registered_count > 0"]

登録済みの参加者を追加する[r]

[if exp="f.rnf_registered_1"]

[glink text=&f.rnf_registered_button_1 target="*add_participant_1" x=160 y=210 width=420 cm=false]

[endif]

[if exp="f.rnf_registered_2"]

[glink text=&f.rnf_registered_button_2 target="*add_participant_2" x=160 y=300 width=420 cm=false]

[endif]

[if exp="f.rnf_registered_3"]

[glink text=&f.rnf_registered_button_3 target="*add_participant_3" x=160 y=390 width=420 cm=false]

[endif]

[else]

登録済みの参加者はまだいません。[p]

[endif]

[glink text="新しい名前を登録して追加" target="*participant_input" x=160 y=500 width=420 cm=false]

[if exp="f.rnf_play_mode == 'group' && f.rnf_session_count > 0"]

[glink text="このメンバーで回答を始める" target="*start_session_answers" x=160 y=610 width=420 cm=false]

[endif]

[s]


*add_participant_1

[eval exp="f.rnf_add_result=window.RNF.addSessionParticipantById(f.rnf_registered_1.participantId)"]

[if exp="f.rnf_play_mode == 'solo'"]

[jump target="*start_solo_answers"]

[else]

[jump target="*participant_menu"]

[endif]


*add_participant_2

[eval exp="f.rnf_add_result=window.RNF.addSessionParticipantById(f.rnf_registered_2.participantId)"]

[if exp="f.rnf_play_mode == 'solo'"]

[jump target="*start_solo_answers"]

[else]

[jump target="*participant_menu"]

[endif]


*add_participant_3

[eval exp="f.rnf_add_result=window.RNF.addSessionParticipantById(f.rnf_registered_3.participantId)"]

[if exp="f.rnf_play_mode == 'solo'"]

[jump target="*start_solo_answers"]

[else]

[jump target="*participant_menu"]

[endif]

*start_solo_answers

[cm]

[eval exp="f.rnf_first_selection=window.RNF.selectFirstSessionParticipant()"]

[if exp="!f.rnf_first_selection"]

参加者を選択できませんでした。[p]

[glink text="参加者選択へ戻る" target="*participant_menu" x=200 y=350 width=360]

[s]

[else]

[eval exp="f.rnf_choice_text=''; f.rnf_text_answer=''"]

[eval exp="window.RNF.saveCurrentPlay({currentStep:'choice', playMode:f.rnf_play_mode, choiceText:'', textAnswer:''})"]

[jump target="*start"]

[endif]

*start_session_answers

[cm]

[eval exp="f.rnf_first_selection=window.RNF.selectFirstSessionParticipant()"]

[if exp="!f.rnf_first_selection"]

参加者が選ばれていません。[p]

[glink text="参加者選択へ戻る" target="*participant_menu" x=200 y=350 width=360]

[s]

[else]

[eval exp="f.rnf_choice_text=''; f.rnf_text_answer=''"]

[eval exp="window.RNF.saveCurrentPlay({currentStep:'choice', playMode:f.rnf_play_mode, choiceText:'', textAnswer:''})"]

[jump target="*start"]

[endif]


*participant_input

[cm]

[eval exp="window.RNF.getProjectConfig().SCENES.PARTICIPANT_INPUT; window.RNF.saveCurrentPlay({currentStep:'participant_input', choiceText:'', textAnswer:''})"]

新しい参加者のお名前を入力してください。[p]

本名でなく、ニックネームでも構いません。[p]

[edit name="f.rnf_participant_name" left=160 top=250 width=420 height=50 maxchars=30]

[glink text="この名前を参加者に追加" target="*submit_participant" x=200 y=350 width=400 cm=false]

[glink text="登録済み一覧へ戻る" target="*participant_menu" x=220 y=430 width=360]

[s]


*submit_participant

[commit]

[if exp="!f.rnf_participant_name || f.rnf_participant_name.trim() == ''"]

[cm]

お名前が入力されていません。[p]

ニックネームなどを入力してください。[p]

[glink text="入力画面へ戻る" target="*participant_input" x=220 y=350 width=360]

[s]

[else]

[eval exp="f.rnf_participant_name=f.rnf_participant_name.trim(); f.rnf_add_result=window.RNF.addSessionParticipantByName(f.rnf_participant_name); f.rnf_participant_name=''"]

[if exp="f.rnf_play_mode == 'solo'"]

[jump target="*start_solo_answers"]

[else]

[eval exp="window.RNF.saveCurrentPlay({currentStep:'participant_menu', playMode:f.rnf_play_mode, choiceText:'', textAnswer:''})"]

[jump target="*participant_menu"]

[endif]

[endif]


*start

[cm]

[eval exp="window.RNF.getProjectConfig().SCENES.TEXT"]
[eval exp="window.RNF.setRoute(window.RNF.getProjectConfig().ROUTES.MAIN)"]
[eval exp="f.rnf_current_participant=window.RNF.getCurrentParticipant(); f.rnf_session_status=window.RNF.getSessionParticipantStatus(); f.rnf_current_order=f.rnf_session_status.currentIndex+1; f.rnf_total_participants=f.rnf_session_status.participantCount"]

回答者：[emb exp="f.rnf_current_participant.displayName"][r]

[emb exp="f.rnf_current_order"]人目／全[emb exp="f.rnf_total_participants"]人[p]

これはRNFの動作確認用デモです。[p]

[eval exp="window.RNF.saveCurrentPlay({currentStep:'choice', playMode:f.rnf_play_mode, choiceText:'', textAnswer:''})"]

あなたが今、大切にしたいものを選んでください。[p]

[glink text="家族との時間" target="*choice_family" x="150" y="250" width="320"]
[glink text="自分自身の時間" target="*choice_myself" x="150" y="330" width="320"]
[glink text="仕事や学び" target="*choice_work" x="150" y="410" width="320"]

[s]


*choice_family

[eval exp="window.RNF.recordChoice(window.RNF.getProjectConfig().ANSWERS.MAIN_CHOICE.QUESTION_ID, window.RNF.getProjectConfig().ANSWERS.MAIN_CHOICE.CHOICES.FAMILY, '家族との時間')"]
[eval exp="f.rnf_choice_text='家族との時間'"]
[eval exp="window.RNF.saveCurrentPlay({currentStep:'text_question', choiceText:f.rnf_choice_text, textAnswer:''})"]

[jump target="*text_question"]

*choice_myself

[eval exp="window.RNF.recordChoice(window.RNF.getProjectConfig().ANSWERS.MAIN_CHOICE.QUESTION_ID, window.RNF.getProjectConfig().ANSWERS.MAIN_CHOICE.CHOICES.MYSELF, '自分自身の時間')"]
[eval exp="f.rnf_choice_text='自分自身の時間'"]
[eval exp="window.RNF.saveCurrentPlay({currentStep:'text_question', choiceText:f.rnf_choice_text, textAnswer:''})"]

[jump target="*text_question"]

*choice_work

[eval exp="window.RNF.recordChoice(window.RNF.getProjectConfig().ANSWERS.MAIN_CHOICE.QUESTION_ID, window.RNF.getProjectConfig().ANSWERS.MAIN_CHOICE.CHOICES.WORK, '仕事や学び')"]
[eval exp="f.rnf_choice_text='仕事や学び'"]
[eval exp="window.RNF.saveCurrentPlay({currentStep:'text_question', choiceText:f.rnf_choice_text, textAnswer:''})"]

[jump target="*text_question"]

*text_question

[cm]

[eval exp="window.RNF.setScene('SC_DEMO_TEXT')"]

あなたは「[emb exp='f.rnf_choice_text']」を選びました。[p]

それを大切にするために、これからしたいことを自由に入力してください。[p]

[edit name="f.rnf_text_answer" left=120 top=250 width=500 height=50 maxchars=200]

[glink text="回答を決定する" target="*submit_text" x=240 y=350 width=300 cm=false]

[s]


*submit_text

[commit]

[eval exp="window.RNF.recordTextInput(window.RNF.getProjectConfig().ANSWERS.MAIN_TEXT.INPUT_ID, f.rnf_text_answer)"]
[eval exp="window.RNF.saveCurrentPlay({currentStep:'reflection', choiceText:f.rnf_choice_text, textAnswer:f.rnf_text_answer})"]

[cm]

[jump target="*reflection"]

*reflection

[cm]

[eval exp="window.RNF.getProjectConfig().SCENES.REFLECTION"]

[eval exp="f.rnf_answers=window.RNF.getCurrentAnswers(); f.rnf_previous_play=window.RNF.getPreviousPlayAnswers(); f.rnf_reflection_choice=f.rnf_choice_text; f.rnf_reflection_text=f.rnf_text_answer; f.rnf_previous_choice=''; f.rnf_previous_text=''; f.rnf_has_previous=false; f.rnf_choice_changed=false; f.rnf_text_changed=false; f.rnf_answers.forEach(function(answer){ if(answer.answerId=='Q001'){ f.rnf_reflection_choice=answer.displayValue || answer.value || ''; } if(answer.answerId=='I001'){ f.rnf_reflection_text=answer.displayValue || answer.value || ''; } }); if(f.rnf_previous_play && f.rnf_previous_play.answers){ f.rnf_has_previous=true; if(f.rnf_previous_play.answers.Q001){ f.rnf_previous_choice=f.rnf_previous_play.answers.Q001.displayValue || f.rnf_previous_play.answers.Q001.value || ''; } if(f.rnf_previous_play.answers.I001){ f.rnf_previous_text=f.rnf_previous_play.answers.I001.displayValue || f.rnf_previous_play.answers.I001.value || ''; } f.rnf_choice_changed=f.rnf_previous_choice!==f.rnf_reflection_choice; f.rnf_text_changed=f.rnf_previous_text!==f.rnf_reflection_text; }"]

[eval exp="f.rnf_current_participant=window.RNF.getCurrentParticipant(); f.rnf_session_status=window.RNF.getSessionParticipantStatus(); f.rnf_current_order=f.rnf_session_status.currentIndex+1; f.rnf_total_participants=f.rnf_session_status.participantCount"]

回答者：[emb exp="f.rnf_current_participant.displayName"][r]

[emb exp="f.rnf_current_order"]人目／全[emb exp="f.rnf_total_participants"]人[p]

今回の回答を振り返ってみましょう。[p]

[if exp="f.rnf_has_previous"]

前回の回答[p]

大切にしたいもの：[emb exp="f.rnf_previous_choice"][p]

これからしたいこと：[emb exp="f.rnf_previous_text"][p]

今回の回答[p]

大切にしたいもの：[emb exp="f.rnf_reflection_choice"][p]

これからしたいこと：[emb exp="f.rnf_reflection_text"][p]

[if exp="f.rnf_choice_changed"]

大切にしたいものは、前回から変化しました。[p]

[else]

大切にしたいものは、前回と同じでした。[p]

[endif]

[if exp="f.rnf_text_changed"]

これからしたいことは、前回から変化しました。[p]

[else]

これからしたいことは、前回と同じでした。[p]

[endif]

[else]

今回は最初のプレイです。[p]

次回から、以前の回答と比較できます。[p]

今回、大切にしたいもの：[emb exp="f.rnf_reflection_choice"][p]

これからしたいこと：[emb exp="f.rnf_reflection_text"][p]

[endif]

この回答でよろしいですか？[p]

現在、[emb exp="window.RNF.getResearchQueueCount()"]件の研究データが端末内に保存されています。[p]

[eval exp="f.rnf_session_status=window.RNF.getSessionParticipantStatus(); f.rnf_is_last_participant=f.rnf_session_status.currentIndex >= f.rnf_session_status.participantCount - 1"]

[if exp="f.rnf_is_last_participant"]

[glink text="全員の回答を送信する" target="*finish_participant_answer" x=160 y=440 width=420 cm=false]

[else]

[glink text="次の参加者へ進む" target="*finish_participant_answer" x=160 y=440 width=420 cm=false]

[endif]

[glink text="回答をやり直す" target="*restart_answers" x=160 y=520 width=420 cm=false]

[s]

*finish_participant_answer

[cm]

[eval exp="f.rnf_next_participant_result=window.RNF.selectNextSessionParticipant()"]

[if exp="f.rnf_next_participant_result.completed"]

[jump target="*send_data"]

[else]

[eval exp="f.rnf_choice_text=''; f.rnf_text_answer=''; f.rnf_reflection_choice=''; f.rnf_reflection_text=''; f.rnf_next_participant=f.rnf_next_participant_result.participant"]

[eval exp="window.RNF.saveCurrentPlay({currentStep:'participant_handoff', choiceText:'', textAnswer:''})"]

[jump target="*participant_handoff"]

[endif]

*participant_handoff

[cm]

[eval exp="window.RNF.getProjectConfig().SCENES.PARTICIPANT_HANDOFF"]

[eval exp="f.rnf_current_participant=window.RNF.getCurrentParticipant(); f.rnf_session_status=window.RNF.getSessionParticipantStatus(); f.rnf_current_order=f.rnf_session_status.currentIndex+1; f.rnf_total_participants=f.rnf_session_status.participantCount"]

前の回答者の回答が完了しました。[p]

次の回答者は、[emb exp="f.rnf_current_participant.displayName"]さんです。[p]

[emb exp="f.rnf_current_order"]人目／全[emb exp="f.rnf_total_participants"]人[r]

端末を次の回答者へ渡してください。[p]

この画面では、前の回答者の回答内容は表示されません。[p]

[glink text="準備ができたら回答を始める" target="*begin_next_participant" x=170 y=430 width=460 cm=false]

[s]


*begin_next_participant

[cm]

[eval exp="f.rnf_choice_text=''; f.rnf_text_answer=''"]

[eval exp="window.RNF.saveCurrentPlay({currentStep:'choice', playMode:f.rnf_play_mode, choiceText:'', textAnswer:''})"]

[jump target="*start"]

*restart_answers

[cm]

[eval exp="f.rnf_restart_result=window.RNF.restartCurrentAnswers([window.RNF.getProjectConfig().ANSWERS.MAIN_CHOICE.QUESTION_ID, window.RNF.getProjectConfig().ANSWERS.MAIN_TEXT.INPUT_ID]); f.rnf_choice_text=''; f.rnf_text_answer=''; f.rnf_reflection_choice=''; f.rnf_reflection_text=''"]

回答を取り消しました。[p]

同じプレイのまま、最初から回答し直します。[p]

[jump target="*start"]

*send_data

[cm]

研究データを送信しています。[p]

しばらくお待ちください。[p]

[eval exp="f.rnf_send_done=false; f.rnf_send_success=false; f.rnf_send_status='sending'; f.rnf_send_message=''; window.RNF.sendAllResearchRecords().then(function(result){ f.rnf_send_result=result; f.rnf_send_success=result.success; f.rnf_send_status=result.status; f.rnf_send_message=result.message || ''; f.rnf_send_done=true; }).catch(function(error){ f.rnf_send_success=false; f.rnf_send_status='failed'; f.rnf_send_message=error.message; f.rnf_send_done=true; })"]

[jump target="*wait_for_send"]


*wait_for_send

[wait time=300]

[if exp="f.rnf_send_done"]

[jump target="*send_result"]

[else]

[jump target="*wait_for_send"]

[endif]


*send_result

[cm]

[if exp="f.rnf_send_success && f.rnf_send_status == 'completed'"]

[eval exp="window.RNF.getProjectConfig().SCENES.SEND_COMPLETE"]
[eval exp="f.rnf_history_result=window.RNF.saveCurrentPlayHistory()"]
[eval exp="window.RNF.clearCurrentPlaySave()"]

送信件数：[emb exp="f.rnf_send_result.sentCount"]件[p]

端末内に残っているデータ：0件[p]

[if exp="f.rnf_history_result.saved"]

今回の回答をプレイ履歴へ保存しました。[p]

プレイ履歴：[emb exp="window.RNF.getPlayHistoryCount()"]件[p]

[else]

今回のプレイは、すでに履歴へ保存されています。[p]

[endif]

ご協力ありがとうございました。[p]

[glink text="もう一度プレイする" target="*entry" x="190" y="390" width="400"]

[s]

[elsif exp="f.rnf_send_status == 'empty'"]

送信待ちの研究データはありません。[p]

すでに送信が完了している可能性があります。[p]

[s]

[elsif exp="f.rnf_send_status == 'busy'"]

現在、別の送信処理が動いています。[p]

しばらく待ってから、もう一度お試しください。[p]

[glink text="もう一度確認する" target="*send_data" x="190" y="390" width="400"]

[s]

[else]

研究データを送信できませんでした。[p]

データは端末内に保存されたままです。[p]

通信環境を確認して、もう一度お試しください。[p]

[glink text="もう一度送信する" target="*send_data" x="190" y="390" width="400"]

[s]

[endif]