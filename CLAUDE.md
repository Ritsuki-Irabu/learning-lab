# Claude への作業指示

## Git ワークフロー

このリポジトリは個人学習用のため、**原則 main へ直接プッシュする**。

```bash
git add <files>
git commit -m "<メッセージ>"
git push origin main
```

### ブランチを使うケース

以下のような大きな変更のみブランチを使う：

- ディレクトリ構造の大幅な変更
- 複数ファイルにまたがるリファクタリング
- 試験的な変更で、取り消す可能性がある作業

```bash
git checkout -b <種別>/<内容>
git push -u origin <ブランチ名>
# mcp__github__create_pull_request でPR作成 → マージ
```

### ブランチ命名規則

| 種別 | 用途 | 例 |
|---|---|---|
| `feat/` | 新機能追加 | `feat/new-topic-script` |
| `docs/` | ドキュメント更新 | `docs/laravel-learning-log` |
| `fix/` | 修正 | `fix/readme-typo` |
| `refactor/` | 構造変更 | `refactor/directory-structure` |
