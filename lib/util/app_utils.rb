require 'gtk3'
require 'csv'
require 'date'
require 'json'
require 'open3'
require 'launchy'

# ##################### #
#   ユーティリティコード
# ##################### #
class Utility
  # 半角文字を全角文字に変換する
  def self.convert_to_zenkaku(text)
    text.unicode_normalize(:nfkc)
  end

  # タスクのロードを行う
  def self.load_tasks(list_file)
    CSV.open(list_file, 'r', encoding: 'utf-8', headers: :first_row) do |csv|
      @tasks = csv.map(&:to_h)
    end
  rescue Errno::ENOENT
    @tasks = []
  end

  # タスクのセーブを行う
  def self.save_tasks(list_file)
    CSV.open(list_file, 'w', encoding: 'utf-8', headers: %w[type name text checked]) do |csv|
      csv << %w[type name text checked]
      @tasks.each do |task|
        csv << task.values
      end
    end
  end

  # 設定のロードを行う
  def self.load_config(config_file)
    # JSONファイルを読み込み、配列またはハッシュを返す
    JSON.parse(File.read(config_file, encoding: 'utf-8'))
  rescue Errno::ENOENT
    puts "Config file not found: #{config_file}"
    [] # ファイルが存在しない場合は空の配列を返す
  rescue JSON::ParserError => e
    puts "Error parsing config file: #{e.message}"
    [] # JSONのパースエラーが発生した場合も空の配列を返す
  end

  # 設定のセーブを行う
  def self.save_config(config_file, config)
    File.write(config_file, JSON.pretty_generate(config), encoding: 'utf-8')
  end

  # 時刻チェック
  def self.check_time(config_file)
    now = DateTime.now.strftime('%H:%M')
    config = load_config(config_file)

    if config['beforeStart'] && now == config['beforeStartTime']
      show_tasks('before')
    elsif now == config['startTime']
      show_tasks('start')
    elsif now == config['endTime']
      show_tasks('end')
    end
  end

  # タスク表示処理
  def self.show_tasks(tasks)
    # GTKウィンドウを作成
    window = Gtk::Window.new
    window.set_title('タスクリスト')
    window.set_default_size(400, 300)

    # ツリービューを作成
    treeview = Gtk::TreeView.new
    treeview.set_headers_visible(true)

    # カラムを追加
    %W[\u540D\u524D \u5185\u5BB9 \u5B8C\u4E86].each_with_index do |title, index|
      renderer = Gtk::CellRendererText.new
      column = Gtk::TreeViewColumn.new(title, renderer, text: index)
      treeview.append_column(column)
    end

    # リストストアを作成
    list_store = Gtk::ListStore.new(String, String, String)
    tasks.each do |task|
      iter = list_store.append
      iter[0] = task['name']
      iter[1] = task['text']
      iter[2] = task['checked'] ? '完了' : ''
    end
    treeview.model = list_store

    # レイアウトを設定
    scrolled_window = Gtk::ScrolledWindow.new
    scrolled_window.add(treeview)
    window.add(scrolled_window)

    # ウィンドウを表示
    window.signal_connect('destroy') { Gtk.main_quit }
    window.show_all
    Gtk.main
  end

  # アプリを開く
  def self.open_app(app_path)
    Open3.popen3(app_path)
  end

  # ブラウザを開く
  def self.open_url(url)
    Launchy.open(url)
  end
end
