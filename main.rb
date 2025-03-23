require 'gdk3'
require 'csv'
require 'json'
require 'date'
require 'open3'
require 'etc'
require 'uri'

require_relative 'ui/list_screen'
require_relative 'ui/setting_screen'
require_relative 'ui/start_end_popup_screen'
require_relative 'lib/util/app_utils'

# グローバル変数を定義
$shared_array_config = {}
$shared_array_list = []

# ファイルパスを定義
$config_default_path = 'config_default.json'
$config_file_path = 'config.json'
$list_file_path = 'tasks.csv'
$loading_img_path = 'img/loading.png'
$guide_img_path = 'img/guide_image.png'
$StartEndPopup_img_path = 'img/Start-EndPopUp.png'
$icon_path = 'img/Start-EndPopUp.png'

################################################################################
################################################################################

#==============================================================================#
#==============================================================================#

#                           Start-End PopUp!

#==============================================================================#
#==============================================================================#

################################################################################
################################################################################
# このアプリケーションは、以下の機能を提供します：
# - 始業・終業時の通知ポップアップ
# - 設定画面でのタスクやスケジュールの管理
# - リスト画面でのタスクの表示と編集
# - ローディング画面や案内画面の表示
# - ユーザー操作に応じたダイアログ表示と処理
#
# 主なクラスと機能：
# - `StartEndPopUpApp`: アプリケーション全体の管理
# - `show_guide_screen`: 案内画面の表示
# - `show_setting_screen`: 設定画面の表示
# - `show_list_screen`: リスト画面の表示
# - `create_loading_screen`: ローディング画面の作成
# - `handle_window_close`: アプリケーション終了時の処理

