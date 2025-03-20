import tkinter as tk
from tkinter import ttk
import csv
from datetime import datetime
import json
import subprocess
import tkinter.messagebox
import platform

class StartEndPopUpApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Start-End Pop Up!")

        # 設定ファイルパス
        self.config_file = "config.json"
        # リストファイルパス
        self.list_file = "tasks.csv"

        # UIの作成
        self.create_loading_screen()
        self.root.after(2000, self.show_guide_screen)  # 2秒後に案内画面へ

    def create_loading_screen(self):
        """
        Loading画面を作成する
        """
        self.loading_screen = tk.Toplevel(self.root)
        self.loading_screen.title("Loading")
        self.loading_screen.geometry("200x100")  # サイズは適宜調整
        self.loading_screen.attributes("-topmost", True)  # 最前面に表示

        loading_label = ttk.Label(self.loading_screen, text="Loading...")
        loading_label.pack(pady=40)

    def show_guide_screen(self):
        """
        案内画面を表示する
        """
        self.loading_screen.destroy()  # Loading画面を閉じる
        self.guide_screen = tk.Toplevel(self.root)
        self.guide_screen.title("どんなアプリ？")
        self.guide_screen.geometry("400x300")  # サイズは適宜調整
        self.guide_screen.attributes("-topmost", True)  # 最前面に表示

        # 案内画像の表示 (実際の画像ファイルパスを指定)
        guide_image = tk.PhotoImage(file="../img/guide_image.png")
        guide_label = tk.Label(self.guide_screen, image=guide_image)
        guide_label.pack()

        ok_button = ttk.Button(self.guide_screen, text="OK", command=self.process_guide_ok)
        ok_button.pack(pady=20)

    def process_guide_ok(self):
        """
        案内画面のOKボタンの処理
        """
        config = self.load_config()
        if not config.get("initialized"):
            self.guide_screen.destroy()
            self.show_setting_screen()  # 設定画面を起動
        else:
            config["initialized"] = True
            self.save_config(config)
            self.guide_screen.destroy()
            self.show_start_end_popup_screen()  # Start-End Pop Up！画面を表示

    def show_start_end_popup_screen(self):
        """
        Start-End Pop Up!画面を表示する
        """
        self.start_end_popup_screen = tk.Toplevel(self.root)
        self.start_end_popup_screen.title("Start-End Pop Up!")
        self.start_end_popup_screen.geometry("300x200")  # サイズは適宜調整
        self.start_end_popup_screen.attributes("-topmost", True)  # 最前面に表示

        settings_button = ttk.Button(self.start_end_popup_screen, text="⚙", command=self.show_setting_screen)
        settings_button.pack(side=tk.LEFT, padx=10, pady=20)

        ok_button = ttk.Button(self.start_end_popup_screen, text="OK", command=self.start_end_popup_screen.destroy)
        ok_button.pack(side=tk.RIGHT, padx=10, pady=20)

    def show_list_screen(self):
        """
        リスト画面を表示する
        """
        self.list_screen = tk.Toplevel(self.root)
        self.list_screen.title("Todoリスト")
        self.list_screen.geometry("600x400")  # サイズは適宜調整

        self.create_list_ui()
        self.load_tasks()

    def create_list_ui(self):
        """
        リスト画面のUIを作成する
        """
        # Treeview (リスト表示)
        self.tree = ttk.Treeview(self.list_screen, columns=("type", "name", "text", "checked"), show="headings")
        self.tree.heading("type", text="種別")
        self.tree.heading("name", text="名前")
        self.tree.heading("text", text="内容")
        self.tree.heading("checked", text="完了")
        self.tree.pack(padx=10, pady=10, fill=tk.BOTH, expand=True)

        # Perfect! チェックボックス
        self.perfect_var = tk.BooleanVar()
        perfect_check = ttk.Checkbutton(self.list_screen, text="Perfect!", variable=self.perfect_var)
        perfect_check.pack(pady=5)

        # OKボタン
        ok_button_frame = ttk.Frame(self.list_screen)
        ok_button_frame.pack(pady=10)
        ok_button = ttk.Button(ok_button_frame, text="OK", command=self.process_list_ok)
        ok_button.pack()

        # 設定ボタン
        settings_button = ttk.Button(self.list_screen, text="⚙", command=self.show_setting_screen)
        settings_button.place(x=10, y=370)  # 左下角に配置

    def process_list_ok(self):
        """
        リスト画面のOKボタンの処理
        """
        if not self.perfect_var.get():
            self.show_not_perfect_dialog()
        else:
            self.show_ok_screen()

    def show_not_perfect_dialog(self):
        """
        Perfect!でない場合のダイアログを表示する
        """
        dialog = tk.Toplevel(self.list_screen)
        dialog.title("Perfectじゃないみたい")
        dialog.geometry("200x100")  # サイズは適宜調整

        label = ttk.Label(dialog, text="Perfectじゃないみたい")
        label.pack(pady=10)

        button_frame = ttk.Frame(dialog)
        button_frame.pack(pady=10)

        ok_button = ttk.Button(button_frame, text="大丈夫", command=lambda: [dialog.destroy(), self.list_screen.destroy()])
        ok_button.pack(side=tk.LEFT, padx=5)

        back_button = ttk.Button(button_frame, text="もどってみる", command=dialog.destroy)
        back_button.pack(side=tk.RIGHT, padx=5)

    def show_ok_screen(self):
        """
        Perfect!の場合のOK画面を表示する
        """
        self.ok_screen = tk.Toplevel(self.root)
        self.ok_screen.title("OK")
        self.ok_screen.geometry("300x200")  # サイズは適宜調整

        settings_button = ttk.Button(self.ok_screen, text="⚙", command=self.show_setting_screen)
        settings_button.place(x=10, y=170)  # 左下角に配置

        ok_label = ttk.Label(self.ok_screen, text="OK!", font=("Arial", 36))
        ok_label.pack(pady=20)

        ok_button = ttk.Button(self.ok_screen, text="OK", command=lambda: [self.ok_screen.destroy(), self.list_screen.destroy()])
        ok_button.pack(pady=10)

    def show_setting_screen(self):
        """
        設定画面を表示する
        """
        self.setting_screen = tk.Toplevel(self.root)
        self.setting_screen.title("設定")
        self.setting_screen.geometry("600x500")  # サイズは適宜調整

        self.create_setting_ui()
        self.load_setting_data()

    def create_setting_ui(self):
        """
        設定画面のUIを作成する
        """
        # 始業前起動の利用
        self.before_start_var = tk.BooleanVar()
        before_start_check = ttk.Checkbutton(self.setting_screen, text="始業前起動を利用する", variable=self.before_start_var, command=self.toggle_before_start)
        before_start_check.pack(pady=5)

        # 時刻の選択
        time_frame = ttk.Frame(self.setting_screen)
        time_frame.pack(pady=10)

        ttk.Label(time_frame, text="時刻:").pack(side=tk.LEFT, padx=5)

        self.hour_var = tk.StringVar()
        hour_combo = ttk.Combobox(time_frame, textvariable=self.hour_var, values=[str(i).zfill(2) for i in range(24)], width=3)
        hour_combo.pack(side=tk.LEFT, padx=2)

        ttk.Label(time_frame, text=":").pack(side=tk.LEFT)

        self.minute_var = tk.StringVar()
        minute_combo = ttk.Combobox(time_frame, textvariable=self.minute_var, values=[str(i).zfill(2) for i in range(60)], width=3)
        minute_combo.pack(side=tk.LEFT, padx=2)

        # 選択項目 (ラジオボタン)
        self.time_period = tk.StringVar(value="start")  # 初期値は始業時
        radio_frame = ttk.Frame(self.setting_screen)
        radio_frame.pack(pady=10)

        self.before_button = ttk.Radiobutton(radio_frame, text="始業前", variable=self.time_period, value="before", command=self.update_time_selection)
        self.before_button.pack(side=tk.LEFT, padx=5)

        self.start_button = ttk.Radiobutton(radio_frame, text="始業時", variable=self.time_period, value="start", command=self.update_time_selection)
        self.start_button.pack(side=tk.LEFT, padx=5)

        self.end_button = ttk.Radiobutton(radio_frame, text="終業時", variable=self.time_period, value="end", command=self.update_time_selection)
        self.end_button.pack(side=tk.LEFT, padx=5)

        # 入力欄
        input_frame = ttk.Frame(self.setting_screen)
        input_frame.pack(pady=10)

        self.item_type = tk.StringVar(value="todo")  # 初期値はTodo
        type_frame = ttk.Frame(input_frame)
        type_frame.pack(pady=5)

        todo_radio = ttk.Radiobutton(type_frame, text="Todo", variable=self.item_type, value="todo")
        todo_radio.pack(side=tk.LEFT, padx=5)

        url_radio = ttk.Radiobutton(type_frame, text="URL", variable=self.item_type, value="url")
        url_radio.pack(side=tk.LEFT, padx=5)

        app_radio = ttk.Radiobutton(type_frame, text="アプリ", variable=self.item_type, value="app")
        app_radio.pack(side=tk.LEFT, padx=5)

        ttk.Label(input_frame, text="項目名:").pack(pady=2)
        self.name_entry = ttk.Entry(input_frame, width=40)
        self.name_entry.pack(pady=2)
        self.name_entry.insert(0, "タイトルまたは概要")  # プレースホルダー
        self.name_entry.bind("<FocusIn>", lambda e: self.name_entry.delete(0, tk.END))

        ttk.Label(input_frame, text="テキスト:").pack(pady=2)
        self.text_entry = ttk.Entry(input_frame, width=40)
        self.text_entry.pack(pady=2)
        self.text_entry.insert(0, "内容（任意）")  # プレースホルダー
        self.text_entry.bind("<FocusIn>", lambda e: self.text_entry.delete(0, tk.END))
        self.text_entry.bind("<Shift-Return>", self.add_item)  # Shift+Enterで追加

        add_button = ttk.Button(input_frame, text="+", command=self.add_item)
        add_button.pack(pady=5)

        # リスト表示
        self.list_display_frame = ttk.Frame(self.setting_screen)
        self.list_display_frame.pack(pady=10, padx=10, fill=tk.BOTH, expand=True)

        #  リスト表示用のTreeview
        self.setting_tree = ttk.Treeview(self.list_display_frame, columns=("type", "name", "text"), show="headings")
        self.setting_tree.heading("type", text="種別")
        self.setting_tree.heading("name", text="名前")
        self.setting_tree.heading("text", text="テキスト")
        self.setting_tree.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)

        delete_button = ttk.Button(self.list_display_frame, text="❌", command=self.delete_selected_item)
        delete_button.pack(side=tk.RIGHT, padx=5)

        # 完了ボタン
        complete_button = ttk.Button(self.setting_screen, text="完了", command=self.process_setting_complete)
        complete_button.pack(pady=20)

        # 案内画面起動ボタン
        guide_button = ttk.Button(self.setting_screen, text="?", command=self.show_guide_screen)
        guide_button.place(x=10, y=470)  # 左下角に配置

    def toggle_before_start(self):
        """
        始業前起動の利用チェックボックスの状態変更時の処理
        """
        if self.before_start_var.get():
            self.before_button.config(state=tk.NORMAL)
        else:
            self.before_button.config(state=tk.DISABLED)

    def update_time_selection(self):
        """
        始業前、始業時、終業時の選択項目クリック時の処理
        """
        config = self.load_config()
        selected_time_period = self.time_period.get()

        if selected_time_period == "before":
            self.before_button.config(state=tk.NORMAL)
            start_time = config.get("startTime", "09:00")  # デフォルト値を設定
            before_time = self.calculate_before_time(start_time)
            self.hour_var.set(before_time[:2])
            self.minute_var.set(before_time[3:])
        elif selected_time_period == "start":
            start_time = config.get("startTime", "09:00")  # デフォルト値を設定
            self.hour_var.set(start_time[:2])
            self.minute_var.set(start_time[3:])
        elif selected_time_period == "end":
            end_time = config.get("endTime", "18:00")  # デフォルト値を設定
            self.hour_var.set(end_time[:2])
            self.minute_var.set(end_time[3:])

        self.populate_list_display()  # リスト表示を更新

    def calculate_before_time(self, start_time):
        """
        始業前時刻を計算する
        """
        start_datetime = datetime.strptime(start_time, "%H:%M")
        before_datetime = start_datetime.replace(minute=max(start_datetime.minute - 5, 0))
        return before_datetime.strftime("%H:%M")

    def add_item(self):
        """
        入力欄の内容をリストファイルに書き込む
        """
        name = self.name_entry.get()
        text = self.text_entry.get()
        item_type = self.item_type.get()

        # エラーとなりうる半角記号と空白を全角に変換
        name = self.convert_to_zenkaku(name)
        text = self.convert_to_zenkaku(text)

        # 項目名とテキストが両方空欄または空白の場合は書き込み処理を行わない
        if not name.strip() or not text.strip():
            return

        with open(self.list_file, "a", newline="", encoding="utf-8")