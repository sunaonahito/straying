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

; 大学側で研究同意を取得済みであることを前提に、
; RNF内部のConsent状態だけを現在Participantへ登録
[eval exp="window.RNF.recordConsent()"]

; SOU研究参加フローへ
[jump target="*notice"]


; ========================================
; 注意事項
; ========================================

*notice

[cm]

;タイトル画面用にメッセージ枠を隠す設定(first.ks)が正しく効いていない場合の
;保険として、ここでも明示的に隠しておく（サイズ未設定の枠が一瞬重なって
;黒く見えてしまう不具合の対策）
@layopt layer="message" visible=false

;注意事項一覧はユーザー作成のnotice001.jpg（日英併記）に差し替え
;メニューボタンと同様、少し時間をかけて表示させる
[bg storage="notice001.jpg" time=1500]
;STARTボタンは、画面中央(x=640)ではなく本文テキストの中心付近（x≈610）に
;合わせるとバランスが良かったため少し左へ。また元のy=640だと画面下端(720)
;まで20pxしかなくボタン下端が見切れていたため、文末より少し下・画面端より
;十分上のy=580へ移動
;※[glink]は環境によってサイズが指定より大きく描画される不具合があったため、
;　テキストを画像に焼き込んだ[button]方式に変更
[iscript]

if ($('#straying-notice-style').length === 0) {
    $('head').append(`
        <style id="straying-notice-style">

        .straying-notice-button {
            position: absolute;

            width: 460px;
            height: 74px;

            background-image: url("./data/image/button/modalselect_off.png");
            background-size: 100% 100%;
            background-repeat: no-repeat;

            display: flex;
            align-items: center;
            justify-content: center;

            box-sizing: border-box;

            color: #ffffff;
            font-family: sans-serif;
            font-size: 30px;
            font-weight: normal;
            letter-spacing: 0.08em;
            line-height: 1;

            text-align: center;
            cursor: pointer;
            z-index: 9999;
        }

        .straying-notice-button:hover {
            background-image: url("./data/image/button/modalselect_on.png");
        }

        </style>
    `);
}

var $noticeButton = $('<div></div>')
    .addClass('straying-notice-button')
    .text('START')
    .css({
        left: '410px',
        top: '610px'
    });

$noticeButton.on('click', function () {
    $('.straying-notice-button').remove();

    TYRANO.kag.ftag.startTag('jump', {
        target: '*start'
    });
});

$('#tyrano_base').append($noticeButton);

[endscript]

[s]


; ========================================
; 研究参加への同意
; ========================================

*consent

[cm]

;notice001.jpgの背景をここで消しておく（消さないとこの後もずっと背景に残ってしまう）
[bg storage="bimg_black.png" time=100]

;同意画面から見た目を本編と統一する（メッセージ枠・クリック待ち矢印）ため、
;*startで行っている設定をここで済ませておく。*notice画面には枠を
;被せたくないため、*entryではなくここ（*notice以降）で設定している
[position layer=message0 left=0 top=423 width=1280 height=297 page=fore visible=true frame="config/t_window.png"]
[position layer=message0 page=fore margint="110" marginl="60" marginr="60" marginb="30"]
[glyph line="t_arrow.png" folder="image" fix=true left=1219 top=668 width=41 height=32]

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

[jump target="*start"]


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

*start
;キャラクター登録・キーフレーム定義・メッセージウィンドウ設定などは
;*setup_commonに切り出し、デバッグジャンプ（first.ks）からも共通で呼べるようにしている
[call storage="straying_sou.ks" target="*setup_common"]

; ============================================================
; 0. オープニング（霧の森／目を開ける・開けない）
; ============================================================
*start1
[cm]


;※time=0以外だと、クロスフェード完了を待つ処理が何らかの条件で
;　完了コールバックを呼ばないまま止まってしまうことがあったため、
;　time=0（即時）にし、代わりにwaitで間を取るようにしている
[bg storage="bimg_black.png" time=0]
[wait time=2000]

; デバッグ用
;@jump target=*wake_transition2

──なにかが、聞こえる。[p]

泣き声？　猫みたいな…。[p]

──違う、子どもの声だ。[p]

[wait time=2000]

; ----------------------------------------------------------
; 選択場面0-1：目を開ける／目を開けない（1回目）
; ----------------------------------------------------------
[iscript]
f.selEye1 = "目を開ける"
f.selEye2 = "目を開けない"
f.popUpText = "どちらかを選んでください"
[endscript]

;[image]のfolder=省略時のデフォルトは"image"ではなく"fgimage"だったため、明示的に指定
;tuto_select.pngの原寸1050x352を半分(525x176)に縮小して使用
[image layer="1" x="377" y="50" storage="tuto_select.png" folder="image" time = 100 width="525" height="176"]
;name=を付けておくと、後で同じ名前を指定して中身を書き換えられる（新規追加ではなく上書き）
[ptext layer="1" x="437" y="95" text="&f.popUpText" color="black" edge="0xFFFFFF" size="24" name="popup_ptext"]

[glink x=270 y=200 text="&f.selEye1" target="*eyes_open" graphic="select_off.png" enterimg="select_on.png" width="600" height="50" size="32" ]
[glink x=270 y=320 text="&f.selEye2" target="*eyes_closed_1" graphic="select_off.png" enterimg="select_on.png" width="600" height="50" size="32" ]

[s]

;---------
*eyes_open
;---------
[cm]
[freeimage layer="1" time="700"]
;「どちらかを選んでください」の案内テキストも合わせて消す
;※name=を指定せずに[ptext text=""]を呼ぶと「上書き」ではなく「新規追加」になってしまい
;　元のテキストは消えずに残ったままだったため、overwrite=true + 同じname=で修正
[ptext layer="1" x="437" y="95" text="" color="black" edge="0xFFFFFF" size="24" name="popup_ptext" overwrite="true"]

;まぶたの開け閉めのような演出（明滅）
;※動く霧レイヤーをこの時点から重ねると、明滅の間もずっと霧が揺れ動いてしまい
;　不自然に見えたため、明滅中はbg001a.jpgに霧をあらかじめ合成した
;　静止画（bg001a_fog.jpg）を使用する。動く霧は目が完全に開いてから重ねる
[bg storage="bg001a_fog.jpg" time="80"]
[wait time=120]
[bg storage="bimg_black.png" time="80"]
[wait time=250]

[bg storage="bg001a_fog.jpg" time="80"]
[wait time=120]
[bg storage="bimg_black.png" time="80"]
[wait time=300]

; ============================================================
; 最後の開眼：本編用の無限スクロール霧
; ============================================================

; layer 2 を取得するためのアンカー
[image layer="2" page="fore" visible=true storage="bg004.png" folder="image" opacity=0 x=0 y=0 name="fog_main_anchor"]

[iscript]
(function () {

    if (window.strayingFogMainRaf) {
        cancelAnimationFrame(window.strayingFogMainRaf);
        window.strayingFogMainRaf = null;
    }

    $('.straying-main-fog').remove();

    var $anchor = $('.fog_main_anchor');

    if (!$anchor.length) {
        return;
    }

    var $layer = $anchor.parent();
    $anchor.remove();

    var $fog = $('<div class="straying-main-fog"></div>');

    $fog.css({
        position: 'absolute',
        left: '0px',
        top: '0px',

        width: '1280px',
        height: '720px',

        backgroundImage: 'url("./data/image/bg004.png")',
        backgroundRepeat: 'repeat-x',
        backgroundPosition: '0px 0px',
        backgroundSize: 'auto 720px',

        opacity: 0,
        pointerEvents: 'none'
    });

    $layer.append($fog);

    var speed = 15;
    var positionX = 0;
    var lastTime = performance.now();

    function moveFog(now) {

        if (!$fog[0] || !$fog[0].isConnected) {
            window.strayingFogMainRaf = null;
            return;
        }

        var delta = Math.min((now - lastTime) / 1000, 0.05);
        lastTime = now;

        positionX -= speed * delta;

        $fog.css(
            'background-position',
            positionX + 'px 0px'
        );

        window.strayingFogMainRaf =
            requestAnimationFrame(moveFog);
    }

    window.strayingFogMainRaf =
        requestAnimationFrame(moveFog);

    ; 目が開くと同時に霧をゆっくり出す
    $fog.animate({ opacity: 1 }, 2600);

})();
[endscript]

; 黒から森へゆっくり開眼
[bg storage="bg001a.jpg" time="1800"]

; 霧が十分馴染むまで待つ
[wait time=800]
[wait time=400]

; 夜の森の環境音
[playbgm storage="bgm001.mp3" html5=true]

…ここは……？[p]

目を開けたとたん、[l][r]
肌にまとわりつくような[r]
冷たい感覚に気づく。[p]

土と、[r]
湿った木の匂いがする。[p]

自分の呼吸と心臓の音が[r]
やけにはっきり聞こえて、[p]

とても静かなのに、[r]
うるさい。[p]

@jump target=*forest_start

;---------
*eyes_closed_1
;---------
[cm]
;「……。」の静かな間は選択を求めていないため、案内ポップアップも一旦消す
[freeimage layer="1" time="300"]
[ptext layer="1" x="437" y="95" text="" color="black" edge="0xFFFFFF" size="24" name="popup_ptext" overwrite="true"]

……。[p]

………。[p]

; ----------------------------------------------------------
; 選択場面0-2：目を開ける／目を開けない（2回目）
; ----------------------------------------------------------
;案内ポップアップは最初の1回だけ表示すればよいため、ここでは出し直さない

[glink x=270 y=200 text="&f.selEye1" target="*eyes_open" graphic="select_off.png" enterimg="select_on.png" width="600" height="50" size="32" ]
[glink x=270 y=320 text="&f.selEye2" target="*eyes_closed_2" graphic="select_off.png" enterimg="select_on.png" width="600" height="50" size="32" ]

[s]

;---------
*eyes_closed_2
;---------
[cm]
;「……。」の静かな間は選択を求めていないため、案内ポップアップも一旦消す
[freeimage layer="1" time="300"]
[ptext layer="1" x="437" y="95" text="" color="black" edge="0xFFFFFF" size="24" name="popup_ptext" overwrite="true"]

……。[p]

………。[p]

; ----------------------------------------------------------
; 選択場面0-3：目を開ける（強制・3回目）
; ----------------------------------------------------------
;案内ポップアップは最初の1回だけ表示すればよいため、ここでは出し直さない

[glink x=270 y=250 text="&f.selEye1" target="*eyes_open" graphic="select_off.png" enterimg="select_on.png" width="600" height="50" size="32" ]

[s]

; ============================================================
; 1. 導入：霧の森で迷子になる
; ============================================================
*forest_start
[autosave]
[cm]

──どうして、こんなところに？[p]

さっき確かに[r]
眠ったはずなのに…。[p]

じゃあこれは…夢？[p]

とりあえず、[r]
あたりを見回してみる。[p]

…また、聞こえる。[p]

; ----------------------------------------------------------
; 選択場面1：声のする方へ歩く／その場にとどまる
; ----------------------------------------------------------
[iscript]
f.selApproach1 = "声のする方へ歩く"
f.selApproach2 = "その場にとどまる"
[endscript]

