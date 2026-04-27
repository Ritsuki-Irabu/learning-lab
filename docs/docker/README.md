# Docker + WSL2 技術資産ドキュメント

> Docker + WSL2 を用いた Laravel 開発環境の操作知識を体系化した技術資産。
> 環境起因のトラブル（419・404・リビルド漏れ）を再現・解決した経験から、仕組みレベルで理解を深めることを目的とする。

---

## 技術スタック

| カテゴリ | 技術 |
|---|---|
| コンテナランタイム | Docker Desktop（WSL2バックエンド） |
| ホスト環境 | WSL2（Ubuntu on Windows） |
| Web サーバー | Apache 2.4（コンテナ内） |
| アプリケーション | Laravel（PHP） |
| オーケストレーション | Docker Compose |

---

## 学習プロセス

### 学習スタイル
- Docker 環境で Laravel を動かすトラブルシューティングを通じた実践学習
- エラーを再現 → 原因調査 → 解決のサイクルで仕組みを理解

### 到達レベル

| 領域 | レベル |
|---|---|
| WSL2 ターミナル操作 | ✅ 完了 |
| コンテナの内外操作 | ✅ 完了 |
| Dockerfile リビルド | ✅ 完了 |
| 419・404 エラー対処 | ✅ 完了 |
| Docker Compose 設計 | 学習中 |
| マルチステージビルド | 未着手 |

---

## チートシート

### WSL2 ターミナル必須：なぜ PowerShell ではダメか

Docker Desktop for Windows は **WSL2 バックエンド** を使用する場合、コンテナは WSL2 の Linux 環境内で動作する。PowerShell は Windows ネイティブのシェルのため、以下の問題が起きる。

| 問題 | 詳細 |
|---|---|
| ファイルパス不整合 | Windows パス（`C:\Users\...`）と Linux パス（`/mnt/c/...`）が混在し、バインドマウントが機能しない場合がある |
| 改行コードの混入 | Windows（CRLF）と Linux（LF）の改行コード差異により、シェルスクリプト・設定ファイルが誤動作する |
| パーミッション問題 | Windows ファイルシステム（NTFS）上のファイルは WSL2 から実行権限 `755` 扱いになり、意図しない権限になる場合がある |
| ネットワーク差異 | WSL2 は独自のネットワークアダプタを持ち、`localhost` の解決が PowerShell と WSL2 で異なる場合がある |

```bash
# 正：WSL2（Ubuntu）ターミナルから操作
cd ~/project-name
docker compose up -d

# 誤：PowerShell（PS C:\...>）から操作しない
```

---

### コンテナの内外を意識する

Docker Compose はホスト上の Docker デーモンへの命令に過ぎない。PHP ランタイム・Composer は **コンテナ内にのみ存在** するため、PHP 関連コマンドは必ずコンテナ内で実行する。

| 場所 | 操作内容 |
|---|---|
| ホスト側（WSL2 ターミナル） | `docker compose up/down/build/ps/logs` |
| コンテナ内 | `php artisan <cmd>`、`composer <cmd>`、`npm <cmd>` |

```bash
# コンテナ内に入る（apache サービスの bash を起動）
docker compose exec apache bash

# コンテナ内で作業
php artisan migrate
composer require <package>

# コンテナを出る
exit
```

> `docker compose exec` はコンテナ内でプロセスを起動するコマンド。`exit` でそのプロセス（bash）は終了するが、コンテナ自体（メインプロセス）は動き続ける。`docker compose stop` を実行しない限りコンテナは停止しない。

---

### Dockerfile を変更したら必ずリビルドする

`docker compose up -d` は **既存イメージが存在する場合そのまま再利用** する。Dockerfile の変更はイメージのビルドレイヤーに影響するため、変更をコンテナに反映させるには明示的な再ビルドが必要。

