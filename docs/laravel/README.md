# Laravel メモ

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

## トラブルシュート

| エラー | 原因 | 解決策 |
|---|---|---|
| 404 | ルート未定義 / URLのタイポ | `php artisan route:list` で確認 |
| 419 | CSRFトークン不一致 | フォームに `@csrf` を追加。キャッシュ・Cookie削除も試す |
| 500 | ParseError / DB接続エラー | ログ確認（`storage/logs/laravel.log`） |
| 権限エラー | storageへの書き込み不可 | `chmod -R 775 storage bootstrap/cache` |

---

## 学んだこと

| 日付 | トピック | メモ |
|---|---|---|
| 2026-04-24 | CRUD・ルート設計 | show（詳細）とedit（編集）の役割を分けて考える。URLとViewファイル名の整合性が重要 |
| 2026-04-24 | Breeze・CSRF・UX | 419エラーの仕組みを理解。old()で入力保持、フォームリクエストでコントローラーを簡略化 |
| 2026-04-24 | API実装 | RemotePostController作成。bootstrap/app.phpへのAPI設定追記がポイント |
| 2026-04-24 | テスト・ロギング | PHPUnitのアサーション概念とLog::infoによるデバッグ手法を習得 |
| 2026-04-24 | タスク管理システム | 1対多のリレーション設計、Docker環境構築（Apache/MySQL）、Breezeによる認証基盤導入 |
