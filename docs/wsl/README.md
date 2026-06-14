# WSL 技術資産ドキュメント

> WSL と Linux ファイルシステムの基礎理解を、Windows 上で開発するときに迷わない形で整理する。
> Docker・Laravel・Next.js などの開発環境で、作業場所や実行環境を取り違えないことを目的とする。

---

## 技術スタック

| カテゴリ | 技術 |
|---|---|
| 実行環境 | WSL / WSL 2 |
| Linuxディストリビューション | Ubuntu |
| シェル | bash など |
| ファイルシステム | Linux ルートファイルシステム、`/tmp`、`/var/tmp` |

---

## 学習プロセス

### 学習スタイル
- Windows と Linux の境界を、言葉ではなく「どこで何が動いているか」で整理する
- Docker や開発コマンドで詰まったときに、PowerShell 側なのか WSL/Linux 側なのかを切り分ける
- 一時ファイルや検証用ファイルは、メインの作業場所を汚さない前提で扱う

### 到達レベル

| 領域 | レベル |
|---|---|
| WSL の役割 | Windows 上で Linux 環境を動かす仕組みとして理解 |
| Ubuntu の役割 | WSL 上で動く Linux ディストリビューションとして理解 |
| `/tmp` の役割 | 一時ファイル用で、永続保存を前提にしない場所として理解 |
| 作業場所の分離 | メイン作業ディレクトリと一時作業ディレクトリを分ける理由を理解 |

---

## チートシート

### WSL / Ubuntu の関係

```text
Windows
  └─ WSL
      └─ Ubuntu などの Linux ディストリビューション
          └─ bash などのシェルで操作
```

- WSL は、Windows 上で Linux 環境を動かすための仕組み
- Ubuntu は、WSL の中で動かす Linux ディストリビューションの一つ
- 「Ubuntuそのもの」がコマンドプロンプトなのではなく、Ubuntu を開いたときのターミナルや bash が操作画面になる

### `/tmp` の使いどころ

```bash
# 未実行の基本例：作業ごとに一時ディレクトリを作る
workdir="$(mktemp -d /tmp/my-task.XXXXXX)"
cd "$workdir"
```

- `/tmp` は一時ファイルを必要とするプログラムのために用意される場所
- プログラムの実行をまたいで `/tmp` の中身が残るとは限らない
- メインの作業ディレクトリで試行錯誤すると、同名ファイルの衝突や不要ファイルの混入が起きやすい
- 作業単位で `/tmp/<作業名>` や `mktemp -d` を使うと、検証後にまとめて消しやすい

### `/tmp` と `/var/tmp` の違い

| 場所 | 用途 | 考え方 |
|---|---|---|
| `/tmp` | 短期の一時ファイル | 再起動や運用ルールで消える可能性がある |
| `/var/tmp` | 再起動後も残したい一時ファイル | `/tmp` より長く残る前提の一時領域 |

---

## 実装資産

現時点では実装資産なし。今後、WSL 上での開発環境構築手順や Docker 連携時の作業ディレクトリ例を追加する。

---

## 技術的課題と改善方針

| # | 課題 | 問題点 | 改善方針 |
|---|---|---|---|
| 1 | WSL と Ubuntu の混同 | WSLをLinuxそのもの、Ubuntuをコマンドプロンプトのように捉えると、環境・ディストリビューション・シェルの境界が曖昧になる | WSL=仕組み、Ubuntu=ディストリビューション、bash=操作するシェルとして分けて覚える |
| 2 | 一時ファイルをメイン作業場所に置く | ファイル名の衝突、不要ファイルの混入、検証後の片付け漏れが起きやすい | `/tmp` や `mktemp -d` で作業ごとの一時ディレクトリを作る |

---

## 今後の強化方針

### 優先度 高
- [ ] WSL 上で Docker / Laravel / Next.js を扱うときの「PowerShell側で実行するコマンド」と「WSL側で実行するコマンド」を整理する

### 優先度 中
- [ ] `/mnt/c/...` と Linux 側ホームディレクトリの使い分けを整理する
- [ ] 一時ディレクトリ作成・削除の安全なパターンを実動作で確認する

---

## 学んだこと

| 日付 | トピック | メモ |
|---|---|---|
| 2026-06-14 | WSL と Ubuntu の関係 | WSLはWindows上でLinux環境を動かす仕組み。Ubuntuはその中で動くLinuxディストリビューションの一つで、操作入口はUbuntuターミナルやbashとして捉えると混乱しにくい。 |
| 2026-06-14 | `/tmp` と一時ディレクトリ | `/tmp` は一時ファイル用の場所で、永続保存を前提にしない。検証作業では作業ごとに一時ディレクトリを作ると、メイン作業場所を汚さずファイル衝突も避けやすい。 |

---

## 参考

- Microsoft Learn: [What is the Windows Subsystem for Linux?](https://learn.microsoft.com/en-us/windows/wsl/about)
- Filesystem Hierarchy Standard 3.0: [`/tmp` Temporary files](https://refspecs.linuxfoundation.org/FHS_3.0/fhs/ch03s18.html)
- Filesystem Hierarchy Standard 3.0: [`/var/tmp` Temporary files preserved between system reboots](https://refspecs.linuxfoundation.org/FHS_3.0/fhs/ch05s15.html)
