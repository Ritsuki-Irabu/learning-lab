# Java 技術資産ドキュメント

> Javaを用いた学習・開発経験を体系化した技術資産。
> 学習内容の再利用性向上・設計思考ログの蓄積・ポートフォリオ提示を目的とする。

---

## 技術スタック

| カテゴリ | 技術 |
|---|---|
| 言語 | Java |
| フレームワーク | Spring Boot |
| ORM | Spring Data JPA |
| 開発環境 | IntelliJ IDEA |
| バージョン管理 | Git |

---

## 学習プロセス

### 学習スタイル
- 一日一課題ベースでの継続学習
- 問題解決型（ロジック構築中心）
- 選択問題もコード（print）で表現

### 到達レベル

| 領域 | レベル |
|---|---|
| 文法理解 | ✅ 完了 |
| ロジック構築 | 実務初級レベル |
| API設計 | 学習中 |

---

## チートシート

### Stream API

```java
List<String> names = users.stream()
    .filter(u -> u.isActive())
    .map(User::getName)
    .collect(Collectors.toList());
```

### Optional

```java
Optional.ofNullable(value)
    .map(String::trim)
    .orElse("default");
```

### 条件分岐

```java
if (score >= 80) {
    System.out.println("A");
} else if (score >= 60) {
    System.out.println("B");
} else {
    System.out.println("C");
}

switch (day) {
    case "MON": System.out.println("月曜"); break;
    default:    System.out.println("その他"); break;
}
```

### ループ処理

```java
for (int i = 0; i < 10; i++) { ... }
while (condition) { ... }
for (String item : list) { ... }
```

---

## 実装資産

### 基礎実装
- クラス設計・メソッド分割
- 条件分岐（if / switch）
- ループ処理（for / while）
- 処理の分割を意識した再利用可能なメソッド構造

### 課題ベース開発（構成）

```
src/
 └─ curriculum2/
     ├─ Question1.java
     ├─ Question2.java
     └─ ...
```

- 1課題1クラスで責務分離
- ロジック単位での独立性確保

---

## API開発資産（KPI管理API）

### Entity設計（階層）

```
AppUser
 └─ KGI
     └─ KPI
         └─ KPIRecord
```

### 各Entityのフィールド

| Entity | フィールド |
|---|---|
| AppUser | id, userName, createdAt |
| KGI | id, user（ManyToOne）, title, targetValue |
| KPI | id, kgi（ManyToOne）, title, targetValue |
| KPIRecord | id, kpi（ManyToOne）, recordDate, actualValue |

### Repositoryメソッド

```java
findByUserId(Long userId);
findByKgiId(Long kgiId);
findByKpiId(Long kpiId);
```

> ⚠️ 課題：ネストプロパティ未最適化

### Service層の実装機能

```java
create(...)
findAll()
findById(Long id)
deleteById(Long id)
```

> ⚠️ 課題：Entityを直接返却・DTO未導入

---

## 技術的課題と改善方針

| # | 課題 | 問題点 | 改善方針 |
|---|---|---|---|
| 1 | DTO未導入 | Entityの外部公開・変更に弱い設計 | DTOを導入しEntityとAPIレスポンスを分離 |
| 2 | Service責務の曖昧さ | ロジック集約不足 | ビジネスロジック明確化・トランザクション管理整理 |
| 3 | 設計の抽象度不足 | CRUD中心で拡張性が低い | ユースケースベース設計へ移行 |

---

## 今後の強化方針

### 優先度 高
- [ ] DTO設計
- [ ] APIレスポンス設計
- [ ] Service層再設計

### 優先度 中
- [ ] アルゴリズム強化（計算問題・未知問題対応）
- [ ] リファクタリング習慣
- [ ] 設計パターン理解

---

## 学んだこと

| 日付 | トピック | メモ |
|---|---|---|
| - | - | - |