[glink x=270 y=200 text="&f.selApproach1" target="*approach_child" graphic="select_off.png" enterimg="select_on.png" width="600" height="50" size="32" ]
[glink x=270 y=320 text="&f.selApproach2" target="*stay_still" graphic="select_off.png" enterimg="select_on.png" width="600" height="50" size="32" ]

[s]

;---------
*approach_child
;---------
[cm]

[eval exp="window.RNF.recordChoice(window.RNF.getProjectConfig().ANSWERS.Q001.QUESTION_ID,window.RNF.getProjectConfig().ANSWERS.Q001.CHOICES.C01,'Walk toward the sound')"]

霧をかき分けるように、[r]
声のするほうへ歩き出す。[p]

@jump target=*see_child

;---------
*stay_still
;---------
[cm]

[eval exp="window.RNF.recordChoice(window.RNF.getProjectConfig().ANSWERS.Q001.QUESTION_ID,window.RNF.getProjectConfig().ANSWERS.Q001.CHOICES.C02,'Stay where you are')"]

見えない中を[r]
歩くのは危ないし、怖い。[p]

……でも。[p]

このまま立っていても、[r]
なにも変わらない気がした。[p]

意を決して、[r]
声のするほうへ歩き出す。[p]

@jump target=*see_child

; ============================================================
; 2. 子どもとの出会い
; ============================================================
*see_child
[autosave]
[cm]

暗さと濃い霧のせいで、[r]
どこを歩いているのかわからない。[p]

だけど、だんだんと[r]
声が近づいてきて──。[p]

霧の向こうに、小さな影が見える。[p]

木の根もとに膝を抱えてうずくまる、[l][r]
──子どもだ。[p]

[chara_show name="child"]

; ----------------------------------------------------------
; 選択場面2：声をかける／声をかけない
; ----------------------------------------------------------
[iscript]
f.selCall1 = "声をかける"
f.selCall2 = "声をかけない"
[endscript]

[glink x=270 y=200 text="&f.selCall1" target="*call_out" graphic="select_off.png" enterimg="select_on.png" width="600" height="50" size="32" ]
[glink x=270 y=320 text="&f.selCall2" target="*dont_call" graphic="select_off.png" enterimg="select_on.png" width="600" height="50" size="32" ]

[s]

;---------
*call_out
;---------
[cm]

[eval exp="window.RNF.recordChoice(window.RNF.getProjectConfig().ANSWERS.Q002.QUESTION_ID,window.RNF.getProjectConfig().ANSWERS.Q002.CHOICES.C01,'Call out to the child')"]

大丈夫？[p]

背中に向かって声をかけると[r]
驚いたのか、ほんの少し肩が上がる。[p]

「う……ぐす…」[p]

振り向いたその顔は、[r]
薄暗くてよく見えないけれど[r]
頬がびしょびしょに濡れていることはわかる。[p]

@jump target=*child_notices

;---------
*dont_call
;---------
[cm]

[eval exp="window.RNF.recordChoice(window.RNF.getProjectConfig().ANSWERS.Q002.QUESTION_ID,window.RNF.getProjectConfig().ANSWERS.Q002.CHOICES.C02,'Do not call out')"]

……。[p]

………。[p]

; 結局は声をかける流れになるが、いきなり強制するのではなく
; 「自分で選んだ」形にするため、選択肢を一つだけ挟む（編集メモ反映）
[glink x=270 y=250 text="声をかける" target="*dont_call_decide" graphic="select_off.png" enterimg="select_on.png" width="600" height="50" size="32" ]

[s]

;---------
*dont_call_decide
;---------
[cm]

大丈夫？[p]

背中に向かって声をかけると[l][r]
驚いたのか、ほんの少し肩が上がる。[p]

「う……ぐす…」[p]

振り向いたその顔は、[r]
薄暗くてよく見えないけれど[r]
頬がびしょびしょに濡れていることはわかる。[p]

@jump target=*child_notices

; ============================================================
; 3. 一緒に探す（探し物の中身）
; ============================================================
*child_notices
[autosave]
[cm]

「…ぐす…ひっく…」[p]

声をかけたものの、[l][r]
大粒の涙を流す子どもを見つめるだけで[r]
どうしてあげればいいのかわからない。[p]

; --- 「迷子かな？」：分岐ではなく、押すと進む会話ボタン ---
[glink x=270 y=250 text="迷子かな？" target="*ask_lost" graphic="select_off.png" enterimg="select_on.png" width="600" height="50" size="32" ]
[s]

;---------
*ask_lost
;---------
[cm]

迷子かな？[p]

自分もここがどこだかわからないのに[r]
変な質問だと思いながら、聞いてみる。[p]

「…なくし、ちゃった…」[p]

子どもは、言葉を詰まらせながらそうつぶやく。[p]

; --- 「なにを？」：会話ボタン ---
[glink x=270 y=250 text="なにを？" target="*ask_what" graphic="select_off.png" enterimg="select_on.png" width="600" height="50" size="32" ]
[s]

;---------
*ask_what
;---------
[cm]

なくしたって、なにを？[p]

「………わかんない」[p]

え？[p]

「どうしよう、うっ、[r]
なくしちゃった…ううっ…」[p]

なにをなくしたかわからないのに、[r]
なくしたことが悲しくて泣いてる…？[p]

「うっ、ぐす…ひっく…」[p]

どうしてあげたらいいのかわからなくて、[l][r]
だんだんこっちが泣きたくなってくる。[p]

; --- 「家族はどこ？」：会話ボタン ---
[glink x=270 y=250 text="家族はどこ？" target="*ask_family" graphic="select_off.png" enterimg="select_on.png" width="600" height="50" size="32" ]
[s]

;---------
*ask_family
;---------
[cm]

家族はどこにいるの？[p]

「…わかんない」[p]

「いたかもしれない。[l][r]
…でも、今はひとりぼっち」[p]

そっか…。[p]

ひとりぼっちなのは、自分も同じだ。[p]

「なくしちゃった…[r]
なくなっちゃった…ぐすっ…」[p]

だけど不思議と、[r]
自分より困っている人を見ると[r]
自分の不安は小さく思えてくる。[p]

なんとかしてあげたい。[p]

; ----------------------------------------------------------
; 選択場面3：一緒に探そう／できることはある？
; Q003
; ----------------------------------------------------------
[iscript]
f.selHelp1 = "一緒に探そう"
f.selHelp2 = "できることはある？"
[endscript]

[glink x=270 y=200 text="&f.selHelp1" target="*offer_search" graphic="select_off.png" enterimg="select_on.png" width="600" height="50" size="32" ]
[glink x=270 y=320 text="&f.selHelp2" target="*ask_help" graphic="select_off.png" enterimg="select_on.png" width="600" height="50" size="32" ]

[s]

;---------
*offer_search
;---------
[cm]

[eval exp="window.RNF.recordChoice(window.RNF.getProjectConfig().ANSWERS.Q003.QUESTION_ID,window.RNF.getProjectConfig().ANSWERS.Q003.CHOICES.C01,'Search together')"]

なくしたもの、一緒に探そう。[p]

「……ほんと？」[p]

@jump target=*search_together_yes


;---------
*ask_help
;---------
[cm]

[eval exp="window.RNF.recordChoice(window.RNF.getProjectConfig().ANSWERS.Q003.QUESTION_ID,window.RNF.getProjectConfig().ANSWERS.Q003.CHOICES.C02,'Ask what you can do')"]

なにか、できることはある？[p]

「………」[p]

「……いっしょに、さがしてほしい」[p]

わかった、一緒に探そう。[p]

「……ほんと？」[p]

@jump target=*search_together_yes

;---------
*search_together_yes
;---------
[cm]

びしょびしょに濡れた瞳が[r]
大きく開かれて、きらっと光る。[p]

大きくうなずいてみせると、[p]

「わあ…やったあ！」[p]

跳ねるような高い声が[r]
霧の中に響く。[p]

涙はぴたりと止まって、[r]
ころころと嬉しそうに笑う。[p]

言ってみて良かった。[p]

「えへへ」[p]

よっぽど嬉しかったのか、[l][r]
もたれるように体をすり寄せてくる。[p]

触れたところがあったかくて[r]
なんだかほっとする。[p]

「ん」[p]

;[chara_face]はmap_face（顔の対応表）を更新するだけで、既に表示中の
;キャラクターの見た目はその場では切り替わらない仕様だった（エラーは直ったが
;画像自体が変わらなかった原因）。*ask_nameで使っている「一度隠して
;顔を指定し直して見せる」パターンで、実際に表示を切り替える
[chara_hide name="child"]
[chara_show name="child" face="hand"]

そのまま手を握ってきて、[r]
指先が小さな指に包まれる。[p]

; ----------------------------------------------------------
; 選択場面3-2：握り返す／そのままにする
; Q004
; ----------------------------------------------------------
[iscript]
f.selHand1 = "握り返す"
f.selHand2 = "そのままにする"
[endscript]

[glink x=270 y=200 text="&f.selHand1" target="*hand_back" graphic="select_off.png" enterimg="select_on.png" width="600" height="50" size="32" ]
[glink x=270 y=320 text="&f.selHand2" target="*hand_leave" graphic="select_off.png" enterimg="select_on.png" width="600" height="50" size="32" ]

[s]

;---------
*hand_back
;---------
[cm]

[eval exp="window.RNF.recordChoice(window.RNF.getProjectConfig().ANSWERS.Q004.QUESTION_ID,window.RNF.getProjectConfig().ANSWERS.Q004.CHOICES.C01,'Hold the hand back')"]

[chara_hide name="child"]
[chara_show face="shake" name="child"]

これからよろしく、という感じで[r]
小さな手をしっかり握り返すと、[p]

「きゃきゃっ」[p]

さっきまであんなに[r]
泣いていたのが嘘みたいに、[r]
元気よく笑う。[p]

@jump target=*ask_name


;---------
*hand_leave
;---------
[cm]

[eval exp="window.RNF.recordChoice(window.RNF.getProjectConfig().ANSWERS.Q004.QUESTION_ID,window.RNF.getProjectConfig().ANSWERS.Q004.CHOICES.C02,'Leave the hand as it is')"]

よっぽど心細かったんだろう。[l][r]
握られた指をそのままにする。[p]

@jump target=*ask_name

; ============================================================
; 4. 名前をつける
; ============================================================
*ask_name
[autosave]
[cm]

[chara_hide name="child"]
[chara_show face="walk" name="child"]

「ねえ、なんて呼べばいい？」[p]

指を握ったまま飛び跳ねて、[r]
嬉しそうに尋ねてくる。[p]

なんて呼んでほしいか…。[p]

[chara_hide name="child"]

;プレースホルダー文字は入力欄の幅(280px)に収まる短い言葉にしている
;（元は「呼び名を教えてください」で長すぎて入りきっていなかった）
[iscript]

var namePlaceholderText = {
    ja: "8文字まで",
    en: "Up to 8 chars"
};

f.name_placeholder =
    namePlaceholderText[sf.language] ||
    namePlaceholderText.ja;

[endscript]

*name_input

[chara_hide name="child"]

