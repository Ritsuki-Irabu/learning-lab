# Next.js 技術資産ドキュメント

> Next.jsを用いた学習・開発経験を体系化した技術資産。
> 学習内容の再利用性向上・設計思考ログの蓄積・ポートフォリオ提示を目的とする。

---

## 技術スタック

| カテゴリ | 技術 |
|---|---|
| 言語 / FW | Next.js（App Router） |
| ORM | Prisma |
| 認証 | Auth.js（next-auth v5） |
| AI | Gemini API |

---

## 学習プロセス

### 学習スタイル
- スプリント形式のプロダクト開発を通じて実践的に習得

### 到達レベル

| 領域 | レベル |
|---|---|
| App Router | ルーティング・API Route 実装経験あり |
| Prisma | Schema 設計・Migrate・Client 実装経験あり |
| Auth.js | Google OAuth 実装経験あり |

---

## チートシート

### dotenv が必要な理由（Prisma CLI + Next.js 構成）

#### .env の読み込みフロー比較

```
通常（Next.js）:  .env  →  Next.js が自動で読む
Prisma CLI:      .env  →  prisma.config.ts  →  Prisma CLI
```

#### 問題：Prisma CLI は Next.js を経由しない

```
npx prisma migrate dev
    ↓
prisma.config.ts が実行される（Next.js の外）
    ↓
dotenv がいないと .env が読まれず DATABASE_URL = undefined
```

Next.js は `.env` を自動で読み込む仕組みを持つが、`prisma migrate` は Prisma CLI が直接実行するため Next.js を経由しない。そのため `prisma.config.ts` で dotenv を明示的に呼ぶ必要がある。

#### 対処：prisma.config.ts で dotenv を明示呼び出し

```ts
import 'dotenv/config';
import { defineConfig } from 'prisma/config';

export default defineConfig({
  // ...
});
```

#### なぜ .env に切り出すのか（セキュリティ）

`DATABASE_URL` のような接続情報をソースコードに直書きすると、GitHub にプッシュした際に誰でも見られる状態になる。`.env` ファイルに切り出し `.gitignore` で除外することで認証情報をリポジトリから守る。

dotenv はその `.env` ファイルを読み込んで `process.env` に展開するライブラリ。

---

### Auth.js（next-auth v5）で Google ログインを実装する手順

#### 1. パッケージのインストール

```bash
npm install next-auth@beta @auth/prisma-adapter
```

#### 2. Prisma スキーマにモデルを追加してマイグレーション

Auth.js が公式指定する3つのモデルを `schema.prisma` に追加する。

| モデル | 役割 |
|---|---|
| `Account` | Google アカウントとユーザーの紐付け |
| `Session` | 「今誰がログイン中か」の管理 |
| `VerificationToken` | 認証用チケット |

```bash
npx prisma migrate dev
```

#### 3. Google Cloud Console で OAuth クライアントを作成

- 承認済みリダイレクト URI：`http://localhost:3000/api/auth/callback/google`
- 取得するもの：**Client ID** と **Client Secret**

#### 4. 環境変数を設定する

```bash
# AUTH_SECRET は npx auth secret で生成
AUTH_SECRET=あなたのシークレット
AUTH_GOOGLE_ID=GoogleのClient ID
AUTH_GOOGLE_SECRET=GoogleのClient Secret
```

#### 5. 3つのファイルを配置する

| ファイル | 役割 |
|---|---|
| `auth.ts` | Google プロバイダーと Prisma アダプターを設定する「設定書」 |
| `app/api/auth/[...nextauth]/route.ts` | Google からの通信を受け取る「受付窓口」 |
| `middleware.ts` | 未ログインユーザーを弾く「警備員」 |

#### キャッチオールルート `[...nextauth]` とは

Next.js のキャッチオールルート記法。`/api/auth/` 以下のすべてのパスを1つのファイルで受け取る。

```
/api/auth/signin
/api/auth/callback/google   ←  これらを全部 [...nextauth]/route.ts が処理
/api/auth/signout
```

---

### Prisma Client シングルトン（app/lib/prisma.ts）

Next.js のホットリロードでモジュールが再読み込みされるたびに `PrismaClient` が増殖する問題を防ぐ。`globalThis` にインスタンスを保持して使い回す。

```ts
import { PrismaClient } from '@prisma/client';

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined;
};

export const prisma =
  globalForPrisma.prisma ?? new PrismaClient();

if (process.env.NODE_ENV !== 'production') {
  globalForPrisma.prisma = prisma;
}
```

---

### POST /api/logs の処理フロー

```
① セッション確認（未認証は 401）
② ThoughtLog を DB に保存
③ Gemini API で思考分析
④ AnalysisResult + AnalysisScore を DB に保存
⑤ { success: true, logId } を返す
```

#### 設計上の判断

| 判断 | 選択 | 理由 |
|---|---|---|
| Gemini 失敗時 | ThoughtLog を残す | ユーザーの入力を失わないため |
| レスポンス | 完了通知のみ | フロントは別途 GET で取得するため |
| PATCH/DELETE | 後回し | agility-logic.ts（Sprint 3.1）への依存があるため |

---

## 実装資産

### プロジェクト全体スプリント計画

#### Sprint 1: 基盤構築

