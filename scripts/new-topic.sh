#!/bin/bash
# 新しい技術トピックのドキュメントフォルダを作成する
# 使い方: ./scripts/new-topic.sh <技術名>
# 例:     ./scripts/new-topic.sh react

set -e

TOPIC="$1"

if [ -z "$TOPIC" ]; then
  echo "使い方: $0 <技術名>"
  echo "例:     $0 react"
  exit 1
fi

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DOCS_DIR="$REPO_ROOT/docs/$TOPIC"

if [ -d "$DOCS_DIR" ]; then
  echo "エラー: docs/$TOPIC/ はすでに存在します"
  exit 1
fi

# docsフォルダ＋メモテンプレート
mkdir -p "$DOCS_DIR"
cat > "$DOCS_DIR/README.md" <<EOF
# ${TOPIC} 技術資産ドキュメント

> ${TOPIC}を用いた学習・開発経験を体系化した技術資産。
> 学習内容の再利用性向上・設計思考ログの蓄積・ポートフォリオ提示を目的とする。

---

## 技術スタック

| カテゴリ | 技術 |
|---|---|
| 言語 / FW | ${TOPIC} |

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

<!-- よく使うコマンドやコードスニペットをここに -->

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
| - | - | - |
EOF

echo "作成しました:"
echo "  docs/$TOPIC/README.md"
echo ""
echo "次のステップ:"
echo "  1. docs/$TOPIC/README.md にメモを記録"
echo "  2. README.md の学習ログに追記"