; 再入力時に古いOKボタンが残らないよう削除
[iscript]
$('.straying-name-ok-button').remove();
[endscript]

; 入力欄を画面中央へ
[edit name="sf.player_name" width="280" height="50" size="30" left=500 top=175 maxchars=8]

[iscript]
(function () {

    $('.straying-name-ok-button').remove();

    var $btn = $('<div class="straying-name-ok-button">OK</div>');

    $btn.css({
        position: 'absolute',

        /* 幅200pxなので (1280-200)/2 = 540 */
        left: '540px',
        top: '308px',

        width: '200px',
        height: '50px',

        backgroundImage: 'url("./data/image/button/modalselect_off.png")',
        backgroundSize: '100% 100%',
        backgroundRepeat: 'no-repeat',

        fontFamily: '"Straying Sans", sans-serif',
        fontSize: '28px',
        fontWeight: '400',
        color: '#fff',

        textAlign: 'center',
        lineHeight: '50px',

        cursor: 'pointer',
        userSelect: 'none',

        zIndex: 999
    });

    $btn.on('mouseenter', function () {
        $(this).css(
            'background-image',
            'url("./data/image/button/modalselect_on.png")'
        );
    });

    $btn.on('mouseleave', function () {
        $(this).css(
            'background-image',
            'url("./data/image/button/modalselect_off.png")'
        );
    });

    $btn.on('click', function () {

        $('.straying-name-ok-button').remove();

        TYRANO.kag.ftag.startTag('jump', {
            target: '*check_name'
        });

    });

    $('.layer_free').append($btn);

})();
[endscript]

[iscript]
$(function() {
    var $editBox = $('input[name="sf.player_name"]');
    var defaultText = f.name_placeholder;
    $editBox.val(defaultText);
    $editBox.css('color', '#888');
    $editBox.on('focus', function() {
        if ($(this).val() === defaultText) {
            $(this).val('');
            $(this).css('color', '#000');
        }
    });
    $editBox.on('blur', function() {
        if ($(this).val() === '') {
            $(this).val(defaultText);
            $(this).css('color', '#888');
        }
    });
});
[endscript]

[s]

*check_name
[commit]

[iscript]
$('.straying-name-ok-button').remove();
[endscript]

[iscript]

var trimmed_name = (sf.player_name || "").trim();

if (
    trimmed_name === "" ||
    trimmed_name === f.name_placeholder
) {
    f.is_empty_name = true;
} else {
    f.is_empty_name = false;
}

[endscript]

[if exp="f.is_empty_name==true"]
[cm]
;スキップ/既読による早送りで台詞が流れてしまわないよう明示的に止める
[skipstop]

[chara_show face="walk" name="child"]


「あれ、まだ教えてもらってないよ？[r]
なんて呼べばいい？」[p]
[jump target="*name_input"]
[endif]

[cm]

;glinkのtext=属性の中では[emb]タグは評価されない（そのまま文字列として表示されて
;しまう）ため、先にiscriptで文字列を組み立ててから&f.xxxで渡している
[iscript]
f.name_confirm_text = sf.player_name + "でいい"
[endscript]

[emb exp="sf.player_name"]って、呼んでくれる？[p]

[chara_show face="walk" name="child"]

「[emb exp="sf.player_name"]さん、でいいの？」[p]

; ----------------------------------------------------------
; 選択場面4：〈名前〉でいい／やっぱり変える
; ----------------------------------------------------------
[glink x=270 y=200 text="&f.name_confirm_text" target="*name_confirm" graphic="select_off.png" enterimg="select_on.png" width="600" height="50" size="32" ]
[glink x=270 y=320 text="やっぱり変える" target="*name_retry" graphic="select_off.png" enterimg="select_on.png" width="600" height="50" size="32" ]

[s]

;---------
*name_confirm
;---------
[cm]

うん、よろしく。[p]

「よろしくね、[emb exp="sf.player_name"]さん！」[p]

@jump target=*walk_together

;---------
*name_retry
;---------
[cm]

やっぱり変えよう。[p]

@jump target=*name_input

; ============================================================
; 5. 森を歩きながらの対話
; ============================================================
*walk_together
[autosave]
[cm]

[chara_hide name="child"]

……。[p]

濃い霧の向こうに[r]
目をこらしてみる。[p]

その先に[r]
何があるのかはわからない。[p]

だけどここにいても、この子の[r]
"なくしたもの"は見つからないだろう。[p]

とりあえず、ここから[r]
出られる道を探そう。[p]

[wait time=2000]

…そもそも、[l][r]
この子はどこから来たんだろう？[p]

[chara_show face="walk" name="child"]

; ----------------------------------------------------------
; 選択場面5-1：どこから来たの？／来た道はわかる？
; ----------------------------------------------------------
[glink x=270 y=200 text="どこから来たの？" target="*ask_where_from" graphic="select_off.png" enterimg="select_on.png" width="600" height="50" size="32" ]
[glink x=270 y=320 text="来た道はわかる？" target="*ask_which_way" graphic="select_off.png" enterimg="select_on.png" width="600" height="50" size="32" ]

[s]

;---------
*ask_where_from
;---------
[cm]

きみはどこから来たの？[p]

そう聞くと、[r]
きょとんとした顔で少し上を向く。[p]

「…どこ…？」[p]

「わかんない。[l][r]
どこだろ？」[p]

…そっか。[p]

@jump target=*decide_walk

;---------
*ask_which_way
;---------
[cm]

来た道はわかる？[p]

そう聞くと、[r]
きょとんとした顔で少し上を向く。[p]

「…道…？」[p]

ここに来るまで、どんな道を[r]
来たか覚えてる？[p]

「ううん、わかんない。[l][r]
どこだろ？」[p]

…そっか。[p]

@jump target=*decide_walk

;---------
*decide_walk
;---------
[cm]

それなら、一緒に探すしかない。[p]

; ----------------------------------------------------------
; 選択場面5-2：探検してみよう／歩いてみよう
; ----------------------------------------------------------
[glink x=270 y=200 text="探検してみよう" target="*explore" graphic="select_off.png" enterimg="select_on.png" width="600" height="50" size="32" ]
[glink x=270 y=320 text="歩いてみよう" target="*just_walk" graphic="select_off.png" enterimg="select_on.png" width="600" height="50" size="32" ]

[s]

;---------
*explore
;---------
[cm]

一緒に探検してみよう。[p]

「うん！　探検！」[p]

その言葉が魅力的に聞こえたのか[r]
にっこり笑って[r]
指を握る手に力が込められる。[p]

その反応にほっとして、[r]
手をつないだまま歩き出す。[p]

@jump target=*walking_fog

;---------
*just_walk
;---------
[cm]

一緒に歩いてみようか。[p]

「うん」[p]

その答えを聞いて、[r]
手をつないだまま歩き出す。[p]

@jump target=*walking_fog

;---------
*walking_fog
;---------
[cm]

[chara_hide name="child"]
[wait time=2000]

……。[p]

………。[p]

二人でゆっくり、[r]
霧の中を歩いてみる。[p]

たまに、すねあたりに[r]
草の当たる感触がある。[p]

もしかすると、[l][r]
人が歩いていい道じゃ[r]
ないのかもしれない。[p]

このまま歩き続けて、[r]
どこへ向かうんだろう？[p]

肌にまとわりつく湿り気が[r]
余計に焦らせて、[p]

暑さは感じないのに[r]
額からじわりと汗がしみ出す。[p]

……。[p]

自分の不安が伝わってしまいそうで、[l][r]
そっと手をほどく。[p]

[chara_show name="child"]

「…だいじょうぶ？」[p]

心配そうに顔をのぞき込まれる。[l][r]
さっきまではこの子の方が[r]
不安で仕方なさそうだったのに。[p]

大丈夫じゃない、と答えたいけど[r]
もうあの泣き顔は見たくない。[p]

かと言って、大丈夫だとも答えられない。[p]

なにも言えずにいると、[p]

「みつからないのかなあ」[p]

小さなつぶやきが、[r]
霧の中に響く。[p]

──せめて、この子の不安は[r]
少しでも軽くしてあげたい。[p]

; ----------------------------------------------------------
; 選択場面5-3：まだ思い出せない？／なにか思い出した？
; ----------------------------------------------------------
[glink x=270 y=200 text="まだ思い出せない？" target="*memory_no" graphic="select_off.png" enterimg="select_on.png" width="600" height="50" size="32" ]
[glink x=270 y=320 text="なにか思い出した？" target="*memory_yes" graphic="select_off.png" enterimg="select_on.png" width="600" height="50" size="32" ]

[s]

;---------
*memory_no
;---------
[cm]

なくしたものがなにか、[r]
まだ思い出せない？[p]

「……うん」[p]

@jump target=*ask_hint

;---------
*memory_yes
;---------
[cm]

なくしたものがなにか、[r]
思い出した？[p]

「……ううん」[p]

@jump target=*ask_hint

;---------
*ask_hint
;---------
[cm]

なにか、ヒントはないかな。[p]

「ヒント？」[p]

たとえば…大きさとか、[r]
色とか形とか、匂いとか…。[p]

誰かにもらったとか、[r]
自分で買ったとか。[p]

「…………」[p]

考え込んでいる様子を[r]
祈るような気持ちで見つめる。[p]

せめてこの子の探しものが見つかれば[l][r]
ちょっとは気持ちが軽くなる気がする。[p]

「なくしたくない、もの」[p]

……。[p]

ヒント、それだけ？[p]

「ねえ、[emb exp="sf.player_name"]さんが[l][r]
なくしたくないものって、なに？」[p]

自分が、なくしたくないもの？[p]

「うん。[r]
もしかしたら、同じものかもしれないから」[p]

…なるほど。[p]

ヒントになるのかわからないけど[r]
考えてみよう。[p]

なくしたくないもの。[l][r]
…つまり、なくすと困るもの？[p]

; ----------------------------------------------------------
; 選択場面5-4：ポケットの中身（お金／学生証／スマホ）
; Q005
; ----------------------------------------------------------
[iscript]
f.selPocket1 = "お金"
f.selPocket2 = "学生証"
f.selPocket3 = "スマホ"
f.button1 = 0
f.button2 = 0
f.button3 = 0
[endscript]

;画面中央に3つ並べて表示（この後、選んだ分だけ*after_pocket_checkで中央揃えし直す）
[glink x=416 y=206 text="&f.selPocket1" target="*pocket_money" graphic="select_off.png" enterimg="select_on.png" width="320" height="44" size="32" ]
[glink x=416 y=306 text="&f.selPocket2" target="*pocket_id" graphic="select_off.png" enterimg="select_on.png" width="320" height="44" size="32" ]
[glink x=416 y=406 text="&f.selPocket3" target="*pocket_phone" graphic="select_off.png" enterimg="select_on.png" width="320" height="44" size="32" ]

[s]

;---------
*pocket_money
;---------
[cm]

[eval exp="window.RNF.recordChoice(window.RNF.getProjectConfig().ANSWERS.Q005.QUESTION_ID,window.RNF.getProjectConfig().ANSWERS.Q005.CHOICES.C01,'Money')"]

[eval exp="f.button1=1"]

