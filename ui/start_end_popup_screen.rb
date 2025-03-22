require 'Gtk3'

# ############################# #
# 　　Start-End PopUP！画面のUI
# ############################# #
class StartEndPopUpScreen
  def initialize(root, app)
    @root = root
    @app = app
    @start_end_popup_screen = TkToplevel.new(@root)
    @start_end_popup_screen.title('Start-End Pop Up!')
    @start_end_popup_screen.geometry('610x610')
    @start_end_popup_screen.attributes('-topmost', true)

    create_widgets
  end

  def create_widgets
    guide_image = TkPhotoImage.new(file: '../img/Start-EndPopUp.png')
    loading_label = TkLabel.new(@loading_screen, image: guide_image)
    loading_label.pack(pady: 40)
    
    settings_button = Tk::Button.new(@start_end_popup_screen, text: '⚙', command: proc { @app.show_setting_screen })
    settings_button.pack(side: 'left', padx: 10, pady: 20)

    ok_button = Tk::Button.new(@start_end_popup_screen, text: 'OK', command: proc { destroy })
    ok_button.pack(side: 'right', padx: 10, pady: 20)
  end

  def destroy
    @start_end_popup_screen.destroy
  end
end