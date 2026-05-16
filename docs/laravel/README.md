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
| フロントビルド | Vite / npm |
| バージョン管理 | Git |

---

## 学習プロセス

### 学習スタイル
- SES研修ベースでの実務想定学習
- 機能単位（CRUD・認証・API）で段階的に実装
- エラーを再現・解決して仕組みを理解するスタイル
- コードレビュー → チケット駆動リファクタリング

### 到達レベル

| 領域 | レベル |
|---|---|
| ルーティング・CRUD | ✅ 完了 |
| Bladeテンプレート設計 | ✅ 完了 |
| 認証（Breeze） | ✅ 完了 |
| API実装 | ✅ 完了 |
| Eloquentスコープ・アクセサ・キャスト | ✅ 完了 |
| セキュリティ（SQLi対策・バリデーション） | ✅ 完了 |
| CSS/JS外部化・BEM設計 | ✅ 完了 |
| テスト・ロギング | 学習中 |
| 設計・リファクタリング | 学習中 |

---

## チートシート

### ルーティング

```php
// リソースルート（一覧・詳細・作成・編集・更新・削除を一括定義）
Route::resource('posts', PostController::class);

// 認証必須のグループ化
Route::middleware('auth')->group(function () {
    Route::get('/tasks', [TaskController::class, 'index'])->name('tasks.index');
    Route::resource('/tasks', TaskController::class)->except('index');
});

// APIルート（bootstrap/app.php に追記が必要 ※Laravel 11）
Route::prefix('api')->group(function () {
    Route::get('/posts', [RemotePostController::class, 'index']);
});
```

### Bladeレイアウト・コンポーネント

```blade
{{-- resources/views/layouts/app.blade.php（共通骨格） --}}
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>@yield('title', 'アプリ名')</title>
</head>
<body>
    @include('layouts.header')
    <main>
        @yield('content')
    </main>
</body>
</html>

{{-- 各画面（例: tasks/index.blade.php）--}}
@extends('layouts.app')

@section('title', 'タスク一覧')

@section('content')
    <h1>タスク一覧</h1>
@endsection
```

```blade
{{-- コンポーネントレイアウト（$slot パターン / Breeze標準） --}}
{{-- resources/views/components/layout.blade.php --}}
<!DOCTYPE html>
<html lang="ja">
<body>
    @include('layouts.header')
    <main>{{ $slot }}</main>
</body>
</html>

{{-- 利用側：x-タグで中身を差し込む --}}
<x-layout>
    <h1>コンテンツ</h1>
</x-layout>
```

```blade
{{-- route() 関数：URLをハードコーディングせずルート名で参照 --}}
<a href="{{ route('tasks.index') }}">タスク一覧</a>
<a href="{{ route('tasks.edit', $task) }}">編集</a>

{{-- @error：バリデーションエラーの表示 --}}
@error('title')
<p class="c-error-msg">{{ $message }}</p>
@enderror

{{-- old()：バリデーション失敗時の入力値保持 --}}
<input name="title" value="{{ old('title', $task->title) }}">
```

---

### Eloquent

```php
// リレーション（1対多）
// User.php
public function tasks(): HasMany
{
    return $this->hasMany(Task::class);
}

// Task.php
public function assignedUser(): BelongsTo
{
    return $this->belongsTo(User::class, 'assigned_user_id');
}

// 利用側
$task->assignedUser->name ?? '未設定'
```

```php
// $casts：DB値を自動的に型変換（型不一致バグを防止）
protected $casts = [
    'task_status'      => 'integer',
    'assigned_user_id' => 'integer',
];
```

```php
// アクセサ（旧スタイル）：$task->status_label で呼び出せる
public function getStatusLabelAttribute(): string
{
    $statuses = config('task.statuses');
    return $statuses[$this->task_status] ?? '不明';
}
```

```php
// Eloquent スコープ：クエリロジックをModelにカプセル化
// scopeXxx と定義し、->xxx() で呼び出す（scope プレフィックスは外れる）
public function scopeSearch($query, array $filters): void
{
    if (!empty($filters['keyword'])) {
        $query->where(function ($q) use ($filters) {
            $q->where('title', 'like', "%{$filters['keyword']}%")
              ->orWhere('id', $filters['keyword']);
        });
    }
    if (isset($filters['status']) && $filters['status'] !== '') {
        $query->where('task_status', $filters['status']);
    }
}

// Controller 側
$tasks = Task::query()->search($filters)->orderBy('id', 'asc')->get();
```