お金かな。[p]

「ちがう」[p]

即答。[l][r]
なんだか申し訳ない気持ちになる。[p]

@jump target=*after_pocket_check


;---------
*pocket_id
;---------
[cm]

[eval exp="window.RNF.recordChoice(window.RNF.getProjectConfig().ANSWERS.Q005.QUESTION_ID,window.RNF.getProjectConfig().ANSWERS.Q005.CHOICES.C02,'Student ID')"]

[eval exp="f.button2=1"]

学生証かな。[r]
身分を証明するものだから。[p]

「うーん、ちがうかな」[p]

そうじゃないとしたら…。[p]

@jump target=*after_pocket_check


;---------
*pocket_phone
;---------
[cm]

[eval exp="window.RNF.recordChoice(window.RNF.getProjectConfig().ANSWERS.Q005.QUESTION_ID,window.RNF.getProjectConfig().ANSWERS.Q005.CHOICES.C03,'Smartphone')"]

[eval exp="f.button3=1"]

スマホかな。[r]
必要なものが全部入ってるから。[p]

「そういうのじゃない…」[p]

そうじゃないとしたら…。[p]

@jump target=*after_pocket_check

;---------
*after_pocket_check
;---------
[cm]

; 3択すべて選ぶまで繰り返す
; 残りの選択肢を常に画面中央へ再配置する
[if exp="f.button1==0 || f.button2==0 || f.button3==0"]

[iscript]

var pocket_remaining = [];

if (f.button1 == 0) pocket_remaining.push("money");
if (f.button2 == 0) pocket_remaining.push("id");
if (f.button3 == 0) pocket_remaining.push("phone");

; 見た目上の画面中央
var pocket_centerY = 360;

; ボタン同士の中心間隔
var pocket_gap = 100;

; CSSのpadding込みで見た目の高さは約108px
; glinkのyはボタン外枠の上端なので、その半分を引く
var pocket_visual_half = 54;

var pocket_startCenterY =
    pocket_centerY -
    (pocket_remaining.length - 1) * pocket_gap / 2;

var pocket_posMap = {};

for (var pi = 0; pi < pocket_remaining.length; pi++) {

    var centerY =
        pocket_startCenterY +
        pi * pocket_gap;

    pocket_posMap[pocket_remaining[pi]] =
        Math.round(centerY - pocket_visual_half);
}

f.pos_y_money = pocket_posMap.money;
f.pos_y_id = pocket_posMap.id;
f.pos_y_phone = pocket_posMap.phone;

[endscript]


[if exp="f.button1==0"]
[glink x=416 y="&f.pos_y_money" text="&f.selPocket1" target="*pocket_money" graphic="select_off.png" enterimg="select_on.png" width="320" height="44" size="32" ]
[endif]

[if exp="f.button2==0"]
[glink x=416 y="&f.pos_y_id" text="&f.selPocket2" target="*pocket_id" graphic="select_off.png" enterimg="select_on.png" width="320" height="44" size="32" ]
[endif]

[if exp="f.button3==0"]
[glink x=416 y="&f.pos_y_phone" text="&f.selPocket3" target="*pocket_phone" graphic="select_off.png" enterimg="select_on.png" width="320" height="44" size="32" ]
[endif]

[s]

[endif]

@jump target=*after_pocket

;---------
*after_pocket
;---------
[cm]

…なんだろう。[p]

お金より、学生証より、スマホより[l][r]
なくしたくないもの。[p]

なくしてしまった時に、[l][r]
あんなに悲しくなるもの…。[p]

目を開ける前に聞いた、[l][r]
あの泣き声を思い出す。[p]

「…かわりがないもの…[l][r]
だった気がする」[p]

──かわりがないもの。[p]

つまり代わりがきかない、[l][r]
代わりが存在しないもの、ってことか。[p]

確かに、お金はなくなったら困るけど[l][r]
また手に入れる方法がある。[p]

学生証も、教務課で申請すれば[l][r]
再発行してもらえる。[p]

スマホも、バックアップしていれば[l][r]
中身は復旧できる。[p]

──じゃあ、本当に[l][r]
かわりがないもの、って[r]
なんなんだろう？[p]

「…なんだろう？」[p]

こちらの心を読んでいるような[l][r]
タイミングで、問いかけられる。[p]

; ----------------------------------------------------------
; 選択場面5-5：一緒に考えよう／思いつかない
; Q006
; ----------------------------------------------------------
[glink x=270 y=200 text="一緒に考えよう" target="*think_together" graphic="select_off.png" enterimg="select_on.png" width="600" height="50" size="32" ]
[glink x=270 y=320 text="思いつかない" target="*cant_think" graphic="select_off.png" enterimg="select_on.png" width="600" height="50" size="32" ]

[s]

;---------
*think_together
;---------
[cm]

[eval exp="window.RNF.recordChoice(window.RNF.getProjectConfig().ANSWERS.Q006.QUESTION_ID,window.RNF.getProjectConfig().ANSWERS.Q006.CHOICES.C01,'Think together')"]

一緒に考えてみようか。[p]

「うん！」[p]

たとえば……。[p]

@jump target=*floating_words


;---------
*cant_think
;---------
[cm]

[eval exp="window.RNF.recordChoice(window.RNF.getProjectConfig().ANSWERS.Q006.QUESTION_ID,window.RNF.getProjectConfig().ANSWERS.Q006.CHOICES.C02,'Cannot think of anything')"]

思いつかないな…。[p]

「じゃあ、一緒に考えようよ」[p]

二人なら、思いつくかもしれない。[l][r]
その言葉に力強くうなずいた。[p]

@jump target=*floating_words

;---------
*floating_words
;---------
[cm]

「たとえば…」[p]

ゆっくり、お互いが[r]
思いついたものを挙げていく。[p]

[chara_hide name="child"]

; ----------------------------------------------------------
; 演出：候補の言葉がふわっと浮かぶ
; ----------------------------------------------------------

[iscript]
(function () {

    $('.straying-floating-words').remove();

    var $wrap = $('<div class="straying-floating-words"></div>');

    $wrap.css({
        position: 'absolute',
        left: '0px',
        top: '0px',
        width: '1280px',
        height: '720px',
        pointerEvents: 'none',
        zIndex: 9999
    });

    $('.layer_fore:visible').last().append($wrap);

    function makeWord(text, left, top, delay) {

    var $word = $('<div></div>');
    var $text = $('<span></span>');
    var $glow = $('<div></div>');

    $text.text(text);

    $word.css({
        position: 'absolute',
        left: left + 'px',
        top: top + 'px',

        width: '320px',
        height: '60px',

        textAlign: 'center',
        lineHeight: '60px',

        opacity: 0
    });

    $glow.css({
        position: 'absolute',
        left: '20px',
        top: '10px',

        width: '280px',
        height: '40px',

        borderRadius: '50%',

        background:
            'radial-gradient(ellipse at center, ' +
            'rgba(225, 240, 248, 0.20) 0%, ' +
            'rgba(195, 222, 235, 0.10) 45%, ' +
            'rgba(160, 200, 220, 0.00) 75%)',

        filter: 'blur(10px)',

        pointerEvents: 'none',
        zIndex: '0'
    });

    $text.css({
        position: 'relative',
        zIndex: '1',

        fontFamily: '"Straying Sans", sans-serif',
        fontSize: '28px',
        fontWeight: '400',

        color: 'rgba(250, 252, 255, 0.97)',

        textShadow:
            '0 0 6px rgba(255, 255, 255, 0.65), ' +
            '0 0 14px rgba(225, 240, 248, 0.45), ' +
            '0 0 28px rgba(190, 220, 235, 0.30)'
    });

    $word.append($glow);
    $word.append($text);

    $wrap.append($word);

    setTimeout(function () {

        $word.animate(
            {
                opacity: 0.85,
                top: (top - 12) + 'px'
            },
            1800
        );

    }, delay);
}

    // 1つずつ、ゆっくり間を空けて表示
    makeWord('大切な人',      120, 110,    0);
    makeWord('贈りもの',      480,  90, 1200);
    makeWord('言葉',          820, 140, 2400);
    makeWord('宝物',          180, 300, 3600);
    makeWord('目標',          540, 320, 4800);
    makeWord('思い出の場所',  860, 280, 6000);

})();
[endscript]

; 最後の言葉が完全に出るまで待つ
[wait time=8000]

; 6つを眺める時間
[wait time=2500]

; プレイヤーが確認してから次へ
[p]

二人で考えたおかげで、[l][r]
いろんなものが思い浮かぶ。[p]

「そっか…[l][r]
そう、なのかも」[p]

隣で、目を丸く開いて[l][r]
小さくつぶやく。[p]

なにか、思い出せそう？[p]

「…ねえ、[emb exp="sf.player_name"]さんの[l][r]
なくしたくないものは、[r]
この中にある？」[p]

──自分が、[l][r]
なくしたくないもの…。[p]

「なくしたくない、大切な人。[l][r]
なくしたくない、贈りもの…[r]
なくしたくない、言葉とか」[p]

そうだな…。[p]

; 候補語演出を選択肢表示前に消す
[iscript]
$('.straying-floating-words').fadeOut(700, function () {
    $(this).remove();
});
[endscript]

[wait time=700]

; ----------------------------------------------------------
; 選択場面5-6：ある／多分ある
; ----------------------------------------------------------
[glink x=270 y=200 text="ある" target="*there_is" graphic="select_off.png" enterimg="select_on.png" width="600" height="50" size="32" ]
[glink x=270 y=320 text="多分ある" target="*maybe_is" graphic="select_off.png" enterimg="select_on.png" width="600" height="50" size="32" ]

[s]

;---------
*there_is
;---------
[cm]

ある。[p]

「ほんと？」[p]

答えると、[l][r]
ぱあっと目を輝かせる。[p]

「ねえ、もっと教えて！[l][r]
[emb exp="sf.player_name"]さんの[r]
なくしたくないもののこと！」[p]

こちらの手をぎゅっと握って[l][r]
引っ張るように揺さぶってくる。[p]

@jump target=*treasure_category

;---------
*maybe_is
;---------
[cm]

多分…あるかも。[p]

「かも…？」[p]

答えると、[l][r]
不安そうに声を震わせる。[p]

うーん…[l][r]
そんな反応をされると…。[p]

; ----------------------------------------------------------
; 選択場面5-7：ある気がしてきた（強制）
; ----------------------------------------------------------
[glink x=270 y=250 text="ある気がしてきた" target="*there_is_now" graphic="select_off.png" enterimg="select_on.png" width="600" height="50" size="32" ]

[s]

;---------
*there_is_now
;---------
[cm]

…ある気がしてきた。[p]

「ほんと？」[p]

答えると、[l][r]
ぱあっと目を輝かせる。[p]

「ねえ、もっと教えて！[l][r]
[emb exp="sf.player_name"]さんの[r]
なくしたくないもののこと！」[p]

こちらの手をぎゅっと握って[l][r]
引っ張るように揺さぶってくる。[p]

@jump target=*treasure_category

; ============================================================
; 6. 「大切なもの」カテゴリ選択＋自由記述（最大3回）
; ============================================================
*treasure_category
[autosave]
[cm]

