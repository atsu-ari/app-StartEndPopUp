require 'gtk3'

# ##################### #
# 　　リスト画面のUI
# ##################### #
# このクラスはリスト画面を構築し、以下の機能を提供します：
# - TreeViewを使用したリスト表示（チェックボックス、種別、内容）
# - チェックボックスのオン・オフ切り替え
# - シングルクリックでの行選択とダイアログ表示
# - スクロール可能なリストビュー
# - OKボタンと設定ボタンの配置
class ListScreen
  def initialize(app)
    @app = app
    @list_screen = Gtk::Window.new
    @list_screen.set_title('デモリスト')
    @list_screen.set_default_size(600, 400)
    @list_screen.set_window_position(:center)
    # 終了ボタンを無効化
    @list_screen.signal_connect('delete-event') { true }

    create_widgets
    @list_screen.show_all
    # @app.load_tasks
  end

  # ウィジェットを作成する
  def create_widgets
    # メインコンテナ
    vbox = Gtk::Box.new(:vertical, 10)
    vbox.margin = 10
    @list_screen.add(vbox)

    # TreeView（リスト表示）
    @tree_store = Gtk::TreeStore.new(TrueClass, String, String) # 完了, 種別, 内容
    @tree_view = Gtk::TreeView.new(@tree_store)

    # チェックボックスカラム
    renderer_toggle = Gtk::CellRendererToggle.new
    renderer_toggle.activatable = true # チェックボックスをクリック可能にする
    renderer_toggle.signal_connect('toggled') do |_, path|
      iter = @tree_store.get_iter(path)
      if iter
        iter[0] = !iter[0] # チェックボックスの状態を切り替え
      end
    end
    column_toggle = Gtk::TreeViewColumn.new('完了', renderer_toggle, active: 0)
    @tree_view.append_column(column_toggle)

    # 種別カラム
    renderer_type = Gtk::CellRendererText.new
    column_type = Gtk::TreeViewColumn.new('種別', renderer_type, text: 1)
    @tree_view.append_column(column_type)

    # 内容カラム
    renderer_content = Gtk::CellRendererText.new
    column_content = Gtk::TreeViewColumn.new('内容', renderer_content, text: 2)
    @tree_view.append_column(column_content)

    # データを追加
    add_list_item(true, 'アプリ', 'demo:アプリの名前')
    add_list_item(true, 'リンク', 'demo:リンクの名前')
    add_list_item(false, 'Todo', 'demo:Todo<内容>')

    # TreeViewをスクロール可能にする
    scrolled_window = Gtk::ScrolledWindow.new
    scrolled_window.set_policy(:automatic, :automatic)
    scrolled_window.add(@tree_view)
    scrolled_window.set_size_request(580, 300) # 最大幅と高さを設定
    vbox.pack_start(scrolled_window, expand: false, fill: true, padding: 10)

    # ハイパーリンククリック時の動作（シングルクリック対応）
    @tree_view.signal_connect('button-press-event') do |tree_view, event|
      # 左クリック（button 1）の場合のみ処理
      if event.button == 1
        x = event.x
        y = event.y
        path_info = tree_view.get_path_at_pos(x, y)

        if path_info
          path, _column, _cell_x, _cell_y = path_info
          iter = @tree_store.get_iter(path)

          # iter が nil でないことを確認
          if iter
            case iter[1]
            when 'アプリ'
              show_dialog('アプリが起動します（未実装）')
            when 'リンク'
              show_dialog('ブラウザが起動します（未実装）')
              # when 'Todo'
              #   show_dialog("Todo: #{iter[2]}")
            end
          else
            puts "無効な path: #{path}"
          end
        else
          puts 'クリック位置に対応する行が見つかりません'
        end
      end
    end

    # Perfect! チェックボックス
    @perfect_var = Gtk::CheckButton.new('Perfect！') # 修正済み
    vbox.pack_start(@perfect_var, expand: false, fill: false, padding: 5)

    # ボタンのコンテナ
    button_box = Gtk::Box.new(:horizontal, 10)
    vbox.pack_start(button_box, expand: false, fill: false, padding: 5)

    # 設定ボタン
    settings_button = Gtk::Button.new(label: '⚙')
    settings_button.set_size_request(30, -1) # 幅を30、高さはデフォルト
    button_box.pack_start(settings_button, expand: true, fill: true, padding: 5)

    # OKボタン
    ok_button = Gtk::Button.new(label: 'OK')
    button_box.pack_start(ok_button, expand: true, fill: true, padding: 5)

    # 設定ボタン
    settings_button = Gtk::Button.new(label: '⚙')
    button_box.pack_start(settings_button, expand: true, fill: true, padding: 5)
  end

  # リストにアイテムを追加する
  def add_list_item(checked, type, content)
    iter = @tree_store.append(nil)
    iter[0] = checked
    iter[1] = type
    iter[2] = content
  end

  # ダイアログを表示する
  def show_dialog(message)
    dialog = Gtk::MessageDialog.new(
      parent: @list_screen,
      flags: :modal,
      type: :info,
      buttons: :ok,
      message: message
    )
    dialog.run
    dialog.destroy
  end

  # ウィンドウを破棄する
  def destroy
    @list_screen.destroy
  end
end
