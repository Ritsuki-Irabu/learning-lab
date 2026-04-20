#!/bin/bash
# 新しい技術トピックのフォルダを作成する
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
TOPIC_DIR="$REPO_ROOT/$TOPIC"
DOCS_DIR="$REPO_ROOT/docs/$TOPIC"

if [ -d "$TOPIC_DIR" ]; then
  echo "エラー: $TOPIC/ はすでに存在します"
  exit 1
fi

# 実装フォルダ
mkdir -p "$TOPIC_DIR"
touch "$TOPIC_DIR/.gitkeep"

# docsフォルダ＋メモテンプレート
mkdir -p "$DOCS_DIR"
cat > "$DOCS_DIR/README.md" <<EOF
# ${TOPIC} メモ

## チートシート

<!-- よく使うコマンドやコードスニペットをここに -->

---

## 学んだこと

| 日付 | トピック | メモ |
|---|---|---|
| - | - | - |
EOF

echo "作成しました:"
echo "  $TOPIC/              # 実装を置く場所"
echo "  docs/$TOPIC/README.md # メモ・チートシート"
echo ""
echo "次のステップ:"
echo "  1. $TOPIC/ に実装を追加"
echo "  2. docs/$TOPIC/README.md にメモを記録"
echo "  3. README.md の学習ログに追記"
