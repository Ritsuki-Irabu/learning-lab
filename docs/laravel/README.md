# Laravel 技術資産ドキュメント

> Laravelを用いた学習・開発経験を体系化した技術資産。
> 学習内容の再利用性向上・設計思考ログの蓄積・ポートフォリオ提示を目的とする。

---

## 技術スタック

| カテゴリ | 技術 |
|---|---|
| 言語 | PHP |
| フレームワーク | Laravel |
| 認証 | Laravel Breeze |
| テスト | PHPUnit |
| 開発環境 | Docker（Apache / MySQL） |
| バージョン管理 | Git |

---

## 学習プロセス

### 学習スタイル
- SES研修ベースでの実務想定学習
- 機能単位（CRUD・認証・API）で段階的に実装
- エラーを再現・解決して仕組みを理解するスタイル

### 到達レベル

| 領域 | レベル |
|---|---|
| ルーティング・CRUD | ✅ 完了 |
| 認証（Breeze） | ✅ 完了 |
| API実装 | ✅ 完了 |
| テスト・ロギング | 学習中 |
| 設計・リファクタリング | 学習中 |

---

## チートシート

### ルーティング

```php
// リソースルート（一覧・詳細・作成・編集・更新・削除を一括定義）
Route::resource('posts', PostController::class);

// APIルート（bootstrap/app.php に追記が必要）
Route::prefix('api')->group(function () {
    Route::get('/posts', [RemotePostController::class, 'index']);
});
```

### Eloquent

```php
// リレーション（1対多）
$user->posts()->where('published', true)->get();

// アクセサ
public function getFullNameAttribute(): string
{
    return "{$this->first_name} {$this->last_name}";
}
```

### バリデーション（フォームリクエスト）

```bash
php artisan make:request StorePostRequest
```

```php
// フォームリクエストでコントローラーをスッキリさせる
public function store(StorePostRequest $request)
{
    Post::create($request->validated());
}

// Viewでold()を使って入力保持（UX向上）
<input name="title" value="{{ old('title') }}">
```

### 認証（Breeze）

```bash
composer require laravel/breeze --dev
php artisan breeze:install
npm install && npm run dev
php artisan migrate
```

### テスト（PHPUnit）

```bash
php artisan make:test UserTest --unit
php artisan test
```

```php
// アサーション例
$this->assertTrue($user->isAdmin());
$this->assertDatabaseHas('users', ['email' => 'test@example.com']);
```

### ロギング

```php
// デバッグログの出力（storage/logs/laravel.log に記録）
Log::info('ユーザーがログイン', ['user_id' => $user->id]);
Log::error('エラー発生', ['message' => $e->getMessage()]);
```

### Artisan

```bash
php artisan make:model Post -mcr   # Model + Migration + Controller(resource)
php artisan migrate:fresh --seed   # DBリセット＋シード
php artisan tinker                  # REPL
php artisan route:list              # ルート一覧確認
```

### Git操作（開発フロー）

```bash
git stash                        # 変更を一時退避
git pull origin main             # 最新を取り込む
git stash pop                    # 退避した変更を戻す
# コンフリクトが発生した場合は手動解消 → git add → git commit
```

---

## 実装資産

### 基礎実装
- リソースルートによるCRUD実装
- Breezeを用いた認証基盤構築
- フォームリクエストによるバリデーション分離
- old()を使った入力保持（UX向上）

### API実装
- RemotePostControllerによるAPIエンドポイント作成
- bootstrap/app.phpへのAPI設定追記

### 課題ベース開発（構成）

```
app/
 ├─ Http/
 │   ├─ Controllers/
 │   │   ├─ PostController.php        # リソースコントローラー
 │   │   └─ RemotePostController.php  # APIコントローラー
 │   └─ Requests/
 │       └─ StorePostRequest.php      # フォームリクエスト
 └─ Models/
     └─ Post.php
```

### タスク管理システム
- 1対多のリレーション設計（User → Task）
- Docker環境構築（Apache / MySQL）
- Breezeによる認証基盤導入

---

## 技術的課題と改善方針

| # | 課題 | 問題点 | 改善方針 |
|---|---|---|---|
| 1 | テスト不足 | 手動確認が中心でリグレッションリスクあり | PHPUnitでFeature/Unitテストを整備 |
| 2 | API設計の甘さ | レスポンス形式が統一されていない | APIリソースクラス（JsonResource）を導入 |
| 3 | 認可未実装 | 認証はあるが権限制御がない | ポリシー・ミドルウェアで認可を追加 |

---

## 今後の強化方針

### 優先度 高
- [ ] Featureテストの整備
- [ ] APIリソースクラスの導入
- [ ] 認可（ポリシー）の実装

### 優先度 中
- [ ] サービス層の分離（Fat Controller解消）
- [ ] ページネーション・検索機能の実装
- [ ] エラーハンドリングの統一

---

## 学んだこと

| 日付 | トピック | メモ |
|---|---|---|
| 2026-04-24 | CRUD・ルート設計 | show（詳細）とedit（編集）の役割を分けて考える。URLとViewファイル名の整合性が重要 |
| 2026-04-24 | Breeze・CSRF・UX | 419エラーの仕組みを理解。old()で入力保持、フォームリクエストでコントローラーを簡略化 |
| 2026-04-24 | API実装 | RemotePostController作成。bootstrap/app.phpへのAPI設定追記がポイント |
| 2026-04-24 | テスト・ロギング | PHPUnitのアサーション概念とLog::infoによるデバッグ手法を習得 |
| 2026-04-24 | タスク管理システム | 1対多のリレーション設計、Docker環境構築（Apache/MySQL）、Breezeによる認証基盤導入 |
