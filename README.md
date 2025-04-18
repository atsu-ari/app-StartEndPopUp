# StartEndPopUpについて

## 作成動機
ミニマムスタートで作成したいアプリの一歩目として~~Python~~ Rubyで便利ツールを作ってみることにしました。

## 概要
設定した始業・就業時刻にリンクやアプリ、タスクを一覧を起動し、表示するアプリ。

## 開発の背景と効果
 - [x] 始業時に起動するアプリが決まっている
 - [x] バッチを作成するスキルがなくても一括管理・起動可能にしたい
 - [x] 勤怠の打刻漏れをなくす
 - [x] 終業時に起動することで、無駄な残業の防止
 - [x] さらに勤怠締めや始業時にやることのTodoも表示されることで作業漏れが防げる

## ##################################
## 2025-03-23 デモ版として一旦完成とする
## ##################################

## デモ版の内容
*   画面遷移状態や、ボタンにどのような機能があるか確認可能です。
*   一部動作するボタンもあります。

## 詳細設計について
*   アプリケーションの詳細な設計仕様については、`docs` フォルダ内に記載されています。
    *   `docs/detailed-spec.md`: アプリ全体の詳細設計。
    *   `docs/src-detailed-spec.md`: ソースコードに関する詳細な仕様。

## 開発環境・システム要件
* 開発エディタ: Visual Studio Code (VSCode)
* 開発言語: Ruby 3.2.7
* UIフレームワーク: Gtk3
* OS: macOS
* 必要なGem:
    * gdk3
    * その他標準ライブラリ（csv, json, date, open3, etc, uri）

## 使用方法

1. アプリケーションを起動すると、以下の画面が表示されます：
    * **Loading画面**: アプリケーションの起動中に表示されます。
    * **案内画面**: 初回起動時にアプリの概要を説明します。
    * **リスト画面**: 始業・終業時にタスクやリンクを表示します。

2. 各画面の操作：
    * **リスト画面**:
        - チェックボックスをオンにしてタスクを完了。
        - 「Perfect!」をオンにすると、すべてのタスクが完了していなくても終了可能。
    * **設定画面**:
        - 始業・終業時刻やタスクを設定。
        - 「完了」ボタンで設定を保存して終了。

## 既知の問題

* 一部のボタンは未実装です（デモ版のため）。
* Windows環境での動作確認は未実施です。
* Gemfileが整備不十分のため、必要なGemを手動でインストールする必要があります。

## Ruby初開発の感想
### 良かった点
*   開発環境の拡張機能で開発が手厚く、比較的楽に組めた。
*   Rubyの基本のフォルダ構成や環境構築の仕方がわかった。

### 大変だった点
*  デバッグや実行環境の構築が大変だった。（ほぼ丸１日潰れた）

## 実装予定
### ver1.0
- デモ画面・仕様書記載の各機能の動作
### 今後の拡張
- タスクの編集機能
- タスクバーへの収納
- ドラッグアンドドロップでアプリの登録
- スタートアップ登録機能
- 終業時に「PCを終了する」チェックをつける事でパソコン自体の終了を可能にする
- 終業時、残業対応のためのスヌーズ（定期的に知らせがあることで、残業時間が延びることの抑止

## ライセンス

このプロジェクトは [MITライセンス](LICENSE) のもとで公開されています。