### バリデーション

```bash
php artisan make:request StorePostRequest
```

```php
// フォームリクエストでコントローラーをスッキリさせる
public function store(StorePostRequest $request)
{
    Post::create($request->validated());
}
```

```php
// Rule::in()：許可値を動的に設定（ハードコーディング排除）
use Illuminate\Validation\Rule;

$request->validate([
    'task_status' => ['required', 'integer', Rule::in(array_keys(config('task.statuses')))],
]);
```

### セキュリティ（ソートのSQLインジェクション対策）

```php
// orderBy($sort) の $sort を直接ユーザー入力から使うのは危険
// → ホワイトリストで許可カラムを限定する
$allowed_sorts = ['id', 'title', 'task_status', 'created_at'];
$sort  = in_array($request->input('sort'), $allowed_sorts)
    ? $request->input('sort')
    : 'id';
$order = $request->input('order') === 'desc' ? 'desc' : 'asc';

Task::query()->orderBy($sort, $order)->get();
```

### 認証（Breeze）

```bash
composer require laravel/breeze --dev
php artisan breeze:install
npm install && npm run dev
php artisan migrate
```

```php
// ログイン後のリダイレクト先変更
// app/Http/Controllers/Auth/AuthenticatedSessionController.php
return redirect()->intended(route('tasks.index', absolute: false));

// 登録後のリダイレクト先変更
// app/Http/Controllers/Auth/RegisteredUserController.php
return redirect(route('tasks.index', absolute: false));
```

> ⚠️ 要確認：`vendor/` 以下にも同名ファイルが存在するが、編集対象は `app/Http/Controllers/Auth/` のみ。

### JS の外部ファイル化（Vite）

```js
// resources/js/my-feature.js（新規作成）
document.addEventListener('DOMContentLoaded', () => {
    const btn = document.getElementById('myBtn');
    if (!btn) return;
    btn.addEventListener('click', () => { /* 処理 */ });
});
```

```js
// resources/js/app.js に import 追記
import './my-feature';
```

```bash
npm run build  # Vite でバンドル → public/build/ に出力
```

### テスト（PHPUnit）

```bash
php artisan make:test UserTest --unit
php artisan test
```

```php
$this->assertTrue($user->isAdmin());
$this->assertDatabaseHas('users', ['email' => 'test@example.com']);
```

### ロギング

```php
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
- 共通レイアウト（app.blade.php）の設計（@yield/@section によるコンテンツ差し替え）
- ヘッダーコンポーネント（layouts/header.blade.php）の切り出しと@includeによる読み込み
- route()関数を使った動的ナビゲーション（URLハードコーディングの排除）
- POSTフォーム＋@csrfによる認証連動ログアウト実装

### API実装
- RemotePostControllerによるAPIエンドポイント作成
- bootstrap/app.phpへのAPI設定追記

### タスク管理システム

```
app/
 ├─ Http/
 │   ├─ Controllers/
 │   │   └─ TaskController.php        # 一覧・作成・編集・更新・削除
 │   └─ Requests/
 │       └─ ProfileUpdateRequest.php  # プロフィール更新バリデーション
 └─ Models/
     ├─ Task.php                      # scopeSearch / $casts / アクセサ
     └─ User.php                      # hasMany(Task) / プロフィール画像

resources/
 ├─ css/
 │   └─ app.css                       # BEM設計（インラインスタイル外部化）
 ├─ js/
 │   ├─ app.js                        # エントリポイント
 │   ├─ task-delete-modal.js          # 削除確認モーダル
 │   └─ profile-image-preview.js      # プロフィール画像プレビュー
 └─ views/
     ├─ tasks/
     │   ├─ index.blade.php           # 一覧（検索・ソート・削除モーダル）
     │   ├─ create.blade.php          # 新規登録
     │   └─ edit.blade.php            # 編集
     └─ profile/
         └─ edit.blade.php            # プロフィール編集（画像アップロード）

config/
 └─ task.php                          # ステータス定義（1:未着手 〜 4:完了）