| コマンド | 動作 |
|---|---|
| `docker compose up -d` | イメージが存在すれば再利用（Dockerfile 変更は反映されない） |
| `docker compose up -d --build` | イメージを再ビルドしてからコンテナを起動 |
| `docker compose restart` | コンテナを再起動するだけ（イメージは変えない） |
| `docker compose build --no-cache` | キャッシュなしで完全に再ビルド（レイヤー全体をやり直す） |

```bash
# Dockerfile または docker-compose.yml を変更したとき
docker compose up -d --build

# apt パッケージ追加など、キャッシュが問題になるとき
docker compose build --no-cache
docker compose up -d
```

**Docker レイヤーキャッシュの仕組み：**
Dockerfile の各命令は「レイヤー」として積み上げられる。前のレイヤーと内容が変わらない限りキャッシュが使われる。変更があった命令以降のすべてのレイヤーが再ビルドされる。`--no-cache` はすべてのキャッシュを無効化して最初から積み直す。

---

### 419 エラー：原因と対処

**419 = "Page Expired"** は Laravel の CSRF（Cross-Site Request Forgery）保護機能によるエラー。

**原因メカニズム：**
1. Laravel はフォーム送信時に `_token` という隠しフィールド（CSRF トークン）を検証する
2. CSRF トークンはセッションに保存されており、セッションの有効期限切れ・キャッシュの不整合・`APP_KEY` の不一致で検証失敗する
3. Docker 環境ではコンテナ再起動・`.env` 変更後にセッションが無効になりやすい

```bash
# 419 が出たらまずキャッシュをクリア
docker compose exec apache php artisan config:clear
docker compose exec apache php artisan cache:clear

# 上記で解決しない場合：全キャッシュを一括クリア
docker compose exec apache php artisan optimize:clear

# APP_KEY が未設定の場合（.env の APP_KEY= が空のとき）
docker compose exec apache php artisan key:generate
```

| コマンド | 対象ファイル/ストア | 削除されるもの |
|---|---|---|
| `config:clear` | `bootstrap/cache/config.php` | キャッシュされた設定ファイル（`.env` の変更を反映させる） |
| `cache:clear` | application cache ストア | アプリキャッシュ（session driver が `cache` の場合も影響） |
| `optimize:clear` | 全キャッシュ | config + route + view + event キャッシュを一括削除 |

**なぜ `config:clear` が必要か：**
Laravel は初回リクエスト時に `.env` の内容を読み込んで `bootstrap/cache/config.php` にキャッシュする。コンテナ再起動後も古いキャッシュが残ると、変更した `.env` の値が反映されない。CSRF はセッションキーの照合に `APP_KEY` を使うため、`APP_KEY` のキャッシュ不整合が直接 419 に繋がる。

---

### 404 エラー：原因と対処

Laravel は **Front Controller パターン** を採用しており、すべてのリクエストを `public/index.php` に転送する仕組みに依存する。404 が出る場合、この転送が機能していない可能性がある。

| 原因 | 確認方法 | 対処 |
|---|---|---|
| `mod_rewrite` が無効 | `apache2ctl -M \| grep rewrite` | `a2enmod rewrite` + Apache リスタート |
| `.htaccess` が無効（`AllowOverride None`） | Apache バーチャルホスト設定を確認 | `AllowOverride All` に変更 |
| ルートが未登録 | `php artisan route:list` | `routes/web.php` にルートを追加 |
| `DocumentRoot` が `public` でない | Apache バーチャルホスト設定を確認 | `DocumentRoot /var/www/html/public` に修正 |

```bash
# mod_rewrite が有効か確認（rewrite_module が一覧に出れば OK）
docker compose exec apache apache2ctl -M | grep rewrite

# ルートが登録されているか確認
docker compose exec apache php artisan route:list

# mod_rewrite を有効化（Dockerfile に記述するのが望ましい）
docker compose exec apache a2enmod rewrite
docker compose exec apache service apache2 restart
```

**mod_rewrite の役割：**
Apache の `mod_rewrite` モジュールは `public/.htaccess` の RewriteRule を解釈し、`/tasks` や `/api/posts` などのすべてのリクエストを `index.php` にリライトする。これがないと Apache は `/tasks` というファイルを探しに行き、見つからないので 404 を返す。

