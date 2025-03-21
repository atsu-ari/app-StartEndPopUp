require 'tk'
require 'csv'
require 'json'
require 'date'
require 'open3'
require 'etc'
require 'uri'

class StartEndPopUpApp
    # 起動時処理
    def initialize(root)

    @root = root
    @root.title("Start-End Pop Up!")

    # 設定ファイルパス
    @config_file = "config.json"
    # リストファイルパス
    @list_file = "tasks.csv"

    # UIの作成
    create_loading_screen
    TkTimer.new(2000, 1, proc { show_guide_screen }).start # 2秒後に案内画面へ
  end

  # Loading画面を作成する 
  def create_loading_screen
    @loading_screen = TkToplevel.new(@root)
    @loading_screen.title("Loading")
    @loading_screen.geometry("610x610") # サイズは適宜調整
    @loading_screen.attributes('-topmost', 1) # 最前面に表示

    guide_image = TkPhotoImage.new(file: "../img/loading.png")
    loading_label = TkLabel.new(@loading_screen, image: guide_image)
    loading_label.pack(pady: 40)
  end

# 案内画面を表示する
  def show_guide_screen
    @loading_screen.destroy # Loading画面を閉じる
    @guide_screen = TkToplevel.new(@root)
    @guide_screen.title("どんなアプリ？")
    @guide_screen.geometry("710x620") # サイズは適宜調整
    @guide_screen.attributes('-topmost', 1) # 最前面に表示

    # 案内画像の表示 (実際の画像ファイルパスを指定)
    guide_image = TkPhotoImage.new(file: "../img/guide_image.png")
    guide_label = TkLabel.new(@guide_screen, image: guide_image)
    guide_label.pack

    ok_button = TkButton.new(@guide_screen, text: "OK", command: proc { process_guide_ok })
    ok_button.pack(pady: 20)
  end

# 案内画面のOKボタンの処理
  def process_guide_ok
    config = load_config
    if !config["initialized"]
      @guide_screen.destroy
      show_setting_screen # 設定画面を起動
    else
      config["initialized"] = true
      save_config(config)
      @guide_screen.destroy
      show_start_end_popup_screen # Start-End Pop Up！画面を表示
    end
  end

# Start-End Pop Up!画面を表示する
  def show_start_end_popup_screen
    @start_end_popup_screen = TkToplevel.new(@root)
    @start_end_popup_screen.title("Start-End Pop Up!")
    @start_end_popup_screen.geometry("610x610") # サイズは適宜調整
    @start_end_popup_screen.attributes('-topmost', 1) # 最前面に表示

    settings_button = TkButton.new(@start_end_popup_screen, text: "⚙", command: proc { show_setting_screen })
    settings_button.pack(side: 'left', padx: 10, pady: 20)

    ok_button = TkButton.new(@start_end_popup_screen, text: "OK", command: proc { @start_end_popup_screen.destroy })
    ok_button.pack(side: 'right', padx: 10, pady: 20)
  end

# リスト画面を表示する
  def show_list_screen
    @list_screen = TkToplevel.new(@root)
    @list_screen.title("Todoリスト")
    @list_screen.geometry("600x400") # サイズは適宜調整

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
    dialog = TkToplevel.new(@list_screen)
    dialog.title("Perfectじゃないみたい")
    dialog.geometry("200x100") # サイズは適宜調整

    label = TkLabel.new(dialog, text: "Perfectじゃないみたい")
    label.pack(pady: 10)

    button_frame = TkFrame.new(dialog)
    button_frame.pack(pady: 10)

    ok_button = TkButton.new(button_frame, text: "大丈夫", command: proc { dialog.destroy; @list_screen.destroy })
    ok_button.pack(side: 'left', padx: 5)

    back_button = TkButton.new(button_frame, text: "もどってみる", command: proc { dialog.destroy })
    back_button.pack(side: 'right', padx: 5)
  end

  # Perfect!の場合のOK画面を表示する
  def show_ok_screen
    @ok_screen = TkToplevel.new(@root)
    @ok_screen.title("OK")
    @ok_screen.geometry("300x200") # サイズは適宜調整

    settings_button = TkButton.new(@ok_screen, text: "⚙", command: proc { show_setting_screen })
    settings_button.place(x: 10, y: 170) # 左下角に配置

    ok_label = TkLabel.new(@ok_screen, text: "OK!", font: "Arial 36")
    ok_label.pack(pady: 20)

    ok_button = TkButton.new(@ok_screen, text: "OK", command: proc { @ok_screen.destroy; @list_screen.destroy })
    ok_button.pack(pady: 10)
  end

  # 設定画面を表示する
  def show_setting_screen
    @setting_screen = TkToplevel.new(@root)
    @setting_screen.title("設定")
    @setting_screen.geometry("600x500") # サイズは適宜調整

    create_setting_ui
    load_setting_data
  end

  def toggle_before_start
    # 始業前起動の利用チェックボックスの状態変更時の処理
    if @before_start_var.get
      @before_button.configure(state: 'normal')
    else
      @before_button.configure(state: 'disabled')
    end
  end

  def update_time_selection
    # 始業前、始業時、終業時の選択項目クリック時の処理
    config = load_config
    selected_time_period = @time_period.value

    if selected_time_period == "before"
      @before_button.configure(state: 'normal')
      start_time = config["startTime"] || "99:99" # デフォルト値を設定
      before_time = calculate_before_time(start_time)
      @hour_var.value = before_time[0, 2]
      @minute_var.value = before_time[3, 2]
    elsif selected_time_period == "start"
      start_time = config["startTime"] || "09:00" # デフォルト値を設定
      @hour_var.value = start_time[0, 2]
      @minute_var.value = start_time[3, 2]
    elsif selected_time_period == "end"
      end_time = config["endTime"] || "18:00" # デフォルト値を設定
      @hour_var.value = end_time[0, 2]
      @minute_var.value = end_time[3, 2]
    end

    populate_list_display # リスト表示を更新
  end

  def calculate_before_time(start_time)
    # 始業前時刻を計算する
    start_datetime = DateTime.strptime(start_time, "%H:%M")
    before_datetime = start_datetime.new_offset(Rational(0, 24 * 60)).change(min: [start_datetime.min - 5, 0].max)
    before_datetime.strftime("%H:%M")
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
    str.tr('a-zA-Z0-9 ', 'ａ-ｚＡ-Ｚ０-９　')
  end
end

# メインウィンドウを作成
root = TkRoot.new { title 'StartEndPopUpApp' }

# アプリケーションを開始
app = StartEndPopUpApp.new(root, 'list.csv')

# メインループ
Tk.mainloop