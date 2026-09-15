
[cm]

@clearstack

;背景（森・霧なし）
;※time=0以外だと、クロスフェード完了を待つ処理が何らかの条件で
;　完了コールバックを呼ばないまま止まってしまうことがあったため、
;　最初の背景表示はフェードなし（即時表示）にして、この待機自体を回避する
[bg storage="title_bg001.jpg" time=0]

; ============================================================
; タイトル画面：霧の無限スクロール
; bg004.png の横幅は 2172px
; ============================================================

[image layer="1" page="fore" visible=true storage="bg004.png" folder="image" opacity=0 x=0 y=0 name="fog_title_anchor"]

[iscript]
(function () {

    // --------------------------------------------------
    // ゲーム中にJavaScriptで生成したUIを削除
    // --------------------------------------------------
    $('#straying-lang-button').remove();
    $('#straying-language-panel').remove();

    // 以前のタイトル霧アニメーションを停止
    if (window.strayingFogTitleRaf) {
        cancelAnimationFrame(window.strayingFogTitleRaf);
        window.strayingFogTitleRaf = null;
    }

    // 古い霧DIVがあれば削除
    $('.straying-title-fog').remove();

    var $anchor = $('.fog_title_anchor');

    if (!$anchor.length) {
        return;
    }

    // Tyranoのlayer 1を取得
    var $layer = $anchor.parent();

    // アンカー画像自体は不要なので削除
    $anchor.remove();

    // 横方向に自動リピートする霧レイヤー
    var $fog = $('<div class="straying-title-fog"></div>');

    $fog.css({
        position: 'absolute',
        left: '0px',
        top: '0px',

        // Tyranoのゲーム座標
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

    // ふわっと表示
    $fog.animate({ opacity: 1 }, 1800);

    var speed = 15; // px / 秒
    var positionX = 0;
    var lastTime = performance.now();

    function moveFog(now) {

        if (!$fog[0] || !$fog[0].isConnected) {
            window.strayingFogTitleRaf = null;
            return;
        }

        var delta = Math.min((now - lastTime) / 1000, 0.05);
        lastTime = now;

        positionX -= speed * delta;

        $fog.css(
            'background-position',
            positionX + 'px 0px'
        );

        window.strayingFogTitleRaf =
            requestAnimationFrame(moveFog);
    }

    window.strayingFogTitleRaf =
        requestAnimationFrame(moveFog);

})();
[endscript]


*start

;ロゴ画像(logo_top_fog.png)のテキストがy=141〜320あたりまでのため、
;重ならないよう「はじめから／つづきから」の位置をy=460に下げている
;オートセーブ（[autosave]タグ）の有無を確認し、セーブデータがある場合は
;「つづきから」を「はじめから」の下に追加で表示する（新規プレイも常に選べるようにする）
;※$.getStorageは[autoload]タグの内部実装と同じ判定方法（プロジェクトIDキーのオートセーブ有無）
;※modalselect_off/on.pngは単なるグラデーション画像で決まった縦横比を保つ必要がないため、
;　元の「はじめから」ボタン(title/button_start.png)と同じ360x74pxのサイズに合わせている
[iscript]
f.has_autosave = !!$.getStorage(tyrano.plugin.kag.config.projectID + "_tyrano_auto_save", tyrano.plugin.kag.config.configSave);
[endscript]

[iscript]

if ($('#straying-title-style').length === 0) {

    $('head').append(`
        <style id="straying-title-style">

        .straying-title-button {
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

            text-align: center;
            line-height: 1;
        }

        .straying-title-button:hover {
            background-image: url("./data/image/button/modalselect_on.png");
        }

        </style>
    `);

}

[endscript]

[iscript]

var $titleLayer = $("#tyrano_base");

function createTitleButton(id, text, x, y, target) {

    var $btn = $('<div></div>')
        .attr('id', id)
        .addClass('straying-title-button')
        .text(text)
        .css({
            position: 'absolute',
            left: x + 'px',
            top: y + 'px',
            width: '360px',
            height: '74px',
            cursor: 'pointer',
            zIndex: 9999
        });

    $btn.on('click', function () {

        // --------------------------------------------------
        // タイトル画面専用UIを削除
        // --------------------------------------------------

        $('#straying-title-logo').remove();
        $('#straying-title-copyright').remove();

        $('#straying-title-lang').remove();
        $('#straying-title-menu').remove();
        $('#straying-title-language-panel').remove();

        $('.straying-title-button').remove();


        // --------------------------------------------------
        // タイトル画面専用の霧演出も停止・削除
        // --------------------------------------------------

        if (window.strayingFogTitleRaf) {
            cancelAnimationFrame(window.strayingFogTitleRaf);
            window.strayingFogTitleRaf = null;
        }

        $('.straying-title-fog').remove();


        // --------------------------------------------------
        // ゲーム開始 / CONTINUE
        // --------------------------------------------------

        TYRANO.kag.ftag.startTag("jump", {
            target: target
        });

    });

    $titleLayer.append($btn);
}

createTitleButton(
    'straying-start-button',
    'START',
    200,
    460,
    '*gamestart'
);

if (f.has_autosave) {
    createTitleButton(
        'straying-continue-button',
        'CONTINUE',
        200,
        550,
        '*continuegame'
    );
}

// --------------------------------------------------
// タイトルロゴ
// --------------------------------------------------

$('#straying-title-logo').remove();

var $titleLogo = $('<img>')
    .attr('id', 'straying-title-logo')
    .attr('src', './data/image/title/straying_title_logo.png')
    .css({
        position: 'absolute',

        left: '135px',
        top: '115px',

        width: '520px',
        height: 'auto',

        zIndex: 9998
    });

$titleLayer.append($titleLogo);

// --------------------------------------------------
// Montserrat 読み込み
// --------------------------------------------------

if (!document.getElementById('straying-montserrat-font')) {

    var montserratStyle = document.createElement('style');

    montserratStyle.id = 'straying-montserrat-font';

    montserratStyle.textContent =
        '@font-face {' +
            'font-family: "Montserrat";' +
            'src: url("./data/others/font/Montserrat-Regular.ttf") format("truetype");' +
            'font-weight: 400;' +
            'font-style: normal;' +
        '}';

    document.head.appendChild(montserratStyle);
}

// --------------------------------------------------
// コピーライト
// --------------------------------------------------

$('#straying-title-copyright').remove();

var $titleCopyright = $('<div></div>')
    .attr('id', 'straying-title-copyright')
    .text("© 2026 Hironori 'Tom' SAKAI, Akane YATA, Hizakake LLC")
    .css({
        position: 'absolute',

        right: '24px',
        bottom: '18px',

        fontFamily: '"Montserrat", sans-serif',
        fontSize: '13px',
        fontWeight: '400',

        color: 'rgba(255,255,255,0.72)',
        letterSpacing: '0.03em',

        textAlign: 'right',

        zIndex: 9998
    });

$titleLayer.append($titleCopyright);

// ==========================================================
// タイトル画面専用 LANG / MENU
// ==========================================================

// 二重生成防止
$('#straying-title-lang').remove();
$('#straying-title-menu').remove();
$('#straying-title-language-panel').remove();


// ----------------------------------------------------------
// 画像パス
// ----------------------------------------------------------

var titleLangNormal =
    './data/image/button/btn_lang_normal.png';

var titleLangHover =
    './data/image/button/btn_lang_hover.png';

var titleLangPressed =
    './data/image/button/btn_lang_pressed.png';

var titleMenuNormal =
    './data/image/button/btn_menu_normal.png';

var titleMenuHover =
    './data/image/button/btn_menu_hover.png';

var titleMenuPressed =
    './data/image/button/btn_menu_pressed.png';


// ==========================================================
// LANGボタン
// ==========================================================

var $titleLang = $('<img>')
    .attr('id', 'straying-title-lang')
    .attr('src', titleLangNormal)
    .css({
        position: 'absolute',

        left: '1005px',
        top: '20px',

        width: '120px',
        height: '48px',

        cursor: 'pointer',
        zIndex: 9999
    });


$titleLang.on('mouseenter', function () {
    $(this).attr(
        'src',
        titleLangHover
    );
});


$titleLang.on('mouseleave', function () {
    $(this).attr(
        'src',
        titleLangNormal
    );
});


$titleLang.on('mousedown', function () {
    $(this).attr(
        'src',
        titleLangPressed
    );
});


$titleLang.on('mouseup', function () {
    $(this).attr(
        'src',
        titleLangHover
    );
});


// ==========================================================
// MENUボタン
// ==========================================================

var $titleMenu = $('<img>')
    .attr('id', 'straying-title-menu')
    .attr('src', titleMenuNormal)
    .css({
        position: 'absolute',

        left: '1140px',
        top: '20px',

        width: '120px',
        height: '48px',

        cursor: 'pointer',
        zIndex: 9999
    });


$titleMenu.on('mouseenter', function () {
    $(this).attr(
        'src',
        titleMenuHover
    );
});


$titleMenu.on('mouseleave', function () {
    $(this).attr(
        'src',
        titleMenuNormal
    );
});


$titleMenu.on('mousedown', function () {
    $(this).attr(
        'src',
        titleMenuPressed
    );
});


$titleMenu.on('mouseup', function () {
    $(this).attr(
        'src',
        titleMenuHover
    );
});


// MENU → 設定画面
$titleMenu.on('click', function () {

    // 言語パネルを閉じる
    $titleLangPanel.hide();

    // タイトル専用UIを一時的に非表示
    $('.straying-title-button').hide();
    $('#straying-title-lang').hide();
    $('#straying-title-menu').hide();
    $('#straying-title-language-panel').hide();

    // タイトルロゴ・コピーライトも非表示
    $('#straying-title-logo').hide();
    $('#straying-title-copyright').hide();

    // コンフィグ画面へ
    TYRANO.kag.ftag.startTag(
        'sleepgame',
        { storage: 'config.ks' }
    );
});


// ==========================================================
// タイトル画面用 言語選択パネル
// ==========================================================

var $titleLangPanel =
    $('<div id="straying-title-language-panel"></div>');


$titleLangPanel.css({
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


// ----------------------------------------------------------
// 言語項目生成
// ----------------------------------------------------------

function createTitleLanguageItem(
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

            fontFamily:
                '"Straying Sans", sans-serif',

            color: '#ffffff',

            fontSize: '14px',

            textAlign: 'center',

            cursor: 'pointer',

            borderRadius: '7px'
        });


    $item.on(
        'mouseenter',
        function () {

            $(this).css(
                'background',
                'rgba(255,255,255,0.15)'
            );

        }
    );


    $item.on(
        'mouseleave',
        function () {

            $(this).css(
                'background',
                'transparent'
            );

        }
    );


    $item.on(
        'click',
        function (e) {

            e.stopPropagation();

            // 選択言語を保存
            TYRANO.kag.variable.sf.language =
                lang;

            if (
                TYRANO.kag.saveSystemVariable
            ) {

                TYRANO.kag
                    .saveSystemVariable();

            }

            $titleLangPanel
                .fadeOut(150);

            console.log(
                'Title language selected:',
                lang
            );

        }
    );


    $titleLangPanel.append(
        $item
    );

}


// 対応言語
createTitleLanguageItem(
    '日本語',
    'ja'
);

createTitleLanguageItem(
    'English',
    'en'
);


// ----------------------------------------------------------
// LANGクリック → パネル開閉
// ----------------------------------------------------------

$titleLang.on(
    'click',
    function (e) {

        e.preventDefault();
        e.stopPropagation();

        $titleLangPanel
            .stop(true, true)
            .fadeToggle(150);

    }
);


// パネル内クリックは閉じない
$titleLangPanel.on(
    'click',
    function (e) {

        e.stopPropagation();

    }
);


// ==========================================================
// タイトルレイヤーへ追加
// ==========================================================

$titleLayer.append(
    $titleLang
);

$titleLayer.append(
    $titleMenu
);

$titleLayer.append(
    $titleLangPanel
);


[endscript]

;「コンフィグ」はこのプロトタイプでは現時点で使わないため非表示（要望があれば復活可能なようコメントアウトで保持）
;[button x=135 y=550 graphic="title/button_config.png" enterimg="title/button_config2.png" role="sleepgame" storage="config.ks" keyfocus="2"]

[s]

;---------
*continuegame
;---------
;オートセーブされた地点から再開する

[iscript]
$('.straying-title-button').remove();

if (window.strayingFogTitleRaf) {
    cancelAnimationFrame(window.strayingFogTitleRaf);
    window.strayingFogTitleRaf = null;
}
[endscript]

[cm]
[autoload]

[iscript]
$('.straying-title-button').remove();
[endscript]

[cm]
[autoload]

[s]

*gamestart

[iscript]
$('.straying-title-button').remove();

if (window.strayingFogTitleRaf) {
    cancelAnimationFrame(window.strayingFogTitleRaf);
    window.strayingFogTitleRaf = null;
}
[endscript]

[iscript]
$('.straying-title-button').remove();
[endscript]

;タイトル画面で使っていた霧・ロゴ画像（layer 1・2）は、ジャンプしても
;自動では消えず本編側に残ってしまうため、ここで明示的に消しておく
[freeimage layer="1"]
[freeimage layer="2"]

;「コンフィグ」ボタンはrole=指定のため常時表示レイヤー(fix)に置かれ、
;[freeimage]では消えない。本編側のbt_menu等（同じくrole=を使う）に影響
;しないよう、レイヤーごと隠すのではなくこのボタン画像だけを名前で特定して削除する
;※fixlayerクラスは<img>要素自身に付く（親要素ではない）ので、img自体を対象にする
[iscript]
$('.fixlayer').filter(function() {
    return this.tagName === 'IMG' && this.src.indexOf("button_config") !== -1;
}).remove();
[endscript]

;first.ks側で「タイトル画面ではメッセージ枠を隠す」設定
;（@layopt layer="message" visible=false）がされたままだと、
;ゲーム本編に入っても同意文言などが非表示のままになる。
;※ここで先にvisible=trueへ戻すと、位置・サイズが未設定のデフォルトの
;　大きな枠が*notice画面に一瞬重なって黒く見えてしまっていた（実機で確認済み）。
;　straying_sou.ks側の[position layer=message0 ... visible=true ...]
;　（*consentで設定）に、サイズ確定と同時のvisible=trueをまとめて任せる
;　ことで解決。ここでは何もしない

;[freeimage]はlayer 1/2の画像のみを消し、背景(base)自体はタイトル画面の
;森の絵(title_bg001.jpg)のまま残ってしまう。本編の*start1が黒(bimg_black.png)へ
;クロスフェードする際、消し忘れた森の背景から黒へフェードする形になり、
;同意画面の間もずっと森が一瞬見えてしまっていた。ここで先に黒へ変えておく
[bg storage="bimg_black.png" time=0]

;Straying SOU本編へ
@jump storage="straying_sou.ks" target="*entry"

