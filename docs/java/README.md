# Java メモ

## チートシート

### Stream API

```java
// filter / map / collect
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

---

## 学んだこと

| 日付 | トピック | メモ |
|---|---|---|
| - | - | - |
