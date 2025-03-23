require 'gtk3'

# ##################### #
# 　　設定画面のUI
# ##################### #
# このクラスは設定画面を構築し、以下の機能を提供します：
# - 始業前起動や時刻設定のチェックボックスとラジオボタン
# - 項目の追加（URL、アプリ、Todo）とリスト表示
# - リストの各項目に対するチェックボックスのオン・オフ切り替え
# - デモ画面（リスト画面）の起動
# - 設定内容の保存と完了ボタン
class SettingScreen
  def initialize(app)
    @app = app
    @setting_screen = Gtk::Window.new
    @setting_screen.set_title('設定')
    @setting_screen.set_default_size(600, 500)
    @setting_screen.set_window_position(:center)

    create_widgets
    @setting_screen.show_all
  end

  def create_widgets
    # メインコンテナ
    vbox = Gtk::Box.new(:vertical, 10)
    vbox.margin = 10
    @setting_screen.add(vbox)

    # 始業前起動の利用
    before_start_checkbox = Gtk::CheckButton.new('始業前起動を利用する')
    before_start_checkbox.sensitive = false # チェックボックスを無効化【次回実装予定】
    before_start_checkbox.signal_connect('toggled') { toggle_before_start }
    vbox.pack_start(before_start_checkbox, expand: false, fill: false, padding: 5)

    # 時刻の選択
    time_frame = Gtk::Box.new(:horizontal, 5)
    vbox.pack_start(time_frame, expand: false, fill: false, padding: 5)

    time_label = Gtk::Label.new('時刻:')
    time_frame.pack_start(time_label, expand: false, fill: false, padding: 5)

    @hour_combo = Gtk::ComboBoxText.new
    (0..23).each { |i| @hour_combo.append_text(format('%02d', i)) }
    time_frame.pack_start(@hour_combo, expand: false, fill: false, padding: 5)

    colon_label = Gtk::Label.new(':')
    time_frame.pack_start(colon_label, expand: false, fill: false, padding: 0)

    @minute_combo = Gtk::ComboBoxText.new
    (0..59).each { |i| @minute_combo.append_text(format('%02d', i)) }
    time_frame.pack_start(@minute_combo, expand: false, fill: false, padding: 5)

    # 選択項目 (ラジオボタン)
    radio_frame = Gtk::Box.new(:horizontal, 5)
    vbox.pack_start(radio_frame, expand: false, fill: false, padding: 5)

    @time_period = Gtk::RadioButton.new(label: '始業前')
    @time_period.sensitive = false # 始業前ボタンを無効化
    @time_period.signal_connect('toggled') { update_time_selection }
    radio_frame.pack_start(@time_period, expand: false, fill: false, padding: 5)

    @start_radio = Gtk::RadioButton.new(member: @time_period, label: '始業時')
    @start_radio.signal_connect('toggled') { update_time_selection }
    radio_frame.pack_start(@start_radio, expand: false, fill: false, padding: 5)

    @end_radio = Gtk::RadioButton.new(member: @time_period, label: '終業時')
    @end_radio.sensitive = false # 終業時ボタンを無効化
    @end_radio.signal_connect('toggled') { update_time_selection }
    radio_frame.pack_start(@end_radio, expand: false, fill: false, padding: 5)

    # デフォルトで「始業時」を選択
    @start_radio.active = true

    # 入力欄
    input_frame = Gtk::Box.new(:vertical, 5)
    vbox.pack_start(input_frame, expand: false, fill: false, padding: 5)

    # 項目名入力とラベルを水平に並べる
    name_and_label_frame = Gtk::Box.new(:horizontal, 5)
    input_frame.pack_start(name_and_label_frame, expand: false, fill: false, padding: 2)

    # ドロップダウンボックス（選択内容: URL、アプリ、Todo）
    @item_type = Gtk::ComboBoxText.new
    @item_type.set_size_request(50, -1) # 幅を50、高さはデフォルト
    @item_type.append_text('URL')
    @item_type.append_text('アプリ')
    @item_type.append_text('Todo')
    @item_type.active = 2 # デフォルトで「Todo」を選択
    name_and_label_frame.pack_start(@item_type, expand: false, fill: false, padding: 2)

    # 項目名入力欄
    @name_entry = Gtk::Entry.new
    @name_entry.set_placeholder_text('タイトルまたは概要')
    name_and_label_frame.pack_start(@name_entry, expand: true, fill: true, padding: 2)

    # テキスト入力とボタンを水平に並べる
    text_and_label_frame = Gtk::Box.new(:horizontal, 5)
    input_frame.pack_start(text_and_label_frame, expand: false, fill: false, padding: 2)

    @text_entry = Gtk::Entry.new
    @text_entry.set_placeholder_text('内容（任意）')
    text_and_label_frame.pack_start(@text_entry, expand: true, fill: true, padding: 2)

    add_button = Gtk::Button.new(label: '+')
    add_button.set_size_request(30, -1) # 幅を30、高さはデフォルト
    add_button.signal_connect('clicked') { add_item }
    text_and_label_frame.pack_start(add_button, expand: false, fill: false, padding: 2)

    # リスト表示
    list_display_frame = Gtk::ScrolledWindow.new
    list_display_frame.set_policy(:automatic, :automatic)
    vbox.pack_start(list_display_frame, expand: true, fill: true, padding: 5)

    # TreeViewのデータモデルを設定（4列: Topic, ☑, 項目名, 内容）
    list_store = Gtk::ListStore.new(String, TrueClass, String, String)
    @setting_tree = Gtk::TreeView.new(list_store)
    list_display_frame.add(@setting_tree)

    # カラムを追加

    # Topic カラム
    topic_renderer = Gtk::CellRendererText.new
    topic_column = Gtk::TreeViewColumn.new('Topic', topic_renderer, text: 0)
    @setting_tree.append_column(topic_column)

    # ☑ カラム（チェックボックス）
    checkbox_renderer = Gtk::CellRendererToggle.new
    checkbox_renderer.activatable = true
    checkbox_renderer.signal_connect('toggled') do |_, path|
      iter = list_store.get_iter(path)
      iter[1] = !iter[1] # チェック状態をトグル
    end
    checkbox_column = Gtk::TreeViewColumn.new('☑', checkbox_renderer, active: 1)
    @setting_tree.append_column(checkbox_column)

    # 項目名 カラム
    name_renderer = Gtk::CellRendererText.new
    name_column = Gtk::TreeViewColumn.new('項目名', name_renderer, text: 2)
    @setting_tree.append_column(name_column)

    # 内容 カラム
    content_renderer = Gtk::CellRendererText.new
    content_column = Gtk::TreeViewColumn.new('内容', content_renderer, text: 3)
    @setting_tree.append_column(content_column)

    # TreeViewのモデルを設定
    @setting_tree.model = list_store

    # ボタンを水平に並べるためのコンテナ
    button_box = Gtk::Box.new(:horizontal, 10)
    vbox.pack_start(button_box, expand: false, fill: false, padding: 10)

    # デモボタン（左側）
    demo_button = Gtk::Button.new(label: 'デモのリスト画面を見る')
    demo_button.set_size_request(400, -1) # 幅を400、高さはデフォルト
    demo_button.signal_connect('clicked') do
      @setting_screen.destroy # 設定画面を閉じる
      @list_screen = ListScreen.new(self) # リスト画面を起動
    end
    button_box.pack_start(demo_button, expand: true, fill: true, padding: 5)

    # 完了ボタン（右側）
    complete_button = Gtk::Button.new(label: '完了')
    complete_button.set_size_request(200, -1) # 幅を200、高さはデフォルト
    complete_button.signal_connect('clicked') { process_setting_complete }
    button_box.pack_end(complete_button, expand: false, fill: false, padding: 5)
  end

  def toggle_before_start
    if @before_start_checkbox.active?
      puts '始業前起動が有効になりました'
    else
      puts '始業前起動が無効になりました'
    end
  end

  def update_time_selection
    if @time_period.active?
      puts '始業前が選択されました'
    elsif @start_radio.active?
      puts '始業時が選択されました'
    elsif @end_radio.active?
      puts '終業時が選択されました'
    end
  end

  def add_item
    # 入力値を取得
    item_type = @item_type.active_text || 'Todo' # ドロップダウンの選択値
    name = @name_entry.text.strip                # 項目名入力欄の値
    content = @text_entry.text.strip # 内容入力欄の値

    # 入力値が空の場合は何もしない
    return if name.empty?

    # データモデルに追加
    list_store = @setting_tree.model
    iter = list_store.append
    iter[0] = item_type # Topic カラムに @item_type の値を設定
    iter[1] = false     # ☑ カラム（初期値: 未チェック）
    iter[2] = name      # 項目名 カラムに @name_entry の値を設定
    iter[3] = content   # 内容 カラムに @text_entry の値を設定

    # 入力欄をクリア
    @name_entry.text = ''
    @text_entry.text = ''
  end

  def process_setting_complete
    # 設定内容を保存
    puts '設定内容を保存しました'

    # 設定画面を閉じる
    @setting_screen.destroy
  end
end
