# Laravel メモ

## チートシート

### Eloquent

```php
// リレーション
$user->posts()->where('published', true)->get();

// アクセサ
public function getFullNameAttribute(): string
{
    return "{$this->first_name} {$this->last_name}";
}
```

### Artisan

```bash
php artisan make:model Post -mcr   # Model + Migration + Controller(resource)
php artisan migrate:fresh --seed   # DBリセット＋シード
php artisan tinker                  # REPL
```

---

## 学んだこと

| 日付 | トピック | メモ |
|---|---|---|
| - | - | - |
