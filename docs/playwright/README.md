# Playwright 技術資産ドキュメント

> Playwrightを用いた学習・開発経験を体系化した技術資産。
> 学習内容の再利用性向上・設計思考ログの蓄積・ポートフォリオ提示を目的とする。

---

## 技術スタック

| カテゴリ | 技術 |
|---|---|
| テストフレームワーク | Playwright |
| 言語 | TypeScript |
| 対象ブラウザ | Chromium / Firefox / WebKit |
| テスト種別 | E2Eテスト・UIオートメーション |

---

## 学習プロセス

### 学習スタイル
- 公式ドキュメント + コード自動生成（codegen）で操作を学習
- ロケーター優先順位を意識した安定したセレクター選択に注力

### 到達レベル

| 領域 | レベル |
|---|---|
| 基本操作（goto・click・fill） | 実装経験あり |
| ロケーター選択（getByRole等） | 理解・実践中 |
| デバッグ（UI mode・PWDEBUG） | 使用経験あり |
| ネットワークモック（page.route） | 概念理解 |
| Page Object Model | 未着手 |

---

## チートシート

### 基本操作

```ts
await page.goto('https://example.com');
await page.getByRole('button', { name: '送信' }).click();
await expect(page.getByText('完了')).toBeVisible();
```

### ロケーター優先順位

アクセシビリティに近い順で選ぶ。壊れにくい順でもある。

```ts
// 1. getByRole — アクセシビリティロールで取得（最推奨）
page.getByRole('button', { name: 'ログイン' })
page.getByRole('heading', { name: 'ダッシュボード' })

// 2. getByLabel — フォームラベルで取得
page.getByLabel('メールアドレス')

// 3. getByPlaceholder — placeholder属性で取得
page.getByPlaceholder('例: user@example.com')

// 4. getByText — テキスト内容で取得
page.getByText('ようこそ')

// 5. getByTestId — data-testid属性で取得（実装者が明示的に設定）
page.getByTestId('submit-button')

// 6. locator — CSSセレクタ（最終手段、壊れやすい）
page.locator('.btn-primary')
```

### フォーム操作

```ts
await page.getByLabel('メールアドレス').fill('user@example.com');
await page.getByLabel('パスワード').fill('secret');
await page.getByRole('combobox', { name: '都道府県' }).selectOption('東京都');
await page.getByRole('checkbox', { name: '同意する' }).check();
```

### アサーション

```ts
// 表示確認
await expect(page.getByText('保存しました')).toBeVisible();
await expect(page.getByRole('alert')).toBeHidden();

// URL確認
await expect(page).toHaveURL('/dashboard');
await expect(page).toHaveURL(/\/users\/\d+/);

// 値・属性確認
await expect(page.getByLabel('名前')).toHaveValue('Alice');
await expect(page.getByRole('button')).toBeDisabled();
```

### デバッグ

```bash
npx playwright test --ui          # GUIでテストを確認しながら実行
npx playwright codegen            # ブラウザ操作を自動でコードに変換
PWDEBUG=1 npx playwright test     # ステップ実行（一時停止できる）
npx playwright test --headed      # ブラウザを可視化して実行
npx playwright show-report        # HTML形式のテストレポートを開く
```

### ネットワークインターセプト

```ts
// APIレスポンスをモックして、バックエンドなしでUIテストを安定化
await page.route('**/api/users', (route) =>
  route.fulfill({
    status: 200,
    contentType: 'application/json',
    body: JSON.stringify([{ id: 1, name: 'Alice' }]),
  })
);

// 特定リクエストをブロック（広告・トラッキングなど）
await page.route('**/*.{png,jpg}', (route) => route.abort());
```

### 複数タブ・新しいウィンドウ

```ts
// 新しいページ（タブ）の検知
const [newPage] = await Promise.all([
  page.context().waitForEvent('page'),
  page.getByText('新しいタブで開く').click(),
]);
await newPage.waitForLoadState();
```

---

## 実装資産

学習中。テスト対象プロジェクトへの導入を検討中。

---

## 技術的課題と改善方針

| # | 課題 | 問題点 | 改善方針 |
|---|---|---|---|
| 1 | セレクターの壊れやすさ | UIリニューアル時にテストが大量に落ちる | `getByRole` / `getByTestId` に統一する |
| 2 | テストの実行速度 | ブラウザ起動が伴うため遅い | 重要シナリオに絞り、数を増やしすぎない |
| 3 | Page Object Modelの未導入 | テストコードが長くなり重複が増える | POMパターンを学んでリファクタリング |

---

## 今後の強化方針

### 優先度 高
- [ ] 実プロジェクトにPlaywrightを導入してログイン・主要フローをテスト
- [ ] ネットワークモック（page.route）を実際に使ってみる

### 優先度 中
- [ ] Page Object Model パターンを学ぶ
- [ ] GitHub Actionsと連携してCIで自動実行する
- [ ] スクリーンショットの差分テスト（Visual comparison）を試す

---

## 学んだこと

| 日付 | トピック | メモ |
|---|---|---|
| 2026-05-18 | ロケーター優先順位 | getByRole > getByLabel > getByTestId > locator の順。壊れにくさと一致 ✅ |
| 2026-05-18 | Playwrightの立ち位置 | E2E担当。遅いため重要シナリオに絞るのがベストプラクティス |
| 2026-05-18 | page.route() | APIモックでバックエンド依存を切り離しテストを安定化できる |
| 2026-05-18 | codegen | 手動でブラウザ操作するとPlaywrightコードが自動生成される。学習に最適 |
