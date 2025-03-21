require 'tk'
require 'tk/ttk'

# ##################### #
# 　　案内画面のUI
# ##################### #
class GuideScreen
  def initialize(root, app)
    @root = root
    @app = app
    @guide_screen = TkToplevel.new(@root)
    @guide_screen.title('どんなアプリ？')
    @guide_screen.geometry('710x620')
    @guide_screen.attributes('-topmost', true)

    create_widgets
  end

  def create_widgets
    guide_image = TkPhotoImage.new(file: '../img/guide_image.png')
    guide_label = TkLabel.new(@guide_screen, image: guide_image)
    guide_label.pack

    ok_button = Tk::Button.new(@guide_screen, text: 'OK', command: proc { @app.process_guide_ok })
    ok_button.pack(pady: 20)
  end

  def destroy
    @guide_screen.destroy
  end
end