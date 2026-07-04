# Virtualization 技術資産ドキュメント

> VirtualBox / Vagrant / Homestead / WSL2 / Docker の違いを整理し、開発環境ごとの使い分けを判断できるようにする。

---

## 技術スタック

| カテゴリ | 技術 |
|---|---|
| 仮想マシン | VirtualBox |
| 仮想環境管理 | Vagrant |
| Laravel公式Vagrant環境 | Homestead |
| Windows上のLinux環境 | WSL2 |
| コンテナ | Docker |

---

## 学習プロセス

### 学習スタイル
- 「仮想環境」という一括りではなく、何を分離しているかで理解する
- Laravel学習で出てくる Homestead / Sail / Docker / WSL2 の関係を整理する

### 到達レベル

| 領域 | レベル |
|---|---|
| VirtualBox と Vagrant の関係 | 学習中 |
| Homestead の役割 | 学習中 |
| WSL2 と Docker の違い | 学習中 |
| 環境ごとの使い分け | 学習中 |

---

## チートシート

### VirtualBox / WSL2 / Docker の違い

| 技術 | 分類 | 得意なこと | 注意点 |
|---|---|---|---|
| VirtualBox | 仮想マシン | OSごと分けた環境を作る | 比較的重い |
| WSL2 | Windows上のLinux実行環境 | WindowsからLinux開発環境を軽く使う | 本番環境そのものとは限らない |
| Docker | コンテナ | アプリ単位で環境を再現しやすい | コンテナ・イメージの理解が必要 |

VirtualBox は PC の中に別の PC を作るイメージ。WSL2 は Windows 上で Linux を軽く使う仕組み。Docker は OS 丸ごとではなく、アプリと依存関係をコンテナとしてまとめる仕組み。

### Vagrant コマンド

| コマンド | 役割 |
|---|---|
| `vagrant up` | Vagrantfile をもとに仮想マシンを作成・起動する |
| `vagrant ssh` | Vagrant が管理する仮想マシンに SSH ログインする |
| `vagrant halt` | 起動中の仮想マシンを停止する |

```bash
vagrant up
vagrant ssh
vagrant halt
```

### Vagrant / VirtualBox / Homestead の関係

```text
PC
└─ VirtualBox
   └─ Vagrant が作成・管理する仮想マシン
      └─ Ubuntu / Homestead など
```

- VirtualBox: 仮想マシンを実際に動かす土台
- Vagrant: 仮想マシンの作成・起動・停止をコマンドで扱う道具
- Homestead: Laravel公式が用意している Laravel 開発向けの Vagrant box

> ⚠️ 要確認：Laravel公式ドキュメントでは Homestead は legacy package とされており、新規環境では Laravel Sail / Docker も候補にする。

### 使い分けの目安

| 目的 | 候補 |
|---|---|
| OSごと分けて検証したい | VirtualBox |
| Windows上でLinux CLIを使いたい | WSL2 |
| チームで同じアプリ実行環境を揃えたい | Docker |
| Homestead前提のLaravel教材を再現したい | VirtualBox + Vagrant + Homestead |
| 新しめのLaravel開発環境を揃えたい | Docker / Laravel Sail |

### 日本語フォルダ名の注意

仮想環境や共有フォルダでは、Windows / Linux / Git Bash / Vagrant など複数の環境をまたいでパスを扱う。フォルダ名に日本語や空白が含まれると、文字化けやパス解決トラブルの原因になる場合がある。

開発用フォルダは英数字・ハイフン中心にする。

```text
learning-lab
laravel-practice
homestead-projects
```

---

## 実装資産

- Laravel学習で使う開発環境候補の比較表
- Vagrant基本コマンドの早見表

---

## 技術的課題と改善方針

| 課題 | 問題点 | 改善方針 |
|---|---|---|
| 仮想環境の混同 | VirtualBox / WSL2 / Docker を同じものとして捉えやすい | 仮想マシン・Linux実行環境・コンテナとして分けて整理する |
| Homesteadの位置づけ | 古い教材では出るが、現在の主流とは限らない | Laravel Sail / Docker と比較して選ぶ |
| パス文字化け | 日本語フォルダ名が環境間連携で問題になる場合がある | 開発フォルダ名はASCII中心にする |

---

## 今後の強化方針

- [ ] VirtualBox / WSL2 / Docker の実測比較を追加する
- [ ] Laravel Sail と Homestead の使い分けを動作確認ベースで整理する

---

## 学んだこと

| 日付 | トピック | メモ |
|---|---|---|
| 2026-07-02 | Vagrant / Homestead | Vagrantは仮想マシンを作成・管理する道具で、VirtualBoxは仮想マシンを動かす土台。HomesteadはLaravel公式のVagrant boxだが、現在はlegacy扱いのためSail/Dockerも候補にする。 ✅ |
| 2026-07-03 | VirtualBox / WSL2 / Docker | VirtualBoxは仮想マシン、WSL2はWindows上のLinux実行環境、Dockerはコンテナ。環境・規模・再現性・分離度によって使い分ける。 |
| 2026-07-04 | Vagrant基本コマンド | `vagrant up` で起動、`vagrant ssh` でログイン、`vagrant halt` で停止する。 |

---

## 参考

- HashiCorp Developer: Vagrant Documentation
- Laravel Documentation: Homestead
- Microsoft Learn: WSL Documentation
- Docker Docs: What is a container?