**Laravel デフォルトの `.htaccess`（`public/.htaccess`）：**

```apache
<IfModule mod_rewrite.c>
    <IfModule mod_negotiation.c>
        Options -MultiViews -Indexes
    </IfModule>

    RewriteEngine On

    # Authorization ヘッダーを PHP へ渡す
    RewriteCond %{HTTP:Authorization} .
    RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]

    # 末尾スラッシュのリダイレクト（ディレクトリでない場合）
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteCond %{REQUEST_URI} (.+)/$
    RewriteRule ^ %1 [L,R=301]

    # すべてのリクエストを index.php へ転送（Front Controller パターン）
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteRule ^ index.php [L]
</IfModule>
```

---

## 実装資産

### 開発環境構成例

```yaml
# docker-compose.yml（Laravel + Apache + MySQL 構成）
services:
  apache:
    build: .
    ports:
      - "8080:80"
    volumes:
      - .:/var/www/html
    depends_on:
      - mysql

  mysql:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: laravel_db
    volumes:
      - mysql_data:/var/lib/mysql

volumes:
  mysql_data:
```

```dockerfile
# Dockerfile（Apache + PHP 構成例）
FROM php:8.2-apache

# mod_rewrite を有効化（忘れると 404 の原因になる）
RUN a2enmod rewrite

# DocumentRoot を public に向ける
RUN sed -i 's|/var/www/html|/var/www/html/public|g' /etc/apache2/sites-available/000-default.conf

# AllowOverride を All に変更（.htaccess を有効化）
RUN sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

# PHP 拡張インストール
RUN docker-php-ext-install pdo pdo_mysql

# Composer インストール
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
```

---

## 技術的課題と改善方針

| # | 課題 | 問題点 | 改善方針 |
|---|---|---|---|
| 1 | mod_rewrite 設定 | Dockerfile に記述しないと毎回手動で有効化が必要 | `RUN a2enmod rewrite` を Dockerfile に明記する |
| 2 | セッション永続化 | コンテナ再起動で file セッションが消える | `storage/` のパーミッション設定を Dockerfile に明示する |
| 3 | 環境変数管理 | `.env` をコンテナ内外で二重管理になりやすい | `docker-compose.yml` の `env_file` で一元管理する |

---

## 今後の強化方針

### 優先度 高
- [ ] Dockerfile の `mod_rewrite`・`DocumentRoot` 設定を標準化
- [ ] `storage/` パーミッション設定を Dockerfile に組み込む

### 優先度 中
- [ ] マルチステージビルドによる本番イメージの軽量化
- [ ] `.env` 管理の標準化（`env_file` vs `environment`）

---

## 学んだこと

| 日付 | トピック | メモ |
|---|---|---|
| 2026-04-27 | WSL2 ターミナル必須 | PowerShell は Windows ネイティブのためファイルパス・改行コード・パーミッションの不整合が起きる。WSL2 の Ubuntu ターミナルから操作する |
| 2026-04-27 | コンテナの内外意識 | PHP ランタイムはコンテナ内のみ。`docker compose exec` でコンテナ内に入り、`exit` してもコンテナは停止しない |
| 2026-04-27 | Dockerfile リビルド | `docker compose up` は既存イメージを再利用する。Dockerfile 変更後は `--build` フラグで再ビルドが必要 |
| 2026-04-27 | 419 エラー対処 | Laravel の CSRF トークン検証失敗。`config:clear` + `cache:clear` でキャッシュ不整合を解消する。根本原因は APP_KEY 不一致やセッション失効 |
| 2026-04-27 | 404 エラー対処 | `mod_rewrite` が無効だと Laravel の `.htaccess` が機能せず、全リクエストが `index.php` に転送されない。`apache2ctl -M` で確認し、Dockerfile に `RUN a2enmod rewrite` を必ず記述する |
