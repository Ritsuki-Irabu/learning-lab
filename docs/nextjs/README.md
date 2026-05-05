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

## 実装資産

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