[iscript]
f.selCat1 = "大切な人"
f.selCat2 = "贈りもの"
f.selCat3 = "言葉"
f.selCat4 = "宝物"
f.selCat5 = "目標"
f.selCat6 = "思い出の場所"
[endscript]

「この中からひとつ、[r]
選んでみて？」[p]

; ----------------------------------------------------------
; 大切なもの：6つの言葉をそのまま選択肢にする
; ----------------------------------------------------------

[iscript]
(function () {

    $('.straying-treasure-choices').remove();

    var $wrap = $('<div class="straying-treasure-choices"></div>');

    $wrap.css({
        position: 'absolute',
        left: '0px',
        top: '0px',
        width: '1280px',
        height: '720px',
        pointerEvents: 'none',
        zIndex: 9999
    });

    $('.layer_fore:visible').last().append($wrap);

    var choiceLocked = false;


    function makeChoice(text, target, left, top, delay) {

        var $choice = $('<div></div>');
        var $text = $('<span></span>');
        var $glow = $('<div></div>');

        $text.text(text);


        /* 選択肢全体 */
        $choice.css({
            position: 'absolute',

            left: left + 'px',
            top: (top + 8) + 'px',

            width: '320px',
            height: '60px',

            textAlign: 'center',
            lineHeight: '60px',

            cursor: 'pointer',
            pointerEvents: 'auto',
            userSelect: 'none',

            opacity: 0
        });


        /* 文字の後ろの淡い光 */
        $glow.css({
            position: 'absolute',

            left: '20px',
            top: '10px',

            width: '280px',
            height: '40px',

            borderRadius: '50%',

            background:
                'radial-gradient(ellipse at center, ' +
                'rgba(225,240,248,0.12) 0%, ' +
                'rgba(195,222,235,0.06) 45%, ' +
                'rgba(160,200,220,0.00) 75%)',

            filter: 'blur(10px)',

            pointerEvents: 'none'
        });


        /* 通常時の文字 */
        $text.css({
            position: 'relative',
            zIndex: '1',

            fontFamily: '"Straying Sans", sans-serif',
            fontSize: '28px',
            fontWeight: '400',

            color: 'rgba(245,248,250,0.90)',

            textShadow:
                '0 0 6px rgba(255,255,255,0.35), ' +
                '0 0 14px rgba(220,235,245,0.20)',

            /* 「選べる」ことを示す薄い下線 */
            borderBottom:
                '1px solid rgba(230,240,245,0.16)',

            paddingBottom: '4px'
        });


        $choice.append($glow);
        $choice.append($text);

        $wrap.append($choice);


        /* 少しずつ出現 */
        setTimeout(function () {

            $choice.animate(
                {
                    opacity: 1,
                    top: top + 'px'
                },
                600
            );

        }, delay);


        /* --------------------------------
           ホバー時
        -------------------------------- */
        $choice.on('mouseenter', function () {

            $glow.css({
                background:
                    'radial-gradient(ellipse at center, ' +
                    'rgba(235,247,252,0.28) 0%, ' +
                    'rgba(205,230,240,0.14) 45%, ' +
                    'rgba(170,205,220,0.00) 78%)'
            });


            $text.css({

                color: 'rgba(255,255,255,1)',

                borderBottom:
                    '1px solid rgba(240,250,255,0.55)',

                textShadow:
                    '0 0 6px rgba(255,255,255,0.65), ' +
                    '0 0 16px rgba(220,240,248,0.42), ' +
                    '0 0 28px rgba(190,220,235,0.22)'
            });

        });


        /* --------------------------------
           ホバー解除
        -------------------------------- */
        $choice.on('mouseleave', function () {

            $glow.css({
                background:
                    'radial-gradient(ellipse at center, ' +
                    'rgba(225,240,248,0.12) 0%, ' +
                    'rgba(195,222,235,0.06) 45%, ' +
                    'rgba(160,200,220,0.00) 75%)'
            });


            $text.css({

                color: 'rgba(245,248,250,0.90)',

                borderBottom:
                    '1px solid rgba(230,240,245,0.16)',

                textShadow:
                    '0 0 6px rgba(255,255,255,0.35), ' +
                    '0 0 14px rgba(220,235,245,0.20)'
            });

        });


        /* --------------------------------
           選択時
        -------------------------------- */
        $choice.on('click', function () {

            if (choiceLocked) return;

            choiceLocked = true;


            $('.straying-treasure-choices').fadeOut(
                300,
                function () {

                    $(this).remove();

                    TYRANO.kag.ftag.startTag(
                        'jump',
                        {
                            target: target
                        }
                    );

                }
            );

        });

    }


    /* 6つの選択肢 */

    makeChoice(
        f.selCat1,
        '*cat_person',
        120,
        98,
        0
    );

    makeChoice(
        f.selCat2,
        '*cat_gift',
        480,
        78,
        180
    );

    makeChoice(
        f.selCat3,
        '*cat_words',
        820,
        128,
        360
    );

    makeChoice(
        f.selCat4,
        '*cat_treasure',
        180,
        288,
        540
    );

    makeChoice(
        f.selCat5,
        '*cat_goal',
        540,
        308,
        720
    );

    makeChoice(
        f.selCat6,
        '*cat_place',
        860,
        268,
        900
    );

})();
[endscript]

[s]

;---------
*cat_person
;---------
[cm]
[if exp="f.used_person == 0"]
なくしたくない、[l][r]
大切な人がいるよ。[p]

「[emb exp="sf.player_name"]さんの[r]
大切な人って、どんな人？」[p]

どんな人…。[p]

あの人の顔や[r]
一緒に過ごした時間を、[r]
思い浮かべてみる。[p]

[else]
;2回目以降に同じカテゴリを選んだ場合の反応（新規に書き起こし）
大切な人が、[r]
もう一人いるよ。[p]

「他にもいるの？　すごい！[l][r]
その人のこと、教えて！」[p]
[endif]
[eval exp="f.used_person = 1"]
[eval exp='if (f.first_category == "") f.first_category = "person";']
@jump target=*treasure_freewrite

;---------
*cat_gift
;---------
[cm]
[if exp="f.used_gift == 0"]
なくしたくない、[l][r]
贈りものがあるよ。[p]

「どんなもの？[r]
どんな人からもらったの？」[p]

どんなもの…。[p]

贈ってくれた人のことや[r]
なくしたくない理由を、考えてみる。[p]

[else]
もうひとつ、[r]
大切な贈り物があるよ。[p]

「他にもあるの？　すごい！[l][r]
その贈り物のこと、教えて！」[p]
[endif]
[eval exp="f.used_gift = 1"]
[eval exp='if (f.first_category == "") f.first_category = "gift";']
@jump target=*treasure_freewrite

;---------
*cat_words
;---------
[cm]
[if exp="f.used_words == 0"]
なくしたくない、[l][r]
言葉があるよ。[p]

「どんな言葉？[r]
どこかで見つけたの？[r]
誰かに言われたの？」[p]

どんな言葉…。[p]

その言葉を思い出して[r]
どうして特別なのか、考えてみる。[p]

[else]
もうひとつ、[r]
大切な言葉があるよ。[p]

「他にもあるの？　すごい！[l][r]
その言葉のこと、教えて！」[p]
[endif]
[eval exp="f.used_words = 1"]
[eval exp='if (f.first_category == "") f.first_category = "words";']
@jump target=*treasure_freewrite

;---------
*cat_treasure
;---------
[cm]
[if exp="f.used_treasure == 0"]
なくしたくない、[l][r]
宝物を持ってるよ。[p]

「どんなもの？[r]
どうやって見つけたの？」[p]

どんなもの…。[p]

自分にとって[r]
あれがどうして宝物なのかを[r]
なんて説明したらいいか、考えてみる。[p]
[else]
もうひとつ、[r]
宝物があるよ。[p]

「他にもあるの？　すごい！[l][r]
その宝物のこと、教えて！」[p]
[endif]
[eval exp="f.used_treasure = 1"]
[eval exp='if (f.first_category == "") f.first_category = "treasure";']
@jump target=*treasure_freewrite

;---------
*cat_goal
;---------
[cm]
[if exp="f.used_goal == 0"]
なくしたくない、[l][r]
目標があるよ。[p]

「どんな目標？[r]
いつからあるの？[r]
どうやってできたの？」[p]

どんな目標…。[p]

いつから、どうやって…[r]
目標が生まれた時のことを[r]
思い出してみる。[p]

[else]
もうひとつ、[r]
大切な目標があるよ。[p]

「他にもあるの？　すごい！[l][r]
その目標のこと、教えて！」[p]
[endif]
[eval exp="f.used_goal = 1"]
[eval exp='if (f.first_category == "") f.first_category = "goal";']
@jump target=*treasure_freewrite

;---------
*cat_place
;---------
[cm]
[if exp="f.used_place == 0"]
なくしたくない、[l][r]
思い出の場所があるよ。[p]

「どんな場所？[r]
どんな思い出があるの？」[p]

あの場所の思い出…。[p]

どんな風に過ごして[r]
どんな思い出があるか、考えてみる。[p]

[else]
もうひとつ、[r]
大切な場所があるよ。[p]

「他にもあるの？　すごい！[l][r]
その場所のこと、教えて！」[p]
[endif]
[eval exp="f.used_place = 1"]
[eval exp='if (f.first_category == "") f.first_category = "place";']
@jump target=*treasure_freewrite

; ----------------------------------------------------------
; 自由記述パート
; ----------------------------------------------------------
*treasure_freewrite
[cm]

[if exp="f.treasure_round == 0"]

「どんなことでもいいから、[r]
教えてほしいな」[p]

待ちきれないというように、[r]
じっとこちらを見つめている。[p]

うまく言葉にできるだろうか。[l][r]
──でも、やってみよう。[p]

[else]

「ほかにもあったら、[r]
聞かせてほしいな」[p]

[endif]

[iscript]
f.treasureInput = "ここに書いてください"
[endscript]

*treasure_input_label
[label name="treasure_input_label"]

; 再入力時に古いOKボタンが残らないよう削除
[iscript]
$('.straying-treasure-ok-button').remove();
[endscript]

; 自由記入欄
; 最大60文字
[edit name="sf.player_treasure" width="700" height="50" size="26" left=290 top=280 maxchars=60]

[iscript]
(function () {

    var $editBox = $('input[name="sf.player_treasure"]');

    var treasurePlaceholderText = {
        ja: "60文字まで",
        en: "Up to 60 chars"
    };

    var currentLang =
        TYRANO.kag.variable.sf.language || "ja";

    var placeholder =
        treasurePlaceholderText[currentLang] ||
        treasurePlaceholderText.ja;

    $editBox.val('');

    $editBox.attr(
        'placeholder',
        placeholder
    );

    $editBox.css({
        color: '#000',
        boxSizing: 'border-box'
    });

})();
[endscript]


