import os
import sys
import json

from PySide6.QtCore import Qt, QSize, QUrl, QStandardPaths, QTimer
from PySide6.QtGui import QKeySequence, QShortcut, QIcon, QBrush, QColor, QPixmap
from PySide6.QtWidgets import (
    QApplication,
    QMainWindow,
    QWidget,
    QVBoxLayout,
    QHBoxLayout,
    QPushButton,
    QTextEdit,
    QTreeWidget,
    QTreeWidgetItem,
    QFileDialog,
    QLabel,
    QSplitter,
    QDialog,
    QDialogButtonBox,
    QLineEdit,
    QMessageBox,
    QStyle,
    QSystemTrayIcon,
)
from PySide6.QtMultimedia import QMediaPlayer, QAudioOutput

# --- Configuraciones por defecto ---
DEFAULT_EXTENSIONS = ('.java', '.py', '.sh', '.md', '.js',
                      '.txt', '.css', '.cpp', '.c', '.html', '.xml')
# Diccionario de colores para algunos tipos de fichero
EXT_COLORS = {
    '.py': "#4EC9B0",
    '.java': "#B07219",
    '.sh': "#6A9955",
    '.md': "#CCCCCC",
    '.js': "#F1E05A",
    '.txt': "#D4D4D4",
    '.css': "#563D7C",
    '.cpp': "#00599C",
    '.c': "#555555",
    '.html': "#E34C26",
    '.xml': "#0060AC"
}

# --- DiÃ¡logo para editar informaciÃ³n del proyecto y extensiones ---


class ProjectInfoDialog(QDialog):
    def __init__(self, project_folder, current_info, current_exts, parent=None):
        super().__init__(parent)
        self.setWindowTitle("InformaciÃ³n del proyecto")
        self.resize(600, 500)
        self.project_folder = project_folder

        # Ãrea para la informaciÃ³n del proyecto
        self.info_edit = QTextEdit(self)
        self.info_edit.setAcceptRichText(False)
        font = self.info_edit.font()
        font.setPointSize(12)
        self.info_edit.setFont(font)
        self.info_edit.setPlainText(current_info)
        self.info_edit.setPlaceholderText(
            "Introduce informaciÃ³n general del proyecto...")

        # Campo para las extensiones permitidas
        self.ext_label = QLabel(
            "Extensiones permitidas (separadas por comas):", self)
        self.ext_edit = QLineEdit(self)
        self.ext_edit.setText(", ".join(current_exts))

        # Botones OK y Cancel
        self.button_box = QDialogButtonBox(
            QDialogButtonBox.Ok | QDialogButtonBox.Cancel, parent=self)
        self.button_box.accepted.connect(self.accept)
        self.button_box.rejected.connect(self.reject)

        layout = QVBoxLayout(self)
        layout.addWidget(self.info_edit)
        layout.addWidget(self.ext_label)
        layout.addWidget(self.ext_edit)
        layout.addWidget(self.button_box)

    def getValues(self):
        info = self.info_edit.toPlainText()
        exts = [ext.strip().lower()
                for ext in self.ext_edit.text().split(",") if ext.strip()]
        exts = [ext if ext.startswith('.') else f'.{ext}' for ext in exts]
        return info, exts

# --- Main Window ---


