# テストツール比較 技術資産ドキュメント

> Vitest・Postman・Playwright を中心にテストツールの役割・得意不得意・使い分けを体系化した技術資産。
> 学習内容の再利用性向上・設計思考ログの蓄積・ポートフォリオ提示を目的とする。

---

## 技術スタック

| カテゴリ | ツール | 対象レイヤー |
|---|---|---|
| 単体・統合テスト | Vitest | ロジック・関数・コンポーネント |
| APIテスト | Postman / REST Client | HTTP通信・エンドポイント |
| E2Eテスト | Playwright | ブラウザUI操作・ユーザーシナリオ |

---

## 学習プロセス

### 学習スタイル
- テストピラミッドの概念を起点に、各層のツールの役割を整理
- 実装経験（Playwright）と概念理解（Vitest・Postman）を組み合わせて学習

### 到達レベル

| ツール | レベル | 備考 |
|---|---|---|
| Playwright | 実装経験あり | 基本操作・ロケーター選択 |
| Vitest | 概念理解 | Jest経験から類推可能 |
| Postman | 概念理解 | GUI操作・Collection Runner |

---

## テストピラミッド

```
       ┌──────────┐
       │  E2E テスト │  Playwright  ← 少数・遅い・フルスタック
       │  (UIレイヤー) │
      ┌┴──────────┴┐
      │  統合・API テスト │  Postman / supertest ← 中程度
      │  (通信レイヤー) │
     ┌┴────────────┴┐
     │   単体テスト    │  Vitest / Jest ← 大量・速い・ロジック単体
     │  (ロジックレイヤー) │
     └──────────────┘
```

**原則：下の層を厚く、上の層を薄く。** 上に行くほど実行コスト・メンテコストが上がる。

---

## チートシート

### Vitest — ロジックの単体テスト

```ts
// sum.test.ts
import { describe, it, expect } from 'vitest';
import { sum } from './sum';

describe('sum', () => {
  it('2つの数値を足し合わせる', () => {
    expect(sum(1, 2)).toBe(3);
  });

  it('負の数も扱える', () => {
    expect(sum(-1, 5)).toBe(4);
  });
});
```

```bash
npx vitest              # ウォッチモード（開発中）
npx vitest run          # 1回実行（CI向け）
npx vitest --coverage   # カバレッジ計測
```

#### モック（外部依存を切り離す）

```ts
import { vi } from 'vitest';

// モジュール全体をモック
vi.mock('./api', () => ({
  fetchUser: vi.fn().mockResolvedValue({ id: 1, name: 'Alice' }),
}));

// 特定関数だけスパイ
const spy = vi.spyOn(console, 'log');
```

#### コンポーネントテスト（Vue / React）

```ts
// Vue + @vue/test-utils の例
import { mount } from '@vue/test-utils';
import Counter from './Counter.vue';

it('ボタンクリックでカウントが増える', async () => {
  const wrapper = mount(Counter);
  await wrapper.find('button').trigger('click');
  expect(wrapper.text()).toContain('1');
});
```

---

### Postman — API通信テスト

#### 基本的なリクエスト確認

```
GET  https://api.example.com/users/1
Authorization: Bearer {{token}}
```

#### Testsタブ（自動検証スクリプト）

```js
// PostmanのTestsタブに書くスクリプト（pm.test API）
pm.test('ステータスコードが200', () => {
  pm.response.to.have.status(200);
});

pm.test('nameフィールドが存在する', () => {
  const json = pm.response.json();
  pm.expect(json.name).to.be.a('string');
});

pm.test('レスポンスが500ms以内', () => {
  pm.expect(pm.response.responseTime).to.be.below(500);
});
```

#### Environmentで環境切り替え

```
{{base_url}}  → dev: http://localhost:8000 / prod: https://api.example.com
{{token}}     → 環境ごとに異なる認証トークン
```

#### Collection Runner

```bash
# Newman（Postmanのコマンドライン版）でCI連携
npx newman run collection.json -e environment.json
```

---

### Playwright — E2Eテスト

```ts
// tests/login.spec.ts
import { test, expect } from '@playwright/test';

test('ログインして投稿できる', async ({ page }) => {
  await page.goto('/login');
  await page.getByLabel('メールアドレス').fill('user@example.com');
  await page.getByLabel('パスワード').fill('password');
  await page.getByRole('button', { name: 'ログイン' }).click();

  await expect(page).toHaveURL('/dashboard');
  await expect(page.getByText('ようこそ')).toBeVisible();
});
```

```bash
npx playwright test               # 全テスト実行
npx playwright test --ui          # GUIで確認しながら実行
npx playwright codegen            # ブラウザ操作を自動でコード化
npx playwright test --debug       # ステップ実行
```

#### ネットワークのインターセプト

```ts
// APIレスポンスをモックしてUIテストを安定化
await page.route('**/api/users', (route) =>
  route.fulfill({
    status: 200,
    body: JSON.stringify([{ id: 1, name: 'Alice' }]),
  })
);
```

---

## 各ツールの得意・不得意

### Vitest

| 観点 | 内容 |
|---|---|
| **得意** | 関数・クラス・ユーティリティの動作保証 |
| **得意** | コンポーネントのレンダリング・イベント検証 |
| **得意** | 実行速度（Viteベースで高速、ウォッチが快適） |
| **得意** | モック・スパイによる外部依存の分離 |
| **不得意** | 実際のHTTP通信の検証（モックに依存） |
| **不得意** | 複数画面にまたがるユーザーシナリオの検証 |
| **不得意** | ブラウザ固有の挙動（レンダリング差異など） |