```

**実装機能一覧**
- 検索機能（キーワード・担当者・ステータスフィルタ）
- ソート機能（複数カラム対応・昇降順切り替え・▲▼表示）
- 削除確認モーダル（vanilla JS）
- Eloquentスコープ（scopeSearch）によるクエリカプセル化
- BEM CSS設計（インラインスタイルを全て外部化）
- JS の外部ファイル化（Viteバンドル）
- $casts による型安全性確保
- @error による全フォームのエラー表示

---

## 技術的課題と改善方針

| # | 課題 | 問題点 | 改善方針 |
|---|---|---|---|
| 1 | テスト不足 | 手動確認が中心でリグレッションリスクあり | PHPUnitでFeature/Unitテストを整備 |
| 2 | API設計の甘さ | レスポンス形式が統一されていない | APIリソースクラス（JsonResource）を導入 |
| 3 | 認可未実装 | 認証はあるが権限制御がない | ポリシー・ミドルウェアで認可を追加 |
| 4 | ページネーション未実装 | タスクが増えると一覧が肥大化する | `paginate()` でページネーションを追加 |

---

## 今後の強化方針

### 優先度 高
- [ ] Featureテストの整備
- [ ] APIリソースクラスの導入
- [ ] 認可（ポリシー）の実装

### 優先度 中
- [ ] サービス層の分離（Fat Controller解消）
- [ ] ページネーションの実装
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
| 2026-04-25 | 共通レイアウト設計（app.blade.php） | @yield / @section でコンテンツ差し替え可能な骨格を設計。DRY原則を適用し、デザイン変更を1箇所に集約 |
| 2026-04-25 | ヘッダーコンポーネント化 | layouts/header.blade.php として切り出し、@include で読み込み。部品化によりデバッグ・修正が容易になる |
| 2026-04-25 | 動的ナビゲーション | route('tasks.index') 等のルート関数でURLをハードコーディングせず、将来のURL変更に柔軟に対応 |
| 2026-04-25 | 認証連動ログアウト | POST + @csrf によるログアウト実装。GETリンクではなくフォーム送信でセッション無効化後にloginルートへリダイレクト |
| 2026-05-04 | Eloquentスコープ | scopeSearch() でフィルタロジックをModelにカプセル化。Controller がスリムになり、クエリの再利用性が上がる |
| 2026-05-04 | $casts | task_status を integer にキャストすることで、DBから文字列で返った値との型不一致バグを防止 |
| 2026-05-04 | アクセサ | getStatusLabelAttribute() で status_label を動的に返す。Bladeでは $task->status_label として呼び出せる |
| 2026-05-04 | Rule::in() バリデーション | Rule::in(array_keys(config('task.statuses'))) で許可値をconfig定義から動的生成。ハードコーディングを排除し、設定変更に強くなる |
| 2026-05-04 | ソートのSQLインジェクション対策 | orderBy($sort) の $sort をホワイトリストで検証。URL改ざんで任意カラムを指定されるリスクを防止 |
| 2026-05-04 | 削除確認モーダル（vanilla JS） | data-* 属性でタスク情報をボタンに持たせ、JS でモーダルに反映。JS は外部ファイル化して app.js で import |
| 2026-05-04 | BEM CSS設計・インラインスタイル外部化 | style="" を app.css の BEM クラスに移行。クラス名がブロック・要素・モディファイアの構造を表し保守性が上がる |
| 2026-05-04 | JS外部ファイル化（Vite） | onchange / <script> タグを resources/js/*.js に分離。app.js で import し npm run build でバンドル |
| 2026-05-16 | ホワイトリストソートの落とし穴 | 許可リストへの追加漏れが典型的なミス。新カラム（assigned_user_id など）を追加したらホワイトリストへの登録を忘れずに |
| 2026-05-16 | url()->previous() による直前画面遷移 | Laravel の Referer ベース直前 URL 取得。戻るボタンに固定 URL ではなくユーザーの動線を反映できる |
| 2026-05-16 | email:filter バリデーション強化 | Laravel の email ルールは RFC 準拠が緩い。email:filter を使うと PHP の FILTER_VALIDATE_EMAIL（実用的な厳格さ）が適用される |
| 2026-05-16 | GitHubレビュー対応のワークフロー | レビューコメントへの対応は同じブランチへプッシュするだけで自動反映。PR を再作成する必要はない |
| 2026-05-16 | npm run build の実行場所 | ホストマシン側で実行してビルド済みアセットをコミットする。Docker コンテナ内での実行は不要 |