class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Generador de Prompt")
        self.resize(900, 700)

        # Variables del proyecto
        self.project_folder = None
        self.project_info = ""
        self.allowed_exts = list(DEFAULT_EXTENSIONS)
        self.file_word_counts = {}  # filepath -> word count

        # Preparar reproductor de sonido
        self.player = QMediaPlayer(self)
        self.audio_output = QAudioOutput(self)
        self.player.setAudioOutput(self.audio_output)

        # Sistema de notificaciones con icono en la bandeja
        self.tray_icon = QSystemTrayIcon(self)
        self.tray_icon.setIcon(
            self.style().standardIcon(QStyle.SP_ComputerIcon))
        self.tray_icon.show()

        # Widget central y layout principal
        central = QWidget(self)
        self.setCentralWidget(central)
        main_layout = QVBoxLayout(central)
        main_layout.setContentsMargins(5, 5, 5, 5)

        # --- Barra superior con botones (iconos y mayor tamaÃ±o) ---
        self.btn_open = QPushButton("Abrir proyecto")
        self.btn_info = QPushButton("InformaciÃ³n del proyecto")
        self.btn_clear = QPushButton("Eliminar selecciÃ³n de ficheros")
        self.btn_generate = QPushButton("GENERAR PROMPT")

        style = self.style()
        self.btn_open.setIcon(style.standardIcon(QStyle.SP_DirIcon))
        self.btn_info.setIcon(style.standardIcon(
            QStyle.SP_MessageBoxInformation))
        self.btn_clear.setIcon(style.standardIcon(
            QStyle.SP_DialogCancelButton))
        # Usamos un icono estÃ¡ndar para representar el "lanzamiento" (como cohete)
        self.btn_generate.setIcon(style.standardIcon(QStyle.SP_ArrowRight))

        for btn in [self.btn_open, self.btn_info, self.btn_clear]:
            btn.setIconSize(QSize(32, 32))
            btn.setMinimumHeight(40)
            font = btn.font()
            font.setPointSize(12)
            btn.setFont(font)
        self.btn_generate.setIconSize(QSize(32, 32))
        self.btn_generate.setMinimumHeight(45)
        font = self.btn_generate.font()
        font.setPointSize(12)
        self.btn_generate.setFont(font)

        top_bar = QHBoxLayout()
        left_layout = QHBoxLayout()
        left_layout.setSpacing(12)
        left_layout.addWidget(self.btn_open)
        left_layout.addWidget(self.btn_info)
        left_layout.addWidget(self.btn_clear)
        top_bar.addLayout(left_layout)
        top_bar.addStretch()
        top_bar.addWidget(self.btn_generate)
        top_bar.addStretch()
        main_layout.addLayout(top_bar)

        # --- Ãrea dividida con QSplitter (vertical) ---
        self.prompt_text = QTextEdit()
        self.prompt_text.setPlaceholderText(
            "Introduce aquÃ­ el prompt de usuario...")
        self.prompt_text.setAcceptRichText(False)
        font = self.prompt_text.font()
        font.setPointSize(12)
        self.prompt_text.setFont(font)
        self.tree_files = QTreeWidget()
        self.tree_files.setHeaderLabel(
            "Ficheros para incluir en el contexto del prompt")
        self.tree_files.setSelectionMode(QTreeWidget.ExtendedSelection)
        splitter = QSplitter(Qt.Vertical)
        splitter.addWidget(self.prompt_text)
        splitter.addWidget(self.tree_files)
        splitter.setStretchFactor(0, 1)
        splitter.setStretchFactor(1, 2)
        main_layout.addWidget(splitter)

        # --- Barra de estado ---
        self.status_bar_label = QLabel(
            "Ficheros seleccionados: 0   LÃ­neas de cÃ³digo: 0   Tokens estimados: 0")
        main_layout.addWidget(self.status_bar_label)

        # Conectar botones y eventos
        self.btn_open.clicked.connect(self.open_project)
        self.btn_info.clicked.connect(self.edit_project_info)
        self.btn_clear.clicked.connect(self.clear_file_selection)
        self.btn_generate.clicked.connect(self.generate_prompt)
        self.tree_files.itemSelectionChanged.connect(self.update_status)
        self.prompt_text.textChanged.connect(self.update_status)
        QShortcut(QKeySequence("Ctrl+Return"), self,
                  activated=self.generate_prompt)

        # Cargar automÃ¡ticamente el proyecto si hay un iapt.json en el mismo directorio que el script
        local_dir = os.path.dirname(os.path.abspath(sys.argv[0]))
        info_path = os.path.join(local_dir, "iapt.json")
        if os.path.exists(info_path):
            self.project_folder = local_dir
            try:
                with open(info_path, "r", encoding="utf-8") as f:
                    data = json.load(f)
                self.project_info = data.get("info_proyecto", "")
                self.allowed_exts = data.get("extensiones", self.allowed_exts)
            except Exception:
                pass
            self.build_file_tree()
            self.update_status()

    def show_temporary_popup(self, message, duration=2000):
        popup = QDialog(self)
        popup.setWindowFlags(
            Qt.Tool | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint)
        popup.setAttribute(Qt.WA_TranslucentBackground)
        popup.setAttribute(Qt.WA_DeleteOnClose)
        popup.setModal(False)

        layout = QVBoxLayout(popup)
        layout.setContentsMargins(10, 10, 10, 10)

        label = QLabel(message)
        label.setStyleSheet("""
            QLabel {
                background-color: #333;
                color: #fff;
                border: 1px solid #ffaa00;
                padding: 10px;
                font-size: 14px;
                border-radius: 8px;
            }
        """)
        layout.addWidget(label)

        popup.adjustSize()
        popup.move(
            self.geometry().center().x() - popup.width() // 2,
            self.geometry().top() + 50
        )
        popup.show()
        QTimer.singleShot(duration, popup.close)

    def open_project(self):
        desktop = QStandardPaths.writableLocation(
            QStandardPaths.DesktopLocation)
        folder = QFileDialog.getExistingDirectory(
            self, "Seleccione el directorio del proyecto", desktop)
        if folder:
            self.project_folder = folder
            self.file_word_counts = {}
            self.project_info = ""
            info_path = os.path.join(folder, "iapt.json")
            if os.path.exists(info_path):
                try:
                    with open(info_path, "r", encoding="utf-8") as f:
                        data = json.load(f)
                    self.project_info = data.get("info_proyecto", "")
                    self.allowed_exts = data.get(
                        "extensiones", self.allowed_exts)
                except Exception:
                    pass
            self.build_file_tree()
            self.update_status()

    def build_file_tree(self):
        self.tree_files.clear()
        if not self.project_folder:
            return
        root_item = QTreeWidgetItem(
            self.tree_files, [os.path.basename(self.project_folder)])
        root_item.setData(0, Qt.UserRole, self.project_folder)
        self.add_tree_items(root_item, self.project_folder)
        if root_item.childCount() > 0:
            self.tree_files.expandItem(root_item)

    def directory_contains_allowed(self, path):
        try:
            for item in os.listdir(path):
                full_path = os.path.join(path, item)
                if os.path.isdir(full_path):
                    if self.directory_contains_allowed(full_path):
                        return True
                else:
                    ext = os.path.splitext(item)[1].lower()
                    if ext in self.allowed_exts:
                        return True
        except Exception:
            pass
        return False

    def add_tree_items(self, parent_item, path):
        try:
            items = sorted(os.listdir(path))
        except Exception:
            return
        for item in items:
            full_path = os.path.join(path, item)
            if os.path.isdir(full_path):
                if self.directory_contains_allowed(full_path):
                    dir_item = QTreeWidgetItem(parent_item, [item])
                    dir_item.setData(0, Qt.UserRole, full_path)
                    self.add_tree_items(dir_item, full_path)
            else:
                ext = os.path.splitext(item)[1].lower()
                if ext in self.allowed_exts:
                    file_item = QTreeWidgetItem(parent_item, [item])
                    file_item.setData(0, Qt.UserRole, full_path)
                    try:
                        with open(full_path, "r", encoding="utf-8") as f:
                            content = f.read()
                        word_count = len(content.split())
                    except Exception:
                        word_count = 0
                    self.file_word_counts[full_path] = word_count
                    color = EXT_COLORS.get(ext, "#D4D4D4")
                    file_item.setForeground(0, QBrush(QColor(color)))

    def edit_project_info(self):
        if not self.project_folder:
            QMessageBox.information(
                self, "InformaciÃ³n", "Primero debes abrir un proyecto.")
            return

        info_path = os.path.join(self.project_folder, "iapt.json")
        current_info = ""
        current_exts = self.allowed_exts
        if os.path.exists(info_path):
            try:
                with open(info_path, "r", encoding="utf-8") as f:
                    data = json.load(f)
                current_info = data.get("info_proyecto", "")
                current_exts = data.get("extensiones", self.allowed_exts)
            except Exception:
                pass

        dlg = ProjectInfoDialog(self.project_folder,
                                current_info, current_exts, self)
        if dlg.exec():
            new_info, new_exts = dlg.getValues()
            self.project_info = new_info
            self.allowed_exts = new_exts
            data = {"info_proyecto": self.project_info,
                    "extensiones": self.allowed_exts}
            try:
                with open(info_path, "w", encoding="utf-8") as f:
                    json.dump(data, f, indent=4)
            except Exception as e:
                QMessageBox.warning(
                    self, "Error", f"No se pudo guardar la informaciÃ³n:\n{e}")
            self.build_file_tree()
            self.update_status()

    def clear_file_selection(self):
        self.tree_files.clearSelection()
        self.update_status()

    def update_status(self):
        selected_items = self.tree_files.selectedItems()
        file_count = 0
        code_lines = 0

        for item in selected_items:
            full_path = item.data(0, Qt.UserRole)
            if full_path in self.file_word_counts:
                file_count += 1
                try:
                    with open(full_path, "r", encoding="utf-8") as f:
                        lines = f.readlines()
                    code_lines += len(lines)
                except Exception:
                    pass

        prompt_words = len(self.prompt_text.toPlainText().split())
        project_info_words = len(self.project_info.split())

        # Estimaciones
        tokens_text = int(1.4 * (prompt_words + project_info_words))
        tokens_code = code_lines * 8
        total_tokens = tokens_text + tokens_code

        self.status_bar_label.setText(
            f"Ficheros seleccionados: {file_count}   LÃ­neas de cÃ³digo: {
                code_lines}   Tokens estimados: {total_tokens}"
        )

    def play_sound(self):
        sound_path = "iapt.mp3"
        if os.path.exists(sound_path):
            self.player.setSource(QUrl.fromLocalFile(
                os.path.abspath(sound_path)))
            self.player.play()
        else:
            self.tray_icon.showMessage(
                "NotificaciÃ³n", "No se encontrÃ³ iapt.mp3 para reproducir sonido", msecs=2000)

    def generate_prompt(self):
        if not self.project_folder:
            QMessageBox.information(
                self, "InformaciÃ³n", "Primero debes abrir un proyecto.")
            return

        prompt_text = self.prompt_text.toPlainText()
        selected_items = self.tree_files.selectedItems()
        file_contents = ""
        for item in selected_items:
            full_path = item.data(0, Qt.UserRole)
            if full_path in self.file_word_counts:
                try:
                    with open(full_path, "r", encoding="utf-8") as f:
                        content = f.read()
                except Exception:
                    content = "[Error al leer el fichero]"
                file_name = os.path.basename(full_path)
                file_contents += f"\n---------- Fichero {
                    file_name} ----------\n{content}\n"

        project_name = os.path.basename(self.project_folder)
        generated = f"""{prompt_text}
----------
A continuaciÃ³n tienes informaciÃ³n general del proyecto, y el cÃ³digo actualizado de las partes relacionadas con lo que te estoy pidiendo:
---------- Proyecto: {project_name} ----------
{self.project_info}
{file_contents}
"""
        QApplication.clipboard().setText(generated)
        self.play_sound()
        self.update_status()
        self.show_temporary_popup("Prompt copiado al portapapeles", 2000)


