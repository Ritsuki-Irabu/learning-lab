# UI パターン 技術資産ドキュメント

> UIコンポーネントの設計パターン・用語定義・実装知識を体系化した技術資産。
> 学習内容の再利用性向上・設計思考ログの蓄積・ポートフォリオ提示を目的とする。

---

## 技術スタック

| カテゴリ | 技術 |
|---|---|
| マークアップ | HTML5 |
| スタイル | CSS3 |
| スクリプト | JavaScript（Vanilla） |
| アクセシビリティ | WAI-ARIA |

---

## 学習プロセス

### 学習スタイル
- 用語の意味・違いを正確に理解してから実装に落とし込む
- MDN・W3C 仕様を一次ソースとして確認する

### 到達レベル

| 領域 | レベル |
|---|---|
| Modal / Dialog / Popup の定義理解 | ✅ 完了 |
| HTML5 `<dialog>` 要素 | 学習中 |
| HTML Popover API | 学習中 |
| ARIA 対応 | 学習中 |

---

## チートシート

### Modal・Dialog・Popup の違い

| 用語 | 分類 | ブロッキング | 閉じ方 | 代表例 |
|---|---|---|---|---|
| **Modal** | UI パターン（俗称） | ✅ あり（背景操作不可） | 明示的なアクション必須 | 削除確認、ログインフォーム |
| **Dialog** | HTML/ARIA の意味論的用語 | モーダルにも非モーダルにも対応 | モードによる | `<dialog>` 要素全般 |
| **Popup** | UI パターン（俗称） | ❌ なし（背景操作可能） | クリック外・自動消去など | ツールチップ、ドロップダウン |

#### 概念の本質（言葉の意味から捉える）

| 用語 | 本質的な意味 |
|---|---|
| **Modal** | **「制御」** にフォーカス。ユーザーの操作を制限し、今のタスクに集中させる仕組み |
| **Popup** | **「突然の表示」** にフォーカス。ユーザーの操作によらず出現する画面・表示形式を指す俗称 |
| **Dialog** | **「やり取り」** にフォーカス。コンピュータ用語として、指示・案内・警告など何らかの行動を促す対話を表す |

- Modal は「どう表示するか（制御）」、Dialog は「何のために表示するか（目的・やり取り）」という視点の違いがある
- 「モーダルダイアログ」は両者を組み合わせた表現：**制御しながら対話する** UI

#### 重要な整理

- **「Modal」と「Dialog」は同義ではない**
  - Dialog（ダイアログ）はHTMLの意味論的な概念で、モーダル・非モーダルの両方を含む
  - Modal（モーダル）は「背景をブロックする」という動作の説明であり、Dialog の一形態
  - つまり「モーダルダイアログ」と「非モーダルダイアログ」の両方が存在する

- **「Popup」はHTML仕様上の正式用語ではない（2024年以前）**
  - 俗称として広く使われてきた
  - 2024年にHTML Living Standard に `popover` 属性が追加され、Popover API が正式化

---

### HTML5 `<dialog>` 要素

```html
<dialog id="my-dialog">
  <p>本当に削除しますか？</p>
  <button id="confirm">削除</button>
  <button id="cancel">キャンセル</button>
</dialog>

<button id="open">開く</button>
```

```javascript
const dialog = document.getElementById('my-dialog');

// モーダルダイアログとして開く（背景をブロック）
document.getElementById('open').addEventListener('click', () => {
  dialog.showModal();
});

// 非モーダルダイアログとして開く（背景操作可能）
// dialog.show();

document.getElementById('cancel').addEventListener('click', () => {
  dialog.close();
});
```

**`showModal()` vs `show()` の違い：**

| メソッド | 背景ブロック | `::backdrop` 疑似要素 | ESCキー閉鎖 |
|---|---|---|---|
| `showModal()` | ✅ あり | ✅ 表示 | ✅ あり |
| `show()` | ❌ なし | ❌ 非表示 | ❌ なし |

---

### HTML Popover API（2024年〜 Living Standard）

```html
<!-- popovertarget で紐付け -->
<button popovertarget="my-popover">詳細を見る</button>

<div id="my-popover" popover>
  <p>ポップオーバーの内容</p>
</div>
```

**`popover` 属性の種類：**

| 値 | 動作 |
|---|---|
| `auto`（省略時デフォルト） | 外側クリックや ESC で自動的に閉じる。同時に1つだけ表示 |
| `manual` | JS で明示的に開閉する必要あり。複数同時表示も可 |

> ⚠️ 要確認：`popover` 属性は Chrome 114+・Safari 17+・Firefox 125+ で対応。対象ブラウザを確認すること。

---

### ARIA ロールとの対応

| UI パターン | 推奨 ARIA ロール | 補足 |
|---|---|---|
| モーダルダイアログ | `role="dialog"` + `aria-modal="true"` | `<dialog>` 要素の `showModal()` は自動付与 |
| 非モーダルダイアログ | `role="dialog"` + `aria-modal="false"` | |
| ツールチップ | `role="tooltip"` | ホバーで表示される補足情報 |
| ポップオーバー（汎用） | `role="dialog"` or コンテンツに応じて選択 | Popover API は自動では ARIA ロールを付与しない |

---

### 実装パターンの選び方

```
ユーザーの操作をブロックする必要がある？
├── Yes → Dialog（showModal）を使う
│         例：削除確認・フォーム入力・重要な通知
└── No  → Popover API または非モーダル Dialog を使う
          例：ツールチップ・サジェスト・補足情報
```

---

## 実装資産

| 実装 | 説明 | 参照 |
|---|---|---|
| 削除確認モーダル | LaravelタスクアプリのJS外部化済み確認ダイアログ | [laravel](../laravel/README.md) |

---

## 技術的課題と改善方針

| 課題 | 問題点 | 改善方針 |
|---|---|---|
| Popover API のブラウザ対応 | 古いブラウザでは未対応 | `@supports` や polyfill の検討 |
| フォーカストラップ | モーダル表示中にフォーカスが背景に逃げることがある | `focus-trap` ライブラリ または手動実装 |
| スクロールロック | モーダル背景がスクロールできてしまうケース | `body { overflow: hidden }` の動的切り替え |

---

## 今後の強化方針

- [ ] `<dialog>` 要素を使ったモーダルコンポーネントを実装する
- [ ] Popover API を使ったツールチップを実装する
- [ ] フォーカストラップの実装パターンを調査・記録する
- [ ] アニメーション付き開閉（CSS `@starting-style`）を試す

---

## 学んだこと

| 日付 | トピック | メモ |
|---|---|---|
| 2026-05-15 | Modal・Dialog・Popup の定義整理 | Modal＝背景ブロックあり、Dialog＝HTML意味論（両方含む）、Popup＝非ブロッキング俗称 |
| 2026-05-15 | 3用語の本質的な違い | Modal＝制御、Popup＝突然の表示という形式、Dialog＝やり取り（行動を促す対話）というコンピュータ用語 |
| 2026-05-15 | `showModal()` vs `show()` の違い | showModal はブロッキング＋backdrop、show は非ブロッキング |
| 2026-05-15 | HTML Popover API（2024年正式化） | `popover` 属性で宣言的に実装可能。`auto`/`manual` の2種類 |
| 2026-05-15 | ARIA ロールと `<dialog>` 要素の関係 | showModal()は`aria-modal`を自動付与しない（手動設定が必要） |
