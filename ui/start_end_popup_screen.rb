require 'gtk3'

# ############################# #
# 　　Start-End PopUP！画面のUI
# ############################# #
class StartEndPopUpScreen
  def initialize(app)
    @app = app
    @start_end_popup_screen = Gtk::Window.new
    @start_end_popup_screen.set_title('Start-End Pop Up!')
    @start_end_popup_screen.set_default_size(610, 610)
    @start_end_popup_screen.set_window_position(:center)
    @start_end_popup_screen.set_keep_above(true) # 最前面に表示

    create_widgets
    @start_end_popup_screen.show_all
  end

  def create_widgets
    # メインコンテナ
    vbox = Gtk::Box.new(:vertical, 10)
    vbox.margin = 10
    @start_end_popup_screen.add(vbox)

    # 画像の表示
    image_path = File.expand_path('../img/Start-EndPopUp.png', __dir__)
    if File.exist?(image_path)
      guide_image = Gtk::Image.new(file: image_path)
      vbox.pack_start(guide_image, expand: true, fill: true, padding: 40)
    else
      error_label = Gtk::Label.new('画像が見つかりません')
      vbox.pack_start(error_label, expand: true, fill: true, padding: 40)
      log_error("画像が見つかりません: #{image_path}")
    end

    # ボタンのコンテナ
    button_box = Gtk::Box.new(:horizontal, 10)
    vbox.pack_start(button_box, expand: false, fill: false, padding: 20)

    # 設定ボタン
    settings_button = Gtk::Button.new(label: '⚙')
    if @app.respond_to?(:show_setting_screen)
      settings_button.signal_connect('clicked') { @app.show_setting_screen }
    else
      settings_button.sensitive = false
      log_error('show_setting_screen メソッドが見つかりません')
    end
    button_box.pack_start(settings_button, expand: true, fill: true, padding: 10)

    # OKボタン
    ok_button = Gtk::Button.new(label: 'OK')
    ok_button.signal_connect('clicked') { destroy }
    button_box.pack_start(ok_button, expand: true, fill: true, padding: 10)
  end

  def destroy
    @start_end_popup_screen.destroy
  end

  private

  def log_error(message)
    puts "エラー: #{message}" # 必要に応じてログファイルに記録する処理を追加
  end
end
