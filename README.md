# Learning Lab

> 技術学習の資産管理リポジトリ
> 学んだことを正確に実装・記録し、再利用可能な技術資産として蓄積する

---

## 方針

- **正確性優先**：曖昧な記述より「わからない」「未着手」と明示する方が良い
- **ソース意識**：公式ドキュメント・実際の動作に基づいて記述する
- **誤りは必ず訂正**：誤った情報はリポジトリの信頼性を損なう
- **フォーマット統一**：全技術ドキュメントを標準構造に合わせる
- 技術別のメモは `docs/<技術名>/` に置く

---

## ドキュメント標準フォーマット

`docs/<技術名>/README.md` は以下の構造で統一する：

```
## 技術スタック        使用言語・FW・ツールのテーブル
## 学習プロセス        学習スタイルと到達レベルのテーブル
## チートシート        動作確認済みのコードスニペット
## 実装資産            作ったものの一覧・ディレクトリ構成
## 技術的課題と改善方針 課題・問題点・改善方針のテーブル
## 今後の強化方針      優先度別チェックリスト
## 学んだこと          日付・トピック・メモのテーブル
```

> ⚠️ コードスニペットは「動くはず」ではなく「動作確認済み」のものを記載する。
> バージョン依存の情報は対象バージョンを明記し、確信が持てない箇所には `⚠️ 要確認：` を付ける。

---

## 新しい技術を追加するとき

```bash
./scripts/new-topic.sh <技術名>

# 例
./scripts/new-topic.sh react
```

`docs/<技術名>/README.md`（標準フォーマットのテンプレート）が作られる。

---

## ドキュメントの更新・精度検証

`/learning-lab` スキルを使うと以下を自動で行う：

1. 既存ドキュメントの構成・コードスニペット・説明文を検証
2. 誤りや古い情報を発見した場合は訂正
3. 空欄・プレースホルダーを実態に合った内容で補完
4. 標準フォーマットへの統一
5. ブランチ作成・コミット・プッシュ・PR作成

訂正した内容は `学んだこと` テーブルに以下の形式で記録される：

| 日付 | トピック | メモ |
|---|---|---|
| YYYY-MM-DD | [訂正] トピック名 | 誤：旧内容 → 正：新内容 |

---

## フォルダ構成

```
learning-lab/
├── .claude/
│   └── skills/
│       └── learning-lab/  # /learning-lab スキル
├── docs/                  # 技術別ドキュメント・チートシート
│   ├── docker/
│   ├── git/
│   ├── java/
│   ├── laravel/
│   ├── nextjs/
│   ├── playwright/
│   └── ui-patterns/
├── scripts/               # 管理スクリプト
├── CLAUDE.md
└── README.md
```

---

## 学習ログ

| 日付 | 技術 | 内容 | 参照 |
|---|---|---|---|
| 2026-04-24 | Laravel | CRUD・ルート設計 | [メモ](docs/laravel/README.md) |
| 2026-04-24 | Laravel | Breeze・CSRF・UX | [メモ](docs/laravel/README.md) |
| 2026-04-24 | Laravel | API実装 | [メモ](docs/laravel/README.md) |
| 2026-04-24 | Laravel | テスト・ロギング | [メモ](docs/laravel/README.md) |
| 2026-04-24 | Laravel | タスク管理システム | [メモ](docs/laravel/README.md) |
| 2026-04-25 | Laravel | 共通レイアウト設計（app.blade.php） | [メモ](docs/laravel/README.md) |
| 2026-04-25 | Laravel | ヘッダーコンポーネント化 | [メモ](docs/laravel/README.md) |
| 2026-04-25 | Laravel | 動的ナビゲーション | [メモ](docs/laravel/README.md) |
| 2026-04-25 | Laravel | 認証連動ログアウト | [メモ](docs/laravel/README.md) |
| 2026-04-27 | Docker | WSL2 ターミナル必須（PowerShell 不可の理由） | [メモ](docs/docker/README.md) |
| 2026-04-27 | Docker | コンテナの内外意識（exec / exit の挙動） | [メモ](docs/docker/README.md) ✅ |
| 2026-04-27 | Docker | Dockerfile リビルド（--build / --no-cache） | [メモ](docs/docker/README.md) |
| 2026-04-27 | Docker | 419 エラー対処（CSRF・config:clear の仕組み） | [メモ](docs/docker/README.md) |
| 2026-04-27 | Docker | 404 エラー対処（mod_rewrite・Front Controller） | [メモ](docs/docker/README.md) |
| 2026-05-03 | Docker | Engine 起動不具合（npipe エラー）の診断と復旧手順 | [メモ](docs/docker/README.md) ✅ |
| 2026-05-04 | Laravel | Eloquentスコープ・$casts・アクセサ | [メモ](docs/laravel/README.md) |
| 2026-05-04 | Laravel | Rule::in()バリデーション・ソートSQLi対策 | [メモ](docs/laravel/README.md) ✅ |
| 2026-05-04 | Laravel | 削除確認モーダル・BEM CSS・JS外部化 | [メモ](docs/laravel/README.md) |
| 2026-05-04 | UI パターン | Modal・Dialog・Popup の定義整理 | [メモ](docs/ui-patterns/README.md) |
| 2026-05-04 | UI パターン | 3用語の本質（制御・表示形式・やり取り） | [メモ](docs/ui-patterns/README.md) ✅ |
| 2026-05-04 | UI パターン | `showModal()` vs `show()` の違い | [メモ](docs/ui-patterns/README.md) |
| 2026-05-04 | UI パターン | HTML Popover API（2024年正式化） | [メモ](docs/ui-patterns/README.md) |
| 2026-05-04 | UI パターン | ARIA ロールと `<dialog>` 要素の関係 | [メモ](docs/ui-patterns/README.md) |
| 2026-05-05 | Git | 実務ブランチ戦略（main=本番・staging=ステージ） | [メモ](docs/git/README.md) ✅ |
| 2026-05-05 | Git | Feature Branch を切る判断基準 | [メモ](docs/git/README.md) ✅ |
| 2026-05-05 | Next.js | dotenv が必要な理由（Prisma CLI は Next.js を経由しない） | [メモ](docs/nextjs/README.md) |
| 2026-05-05 | Next.js | .env のセキュリティ上の役割と .gitignore による除外 | [メモ](docs/nextjs/README.md) |
| 2026-05-06 | Next.js | Auth.js で Google ログイン実装（5ステップ） | [メモ](docs/nextjs/README.md) ✅ |
| 2026-05-06 | Next.js | `[...nextauth]` キャッチオールルートの仕組み | [メモ](docs/nextjs/README.md) ✅ |
| 2026-05-13 | Next.js | Prisma とは（ORM・Eloquent / JPA 相当） | [メモ](docs/nextjs/README.md) |
| 2026-05-13 | Next.js | Prisma の3要素（Schema・Migrate・Client） | [メモ](docs/nextjs/README.md) |
| 2026-05-13 | Next.js | シングルトンパターン（Prisma Client・globalThis） | [メモ](docs/nextjs/README.md) |
| 2026-05-13 | Next.js | POST /api/logs 処理フロー（5ステップ） | [メモ](docs/nextjs/README.md) |
| 2026-05-13 | Next.js | Gemini 失敗時の設計判断（ThoughtLog 先行保存） | [メモ](docs/nextjs/README.md) |
