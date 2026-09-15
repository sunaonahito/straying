;一番最初に呼び出されるファイル

*start

; 開発中は true
; 通常起動を確認するときは false
[eval exp="f.dev_direct_demo = false"]

[if exp="f.dev_direct_demo === true"]

    [title name="Straying Through the Fog"]

    ; デバッグ用：任意のラベルへ直接ジャンプできる入力画面
    ; 何も入力せずOKを押すと*entry（先頭）から開始する
    [cm]
    Debug: enter a label to jump to (leave blank to start from the beginning)[p]
    [iscript]
    f.debug_jump_label = "";
    [endscript]
    [edit name="f.debug_jump_label" width="400" height="50" size="24" left=440 top=300]
    [button graphic="ok.png" folder="image" target="*debug_jump_check" x=650 y=370]

    [s]

    *debug_jump_check
    [commit]
    [iscript]
      f.debug_jump_label = (f.debug_jump_label || "").trim();
      if (f.debug_jump_label === "") { f.debug_jump_label = "entry"; }
      if (f.debug_jump_label.charAt(0) !== "*") { f.debug_jump_label = "*" + f.debug_jump_label; }
    [endscript]
    ;*entry以外へ飛ぶ場合は、キャラクター登録などの共通セットアップ（*setup_common）を
    ;先に済ませておく。*start以降のラベルはchara_new等が未実行の前提で書かれているため、
    ;素通りすると[chara_hide]等でエラーになる
    [if exp='f.debug_jump_label !== "*entry"']
    [call storage="straying_sou.ks" target="*setup_common"]
    [endif]
    [jump storage="straying_sou.ks" target="&f.debug_jump_label"]

[else]

    [title name="Straying Through the Fog"]

    [stop_keyconfig]

    @call storage="tyrano.ks"

    @layopt layer="message" visible=false

    [hidemenubutton]

    @jump storage="title.ks"

[endif]

[s]