class StartEndPopUpApp
  # 起動時処理
  def initialize(root)
    # メインウィンドウを作成
    @root = root
    @root.title = 'Start-End Pop Up!'

    # 配列を初期化
    @shared_array_config = []
    @shared_array_list = []

    # Loading画面の表示
    create_loading_screen

    # $config_file_path にファイルが存在しない場合、$config_default_path をコピー
    unless File.exist?($config_file_path)
      raise "Default config file not found at #{$config_default_path}" unless File.exist?($config_default_path)

      FileUtils.cp($config_default_path, $config_file_path)
      puts "Default config file copied to #{$config_file_path}"

    end

    # $list_file_path にファイルが存在しない場合、空のファイルを作成
    unless File.exist?($list_file_path)
      File.new($list_file_path, 'w') # 空のファイルを作成
      puts "Empty list file created at #{$list_file_path}"
    end

    # 起動時の処理
    $shared_array_config = Utility.load_config($config_file_path)
    # load_list

    # UIの作成
    @main_window = Gtk::Window.new
    @main_window.set_title('x')

    # ウィンドウの幅と高さを定義
    window_width = 120  # ウィンドウの幅
    window_height = 100 # ウィンドウの高さ

    # ウィンドウの位置を上中央に設定
    screen = Gdk::Screen.default
    x_position = (screen.width - window_width) / 2 # 上中央の座標を計算
    y_position = 0 # 上部に配置するためY座標は0

    @main_window.set_default_size(window_width, window_height)
    @main_window.move(x_position, y_position)

    # アイコンを設定
    if File.exist?($icon_path)
      # 画像をPixbufとして読み込む
      pixbuf = GdkPixbuf::Pixbuf.new(file: $icon_path)

      # ウィンドウサイズに合わせて画像をリサイズ
      resized_pixbuf = pixbuf.scale(window_width, window_height)

      # リサイズしたPixbufをGtk::Imageに設定
      icon_image = Gtk::Image.new(pixbuf: resized_pixbuf)

      # EventBoxを作成してクリックイベントを追加
      event_box = Gtk::EventBox.new
      event_box.add(icon_image)
      event_box.signal_connect('button-press-event') do |_widget, _event|
        # ウィンドウの終了処理を呼び出す
        handle_window_close
      end

      # EventBoxをウィンドウに追加
      @main_window.add(event_box)
    else
      puts "アイコン画像が見つかりません: #{$icon_path}"
    end

    @main_window.signal_connect('destroy') do
      handle_window_close
    end

    # メインウィンドウを表示
    @main_window.show_all

    # 2秒後に案内画面を表示
    GLib::Timeout.add(1000) do
      show_guide_screen
      false # タイマーを1回だけ実行
    end
  end

  # Loading画面を作成する
  def create_loading_screen
    @loading_screen = Gtk::Window.new
    @loading_screen.set_title('Loading')
    @loading_screen.set_default_size(610, 610) # サイズは適宜調整
    @loading_screen.set_keep_above(true) # 最前面に表示
    @loading_screen.set_window_position(:center) # ウィンドウを中央に表示

    # 終了ボタンを無効化
    @loading_screen.signal_connect('delete-event') { true }

    # 画像の表示 (画像ファイルが存在する場合)
    if File.exist?($loading_img_path)
      # 画像をPixbufとして読み込む
      pixbuf = GdkPixbuf::Pixbuf.new(file: $loading_img_path)

      # ウィンドウサイズに合わせて画像をリサイズ
      resized_pixbuf = pixbuf.scale(610, 610)

      # リサイズしたPixbufをGtk::Imageに設定
      guide_image = Gtk::Image.new(pixbuf: resized_pixbuf)
      @loading_screen.add(guide_image)
    else
      # 画像がない場合はテキストを表示
      label = Gtk::Label.new('Loading...')
      @loading_screen.add(label)
    end

    @loading_screen.show_all
  end

  # 案内画面を表示する
  def show_guide_screen
    @loading_screen.destroy if @loading_screen # Loading画面を閉じる

    @guide_screen = Gtk::Window.new
    @guide_screen.set_title('どんなアプリ？')
    @guide_screen.set_default_size(710, 620)
    @guide_screen.set_window_position(:center)
    @guide_screen.set_keep_above(true) # 最前面に表示

    # 終了ボタンを無効化
    @guide_screen.signal_connect('delete-event') { true }

    # 案内画像の表示 (画像ファイルが存在する場合)
    guide_image = nil
    if File.exist?($guide_img_path)
      # 画像をPixbufとして読み込む
      pixbuf = GdkPixbuf::Pixbuf.new(file: $guide_img_path)

      # ウィンドウサイズに合わせて画像をリサイズ
      resized_pixbuf = pixbuf.scale(620, 500)

      # リサイズしたPixbufをGtk::Imageに設定
      guide_image = Gtk::Image.new(pixbuf: resized_pixbuf)
    else
      # 画像がない場合はテキストを表示
      guide_image = Gtk::Label.new('案内画面へようこそ！')
    end

    # ラベルを追加
    demo_label = Gtk::Label.new('*******このプログラムは画面表示のみのデモです*******')
    demo_label.set_margin_top(10) # 上部に余白を追加

    # OKボタンを追加
    ok_button = Gtk::Button.new(label: 'OK')
    ok_button.signal_connect('clicked') do
      process_guide_ok # OKボタンがクリックされたときに呼び出す
    end

    # レイアウトを設定
    vbox = Gtk::Box.new(:vertical, 10) # 垂直方向のボックス
    vbox.pack_start(guide_image, expand: true, fill: true, padding: 10) if guide_image
    vbox.pack_start(demo_label, expand: false, fill: false, padding: 10) # ラベルを追加
    vbox.pack_start(ok_button, expand: false, fill: false, padding: 10)

    @guide_screen.add(vbox) # Gtk::Box をウィンドウに追加

    @guide_screen.show_all
  end

  # 案内画面のOKボタンの処理
  def process_guide_ok
    @guide_screen.destroy if @guide_screen
    show_setting_screen # 設定画面を表示
  end

  # Start-End Pop Up!画面を表示する
  def show_start_end_popup_screen
    @start_end_popup_screen = Gtk::Window.new
    @start_end_popup_screen.set_title('Start-End Pop Up!')
    @start_end_popup_screen.set_default_size(610, 610)
    @start_end_popup_screen.set_window_position(:center)

    # 終了ボタンを無効化
    @start_end_popup_screen.signal_connect('delete-event') { true }

    if File.exist?($StartEndPopup_img_path)
      pixbuf = GdkPixbuf::Pixbuf.new(file: $StartEndPopup_img_path)
      resized_pixbuf = pixbuf.scale(610, 610)
      top_image = Gtk::Image.new(pixbuf: resized_pixbuf)
      @start_end_popup_screen.add(top_image)
    else
      label = Gtk::Label.new('案内画面へようこそ！')
      @start_end_popup_screen.add(label)
    end

    @start_end_popup_screen.show_all
  end

  # リスト画面を表示する
  def show_list_screen
    @list_screen = Gtk::Window.new(@root)
    @list_screen.title('Todoリスト')
    @list_screen.geometry('600x400') # サイズは適宜調整

    create_list_ui
    load_tasks
  end

  # リスト画面のOKボタンの処理
  def process_list_ok
    if !@perfect_var.get
      show_not_perfect_dialog
    else
      show_ok_screen
    end
  end

  # Perfect!でない場合のダイアログを表示する
  def show_not_perfect_dialog
    dialog = Gtk::Window.new
    dialog.set_title('Perfectじゃないみたい')
    dialog.set_default_size(200, 100) # サイズは適宜調整

    # ラベルを追加
    label = Gtk::Label.new('Perfectじゃないみたい')
    vbox = Gtk::Box.new(:vertical, 10) # 垂直方向のボックス
    vbox.pack_start(label, expand: false, fill: false, padding: 10)

    # ボタンを追加
    button_box = Gtk::Box.new(:horizontal, 10) # 水平方向のボックス
    ok_button = Gtk::Button.new(label: '大丈夫')
    ok_button.signal_connect('clicked') do
      dialog.destroy
      @list_screen.destroy if @list_screen
    end
    back_button = Gtk::Button.new(label: 'もどってみる')
    back_button.signal_connect('clicked') { dialog.destroy }

    button_box.pack_start(ok_button, expand: true, fill: true, padding: 5)
    button_box.pack_start(back_button, expand: true, fill: true, padding: 5)

    vbox.pack_start(button_box, expand: false, fill: false, padding: 10)
    dialog.add(vbox)

    dialog.show_all
  end

  # Perfect!の場合のOK画面を表示する
  def show_ok_screen
    @ok_screen = Gtk::Window.new
    @ok_screen.set_title('OK')
    @ok_screen.set_default_size(300, 200) # サイズは適宜調整

    # ラベルを追加
    ok_label = Gtk::Label.new('OK!')
    ok_label.override_font(Pango::FontDescription.new('Arial 36'))

    # OKボタンを追加
    ok_button = Gtk::Button.new(label: 'OK')
    ok_button.signal_connect('clicked') do
      @ok_screen.destroy
      @list_screen.destroy if @list_screen
    end

    # レイアウト
    vbox = Gtk::Box.new(:vertical, 10)
    vbox.pack_start(ok_label, expand: false, fill: false, padding: 20)
    vbox.pack_start(ok_button, expand: false, fill: false, padding: 10)

    @ok_screen.add(vbox)
    @ok_screen.show_all
  end

  # 設定画面を表示する
  def show_setting_screen
    @setting_screen = Gtk::Window.new
    @setting_screen.set_title('設定')
    @setting_screen.set_default_size(600, 500)

    # 終了ボタンを無効化
    @setting_screen.signal_connect('delete-event') { true }

    SettingScreen.new(self)
  end

  # 始業前起動の利用チェックボックスの状態変更時の処理
  def toggle_before_start
    if @before_start_var.get
      @before_button.configure(state: 'normal')
    else
      @before_button.configure(state: 'disabled')
    end
  end

  # 始業前、始業時、終業時の選択項目クリック時の処理【後日実装】
  def update_time_selection
    config = load_config
    selected_time_period = @time_period.value

    if selected_time_period == 'before'
      @before_button.configure(state: 'normal')
      start_time = config['startTime'] || '99:99' # デフォルト値を設定
      before_time = calculate_before_time(start_time)
      @hour_var.value = before_time[0, 2]
      @minute_var.value = before_time[3, 2]
    elsif selected_time_period == 'start'
      start_time = config['startTime'] || '09:00' # デフォルト値を設定
      @hour_var.value = start_time[0, 2]
      @minute_var.value = start_time[3, 2]
    elsif selected_time_period == 'end'
      end_time = config['endTime'] || '18:00' # デフォルト値を設定
      @hour_var.value = end_time[0, 2]
      @minute_var.value = end_time[3, 2]
    end

    populate_list_display # リスト表示を更新
  end

  # 始業前時刻を計算する
  def calculate_before_time(start_time)
    start_datetime = DateTime.strptime(start_time, '%H:%M')
    before_datetime = start_datetime.new_offset(Rational(0, 24 * 60)).change(min: [start_datetime.min - 5, 0].max)
    before_datetime.strftime('%H:%M')
  end

  # 入力欄の内容をリストファイルに書き込む
  def add_item
    name = @name_entry.value
    text = @text_entry.value
    item_type = @item_type.value

    # エラーとなりうる半角記号と空白を全角に変換
    name = convert_to_zenkaku(name)
    text = convert_to_zenkaku(text)

    # 項目名とテキストが両方空欄または空白の場合は書き込み処理を行わない
    return if name.strip.empty? || text.strip.empty?

    # リストファイルに書き込み
    CSV.open(@list_file, 'a', headers: %w[type name text], write_headers: !File.exist?(@list_file)) do |csv|
      csv << [item_type, name, text]
    end

    # リスト表示を更新
    populate_list_display

    # 入力欄をクリア
    @name_entry.value = ''
    @text_entry.value = ''
  end

  # リストファイルの内容をTreeviewに表示する
  def populate_list_display
    # Treeviewの内容をクリア
    @setting_tree.delete(*@setting_tree.children)

    begin
      # リストファイルの内容を読み込み、Treeviewに表示
      CSV.foreach(@list_file, headers: true) do |row|
        @setting_tree.insert('', 'end', values: row.fields)
      end
    rescue Errno::ENOENT
      # ファイルが存在しない場合は何もしない
    end
  end

  # 半角記号と空白を全角に変換する
  def convert_to_zenkaku(str)
    str.tr(' !"#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~', '　！＂＃＄％＆＇（）＊＋，－．／：；＜＝＞？＠［＼］＾＿｀｛｜｝～')
  end

  def handle_window_close
    dialog = Gtk::MessageDialog.new(
      parent: @main_window,
      flags: :destroy_with_parent,
      type: :question,
      buttons: :ok_cancel,
      message: 'Start-End Pop Up!を終了しますか？'
    )

    dialog.set_window_position(:center) # ダイアログを画面中央に表示

    response = dialog.run
    dialog.destroy

    return unless response == :ok

    # ファイルを削除（必要に応じてコメントアウト）
    begin
      File.delete($list_file_path) if File.exist?($list_file_path)
      File.delete($config_file_path) if File.exist?($config_file_path)
      puts "Deleted #{$list_file_path} and #{$config_file_path}"
    rescue StandardError => e
      puts "Error deleting files: #{e.message}"
    end

    Gtk.main_quit # アプリケーションを終了
  end
end

# メインウィンドウを作成
root = Gtk::Window.new
StartEndPopUpApp.new(root)

# メインループ
Gtk.main