; ----------------------------------------------------------
; OKボタン
; ----------------------------------------------------------
[iscript]
(function () {

    $('.straying-treasure-ok-button').remove();

    var $btn = $('<div class="straying-treasure-ok-button">OK</div>');

    $btn.css({
        position: 'absolute',

        left: '540px',
        top: '368px',

        width: '200px',
        height: '50px',

        backgroundImage: 'url("./data/image/button/modalselect_off.png")',
        backgroundSize: '100% 100%',
        backgroundRepeat: 'no-repeat',

        fontFamily: '"Straying Sans", sans-serif',
        fontSize: '28px',
        fontWeight: '400',
        color: '#fff',

        textAlign: 'center',
        lineHeight: '50px',

        cursor: 'pointer',
        userSelect: 'none',

        zIndex: 999
    });

    $btn.on('mouseenter', function () {
        $(this).css(
            'background-image',
            'url("./data/image/button/modalselect_on.png")'
        );
    });

    $btn.on('mouseleave', function () {
        $(this).css(
            'background-image',
            'url("./data/image/button/modalselect_off.png")'
        );
    });

    $btn.on('click', function () {

        $('.straying-treasure-ok-button').remove();

        TYRANO.kag.ftag.startTag('jump', {
            target: '*check_treasure'
        });

    });

    $('.layer_free').append($btn);

})();
[endscript]

[s]

*check_treasure
[commit]

[iscript]
$('.straying-treasure-ok-button').remove();

var treasureText = (sf.player_treasure || "").trim();

if (!Array.isArray(sf.treasures)) {
    sf.treasures = [];
}

sf.treasures.push(treasureText);
f.treasure_round = sf.treasures.length;

/*
 * 自由記入を入力順にRNFへ保存
 * 1回目 → I001_1
 * 2回目 → I001_2
 * 3回目 → I001_3
 */
var inputKey = "I001_" + f.treasure_round;
var answersConfig = window.RNF.getProjectConfig().ANSWERS;

if (answersConfig[inputKey]) {
    window.RNF.recordTextInput(
        answersConfig[inputKey].INPUT_ID,
        treasureText
    );
}
[endscript]

[cm]

「[emb exp="sf.player_treasure"]」[p]

「…そうなんだね」[p]

「教えてくれて、ありがとう」[p]

; ==========================================================
; 世界の変化は初回回答時だけ
; ==========================================================

[if exp="f.treasure_round == 1"]

満足そうににっこりと[r]
微笑んだ、その時。[p]

;要素材：夜霧の森
[bg storage="bg001b.jpg" time="2000"]

;;SE：強調
[playse storage="se001.mp3"]

[iscript]
$('.layer_fore')
    .filter(function(){
        return this.className.indexOf('2_fore') !== -1;
    })
    .animate({
        opacity: 170/255
    }, 4000);
[endscript]


; ----------------------------------------------------------
; 「…あれ？」の直前で ch003.png を非表示
; ----------------------------------------------------------
[iscript]
$('img').filter(function () {
    var src = this.src || "";
    return src.indexOf("ch003.png") !== -1;
}).fadeOut(300);
[endscript]


…あれ？[p]

あたりがほんのりと[r]
明るくなっていることに気づく。[p]

暗さに目が[r]
慣れただけかもしれない。[p]

[endif]


; ==========================================================
; 3回答えたら終了
; ==========================================================

[if exp="f.treasure_round >= 3"]

@jump target=*treasure_finish

[endif]


; ==========================================================
; 3回答えたら自動終了
; ==========================================================

[if exp="f.treasure_round >= 3"]

[iscript]
f.treasure_end_reason = "max";
[endscript]

@jump target=*treasure_finish

[endif]


; ==========================================================
; 1回目・2回目だけ継続確認
; ==========================================================

「ねえ、[emb exp="sf.player_name"]さんの[l][r]
なくしたくないもの、[r]
他にもある？」[p]

[iscript]
f.selMore1 = "もう少し話したい"
f.selMore2 = "もう思いつかない"
[endscript]

[glink x=270 y=250 text="&f.selMore1" target="*treasure_category" graphic="select_off.png" enterimg="select_on.png" width="600" height="50" size="32"]

[glink x=270 y=350 text="&f.selMore2" target="*treasure_no_more" graphic="select_off.png" enterimg="select_on.png" width="600" height="50" size="32"]

[s]


; ==========================================================
; 「もう思いつかない」を選んだ場合
; ==========================================================

*treasure_no_more

[iscript]
f.treasure_end_reason = "no_more";
[endscript]

@jump target=*treasure_finish


; ==========================================================
; 自由記述終了
; ==========================================================

*treasure_finish
[cm]

[if exp="f.treasure_end_reason == 'no_more'"]

…もう思いつかないかな。[p]

「そっか。ありがとう」[p]

[endif]

──自分が、[l][r]
なくしたくないもののこと。[p]

考えているうちに、[l][r]
気づいたらあたりの様子が[r]
変わっている。[p]

最初に目を開けた時は[l][r]
真っ暗で、霧に囲まれて、[r]
この子の泣き声だけが聞こえて。[p]

すごく不安だった。[p]

だけど、今は──。[p]

;;BGM：安堵
[playbgm storage="bgm002.mp3" html5=true]
「ここ、好き」[p]

隣で、心から安心した表情で[l][r]
あたりを見回している様子を見ると、[r]
それがずっと昔のことのように思える。[p]

「…なんだか、安心する」[p]

その言葉に小さくうなずくと、[p]

「[emb exp="sf.player_name"]さんも、[l][r]
ここが好き？」[p]

問いかけられて、考える。[p]

; ============================================================
; 7. この場所が好き？
; ============================================================
*self_question
[autosave]
[cm]

;要素材：夜霧の森（さらに明るく、地面の草花がうっすら見え始める）
[bg storage="bg001c.jpg" time="2000"]

[iscript]
f.selSelf1 = "好き"
f.selSelf2 = "悪くない"
f.selSelf3 = "今より好きになりたい"
[endscript]

[glink x=270 y=200 text="&f.selSelf1" target="*self_like" graphic="select_off.png" enterimg="select_on.png" width="600" height="50" size="32" ]
[glink x=270 y=300 text="&f.selSelf2" target="*self_okay" graphic="select_off.png" enterimg="select_on.png" width="600" height="50" size="32" ]
[glink x=270 y=400 text="&f.selSelf3" target="*self_want" graphic="select_off.png" enterimg="select_on.png" width="600" height="50" size="32" ]

[s]

;---------
*self_like
;---------
[cm]

好き、かなあ。[p]

「えへへ」[p]

自分に言われたかのように[l][r]
嬉しそうに照れ笑いを見せる。[p]

「よかったあ」[p]

@jump target=*deepen

;---------
*self_okay
;---------
[cm]

悪くない、かな。[p]

「そっか。[l][r]
悪くない、悪くない」[p]

満足そうにうなずきながら[r]
その言葉を繰り返しつぶやく。[p]

@jump target=*deepen

;---------
*self_want
;---------
[cm]

今はまだ、そんなに…。[p]

だから、今より[r]
好きになりたいな。[p]

「そっか。[l][r]
そういうの、いいね」[p]

少し驚いたように目を丸くしたあと、[l][r]
にっこりと微笑む。[p]

@jump target=*deepen

; ============================================================
; 8. 深まる対話
; ============================================================
*deepen
[autosave]
[cm]

「[emb exp="sf.player_name"]さんは、[l][r]
なくしたくないものを[r]
ちゃんと知ってる」[p]

「それだけで、[r]
じゅうぶんな気がする」[p]

…そう、かな。[p]

気づけば、[l][r]
足もとに霧の切れ間が見えていた。[p]

@jump target=*climax_elder

; ============================================================
; 9. クライマックス：老人との別れ
; ============================================================
*climax_elder
[autosave]
[cm]

「ここに、ずっといたいな」[p]

そう言って、[l][r]
草の上にころんと寝転がる。[p]

「なくしたもの、[r]
探しに行かなくていいの？」[p]

その隣にしゃがんで尋ねる。[p]

「見つかったよ」[p]

え？[p]

「なくしたと思ってたもの、[l][r]
全部ここにあった」[p]

──ここ。[p]

初めは何も見えないくらい、[l][r]
濃い霧に包まれていた。[p]

気づいたら少しずつ晴れて、[l][r]
なんだか安心できるようになった[r]
この場所。[p]

「ここを作ってくれて、[l][r]
ありがとう」[p]

上半身を起こすと、[r]
こちらに顔を向けてそうつぶやく。[p]

作った…？[p]

; ----------------------------------------------------------
; これまで答えた「大切なもの」を、1つずつ[p]で見せる
; （画面での見え方を確認してから、見せ方を変える可能性あり）
; ----------------------------------------------------------
「[emb exp="sf.treasures[0]"]」のこと、[l][r]
教えてくれたよね」[p]

[if exp="sf.treasures.length >= 2"]
「[emb exp="sf.treasures[1]"]」のことも」[p]
[endif]

[if exp="sf.treasures.length >= 3"]
「[emb exp="sf.treasures[2]"]」のことも」[p]
[endif]

「そのときから、[l][r]
すこしずつ、明るくなってった」[p]

──そういえば。[l][r]
あたりが明るくなってきたのは、[p]

"なくしたくないもの"を思い浮かべて[l][r]
この子に話した時だった。[p]

じゃあ…。[p]

この森は、この景色は、[l][r]
自分の"なくしたくないもの"で[r]
できている。[p]

"なくしたくないもの"への[l][r]
想いで、できている。[p]

──と、理解してもいいんだろうか。[p]

「なにもなくなったと思ったけど、[l][r]
なくなってなかったんだ」[p]

;;イラスト：子どもと手を繋ぐ
[chara_hide name="child"]
[chara_show face="shake" name="child"]

小さな手が、[l][r]
またそっと指を握る。[p]

「一緒に歩いてくれて、[l][r]
うれしかった」[p]

その瞬間。[p]

;要素材：明るい朝の森（光が差し込む）
[bg storage="bg001d.jpg" time="100"]
;;SE：風の音
[playse storage="se002.mp3"]

どこからか風が吹き抜けて、[l][r]
まぶしいくらいの朝の光が[r]
森を包んでいく。[p]

驚いてあたりを見回すと、[l][r]
安心させるみたいに[r]
手を強く握られる。[p]

…あれ？[p]

さっきまで握っていた手は、[l][r]
小さくて、柔らかくて、あたたかかった。[p]

;;イラスト：老人の手
[chara_hide name="child"]
[chara_show face="old" name="child"]
だけど今握っている手は、[l][r]
乾いていて、骨ばっていて、少し冷たい。[p]

握った手のほうを見るけれど[l][r]
光のせいなのか、[r]
うまく顔が見えない。[p]

「"その時"が来れば、[l][r]
大切なものは[r]
失ってしまう」[p]

聞こえてきた声も[l][r]
かすれていて、少し震えている。[p]

この人は、[l][r]
誰？[p]

「だから、自分には[r]
なにもないように思えた」[p]

「寂しくて、怖かった」[p]

「──でも、そうじゃなかった」[p]

「"なくしたくないもの"は[l][r]
確かにあった」[p]