| タスクID | タスク名 | 状態 |
|---|---|---|
| 1.1 | Next.js プロジェクト初期化 | ✅ 完了 |
| 1.2 | Prisma Schema 定義 | ✅ 完了 |
| 1.3 | DB マイグレーション & Seed 作成 | ✅ 完了 |
| 1.4 | Auth.js (v5) セットアップ | ✅ 完了 |
| 1.5 | 共有レイアウト（Nav/Sidebar） | ✅ 完了 |

#### Sprint 2: AI 分析エンジン & 入力フロー

| タスクID | タスク名 | 状態 | 備考 |
|---|---|---|---|
| 2.1 | Gemini API 連携 Service 実装 | ✅ 完了 | |
| 2.2 | POST /api/logs エンドポイント | ✅ 完了 | |
| 2.3 | 思考ログ入力フォーム（UI） | ✅ 別PJ完了 | 統合時に移植 |
| 2.4 | 分析中の Loading 状態管理 | ✅ 別PJ完了 | 統合時に移植 |
| 2.5 | ログ履歴一覧コンポーネント | ✅ 別PJ完了 | 統合時に移植 |
| 2.6 | GET /api/logs エンドポイント | ⬜ 未着手 | 統合に必要 |

#### Sprint 3: スコア計算 & データ可視化

| タスクID | タスク名 | 状態 | 備考 |
|---|---|---|---|
| 3.1 | Agility Score 算出アルゴリズム | ⬜ 未着手 | |
| 3.2 | 算出ロジックの単体テスト | ⬜ 未着手 | |
| 3.3 | カスタム SVG レーダーチャート | ✅ 別PJ完了 | 統合時に移植 |
| 3.4 | ポートフォリオ・ダッシュボード | ✅ 別PJ完了 | 統合時に移植 |
| 3.5 | パフォーマンス最適化 | ⬜ 未着手 | |
| 3.6 | PATCH/DELETE /api/logs/[id] | ⬜ 未着手 | 3.1 と同タイミング |
| 3.7 | GET /api/portfolio エンドポイント | ⬜ 未着手 | 統合に必要 |

#### Sprint 4: フロントエンド統合

| タスクID | タスク名 | 状態 | 備考 |
|---|---|---|---|
| 4.1 | reframing-journey プロトタイプ移植 | ⬜ 未着手 | 別PJからの移行 |
| 4.2 | API との結合・動作確認 | ⬜ 未着手 | E2E の疎通確認 |

---

### Sprint 2.2 実装ファイル

| ファイル | 役割 |
|---|---|
| `app/lib/prisma.ts` | Prisma Client のシングルトン初期化 |
| `app/types/api.ts` | リクエスト・レスポンスの型定義 |
| `app/api/logs/route.ts` | POST /api/logs の本体 |

---

## 技術的課題と改善方針

| # | 課題 | 問題点 | 改善方針 |
|---|---|---|---|
| 1 | PATCH/DELETE 未実装 | ログの更新・削除が不可 | Sprint 3.1（agility-logic.ts 実装後）に対応 |
| 2 | GET /api/logs 未実装 | フロントからのログ取得が不可 | Sprint 2.6 で対応 |
| 3 | フロントエンド未統合 | 別PJのUIコンポーネントが本体に未移植 | Sprint 4.1 で移植 |

---

## 今後の強化方針

### 優先度 高
- [ ] GET /api/logs の実装（Sprint 2.6）
- [ ] Agility Score 算出アルゴリズム（Sprint 3.1）
- [ ] PATCH/DELETE /api/logs/[id]（Sprint 3.6）

### 優先度 中
- [ ] reframing-journey プロトタイプ移植（Sprint 4.1）
- [ ] GET /api/portfolio エンドポイント（Sprint 3.7）
- [ ] パフォーマンス最適化（Sprint 3.5）

---

## 学んだこと

| 日付 | トピック | メモ |
|---|---|---|
| 2026-05-05 | dotenv が必要な理由 | Prisma CLI は Next.js を経由しないため `.env` が自動読み込みされない。`prisma.config.ts` で `import 'dotenv/config'` を明示する必要がある |
| 2026-05-05 | .env のセキュリティ上の役割 | 接続情報の直書きを避け `.gitignore` で除外することで認証情報をリポジトリから守る |
| 2026-05-06 | Auth.js（next-auth v5）Google ログイン実装手順 | パッケージ導入→Prismaモデル追加→Google OAuth設定→環境変数→3ファイル配置の5ステップ |
| 2026-05-06 | `[...nextauth]` キャッチオールルート | `/api/auth/` 以下の全パスを1ファイルで受け取る Next.js の記法 |
| 2026-05-13 | Prisma とは（ORM） | TypeScript から DB を操作する ORM。Laravel の Eloquent・Spring Boot の JPA に相当 |
| 2026-05-13 | Prisma の3要素 | Schema（テーブル設計）・Migrate（DB 反映）・Client（コードからの操作窓口） |
| 2026-05-13 | シングルトンパターン（Prisma Client） | ホットリロードによる PrismaClient 増殖を `globalThis` で防ぐ設計パターン |
| 2026-05-13 | POST /api/logs 処理フロー | セッション確認→ThoughtLog 保存→Gemini 分析→Result 保存→完了通知の5ステップ |
| 2026-05-13 | Gemini 失敗時の設計判断 | ThoughtLog を先に保存してユーザー入力を保護。分析失敗でもデータを失わない方針 |
