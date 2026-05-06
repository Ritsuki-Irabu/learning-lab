# Next.js 技術資産ドキュメント

> Next.jsを用いた学習・開発経験を体系化した技術資産。
> 学習内容の再利用性向上・設計思考ログの蓄積・ポートフォリオ提示を目的とする。

---

## 技術スタック

| カテゴリ | 技術 |
|---|---|
| 言語 / FW | Next.js |

---

## 学習プロセス

### 学習スタイル
-

### 到達レベル

| 領域 | レベル |
|---|---|
| - | - |

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

<!-- 実装した内容・ディレクトリ構成をここに記録 -->

---

## 技術的課題と改善方針

| # | 課題 | 問題点 | 改善方針 |
|---|---|---|---|
| - | - | - | - |

---

## 今後の強化方針

### 優先度 高
- [ ]

### 優先度 中
- [ ]

---

## 学んだこと

| 日付 | トピック | メモ |
|---|---|---|
| 2026-05-05 | dotenv が必要な理由 | Prisma CLI は Next.js を経由しないため `.env` が自動読み込みされない。`prisma.config.ts` で `import 'dotenv/config'` を明示する必要がある |
| 2026-05-05 | .env のセキュリティ上の役割 | 接続情報の直書きを避け `.gitignore` で除外することで認証情報をリポジトリから守る |
| 2026-05-06 | Auth.js（next-auth v5）Google ログイン実装手順 | パッケージ導入→Prismaモデル追加→Google OAuth設定→環境変数→3ファイル配置の5ステップ |
| 2026-05-06 | `[...nextauth]` キャッチオールルート | `/api/auth/` 以下の全パスを1ファイルで受け取る Next.js の記法 |
