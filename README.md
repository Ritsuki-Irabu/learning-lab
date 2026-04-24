# Learning Lab

> 技術学習の資産管理リポジトリ  
> 学んだことを実装として残し、スキルを可視化する

---

## 方針

- 学習した内容は必ずここに実装として残す
- 動けばOK。完璧なコードより「動いた記録」を優先する
- コミットメッセージで何を学んだかがわかるようにする
- 技術別のメモは `docs/<技術名>/` に置く

---

## 新しい技術を追加するとき

```bash
./scripts/new-topic.sh <技術名>

# 例
./scripts/new-topic.sh react
```

`<技術名>/`（実装置き場）と `docs/<技術名>/README.md`（メモテンプレート）が同時に作られる。

---

## フォルダ構成

```
learning-lab/
├── scripts/         # 管理スクリプト
├── laravel/         # Laravel学習（SES研修）
├── java/            # Java学習
├── playwright/      # Playwright実験・検証
└── docs/            # 技術別メモ・チートシート
    ├── laravel/
    ├── java/
    └── playwright/
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

<!-- 記録例:
| 2026-04-20 | Laravel | Eloquentのリレーション実装 | [コミット](../commit/abc1234) / [メモ](docs/laravel/eloquent.md) |
-->

