require 'Gtk3'

# ##################### #
# 　　リスト画面のUI
# ##################### #
class ListScreen
  def initialize(root, app)
    @root = root
    @app = app
    @list_screen = TkToplevel.new(@root)
    @list_screen.title('Todoリスト')
    @list_screen.geometry('600x400')

    create_widgets
    @app.load_tasks
  end

  def create_widgets
    @tree = Tk::Tile::Treeview.new(@list_screen, columns: %w[checked type name text], show: 'headings')
    @tree.heading('checked', text: '完了')
    @tree.heading('type', text: '種別')
    @tree.heading('name', text: '名前')
    @tree.heading('text', text: '内容')
    @tree.pack(padx: 10, pady: 10, fill: 'both', expand: true)

    @perfect_var = TkVariable.new
    perfect_check = Tk::CheckButton.new(@list_screen, text: 'Perfect!', variable: @perfect_var)
    perfect_check.pack(pady: 5)

    ok_button_frame = TkFrame.new(@list_screen)
    ok_button_frame.pack(pady: 10)
    ok_button = Tk::Button.new(ok_button_frame, text: 'OK', command: proc { @app.process_list_ok })
    ok_button.pack

    settings_button = Tk::Button.new(@list_screen, text: '⚙', command: proc { @app.show_setting_screen })
    settings_button.place(x: 10, y: 370)
  end

  def destroy
    @list_screen.destroy
  end
end