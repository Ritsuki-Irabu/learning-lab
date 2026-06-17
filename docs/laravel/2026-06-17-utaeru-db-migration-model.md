# 2026-06-17 Laravel 学習ログ: Migration / Model / namespace

## 今日のテーマ

ウタエル Issue #2「DB設計・マイグレーション作成」に向けて、Laravel の Migration と Model の役割、DB設計書から Laravel コードへ翻訳する考え方を学習した。

## 学んだこと

### Sail は保存場所ではなくコマンド実行の入口

`./vendor/bin/sail` はフォルダではなく、Laravel Sail を操作するための実行ファイル。

```bash
./vendor/bin/sail artisan make:migration create_songs_table
```

これは「Sail 経由で Laravel の `artisan` に Migration ファイルを作らせる」という意味。

Migration ファイルは `sail` の中ではなく、以下に作られる。

```text
database/migrations/
```

`Sail is not running.` が出た場合は、先にコンテナを起動する。

```bash
./vendor/bin/sail up -d
./vendor/bin/sail ps
```

### Migration の up と down

Migration の `up()` は DB を進める処理、`down()` は戻す処理。

```php
public function up(): void
{
    // テーブル作成・カラム追加など
}

public function down(): void
{
    // 作ったテーブルやカラムを戻す
}
```

実行コマンドとの対応:

```bash
./vendor/bin/sail artisan migrate          # up() が動く
./vendor/bin/sail artisan migrate:rollback # down() が動く
```

### DB設計書の型を Laravel Migration に翻訳する

設計書は DB 目線、Migration は Laravel 目線で書く。

| 設計書の型 | Laravel Migration |
|---|---|
| `BIGINT PK AUTO_INCREMENT` | `$table->id();` |
| `VARCHAR(255)` | `$table->string('title');` |
| `VARCHAR(100) NULL` | `$table->string('spotify_id', 100)->nullable();` |
| `INT` | `$table->integer('bpm');` |
| マイナス不要の `INT` | `$table->unsignedInteger('bpm');` |
| `created_at` / `updated_at` | `$table->timestamps();` |

`songs` テーブルの例:

```php
Schema::create('songs', function (Blueprint $table) {
    $table->id();
    $table->string('title');
    $table->string('artist');
    $table->unsignedInteger('bpm');
    $table->string('spotify_id', 100)->nullable();
    $table->timestamps();
});
```

ポイント:

- Laravel では `$table->var()` ではなく `$table->string()` を使う。
- Laravel では `$table->int()` ではなく `$table->integer()` や `$table->unsignedInteger()` を使う。
- `timestamps()` は `created_at` と `updated_at` をまとめて作る。
- `nullable()` を付けないカラムは基本的に `NOT NULL` として扱われる。

### Model は PHP から DB を扱う入口

Migration が DB 側の設計図なら、Model は PHP / Laravel 側からテーブルを扱う入口。

対応関係:

| 種類 | 例 | 意味 |
|---|---|---|
| DBテーブル名 | `my_songs` | DB側のテーブル名 |
| Modelクラス名 | `MySong` | PHP / Laravel 側のクラス名 |
| リレーションメソッド名 | `mySongs()` | PHP 側で関係を表すメソッド名 |

命名ルール:

- DBテーブル名: `snake_case` + 複数形
- Model名: `PascalCase` + 単数形
- リレーション名: `camelCase` + 関係に応じて単数/複数

例:

```text
songs    -> Song
tags     -> Tag
my_songs -> MySong
```

### User Model に hasMany を追加する

`User` は複数の `MySong` を持つため、`User.php` に `hasMany` リレーションを追加する。

```php
use Illuminate\Database\Eloquent\Relations\HasMany;

public function mySongs(): HasMany
{
    return $this->hasMany(MySong::class);
}
```

意味:

```text
1人のユーザーは、複数のマイリスト曲を持つ
```

### namespace と use の考え方

`namespace App\Models;` は「このクラスは `App\Models` に所属している」という意味。

- `User` の正式名は `App\Models\User`
- `MySong` の正式名は `App\Models\MySong`

`User.php` と `MySong.php` は同じ `App\Models` namespace にいるため、`MySong::class` はそのまま書ける。

一方、`HasMany` は Laravel 本体側の `Illuminate\Database\Eloquent\Relations` namespace にあるため、`use` が必要。

```php
use Illuminate\Database\Eloquent\Relations\HasMany;
```

## つまずきと理解

- `sail` をフォルダのように考えたが、実際はコマンド実行ファイルだった。
- 設計書の `VARCHAR` / `INT` をそのまま Laravel に書くのではなく、Laravel の Migration メソッドに翻訳する必要があった。
- `MySong` は DB の書き方ではなく PHP 側の Model 名。
- DB側は `my_songs`、PHP側のModelは `MySong`、リレーション名は `mySongs()`。

## 次にやること

1. `songs` / `tags` / `my_songs` / `my_song_tag` の Migration を完成させる。
2. `Song` / `MySong` / `Tag` Model を作成する。
3. 各 Model に `$fillable` と Relation を書く。
4. `./vendor/bin/sail artisan migrate` を実行する。
5. `./vendor/bin/sail artisan test` で確認する。