; ----------------------------------------------------------
; 傾向による分岐：最初に選んだカテゴリで決まる
; ----------------------------------------------------------
[if exp='f.first_category == "person"']
「ちゃんと、あの人のことを[l][r]
想っていたんだ」[p]
[elsif exp='f.first_category == "gift"']
「あの贈りものを、[l][r]
大切にしていたんだ」[p]
[elsif exp='f.first_category == "words"']
「あの言葉は、[l][r]
胸に残っていたんだ」[p]
[elsif exp='f.first_category == "treasure"']
「あの宝物を、[l][r]
大事に想っていたんだ」[p]
[elsif exp='f.first_category == "goal"']
「目標を持って、[l][r]
歩いてきたんだ」[p]
[elsif exp='f.first_category == "place"']
「戻りたい場所が[l][r]
ちゃんとあったんだ」[p]
[endif]

「…思い出させてくれて、ありがとう」[p]

;;イラスト：老人の手を非表示（このあとの「手の感触が消える」描写に合わせる）
[chara_hide name="child"]

その声が響くと、[l][r]
握っていた手の感触が消える。[p]

行方を探すけれど、[l][r]
不思議とわかっている。[p]

ここにいるのは、[l][r]
自分だけ。[p]

…。[p]

……違う。[p]

そもそも、最初からずっと[l][r]
自分だけだったんだろう。[p]

「[emb exp="sf.player_name"]さんも、[l][r]
ここが好き？」[p]

@jump target=*wake_transition

; ============================================================
; 10. エンディング：霧が晴れ、夢から目覚める
; ============================================================
*wake_transition
[autosave]
[cm]

さっき問いかけられた言葉が[l][r]
もう一度頭に響く。[p]

「[emb exp="sf.player_name"]さんのことが、[l][r]
好き？」[p]

; ----------------------------------------------------------
; 選択場面10：自分のことが好き？（好き／悪くない／今より好きになりたい）
; ----------------------------------------------------------
[glink x=270 y=200 text="好き" target="*final_like" graphic="select_off.png" enterimg="select_on.png" width="600" height="50" size="32" ]
[glink x=270 y=300 text="悪くない" target="*final_okay" graphic="select_off.png" enterimg="select_on.png" width="600" height="50" size="32" ]
[glink x=270 y=400 text="今より好きになりたい" target="*final_want" graphic="select_off.png" enterimg="select_on.png" width="600" height="50" size="32" ]

[s]

;---------
*final_like
;---------
[cm]
好き、かなあ。[p]

たぶん、そう思う。[p]
@jump target=*wake_transition2

;---------
*final_okay
;---------
[cm]
悪くない、かな。[p]

好きとまでは言えなくても、[l][r]
嫌いではない。[p]
@jump target=*wake_transition2

;---------
*final_want
;---------
[cm]
今はまだ、そんなに…。[p]

だから、今より[l][r]
好きになりたいな。[p]
@jump target=*wake_transition2

;---------
*wake_transition2
;---------
[cm]

気がつけば、[l][r]
霧はどこにもなかった。[p]

木々の隙間から、[l][r]
やわらかな朝の光が差し込んでいる。[p]

足もとには、[l][r]
小さな花がいくつも咲いていた。[p]

「もうここを出ていいよ」と[l][r]
言われているみたいに。[p]

大丈夫。[l][r]
もう、帰れる。[p]

; ----------------------------------------------------------
; エンディング演出：暗転→まぶたの開け閉め→現実へ
; ----------------------------------------------------------

[wait time=1500]

まぶたを閉じて、[l][r]
深く息を吸い込む。[p]


; ----------------------------------------------------------
; 暗転前に霧レイヤーを消す
; ----------------------------------------------------------

[freeimage layer="2"]


; ----------------------------------------------------------
; 暗転
; ----------------------------------------------------------

[bg storage="bimg_black.png" time="1200"]
[wait time=800]

……。[p]


; ----------------------------------------------------------
; 明滅中はテキストウィンドウを非表示
; ----------------------------------------------------------

[layopt layer="message" visible="false"]


; ----------------------------------------------------------
; まぶたの開け閉めのような演出（明滅）
; ----------------------------------------------------------

[bg storage="bg003.jpg" time="80"]
[wait time=120]

[bg storage="bimg_black.png" time="80"]
[wait time=250]

[bg storage="bg003.jpg" time="80"]
[wait time=120]

[bg storage="bimg_black.png" time="80"]
[wait time=300]

[bg storage="bg003.jpg" time="600"]


; ----------------------------------------------------------
; 明滅終了後、テキストウィンドウを再表示
; ----------------------------------------------------------

[layopt layer="message" visible="true"]

………。[p]

もう一度目を開けると、[l][r]
見慣れた天井が見えた。[p]

霧も、[l][r]
子どもの声も、[r]
もう何もない。[p]

;記入した"大切なもの"を実際にプレイヤーが入力した内容で表示する
[iscript]
f.treasures_summary = sf.treasures.map(function(t){ return "「" + t + "」"; }).join("");
[endscript]

[emb exp="f.treasures_summary"]という[l][r]
"大切なもの"だけは、[r]
はっきりと覚えていた。[p]

──さぁ、[l][r]
これからどうしようか。[p]

*ending
[cm]

[clearfix]
[chara_hide name="child"]
[stopbgm]

; 少し余韻を置いてからクレジットへ
[wait time=800]

@jump target=*credits


; ==========================================================
; END CREDITS
; ==========================================================

*credits

[cm]

; メッセージウィンドウを非表示
[layopt layer="message" visible="false"]

; クレジット背景
[bg storage="bg_endcr004.jpg" time="1500"]

[wait time=600]

[iscript]
(function () {

    // 二重生成防止
    $('#straying-end-credits').remove();

    var $credits = $('<div id="straying-end-credits"></div>');

    $credits.css({
        position: 'absolute',
        left: '0',
        top: '0',
        width: '1280px',
        height: '720px',
        zIndex: 9998,
        color: '#ffffff',
        cursor: 'pointer',
        boxSizing: 'border-box'
    });


    // --------------------------------------------------
    // 右側クレジット
    // --------------------------------------------------

    var $main = $('<div></div>');

    $main.css({
        position: 'absolute',
        left: '650px',
        top: '105px',
        width: '520px',
        textAlign: 'center',
        fontFamily: '"Straying Serif", serif',
        fontWeight: '400',
        textShadow: '0 5px 8px rgba(0,0,0,0.55)'
    });

    $main.html(

        '<div style="font-size:25px; margin-bottom:10px;">Produced by</div>' +

        '<div style="font-size:34px; margin-bottom:52px;">' +
            'Hironori &#39;Tom&#39; SAKAI' +
        '</div>' +

        '<div style="font-size:25px; margin-bottom:10px;">Directed &amp; Written by</div>' +

        '<div style="font-size:34px; margin-bottom:52px;">' +
            'Akane YATA' +
        '</div>' +

        '<div style="font-size:25px; margin-bottom:10px;">Development by</div>' +

        '<div style="font-size:34px; margin-bottom:62px;">' +
            'Hizakake LLC' +
        '</div>' +

        '<div style="font-size:39px; font-weight:500;">' +
            'FOR YOU' +
        '</div>'
    );


    // --------------------------------------------------
    // 左下コピー
    // --------------------------------------------------

    var $tagline = $('<div></div>');

    $tagline
        .text('Stray, and still advance.')
        .css({
            position: 'absolute',
            left: '95px',
            bottom: '66px',
            fontFamily: '"Straying Sans", sans-serif',
            fontSize: '25px',
            fontWeight: '400',
            letterSpacing: '0.02em',
            color: 'rgba(255,255,255,0.92)',
            textShadow: '0 3px 7px rgba(0,0,0,0.7)'
        });


    // --------------------------------------------------
    // クリック案内
    // --------------------------------------------------

    var $returnText = $('<div></div>');

    $returnText
        .text('CLICK TO RETURN')
        .css({
            position: 'absolute',
            right: '28px',
            bottom: '22px',
            fontFamily: '"Montserrat", sans-serif',
            fontSize: '11px',
            fontWeight: '400',
            letterSpacing: '0.12em',
            color: 'rgba(255,255,255,0.55)'
        });


    $credits.append($main);
    $credits.append($tagline);
    $credits.append($returnText);

    $('#tyrano_base').append($credits);


    // --------------------------------------------------
    // クリックでタイトルへ戻る
    // --------------------------------------------------

    $credits.one('click', function () {

    $(this).fadeOut(800, function () {

        $(this).remove();

        TYRANO.kag.ftag.startTag('jump', {
    storage: 'title.ks'
});

    });

});

})();
[endscript]

[s]

; ========================================
; 共通セットアップ（[call]で呼び出す想定のサブルーチン）
; *startから呼ばれる他、first.ksのデバッグジャンプ機能からも
; 任意のラベルへ飛ぶ前に呼ばれる（キャラクター未登録エラー対策）
; ========================================
*setup_common

[title name="Straying Through the Fog"]

[iscript]

if ($('#straying-font-style').length === 0) {

    var css = '';

    // --------------------------------------------------
    // Font Face
    // --------------------------------------------------

    css += '@' + 'font-face {';
    css += 'font-family:"Straying Serif";';
    css += 'src:url("./data/others/font/NotoSerifJP-Regular.ttf") format("truetype");';
    css += 'font-weight:400;';
    css += 'font-style:normal;';
    css += '}';

    css += '@' + 'font-face {';
    css += 'font-family:"Straying Serif";';
    css += 'src:url("./data/others/font/NotoSerifJP-Medium.ttf") format("truetype");';
    css += 'font-weight:500;';
    css += 'font-style:normal;';
    css += '}';

    css += '@' + 'font-face {';
    css += 'font-family:"Straying Sans";';
    css += 'src:url("./data/others/font/NotoSansJP-Regular.ttf") format("truetype");';
    css += 'font-weight:400;';
    css += 'font-style:normal;';
    css += '}';

    css += '@' + 'font-face {';
    css += 'font-family:"Straying Sans";';
    css += 'src:url("./data/others/font/NotoSansJP-Medium.ttf") format("truetype");';
    css += 'font-weight:500;';
    css += 'font-style:normal;';
    css += '}';

    css += '@' + 'font-face {';
    css += 'font-family:"Montserrat";';
    css += 'src:url("./data/others/font/Montserrat-Regular.ttf") format("truetype");';
    css += 'font-weight:400;';
    css += 'font-style:normal;';
    css += '}';


    // --------------------------------------------------
    // 本文
    // --------------------------------------------------

    css += '.message_inner,';
    css += '.message_inner *,';
    css += '.message0_fore {';
    css += 'font-family:"Straying Serif",serif !important;';
    css += 'font-weight:400 !important;';
    css += '}';


    // --------------------------------------------------
    // 選択肢
    // --------------------------------------------------

    css += '.button_graphic.event-setting-element,';
    css += '.button_graphic.event-setting-element * {';
    css += 'font-family:"Straying Sans",sans-serif !important;';
    css += 'font-weight:400 !important;';
    css += 'font-size:32px !important;';
    css += 'text-align:center !important;';
    css += 'line-height:50px !important;';
    css += 'padding:27px 64px 37px !important;';
    css += '}';


    // --------------------------------------------------
    // 入力欄
    // --------------------------------------------------

    css += 'input,textarea {';
    css += 'font-family:"Straying Sans",sans-serif !important;';
    css += 'font-weight:400;';
    css += '}';


    // --------------------------------------------------
    // タイトル・通知ボタン
    // --------------------------------------------------

    css += '.straying-title-button,';
    css += '.straying-notice-button {';
    css += 'font-family:"Straying Sans",sans-serif !important;';
    css += 'font-weight:500;';
    css += '}';


    // --------------------------------------------------
    // CSS反映
    // --------------------------------------------------

    $('<style>')
        .attr('id', 'straying-font-style')
        .text(css)
        .appendTo('head');
}

