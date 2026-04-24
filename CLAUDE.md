# Claude への作業指示

## Git ワークフロー

このリポジトリでは**必ずブランチを経由してPRを作成する**こと。mainへの直接プッシュは禁止。

### 手順（毎回必ず守ること）

1. **ブランチ作成**（作業前に必ず実施）
   ```bash
   git checkout -b <種別>/<内容> # 例: docs/laravel-crud, feat/new-topic-script
   ```

2. **コミット＆プッシュ**
   ```bash
   git add <files>
   git commit -m "<メッセージ>"
   git push -u origin <ブランチ名>
   ```

3. **PR作成**（プッシュ後に必ず実施）
   - MCP GitHub ツール（`mcp__github__create_pull_request`）でPRを作成する
   - base: `main`、head: 作業ブランチ

### ブランチ命名規則

| 種別 | 用途 | 例 |
|---|---|---|
| `feat/` | 新機能追加 | `feat/new-topic-script` |
| `docs/` | ドキュメント更新 | `docs/laravel-learning-log` |
| `fix/` | 修正 | `fix/readme-typo` |

### 禁止事項

- `git push origin main` を直接実行しない
- PRなしでmainにマージしない
