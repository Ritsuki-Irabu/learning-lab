# Playwright メモ

## チートシート

### 基本操作

```ts
await page.goto('https://example.com');
await page.getByRole('button', { name: '送信' }).click();
await expect(page.getByText('完了')).toBeVisible();
```

### ロケーター優先順位

1. `getByRole` — アクセシビリティロールで取得（推奨）
2. `getByLabel` — フォームラベルで取得
3. `getByTestId` — `data-testid` で取得
4. `locator` — CSSセレクタ（最終手段）

### デバッグ

```bash
npx playwright test --ui          # UIモードで実行
npx playwright codegen            # 操作を自動記録
PWDEBUG=1 npx playwright test     # ステップ実行
```

---

## 学んだこと

| 日付 | トピック | メモ |
|---|---|---|
| - | - | - |