def main():
    app = QApplication(sys.argv)
    dark_style = """QMainWindow {
    background-color: #1b1b1b;
}
QWidget {
    background-color: #2b2b2b;
    color: #d3d3d3;
}
QTextEdit, QTreeWidget, QLineEdit {
    background-color: #2c2f31;
    color: #d3d3d3;
    border: 1px solid #555555;
}
QPushButton {
    background-color: #777777;
    color: #1b1b1b;
    border: 1px solid #222222;
    padding: 8px;
}
QPushButton:hover {
    background-color: #999999;
}
QLabel {
    font-size: 13px;  /* Para "Extensiones permitidas" y status bar */
}
QStatusBar QLabel {
    font-size: 13px;
}
QHeaderView::section {
    background-color: #2b2b2b;
    color: #aaaaaa;  /* TÃ­tulo del QTreeWidget */
    padding: 4px;
    border: 1px solid #444;
}

QTreeWidget::item:selected {
    background-color: #ff8c00;
    color: #2b2b2b;
}

/* Scrollbars (moderno, sin rayas) */
QScrollBar:vertical {
    background: #2b2b2b;
    width: 12px;
    margin: 0px;
    border: none;
}
QScrollBar::handle:vertical {
    background: #5c5c5c;
    min-height: 20px;
    border-radius: 6px;
}
QScrollBar::handle:vertical:hover {
    background: #aaaaaa;
}
QScrollBar::add-line:vertical,
QScrollBar::sub-line:vertical,
QScrollBar::add-page:vertical,
QScrollBar::sub-page:vertical {
    background: none;
    height: 0px;
}

QScrollBar:horizontal {
    background: #2b2b2b;
    height: 12px;
    margin: 0px;
    border: none;
}
QScrollBar::handle:horizontal {
    background: #5c5c5c;
    min-width: 20px;
    border-radius: 6px;
}
QScrollBar::handle:horizontal:hover {
    background: #aaaaaa;
}
QScrollBar::add-line:horizontal,
QScrollBar::sub-line:horizontal,
QScrollBar::add-page:horizontal,
QScrollBar::sub-page:horizontal {
    background: none;
    width: 0px;
}
"""
    app.setStyleSheet(dark_style)
    window = MainWindow()
    window.show()
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
