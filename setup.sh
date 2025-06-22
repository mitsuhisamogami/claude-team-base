#!/bin/bash

# 🚀 Multi-Agent Communication Demo 環境構築
# 参考: setup_full_environment.sh

set -e  # エラー時に停止

# 色付きログ関数
log_info() {
    echo -e "\033[1;32m[INFO]\033[0m $1"
}

log_success() {
    echo -e "\033[1;34m[SUCCESS]\033[0m $1"
}

echo "🤖 Multi-Agent Communication Demo 環境構築"
echo "==========================================="
echo ""

# STEP 1: 既存セッションクリーンアップ
log_info "🧹 既存セッションクリーンアップ開始..."

tmux kill-session -t multiagent 2>/dev/null && log_info "multiagentセッション削除完了" || log_info "multiagentセッションは存在しませんでした"
tmux kill-session -t pm 2>/dev/null && log_info "pmセッション削除完了" || log_info "pmセッションは存在しませんでした"

# 完了ファイルクリア
mkdir -p ./tmp
rm -f ./tmp/*_done.txt 2>/dev/null && log_info "既存の完了ファイルをクリア" || log_info "完了ファイルは存在しませんでした"

log_success "✅ クリーンアップ完了"
echo ""

# STEP 2: multiagentセッション作成（4ペイン：eng_leader + frontend/backend/tester）
log_info "📺 multiagentセッション作成開始 (4ペイン)..."

# 最初のペイン作成
tmux new-session -d -s multiagent -n "agents"

# 2x2グリッド作成（合計4ペイン）
tmux split-window -h -t "multiagent:0"      # 水平分割（左右）
tmux select-pane -t "multiagent:0.0"
tmux split-window -v                        # 左側を垂直分割
tmux select-pane -t "multiagent:0.2"
tmux split-window -v                        # 右側を垂直分割

# ペインタイトル設定
log_info "ペインタイトル設定中..."
PANE_TITLES=("eng_leader" "frontend" "backend" "tester")

for i in {0..3}; do
    tmux select-pane -t "multiagent:0.$i" -T "${PANE_TITLES[$i]}"
    
    # 作業ディレクトリ設定
    tmux send-keys -t "multiagent:0.$i" "cd $(pwd)" C-m
    
    # カラープロンプト設定
    case $i in
        0) # eng_leader: 赤色
            tmux send-keys -t "multiagent:0.$i" "export PS1='(\[\033[1;31m\]${PANE_TITLES[$i]}\[\033[0m\]) \[\033[1;32m\]\w\[\033[0m\]\$ '" C-m
            ;;
        1) # frontend: 青色
            tmux send-keys -t "multiagent:0.$i" "export PS1='(\[\033[1;34m\]${PANE_TITLES[$i]}\[\033[0m\]) \[\033[1;32m\]\w\[\033[0m\]\$ '" C-m
            ;;
        2) # backend: 緑色
            tmux send-keys -t "multiagent:0.$i" "export PS1='(\[\033[1;32m\]${PANE_TITLES[$i]}\[\033[0m\]) \[\033[1;33m\]\w\[\033[0m\]\$ '" C-m
            ;;
        3) # tester: 黄色
            tmux send-keys -t "multiagent:0.$i" "export PS1='(\[\033[1;33m\]${PANE_TITLES[$i]}\[\033[0m\]) \[\033[1;32m\]\w\[\033[0m\]\$ '" C-m
            ;;
    esac
    
    # ウェルカムメッセージ
    tmux send-keys -t "multiagent:0.$i" "echo '=== ${PANE_TITLES[$i]} エージェント ==='" C-m
done

log_success "✅ multiagentセッション作成完了"
echo ""

# STEP 3: PMセッション作成（1ペイン）
log_info "📋 PMセッション作成開始..."

tmux new-session -d -s pm
tmux send-keys -t pm "cd $(pwd)" C-m
tmux send-keys -t pm "export PS1='(\[\033[1;35m\]PM\[\033[0m\]) \[\033[1;32m\]\w\[\033[0m\]\$ '" C-m
tmux send-keys -t pm "echo '=== PM セッション ==='" C-m
tmux send-keys -t pm "echo 'プロジェクトマネージャー'" C-m
tmux send-keys -t pm "echo '====================='" C-m

log_success "✅ PMセッション作成完了"
echo ""

# STEP 4: 環境確認・表示
log_info "🔍 環境確認中..."

echo ""
echo "📊 セットアップ結果:"
echo "==================="

# tmuxセッション確認
echo "📺 Tmux Sessions:"
tmux list-sessions
echo ""

# ペイン構成表示
echo "📋 ペイン構成:"
echo "  multiagentセッション（4ペイン）:"
echo "    Pane 0: eng_leader (エンジニアリングリーダー)"
echo "    Pane 1: frontend   (フロントエンドエンジニア)"
echo "    Pane 2: backend    (バックエンドエンジニア)"
echo "    Pane 3: tester     (テスター)"
echo ""
echo "  pmセッション（1ペイン）:"
echo "    Pane 0: PM         (プロジェクトマネージャー)"

echo ""
log_success "🎉 Demo環境セットアップ完了！"
echo ""
echo "📋 次のステップ:"
echo "  1. 🔗 セッションアタッチ:"
echo "     tmux attach-session -t multiagent   # マルチエージェント確認"
echo "     tmux attach-session -t pm           # PM確認"
echo ""
echo "  2. 🤖 Claude Code起動:"
echo "     # 手順1: PM認証"
echo "     tmux send-keys -t pm 'claude' C-m"
echo "     # 手順2: 認証後、multiagent一括起動"
echo "     for i in {0..3}; do tmux send-keys -t multiagent:0.\$i 'claude' C-m; done"
echo ""
echo "  3. 📜 指示書確認:"
echo "     PM:         instructions/pm.md"
echo "     eng_leader: instructions/eng_leader.md"
echo "     frontend:   instructions/frontend.md"
echo "     backend:    instructions/backend.md"
echo "     tester:     instructions/tester.md"
echo "     システム構造: CLAUDE.md"
echo ""
echo "  4. 🎯 デモ実行: PMに「あなたはPMです。プロジェクト開始指示」と入力" 