require 'tk'
require 'tk/ttk'

# ##################### #
# 　　設定画面のUI
# ##################### #
class SettingScreen
  def initialize(root, app)
    @root = root
    @app = app
    @setting_screen = TkToplevel.new(@root)
    @setting_screen.title('設定')
    @setting_screen.geometry('600x500')

    create_widgets
    @app.load_setting_data
  end

  def create_widgets
    # 始業前起動の利用
    @before_start_var = TkVariable.new(false)
    before_start_check = TkCheckButton.new(@setting_screen) do
      text "始業前起動を利用する"
      variable @before_start_var
      command proc { toggle_before_start }
      pack(pady: 5)
    end

    # 時刻の選択
    time_frame = TkFrame.new(@setting_screen) do
      pack(pady: 10)
    end

    TkLabel.new(time_frame) do
      text "時刻:"
      pack(side: 'left', padx: 5)
    end

    @hour_var = TkVariable.new
    hour_combo = TkCombobox.new(time_frame) do
      textvariable @hour_var
      values (0..23).map { |i| format('%02d', i) }
      width 3
      pack(side: 'left', padx: 2)
    end

    TkLabel.new(time_frame) do
      text ":"
      pack(side: 'left')
    end

    @minute_var = TkVariable.new
    minute_combo = TkCombobox.new(time_frame) do
      textvariable @minute_var
      values (0..59).map { |i| format('%02d', i) }
      width 3
      pack(side: 'left', padx: 2)
    end

    # 選択項目 (ラジオボタン)
    @time_period = TkVariable.new("start") # 初期値は始業時
    radio_frame = TkFrame.new(@setting_screen) do
      pack(pady: 10)
    end

    before_button = TkRadioButton.new(radio_frame) do
      text "始業前"
      variable @time_period
      value "before"
      command proc { update_time_selection }
      pack(side: 'left', padx: 5)
    end

    start_button = TkRadioButton.new(radio_frame) do
      text "始業時"
      variable @time_period
      value "start"
      command proc { update_time_selection }
      pack(side: 'left', padx: 5)
    end

    end_button = TkRadioButton.new(radio_frame) do
      text "終業時"
      variable @time_period
      value "end"
      command proc { update_time_selection }
      pack(side: 'left', padx: 5)
    end

    # 入力欄
    input_frame = TkFrame.new(@setting_screen) do
      pack(pady: 10)
    end

    @item_type = TkVariable.new("todo") # 初期値はTodo
    type_frame = TkFrame.new(input_frame) do
      pack(pady: 5)
    end

    todo_radio = TkRadioButton.new(type_frame) do
      text "Todo"
      variable @item_type
      value "todo"
      pack(side: 'left', padx: 5)
    end

    url_radio = TkRadioButton.new(type_frame) do
      text "URL"
      variable @item_type
      value "url"
      pack(side: 'left', padx: 5)
    end

    app_radio = TkRadioButton.new(type_frame) do
      text "アプリ"
      variable @item_type
      value "app"
      pack(side: 'left', padx: 5)
    end

    TkLabel.new(input_frame) do
      text "項目名:"
      pack(pady: 2)
    end

    @name_entry = TkEntry.new(input_frame) do
      width 40
      pack(pady: 2)
    end
    @name_entry.insert(0, "タイトルまたは概要")
    @name_entry.bind("FocusIn", proc { @name_entry.delete(0, 'end') })

    TkLabel.new(input_frame) do
      text "テキスト:"
      pack(pady: 2)
    end

    @text_entry = TkEntry.new(input_frame) do
      width 40
      pack(pady: 2)
    end
    @text_entry.insert(0, "内容（任意）")
    @text_entry.bind("FocusIn", proc { @text_entry.delete(0, 'end') })
    @text_entry.bind("Shift-Return", proc { add_item })

    add_button = TkButton.new(input_frame) do
      text "+"
      command proc { add_item }
      pack(pady: 5)
    end

    # リスト表示
    list_display_frame = TkFrame.new(@setting_screen) do
      pack(pady: 10, padx: 10, fill: 'both', expand: true)
    end

    # リスト表示用のTreeview
    @setting_tree = TkTreeview.new(list_display_frame) do
      columns ["type", "name", "text"]
      show "headings"
      heading("type", text: "種別")
      heading("name", text: "名前")
      heading("text", text: "テキスト")
      pack(side: 'left', fill: 'both', expand: true)
    end

    delete_button = TkButton.new(list_display_frame) do
      text "❌"
      command proc { delete_selected_item }
      pack(side: 'right', padx: 5)
    end

    # 完了ボタン
    complete_button = TkButton.new(@setting_screen) do
      text "完了"
      command proc { process_setting_complete }
      pack(pady: 20)
    end

    # 案内画面起動ボタン
    guide_button = TkButton.new(@setting_screen) do
      text "?"
      command proc { show_guide_screen }
      place(x: 10, y: 470) # 左下角に配置
    end
  end

  def destroy
    @setting_screen.destroy
  end
end