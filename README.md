# 🤖 Claude Team Base - Multi-Agent Communication Framework

カスタマイズ可能なマルチエージェント通信フレームワーク

## 🎯 概要

このフレームワークは、複数のClaudeエージェントが協調して作業を行うためのベースシステムです。
デフォルトでは開発チーム構成が設定されていますが、自由にカスタマイズ可能です。

### 👥 デフォルトチーム構成

```
📊 PM セッション (1ペイン)
└── PM: プロジェクトマネージャー

📊 multiagent セッション (4ペイン)  
├── eng_leader: エンジニアリングリーダー
├── frontend: フロントエンドエンジニア
├── backend: バックエンドエンジニア
└── tester: テスター
```

### 🔄 コミュニケーションフロー

```
PM → eng_leader → [frontend, backend, tester] → eng_leader → PM
```

## 🚀 クイックスタート

### 1. tmux環境構築

⚠️ **注意**: 既存の `multiagent` と `pm` セッションがある場合は自動的に削除されます。

```bash
./setup.sh
```

### 2. セッションアタッチ

```bash
# マルチエージェント確認
tmux attach-session -t multiagent

# PM確認（別ターミナルで）
tmux attach-session -t pm
```

### 3. Claude Code起動

**手順1: PM認証**
```bash
# まずPMで認証を実施
tmux send-keys -t pm 'claude' C-m
```
認証プロンプトに従って許可を与えてください。

**手順2: Multiagent一括起動**
```bash
# 認証完了後、multiagentセッションを一括起動
for i in {0..3}; do tmux send-keys -t multiagent:0.$i 'claude' C-m; done
```

### 4. デモ実行

PMセッションで直接入力：
```
あなたはPMです。プロジェクト開始指示
```

## 📜 チーム構成と役割

### 役割別指示書
- **PM**: `instructions/pm.md` - プロジェクト全体の統括
- **eng_leader**: `instructions/eng_leader.md` - タスク分割・技術調整・コードレビュー
- **frontend**: `instructions/frontend.md` - UI/UX実装
- **backend**: `instructions/backend.md` - サーバーサイド開発
- **tester**: `instructions/tester.md` - 品質保証・テスト設計

### 主要な役割と責任

**エンジニアリングリーダー**:
- タスクの分割と割り当て
- frontend-backend間の技術調整
- コードレビュー（セキュリティ・パフォーマンス重視）

**各エンジニア**:
- 実装とセルフレビュー
- テストコードの尊重（テスト変更禁止）
- 問題報告時の詳細な情報提供

**テスター**:
- テスト設計と実施
- バグ報告（重要度・再現手順・影響範囲）
- テストコードの保守・改善

## 🔧 エージェント間通信

### agent-send.shを使った送信

```bash
# 基本送信
./agent-send.sh [エージェント名] [メッセージ]

# 例
./agent-send.sh pm "プロジェクト開始"
./agent-send.sh eng_leader "【タスク】新機能の実装開始"
./agent-send.sh frontend "【完了】UI実装完了しました"
./agent-send.sh backend "【問題】データベース接続エラー"
./agent-send.sh tester "【バグ報告】重要度:高 ログイン機能に不具合"

# エージェント一覧確認
./agent-send.sh --list
```

### メッセージプレフィックス
- `【タスク】` - 作業指示
- `【完了】` - 作業完了報告
- `【問題】` - 問題・エラー報告
- `【調整要請】` - 他チームとの調整依頼
- `【バグ報告】` - バグ発見報告
- `【レビュー】` - コードレビュー関連

## 📚 ドメイン知識管理

`dictionaries/`ディレクトリで共有知識を管理：
- `project_rules.yaml` - 開発ルール・コーディング規約
- その他、プロジェクト固有の用語集や仕様書を配置可能

指示書内で`@dictionaries/ファイル名`として参照できます。

## 🛠️ カスタマイズ方法

### チーム構成の変更

1. **CLAUDE.md**を編集してエージェント構成を変更
2. **instructions/**内の指示書を作成・編集
3. **agent-send.sh**のマッピングを更新
4. **setup.sh**のセッション構成を変更

### 新しいチームの例
- カスタマーサポートチーム
- データ分析チーム
- デザインチーム
- など、用途に応じて自由に構成可能

## 🧪 確認・デバッグ

### ログ確認

```bash
# 送信ログ確認
cat logs/send_log.txt

# 特定エージェントのログ
grep "frontend" logs/send_log.txt

# 完了ファイル確認
ls -la ./tmp/*_done.txt
```

### セッション状態確認

```bash
# セッション一覧
tmux list-sessions

# ペイン一覧
tmux list-panes -t multiagent
tmux list-panes -t pm
```

## 🔄 環境リセット

```bash
# セッション削除
tmux kill-session -t multiagent
tmux kill-session -t pm

# 完了ファイル削除
rm -f ./tmp/*_done.txt

# 再構築（自動クリア付き）
./setup.sh
```

## 📋 今後の拡張予定

- [ ] チーム設定用JSONスキーマの実装
- [ ] 役割テンプレート自動生成システム
- [ ] 複数チーム構成の切り替え機能
- [ ] メッセージングの可視化ツール

---

## 🙏 参考・謝辞

このプロジェクトは以下のリポジトリを参考にさせていただきました：

- [Akira-Papa/Claude-Code-Communication](https://github.com/Akira-Papa/Claude-Code-Communication)
- [nishimoto265/Claude-Code-Communication](https://github.com/nishimoto265/Claude-Code-Communication)

素晴らしいアイデアとベースを提供していただき、ありがとうございます。

---

## 📄 ライセンス

このプロジェクトはオープンソースで公開されています。

## 🤝 コントリビューション

プルリクエストやIssueでのコントリビューションを歓迎いたします！

---

🚀 **カスタマイズ可能なマルチエージェントチームを構築しましょう！** 🤖✨