### Postman

| 観点 | 内容 |
|---|---|
| **得意** | HTTPエンドポイントの動作確認（ステータス・レスポンスボディ） |
| **得意** | 認証フロー（Bearer・OAuth）のデバッグ |
| **得意** | チーム間でのAPIリクエスト共有（Collection） |
| **得意** | 環境変数による dev/stg/prod の切り替え |
| **不得意** | UIの視覚的な確認（ブラウザを操作しない） |
| **不得意** | フロントエンドコードとの統合（コードベースに乗らない） |
| **不得意** | ユーザーシナリオ全体のテスト（単一APIの確認が主） |

### Playwright

| 観点 | 内容 |
|---|---|
| **得意** | クリック・入力・画面遷移などのユーザー操作のシミュレーション |
| **得意** | 複数ページにまたがるシナリオ（ログイン→操作→ログアウト） |
| **得意** | マルチブラウザ対応（Chromium・Firefox・WebKit） |
| **得意** | スクリーンショット・動画による失敗記録 |
| **不得意** | ロジックの細かい検証（ユニットテストと比べてコストが高い） |
| **不得意** | 実行速度（ブラウザ起動が伴うため遅い） |
| **不得意** | セレクターが壊れやすい（UIが変わるとテストが落ちる） |
| **不得意** | バックエンドのDB状態・ビジネスロジックの直接検証 |

---

## 使い分けの指針

```
「何を壊れたと検知したいか」でツールを選ぶ
```

| 壊れたときに検知したいこと | 使うツール |
|---|---|
| 関数・計算・バリデーションロジックのバグ | **Vitest** |
| リファクタリング後の内部ロジックの回帰 | **Vitest** |
| APIエンドポイントが正しいレスポンスを返すか | **Postman** / supertest |
| 認証・権限・ステータスコードの確認 | **Postman** |
| ログインから投稿まで一連の操作が動くか | **Playwright** |
| フォームのバリデーションエラーが画面に出るか | **Playwright** |
| 本番リリース前の動作確認（スモークテスト） | **Playwright** |

### どれを優先して書くか

1. **Vitest を厚くする**：実行速度が速く、開発サイクルに組み込みやすい。バグの早期発見に最も効果的。
2. **Postman でAPI契約を固める**：フロントとバックエンドの境界を明確にする。チームが多いほど重要。
3. **Playwright は重要シナリオに絞る**：全画面を網羅しようとすると壊れやすくなる。ログイン・決済・主要フローだけに留める。

### コード vs GUI ツール

| | Vitest | Postman | Playwright |
|---|---|---|---|
| テストをコードで書くか | ✅ コード | △ GUIとコード混在 | ✅ コード |
| CIパイプラインに乗せやすいか | ✅ 容易 | △ Newman必要 | ✅ 容易 |
| チームでの共有のしやすさ | ✅ Git管理 | △ Collectionエクスポート | ✅ Git管理 |

---

## 実装資産

| ツール | 実装内容 | 場所 |
|---|---|---|
| Playwright | 基本操作・ロケーター練習 | [docs/playwright/](../playwright/README.md) |
| Vitest | 学習中 | - |
| Postman | 学習中 | - |

---

## 技術的課題と改善方針

| # | 課題 | 問題点 | 改善方針 |
|---|---|---|---|
| 1 | PlaywrightテストのセレクターがUIリニューアルで壊れる | CSSセレクター依存 | `getByRole` / `getByTestId` に統一 |
| 2 | PostmanのCollectionがGitで管理されていない | 手動エクスポートが必要 | Newman + JSON化してリポジトリに含める |
| 3 | Vitestのモック戦略が未確立 | 外部APIを含む関数のテストが難しい | `vi.mock` パターンを体系化する |

---

## 今後の強化方針

### 優先度 高
- [ ] Vitestを既存プロジェクト（Next.js・Laravel）に導入してみる
- [ ] Playwrightでネットワークインターセプトを使いAPIモックを試す

### 優先度 中
- [ ] PostmanのCollectionをNewmanでCI実行する手順を確認
- [ ] テストカバレッジの計測と閾値設定を試す（Vitest）
- [ ] Playwright の Page Object Model パターンを学ぶ

---

## 学んだこと

| 日付 | トピック | メモ |
|---|---|---|
| 2026-05-18 | テストピラミッド | 単体（多）→ 統合 → E2E（少）の構造。下を厚くするほど安定・高速 |
| 2026-05-18 | Vitestの位置づけ | ロジック・コンポーネントの単体テスト担当。Viteベースで高速 |
| 2026-05-18 | Postmanの位置づけ | HTTPエンドポイントの通信確認担当。GUI操作でデバッグしやすい |
| 2026-05-18 | Playwrightの位置づけ | ブラウザUI操作のE2E担当。重要シナリオに絞るのがベストプラクティス |
| 2026-05-18 | ツール選択の指針 | 「何が壊れたときに検知したいか」でツールを選ぶ |
| 2026-05-18 | Playwrightのネットワークモック | `page.route()` でAPIレスポンスをモックしてE2Eを安定化できる |