[endscript]

[iscript]

document.fonts.load('400 16px "Straying Serif"');
document.fonts.load('500 16px "Straying Serif"');
document.fonts.load('400 16px "Straying Sans"');
document.fonts.load('500 16px "Straying Sans"');

[endscript]

[iscript]
sf.save = 0

;--- 「大切なもの」自由記述（複数回答をすべて保存） ---
sf.treasures = [];
sf.player_treasure = ""; // 直近の回答（互換用）
f.treasure_round = 0;    // 今までに答えた回数（最大3）
f.first_category = "";   // 最初に選んだカテゴリ（老人の台詞分岐に使用）

;--- カテゴリごとに「一度選んだか」フラグ ---
f.used_person = 0
f.used_gift = 0
f.used_words = 0
f.used_treasure = 0
f.used_goal = 0
f.used_place = 0
[endscript]

[cm]
[clearfix]
[start_keyconfig]

[layopt layer="0" visible="true"]
[layopt layer="1" visible="true"]
[layopt layer="2" visible="true"]

;夜霧の深い森。足もとまで白く沈むくらい濃い霧
;[bg storage="bg001a.jpg" time="100"]

[button name="role_button" role="menu" graphic="button/btn_exit_normal.png" enterimg="button/btn_exit_hover.png" x="735" y="20" width="120" height="48"]

[button name="role_button" role="backlog" graphic="button/btn_log_normal.png" enterimg="button/btn_log_hover.png" x="870" y="20" width="120" height="48"]

[button name="role_button" role="sleepgame" graphic="button/btn_menu_normal.png" enterimg="button/btn_menu_hover.png" storage="config.ks" x="1140" y="20" width="120" height="48"]

;右上UI
;EXIT / LOG / LANG / MENU
;LANGはJavaScriptで生成し、言語選択パネルを開く
[iscript]


// ==================================================
// EXIT / LOG / MENU
// ==================================================

var $menuBtns = $('.fixlayer').filter(function() {

    var src = this.src || "";

    return src.indexOf("btn_exit_") !== -1 ||
           src.indexOf("btn_log_") !== -1 ||
           src.indexOf("btn_menu_") !== -1;
});


// --------------------------------------------------
// フェードイン
// --------------------------------------------------

$menuBtns
    .css("opacity", 0)
    .animate({
        opacity: 1
    }, 2500);


// --------------------------------------------------
// pressed画像
// --------------------------------------------------

$menuBtns.each(function() {

    var $btn = $(this);

    var normalSrc = $btn.attr('src');
    var hoverSrc = normalSrc.replace(
        '_normal.png',
        '_hover.png'
    );
    var pressedSrc = normalSrc.replace(
        '_normal.png',
        '_pressed.png'
    );


    $btn.on(
        'mousedown.strayingButton',
        function() {

            $btn.attr(
                'src',
                pressedSrc
            );
        }
    );


    $btn.on(
        'mouseup.strayingButton',
        function() {

            $btn.attr(
                'src',
                hoverSrc
            );
        }
    );


    $btn.on(
        'mouseleave.strayingButton',
        function() {

            $btn.attr(
                'src',
                normalSrc
            );
        }
    );

});


// ==================================================
// LANGボタン
// ==================================================

// 二重生成防止
$('#straying-lang-button').remove();

var langNormal =
    './data/image/button/btn_lang_normal.png';

var langHover =
    './data/image/button/btn_lang_hover.png';

var langPressed =
    './data/image/button/btn_lang_pressed.png';


var $langBtn = $('<img>')
    .attr(
        'id',
        'straying-lang-button'
    )
    .attr(
        'src',
        langNormal
    )
    .css({

        position: 'absolute',

        left: '1005px',
        top: '20px',

        width: '120px',
        height: '48px',

        cursor: 'pointer',

        zIndex: 9999,

        opacity: 0

    });


// ゲーム画面へ追加
$('#tyrano_base').append(
    $langBtn
);


// フェードイン
$langBtn.animate(
    {
        opacity: 1
    },
    2500
);


// hover
$langBtn.on(
    'mouseenter',
    function() {

        $(this).attr(
            'src',
            langHover
        );
    }
);


// normal
$langBtn.on(
    'mouseleave',
    function() {

        $(this).attr(
            'src',
            langNormal
        );
    }
);


// pressed
$langBtn.on(
    'mousedown',
    function() {

        $(this).attr(
            'src',
            langPressed
        );
    }
);


// hoverへ戻す
$langBtn.on(
    'mouseup',
    function() {

        $(this).attr(
            'src',
            langHover
        );
    }
);


// ==================================================
// 言語選択パネル
// ==================================================

// 二重生成防止
$('#straying-language-panel').remove();


var $langPanel =
    $('<div id="straying-language-panel"></div>');


$langPanel.css({

    position: 'absolute',

    left: '1005px',
    top: '76px',

    width: '120px',

    padding: '6px',

    boxSizing: 'border-box',

    background:
        'rgba(20, 28, 34, 0.94)',

    border:
        '1px solid rgba(255,255,255,0.35)',

    borderRadius: '10px',

    zIndex: 10000,

    display: 'none'

});


// --------------------------------------------------
// 言語項目を作る関数
// --------------------------------------------------

function createLanguageItem(
    label,
    lang
) {

    var $item =
        $('<div></div>');


    $item
        .text(label)
        .css({

            width: '100%',

            padding: '9px 4px',

            boxSizing: 'border-box',

            color: '#ffffff',

            fontSize: '14px',

            textAlign: 'center',

            cursor: 'pointer',

            borderRadius: '7px'

        });


    $item.on(
        'mouseenter',
        function() {

            $(this).css(
                'background',
                'rgba(255,255,255,0.15)'
            );
        }
    );


    $item.on(
        'mouseleave',
        function() {

            $(this).css(
                'background',
                'transparent'
            );
        }
    );


    $item.on(
        'click',
        function(e) {

            e.stopPropagation();


            // 言語設定を保存
            TYRANO.kag.variable.sf.language =
                lang;


            if (
                TYRANO.kag.saveSystemVariable
            ) {

                TYRANO.kag
                    .saveSystemVariable();

            }


            // パネルを閉じる
            $langPanel.fadeOut(
                150
            );


            console.log(
                'Language selected:',
                lang
            );

        }
    );


    $langPanel.append(
        $item
    );

}


// --------------------------------------------------
// 対応言語
// --------------------------------------------------

createLanguageItem(
    '日本語',
    'ja'
);

createLanguageItem(
    'English',
    'en'
);


// ゲーム画面へ追加
$('#tyrano_base').append(
    $langPanel
);


// ==================================================
// LANGクリック
// ==================================================

$langBtn.on(
    'click.strayingLanguage',
    function(e) {

        e.preventDefault();

        e.stopPropagation();


        $langPanel
            .stop(
                true,
                true
            )
            .fadeToggle(
                150
            );

    }
);


// ==================================================
// パネル外クリックで閉じる
// ==================================================

$(document)
    .off(
        'click.strayingLanguage'
    )
    .on(
        'click.strayingLanguage',
        function() {

            $langPanel.fadeOut(
                150
            );

        }
    );


// パネル内クリックは閉じない
$langPanel.on(
    'click',
    function(e) {

        e.stopPropagation();

    }
);

// ==================================================
// MENU遷移直前にLANGを非表示
// ==================================================

var $strayingMenuButton = $('img').filter(function () {

    var src = this.src || '';

    return src.indexOf('btn_menu_') !== -1;

});

$strayingMenuButton.each(function () {

    var menuButton = this;

    // 二重登録防止
    if (menuButton.dataset.strayingLangHideRegistered === 'true') {
        return;
    }

    menuButton.dataset.strayingLangHideRegistered = 'true';

    // TyranoのMENU処理より先に実行する
    menuButton.addEventListener(
        'click',
        function () {

            $('#straying-lang-button').hide();
            $('#straying-language-panel').hide();

        },
        true
    );

});

[endscript]


;選択肢ボタン（select_off/select_on）上のテキストを、上下左右中央に表示する
;（デフォルトでは高さを固定すると上寄りになってしまうため、CSSで中央揃えに上書き。
;　他のスタイルとの優先度勝負にならないよう!importantを付けている）
;[iscript]
;if ($('#straying-glink-style').length === 0) {
;    $('head').append('<style id="straying-glink-style">.glink_button{display:flex !important;align-items:center !important;justify-content:center !important;padding:0 !important;margin:0 !important;text-align:center !important;line-height:normal !important;box-sizing:border-box !important;}</style>');
;}
;[endscript]

;メッセージウィンドウを画面下部に固定（背景がほとんど見える大きさに縮小）
;t_window.pngの絵の内容（透明→下部半透明グレーのグラデーション）が
;画面幅いっぱい・高さ297px相当だったため、そのサイズに合わせています
[position layer=message0 left=0 top=423 width=1280 height=297 page=fore visible=true frame="config/t_window.png"]
[position layer=message0 page=fore margint="110" marginl="60" marginr="60" marginb="30"]

;クリック待ちの矢印（ウィンドウ右下に固定表示）。[glyph]は呼ぶたびに設定がリセットされるため、ここで一度だけ指定する
;※[glyph]の画像指定は storage= ではなく line= 。folder=を省略すると
;  エンジン内蔵のtyrano/images/system/を見に行ってしまうため、
;  data/image/を見せるには folder="image" の指定が必須
;t_arrow.pngの実サイズ(122x96px)の約1/3(41x32px)に縮小し、
;画面(1280x720)の右下ぎりぎり（余白20px）に収まる座標に調整
[glyph line="t_arrow.png" folder="image" fix=true left=1219 top=668 width=41 height=32]

[chara_config ptext="chara_name_area"]

[keyframe name=flow1]
[frame p=50% y=5 ]
[frame p=100% y=0]
[endkeyframe]

[keyframe name=flow2]
[frame p=100% y=0 ]
[frame p=25% y=-5]
[endkeyframe]

;霧がゆっくり右へ流れるアニメーション
;移動量を-40→-80に、時間も9000ms→6000msに変更し、揺れをわかりやすくした
[keyframe name=fogdrift]
[frame p=0% x=0]
[frame p=100% x=-180]
[endkeyframe]

[chara_new name="child" storage="child/ch001.png" jname="子供" height="725" width="1280"]
[chara_face name="child" face="hand" storage="child/ch002.png"]
[chara_face name="child" face="shake" storage="child/ch003.png"]
[chara_face name="child" face="walk" storage="child/ch004.png"]
[chara_face name="child" face="old" storage="child/ch005.png"]

[wa]

[return]
