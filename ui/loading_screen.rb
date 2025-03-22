require 'Gtk3'

# ##################### #
# 　　Loading画面のUI
# ##################### #
class LoadingScreen
  def initialize(root, app)
    @root = root
    @app = app
    @loading_screen = TkToplevel.new(@root)
    @loading_screen.title('Loading')
    @loading_screen.geometry('610x610')
    @loading_screen.attributes('-topmost', true)

    create_widgets
  end

  def create_widgets
    guide_image = TkPhotoImage.new(file: '../img/loading.png')
    loading_label = TkLabel.new(@loading_screen, image: guide_image)
    loading_label.pack(pady: 40)
  end

  def destroy
    @loading_screen.destroy
  end
end