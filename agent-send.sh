#!/bin/bash

# 🚀 Agent間メッセージ送信スクリプト

# エージェント→tmuxターゲット マッピング
get_agent_target() {
    case "$1" in
        "pm") echo "pm" ;;
        "eng_leader") echo "multiagent:0.0" ;;
        "frontend") echo "multiagent:0.1" ;;
        "backend") echo "multiagent:0.2" ;;
        "tester") echo "multiagent:0.3" ;;
        *) echo "" ;;
    esac
}

show_usage() {
    cat << EOF
🤖 Agent間メッセージ送信

使用方法:
  $0 [エージェント名] [メッセージ]
  $0 --list

利用可能エージェント:
  pm         - プロジェクトマネージャー
  eng_leader - エンジニアリングリーダー  
  frontend   - フロントエンドエンジニア
  backend    - バックエンドエンジニア
  tester     - テスター

使用例:
  $0 pm "あなたはPMです。プロジェクト開始指示"
  $0 eng_leader "【タスク】新機能の実装を開始してください"
  $0 frontend "【完了】UI実装完了しました"
  $0 backend "【問題報告】データベース接続エラーが発生"
  $0 tester "【バグ報告】重要度:高 ログイン機能に不具合"
EOF
}

# エージェント一覧表示
show_agents() {
    echo "📋 利用可能なエージェント:"
    echo "=========================="
    echo "  pm         → pm:0            (プロジェクトマネージャー)"
    echo "  eng_leader → multiagent:0.0  (エンジニアリングリーダー)"
    echo "  frontend   → multiagent:0.1  (フロントエンドエンジニア)"
    echo "  backend    → multiagent:0.2  (バックエンドエンジニア)" 
    echo "  tester     → multiagent:0.3  (テスター)"
    echo ""
    echo "💡 メッセージプレフィックス:"
    echo "  【タスク】    - 作業指示"
    echo "  【完了】      - 作業完了報告"
    echo "  【問題】      - 問題・エラー報告"
    echo "  【調整要請】  - 他チームとの調整依頼"
    echo "  【バグ報告】  - バグ発見報告"
    echo "  【レビュー】  - コードレビュー関連"
}

# ログ記録
log_send() {
    local agent="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    mkdir -p logs
    echo "[$timestamp] $agent: SENT - \"$message\"" >> logs/send_log.txt
}

# メッセージ送信
send_message() {
    local target="$1"
    local message="$2"
    
    echo "📤 送信中: $target ← '$message'"
    
    # Claude Codeのプロンプトを一度クリア
    tmux send-keys -t "$target" C-c
    sleep 0.3
    
    # メッセージ送信
    tmux send-keys -t "$target" "$message"
    sleep 0.1
    
    # エンター押下
    tmux send-keys -t "$target" C-m
    sleep 0.5
}

# ターゲット存在確認
check_target() {
    local target="$1"
    local session_name="${target%%:*}"
    
    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        echo "❌ セッション '$session_name' が見つかりません"
        return 1
    fi
    
    return 0
}

# メイン処理
main() {
    if [[ $# -eq 0 ]]; then
        show_usage
        exit 1
    fi
    
    # --listオプション
    if [[ "$1" == "--list" ]]; then
        show_agents
        exit 0
    fi
    
    if [[ $# -lt 2 ]]; then
        show_usage
        exit 1
    fi
    
    local agent_name="$1"
    local message="$2"
    
    # エージェントターゲット取得
    local target
    target=$(get_agent_target "$agent_name")
    
    if [[ -z "$target" ]]; then
        echo "❌ エラー: 不明なエージェント '$agent_name'"
        echo "利用可能エージェント: $0 --list"
        exit 1
    fi
    
    # ターゲット確認
    if ! check_target "$target"; then
        exit 1
    fi
    
    # メッセージ送信
    send_message "$target" "$message"
    
    # ログ記録
    log_send "$agent_name" "$message"
    
    echo "✅ 送信完了: $agent_name に '$message'"
    
    # プレフィックスに応じたヒント表示
    case "$message" in
        "【タスク】"*)
            echo "💡 ヒント: タスクが完了したら【完了】で報告してください"
            ;;
        "【問題】"*)
            echo "💡 ヒント: 詳細な情報を含めることで迅速な解決が可能です"
            ;;
        "【バグ報告】"*)
            echo "💡 ヒント: 再現手順と影響範囲を明記してください"
            ;;
    esac
    
    return 0
}

main "$@" 