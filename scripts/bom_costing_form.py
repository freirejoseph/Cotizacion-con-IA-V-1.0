from __future__ import annotations

import ctypes
import os
import re
import subprocess
import tempfile
import tkinter as tk
from pathlib import Path
import sys
from threading import Thread
from tkinter import messagebox, scrolledtext, ttk


PROJECT_ROOT = Path(__file__).resolve().parents[1]
SRC_PATH = PROJECT_ROOT / "src"
for path in (PROJECT_ROOT, SRC_PATH):
    if str(path) not in sys.path:
        sys.path.insert(0, str(path))

from cotizador_ia.bom_costing import (
    calculate_stock_cost,
    calculate_tree_cost,
    format_report,
    format_tree_report,
    get_master,
    get_product_class_description,
    get_work_centre,
)


WIN_BG = "#d7e7fb"
BAR_BG = "#c4daf8"
BAR_TOP = "#dbe9ff"
PANEL_BG = "#edf4ff"
PANEL_BORDER = "#88a9d8"
GRID_HEADER = "#edf3fe"
GRID_ALT = "#f8fbff"
FIELD_BG = "#fff6c9"
READONLY_BG = "#ffffff"
TEXT_DARK = "#17365d"
STATUS_BG = "#eef5ff"


class EstimacionesApp(tk.Tk):
    def __init__(self) -> None:
        super().__init__()
        self.title("Estimaciones")
        self.geometry("1600x930")
        self.minsize(1280, 760)
        self.configure(bg=WIN_BG)

        self.parent_part_var = tk.StringVar(value="9320000432")
        self.description_var = tk.StringVar(value="")
        self.uom_var = tk.StringVar(value="")
        self.mass_var = tk.StringVar(value="")
        self.route_var = tk.StringVar(value="0 - ROUTE 0")
        self.batch_var = tk.StringVar(value="")
        self.ebq_var = tk.StringVar(value="")
        self.warehouse_var = tk.StringVar(value="")
        self.maintain_hierarchies_var = tk.BooleanVar(value=False)
        self.status_var = tk.StringVar(value="Inicializando Estimaciones...")
        self.material_var = tk.StringVar(value="...")
        self.labor_var = tk.StringVar(value="...")
        self.fixed_var = tk.StringVar(value="...")
        self.variable_var = tk.StringVar(value="...")
        self.total_var = tk.StringVar(value="...")
        self._refresh_token = 0
        self.progress_window: tk.Toplevel | None = None
        self.progress_value_var = tk.StringVar(value="0%")
        self.progress_text_var = tk.StringVar(value="Preparando estimación...")
        self.progress_bar: ttk.Progressbar | None = None
        self.current_master: dict[str, object] = {}
        self.current_hierarchy_node: object | None = None
        self.scenario_components: list[dict[str, object]] = []
        self.scenario_operations: list[dict[str, object]] = []
        self.mass_rules: list[dict[str, object]] = []
        self.help_window: tk.Toplevel | None = None
        self._edit_widgets: dict[str, tk.Entry] = {}
        self._scenario_recalc_after_id: str | None = None

        self._build_style()
        self._build_menu()
        self._build_ui()
        self.bind_all("<F1>", self._show_help_window)
        self.maintain_hierarchies_var.trace_add("write", self._on_hierarchy_toggle)
        self.after(150, lambda: self._request_initial_load(silent=True, user_message="Cargando estructura base..."))

    def _build_style(self) -> None:
        style = ttk.Style(self)
        try:
            style.theme_use("clam")
        except tk.TclError:
            pass

        style.configure("App.TFrame", background=WIN_BG)
        style.configure("Chrome.TFrame", background=BAR_BG)
        style.configure("Panel.TFrame", background=PANEL_BG, relief="solid", borderwidth=1)
        style.configure("Header.TLabel", background=BAR_BG, foreground=TEXT_DARK, font=("Segoe UI", 9))
        style.configure("Section.TLabel", background=BAR_BG, foreground=TEXT_DARK, font=("Segoe UI", 9, "bold"))
        style.configure("Value.TLabel", background=READONLY_BG, foreground="#1e1e1e", padding=(6, 2))
        style.configure("Hint.TLabel", background=WIN_BG, foreground="#516b90", font=("Segoe UI", 8))
        style.configure("Status.TLabel", background=STATUS_BG, foreground="#2a446b", font=("Segoe UI", 8))
        style.configure(
            "Syspro.Treeview",
            background="white",
            fieldbackground="white",
            foreground="#111111",
            rowheight=22,
            bordercolor=PANEL_BORDER,
            borderwidth=1,
        )
        style.configure(
            "Syspro.Treeview.Heading",
            background=GRID_HEADER,
            foreground=TEXT_DARK,
            relief="solid",
            borderwidth=1,
            font=("Segoe UI", 8, "bold"),
        )
        style.map("Syspro.Treeview", background=[("selected", "#ffd77b")], foreground=[("selected", "#111111")])
        style.map("Syspro.Treeview.Heading", background=[("active", "#dfeafc")])
        style.configure("Slim.TButton", padding=(6, 2), font=("Segoe UI", 8))
        style.configure("Topbar.TButton", padding=(8, 2), font=("Segoe UI", 8))
        style.configure("Topbar.TCombobox", padding=1)

    def _build_menu(self) -> None:
        menu_bar = tk.Menu(self)

        archivo = tk.Menu(menu_bar, tearoff=False)
        archivo.add_command(label="Cargar base", command=self._on_load_base)
        archivo.add_command(label="Guardar version", command=self._on_save_version)
        archivo.add_separator()
        archivo.add_command(label="Cerrar", command=self.destroy)
        menu_bar.add_cascade(label="Archivo", menu=archivo)

        editar = tk.Menu(menu_bar, tearoff=False)
        editar.add_command(label="Editar nodo", command=lambda: self._placeholder_action("Editar"))
        editar.add_command(label="Reemplazar componente", command=lambda: self._placeholder_action("Reemplazar"))
        menu_bar.add_cascade(label="Editar", menu=editar)

        opciones = tk.Menu(menu_bar, tearoff=False)
        opciones.add_command(label="Estimar", command=self._on_estimate)
        opciones.add_command(label="Jerarquia", command=self._show_hierarchy_report)
        opciones.add_command(label="Actualizar masivo", command=self._open_mass_update_dialog)
        menu_bar.add_cascade(label="Opciones", menu=opciones)

        ayuda = tk.Menu(menu_bar, tearoff=False)
        ayuda.add_command(label="Ayuda de Estimaciones\tF1", command=self._show_help_window)
        menu_bar.add_cascade(label="Ayuda", menu=ayuda)

        self.config(menu=menu_bar)

    def _build_ui(self) -> None:
        container = ttk.Frame(self, padding=6, style="App.TFrame")
        container.pack(fill="both", expand=True)
        container.columnconfigure(0, weight=1)
        container.rowconfigure(2, weight=1)

        self._build_topbar(container)
        self._build_info_strip(container)
        self._build_workspace(container)
        self._build_statusbar(container)

    def _build_topbar(self, parent: ttk.Frame) -> None:
        topbar = tk.Frame(parent, bg=BAR_BG, relief="solid", bd=1)
        topbar.grid(row=0, column=0, sticky="ew")
        for col in (1, 3, 6):
            topbar.grid_columnconfigure(col, weight=0)
        topbar.grid_columnconfigure(9, weight=1)

        tk.Label(topbar, text="Código padre:", bg=BAR_BG, fg=TEXT_DARK, font=("Segoe UI", 8)).grid(
            row=0, column=0, padx=(8, 4), pady=6, sticky="w"
        )
        self._entry(topbar, self.parent_part_var, width=24).grid(row=0, column=1, sticky="w", pady=4)
        self.load_button = ttk.Button(topbar, text="Q", width=3, style="Topbar.TButton", command=self._on_load_base)
        self.load_button.grid(row=0, column=2, padx=(4, 8))

        tk.Label(topbar, text="Ruta:", bg=BAR_BG, fg=TEXT_DARK, font=("Segoe UI", 8)).grid(
            row=0, column=3, padx=(0, 4), sticky="w"
        )
        ttk.Combobox(
            topbar,
            textvariable=self.route_var,
            values=["0 - ROUTE 0", "1 - ROUTE 1"],
            width=20,
            state="readonly",
            style="Topbar.TCombobox",
        ).grid(row=0, column=4, sticky="w")

        tk.Checkbutton(
            topbar,
            text="Maintain hierarchies",
            variable=self.maintain_hierarchies_var,
            bg=BAR_BG,
            fg="#6f7f95",
            activebackground=BAR_BG,
        ).grid(
            row=0, column=5, padx=(12, 8), sticky="w"
        )
        self.hierarchy_button = ttk.Button(topbar, text="Jerarquía", style="Topbar.TButton", command=self._show_hierarchy_report)
        self.hierarchy_button.grid(row=0, column=6, padx=(0, 4))
        self.estimate_button = ttk.Button(topbar, text="Estimar", style="Topbar.TButton", command=self._on_estimate)
        self.estimate_button.grid(row=0, column=7, padx=(12, 4))
        self.mass_update_button = ttk.Button(
            topbar,
            text="Actualizar",
            style="Topbar.TButton",
            command=self._open_mass_update_dialog,
        )
        self.mass_update_button.grid(row=0, column=8, padx=(0, 8))
        tk.Label(
            topbar,
            text="Campos amarillos = editables",
            bg=BAR_BG,
            fg="#40628d",
            font=("Segoe UI", 8, "italic"),
        ).grid(row=0, column=9, sticky="e", padx=(8, 10))

    def _build_info_strip(self, parent: ttk.Frame) -> None:
        strip = ttk.Frame(parent, style="App.TFrame")
        strip.grid(row=1, column=0, sticky="ew", pady=(6, 6))
        strip.columnconfigure(0, weight=1)
        strip.columnconfigure(1, weight=1)

        left = self._panel(strip, "Parent Information")
        left.grid(row=0, column=0, sticky="nsew", padx=(0, 3))
        self._form_row(left.body, 0, "Código padre", self.parent_part_var, editable=False)
        self._form_row(left.body, 1, "Descripción", self.description_var, editable=False)
        self._form_row(left.body, 2, "Unidad medida", self.uom_var, editable=False)
        self._form_row(left.body, 3, "Peso unitario (Mass)", self.mass_var, editable=False)
        self._form_row(left.body, 4, "Lote estimación", self.batch_var, editable=True, field_name="batch")
        self._form_row(left.body, 5, "EBQ", self.ebq_var, editable=False)
        self._form_row(left.body, 6, "Warehouse", self.warehouse_var, editable=False)

        right = self._panel(strip, "Estimate Parent Details")
        right.grid(row=0, column=1, sticky="nsew", padx=(3, 0))
        right.body.columnconfigure(0, weight=1)
        right.body.rowconfigure(0, weight=1)
        self._build_cost_strip(right.body, 0)

    def _build_workspace(self, parent: ttk.Frame) -> None:
        workspace = ttk.Panedwindow(parent, orient="horizontal")
        workspace.grid(row=2, column=0, sticky="nsew")

        left_panel = self._panel(workspace, "Estimación")
        left_panel.body.columnconfigure(0, weight=1)
        left_panel.body.rowconfigure(1, weight=1)
        workspace.add(left_panel, weight=34)

        self._build_tree_toolbar(left_panel.body)
        self.tree = ttk.Treeview(
            left_panel.body,
            columns=("udm", "tipo", "total"),
            show="tree headings",
            style="Syspro.Treeview",
            selectmode="browse",
            height=18,
        )
        self.tree.heading("#0", text="Estructura")
        self.tree.heading("udm", text="")
        self.tree.heading("tipo", text="Clasificación")
        self.tree.heading("total", text="Costo")
        self.tree.column("#0", width=260, stretch=True)
        self.tree.column("udm", width=45, anchor="center")
        self.tree.column("tipo", width=110, anchor="w")
        self.tree.column("total", width=80, anchor="e")
        self.tree.grid(row=1, column=0, sticky="nsew")
        self._load_tree()

        right_split = ttk.Panedwindow(workspace, orient="vertical")
        workspace.add(right_split, weight=66)

        ops_panel = self._panel(right_split, "Operaciones")
        ops_panel.body.columnconfigure(0, weight=1)
        ops_panel.body.rowconfigure(1, weight=1)
        right_split.add(ops_panel, weight=56)
        self._panel_toolbar(
            ops_panel.body,
            (
                ("Agregar", self._add_operation),
                ("Editar", self._edit_selected_operation),
                ("Eliminar", self._delete_selected_operation),
            ),
        ).grid(
            row=0, column=0, sticky="ew", pady=(0, 4)
        )
        self.operations = ttk.Treeview(
            ops_panel.body,
            columns=("oper", "wc", "wc_desc", "rate_ind", "run", "cycle", "setup", "startup", "teardown", "sub", "labor", "fixed", "variable", "total"),
            show="headings",
            style="Syspro.Treeview",
        )
        for key, title, width, anchor in [
            ("oper", "Op", 45, "center"),
            ("wc", "Work center", 90, "center"),
            ("wc_desc", "Description", 170, "w"),
            ("rate_ind", "Rate ind", 60, "center"),
            ("run", "Run time", 78, "e"),
            ("cycle", "Ciclo", 78, "e"),
            ("setup", "Setup time", 82, "e"),
            ("startup", "Startup time", 88, "e"),
            ("teardown", "Teardown time", 98, "e"),
            ("sub", "Sub-contracted", 98, "e"),
            ("labor", "Labor and set-up", 112, "e"),
            ("fixed", "Fixed overhead", 105, "e"),
            ("variable", "Variable overhead", 115, "e"),
            ("total", "Total cost", 90, "e"),
        ]:
            self.operations.heading(key, text=title)
            self.operations.column(key, width=width, anchor=anchor)
        self.operations.grid(row=1, column=0, sticky="nsew")
        ops_scroll = ttk.Scrollbar(ops_panel.body, orient="vertical", command=self.operations.yview)
        ops_scroll.grid(row=1, column=1, sticky="ns")
        self.operations.configure(yscrollcommand=ops_scroll.set)
        self.operations.bind("<Double-1>", self._on_operations_double_click)
        comp_panel = self._panel(right_split, "Componentes")
        comp_panel.body.columnconfigure(0, weight=1)
        comp_panel.body.rowconfigure(1, weight=1)
        right_split.add(comp_panel, weight=44)
        self._panel_toolbar(
            comp_panel.body,
            (
                ("Agregar", self._add_component),
                ("Editar", self._edit_selected_component),
                ("Eliminar", self._delete_selected_component),
            ),
        ).grid(
            row=0, column=0, sticky="ew", pady=(0, 4)
        )
        self.components = ttk.Treeview(
            comp_panel.body,
            columns=("seq", "padre", "parte", "desc", "stock", "qty", "udm", "cat", "unit_cost", "total"),
            show="headings",
            style="Syspro.Treeview",
        )
        for key, title, width, anchor in [
            ("seq", "Secuencia", 70, "center"),
            ("padre", "N° parte padre", 120, "w"),
            ("parte", "N° parte", 95, "w"),
            ("desc", "Descripción de parte", 230, "w"),
            ("stock", "Almacén", 90, "w"),
            ("qty", "Cantidad unitaria", 110, "center"),
            ("udm", "UDM", 50, "center"),
            ("cat", "Categoría", 95, "w"),
            ("unit_cost", "Costo unitario", 95, "e"),
            ("total", "Costo total", 95, "e"),
        ]:
            self.components.heading(key, text=title)
            self.components.column(key, width=width, anchor=anchor)
        self.components.grid(row=1, column=0, sticky="nsew")
        comp_scroll = ttk.Scrollbar(comp_panel.body, orient="vertical", command=self.components.yview)
        comp_scroll.grid(row=1, column=1, sticky="ns")
        self.components.configure(yscrollcommand=comp_scroll.set)
        self.components.tag_configure("alt", background=GRID_ALT)
        self.components.bind("<Double-1>", self._on_components_double_click)

    def _build_statusbar(self, parent: ttk.Frame) -> None:
        statusbar = tk.Frame(parent, bg=STATUS_BG, relief="solid", bd=1)
        statusbar.grid(row=3, column=0, sticky="ew", pady=(6, 0))
        statusbar.grid_columnconfigure(0, weight=1)
        ttk.Label(statusbar, textvariable=self.status_var, style="Status.TLabel").grid(row=0, column=0, sticky="w", padx=8, pady=4)
        ttk.Button(statusbar, text="Cerrar", style="Slim.TButton", command=self.destroy).grid(row=0, column=1, sticky="e", padx=6, pady=3)

    def _panel(self, parent: tk.Misc, title: str) -> tk.Frame:
        frame = tk.Frame(parent, bg=PANEL_BORDER, bd=0, highlightthickness=0)
        header = tk.Frame(frame, bg=BAR_BG, height=23, relief="solid", bd=1)
        header.grid(row=0, column=0, sticky="ew")
        header.grid_columnconfigure(0, weight=1)
        tk.Label(header, text=title, bg=BAR_BG, fg=TEXT_DARK, font=("Segoe UI", 8, "bold")).grid(
            row=0, column=0, sticky="w", padx=6, pady=2
        )
        tk.Label(header, text="▾  x", bg=BAR_BG, fg="#446488", font=("Segoe UI", 8)).grid(
            row=0, column=1, sticky="e", padx=6
        )
        body = tk.Frame(frame, bg="white", relief="solid", bd=1)
        body.grid(row=1, column=0, sticky="nsew")
        body.columnconfigure(0, weight=1)
        frame.rowconfigure(1, weight=1)
        frame.columnconfigure(0, weight=1)
        frame.body = body  # type: ignore[attr-defined]
        return frame

    def _form_row(
        self,
        parent: tk.Frame,
        row: int,
        label: str,
        value: str | tk.StringVar,
        *,
        editable: bool,
        multiline: bool = False,
        field_name: str | None = None,
    ) -> None:
        parent.grid_columnconfigure(1, weight=1)
        tk.Label(parent, text=label, bg="white", fg="#48617f", font=("Segoe UI", 8), anchor="w").grid(
            row=row, column=0, sticky="ew", padx=(6, 6), pady=1
        )
        if editable:
            if multiline:
                box = tk.Text(parent, height=3, relief="solid", bd=1, bg=FIELD_BG, font=("Segoe UI", 8))
                box.insert("1.0", value.get() if isinstance(value, tk.StringVar) else value)
                box.grid(row=row, column=1, sticky="ew", padx=(0, 6), pady=1)

                if isinstance(value, tk.StringVar):
                    def sync_note(*_: object) -> None:
                        value.set(box.get("1.0", "end-1c"))

                    box.bind("<KeyRelease>", sync_note)
            else:
                var = value if isinstance(value, tk.StringVar) else tk.StringVar(value=value)
                entry = self._entry(parent, var, width=24)
                entry.grid(row=row, column=1, sticky="ew", padx=(0, 6), pady=1)
                if field_name:
                    self._edit_widgets[field_name] = entry
                    if field_name in {"batch", "ebq"}:
                        entry.bind("<KeyRelease>", lambda _event: self._schedule_scenario_recalc())
                        entry.bind("<Return>", lambda _event: self._apply_scenario_edits())
                        entry.bind("<FocusOut>", lambda _event: self._apply_scenario_edits())
        else:
            label_kwargs = {
                "bg": READONLY_BG,
                "fg": "#1e1e1e",
                "relief": "solid",
                "bd": 1,
                "font": ("Segoe UI", 8),
                "anchor": "w",
                "padx": 6,
                "pady": 2,
            }
            if isinstance(value, tk.StringVar):
                tk.Label(parent, textvariable=value, **label_kwargs).grid(
                    row=row, column=1, sticky="ew", padx=(0, 6), pady=1
                )
            else:
                tk.Label(parent, text=value, **label_kwargs).grid(
                    row=row, column=1, sticky="ew", padx=(0, 6), pady=1
                )

    def _build_cost_strip(self, parent: tk.Frame, row: int) -> None:
        costbar = tk.Frame(parent, bg="#b7cdef", relief="solid", bd=1)
        costbar.grid(row=row, column=0, sticky="nsew", padx=0, pady=0)
        for idx in range(5):
            costbar.grid_columnconfigure(idx, weight=1)
        costbar.grid_rowconfigure(0, weight=1)
        for idx, (title, variable) in enumerate(
            [
                ("Material", self.material_var),
                ("Labor\nand set-up", self.labor_var),
                ("Fixed\nOverhead", self.fixed_var),
                ("Variable\nOverhead", self.variable_var),
                ("Total\ncost", self.total_var),
            ]
        ):
            block = tk.Frame(costbar, bg="#d8e6fb")
            block.grid(row=0, column=idx, sticky="nsew", padx=1, pady=1)
            block.grid_rowconfigure(0, weight=1)
            block.grid_rowconfigure(1, weight=2)
            block.grid_columnconfigure(0, weight=1)
            tk.Label(
                block,
                text=title,
                bg="#d8e6fb",
                fg=TEXT_DARK,
                font=("Segoe UI", 10, "bold"),
                anchor="center",
                justify="center",
            ).grid(row=0, column=0, sticky="nsew", padx=6, pady=(10, 0))
            tk.Label(
                block,
                textvariable=variable,
                bg="#d8e6fb",
                fg="#0d2e55",
                font=("Segoe UI", 18, "bold"),
                anchor="center",
                justify="center",
            ).grid(row=1, column=0, sticky="nsew", padx=6, pady=(0, 10))

    def _build_tree_toolbar(self, parent: tk.Frame) -> None:
        toolbar = tk.Frame(parent, bg="white")
        toolbar.grid(row=0, column=0, sticky="ew", pady=(0, 0))
        ttk.Button(toolbar, text="+", width=3, style="Slim.TButton", command=lambda: self._placeholder_action("Expandir")).pack(side="left", padx=(0, 4))
        ttk.Button(toolbar, text="-", width=3, style="Slim.TButton", command=lambda: self._placeholder_action("Contraer")).pack(side="left", padx=(0, 6))
        tk.Label(toolbar, text="9320000432", bg="white", fg=TEXT_DARK, font=("Segoe UI", 8, "bold")).pack(side="left")

    def _panel_toolbar(self, parent: tk.Frame, actions: tuple[tuple[str, object], ...]) -> tk.Frame:
        toolbar = tk.Frame(parent, bg="white")
        for label, command in actions:
            ttk.Button(toolbar, text=label, style="Slim.TButton", command=command).pack(
                side="left", padx=(0, 4)
            )
        return toolbar

    def _entry(self, parent: tk.Misc, variable: tk.StringVar, width: int) -> tk.Entry:
        return tk.Entry(
            parent,
            textvariable=variable,
            width=width,
            bg=FIELD_BG,
            fg="#1b1b1b",
            relief="solid",
            bd=1,
            font=("Segoe UI", 8),
            insertbackground="#1b1b1b",
        )

    def _fmt_num(self, value: object, decimals: int = 4, *, blank_zero: bool = True) -> str:
        try:
            number = float(value or 0.0)
        except (TypeError, ValueError):
            return str(value or "")
        if blank_zero and abs(number) < 0.0000005:
            return ""
        return f"{number:.{decimals}f}"

    def _r5(self, value: object) -> float:
        try:
            return float(f"{float(value or 0.0):.5f}")
        except (TypeError, ValueError):
            return 0.0

    def _item_value(self, item: object, key: str, default: object = "") -> object:
        if isinstance(item, dict):
            return item.get(key, default)
        return getattr(item, key, default)

    def _clean_report_zeros(self, report: str) -> str:
        return re.sub(r"(?<!\d)-?0\.0{3,6}(?!\d)", lambda match: " " * len(match.group(0)), report)

    def _load_tree(self) -> None:
        for item in self.tree.get_children():
            self.tree.delete(item)

        def insert_nodes(nodes: list[dict[str, object]], parent_id: str = "") -> None:
            for node in nodes:
                item_id = self.tree.insert(parent_id, "end", iid=node["id"], text=node["text"], values=node["values"])
                children = node.get("children", [])
                if children:
                    insert_nodes(children, item_id)

        return

    def _placeholder_action(self, action: str) -> None:
        self.status_var.set(f"Acción '{action}' reservada. En esta fase estamos afinando la apariencia tipo SYSPRO.")

    def _help_sections(self) -> list[dict[str, object]]:
        return [
            {
                "title": "Resumen",
                "summary": "Estimaciones permite simular el costo What-if de un ParentPart no almacenable con la misma lógica ya validada contra el reporte textual. La pantalla visual muestra el detalle del costo, soporta recosteo y permite escenarios sobre materiales, operaciones y reglas masivas.",
                "rows": [
                    ("Código padre", "Parent part", "Parte no almacenable a estimar."),
                    ("Ruta", "Route", "Ruta de fabricación usada por BOM y operaciones."),
                    ("Maintain hierarchies", "Checkbox", "Amplía el detalle visual del árbol sin cambiar la lógica base del total."),
                    ("Jerarquía", "Botón", "Abre el reporte textual del escenario actual."),
                    ("Estimar", "Botón", "Recalcula el escenario con los valores visibles."),
                    ("Actualizar", "Botón", "Aplica reglas masivas sobre componentes."),
                ],
            },
            {
                "title": "Función",
                "summary": "El programa carga la estructura base desde SYSPRO, calcula el costo del ParentPart y presenta el detalle por paneles. Cada cambio editable afecta el escenario actual y recalcula el resumen sin alterar los maestros originales.",
                "rows": [
                    ("InvMaster", "Maestro", "Fuente de Description, Mass, StockUom, Ebq, WarehouseToUse y ProductClass."),
                    ("BomStructure/BOM", "Estructura", "Fuente de componentes y cantidades."),
                    ("BomOperations", "Operaciones", "Fuente de work center y tiempos base."),
                    ("BomWorkCentre", "Tasas", "Fuente de descripción del centro y tasas por Rate ind."),
                    ("What-if", "Lógica", "El costo oficial mostrado sigue la lógica validada contra el reporte de texto."),
                ],
            },
            {
                "title": "Resumen Superior",
                "summary": "Este panel debe leerse como el resumen oficial del escenario actual.",
                "rows": [
                    ("Material", "Costo", "Materiales + cargos tratados como material."),
                    ("Labor and set-up", "Costo", "Mano de obra y tiempos aplicados por operación."),
                    ("Fixed Overhead", "Costo", "Costo fijo de operación."),
                    ("Variable Overhead", "Costo", "Costo variable de operación."),
                    ("Total cost", "Costo", "Suma total del escenario = Material + Labor + Fixed OH + Variable OH."),
                ],
            },
            {
                "title": "Parent Information",
                "summary": "Código padre, Descripción, Unidad medida, Peso unitario, EBQ y Warehouse se cargan del maestro. Lote estimación es editable y permite simular otro tamaño de lote.",
                "rows": [
                    ("Código padre", "InvMaster.StockCode", "Parte a estimar."),
                    ("Descripción", "InvMaster.Description", "Descripción del ParentPart."),
                    ("Unidad medida", "InvMaster.StockUom", "UDM principal del ParentPart."),
                    ("Peso unitario (Mass)", "InvMaster.Mass", "Peso unitario tomado del maestro."),
                    ("Lote estimación", "Escenario", "Lote efectivo editable del cálculo."),
                    ("EBQ", "InvMaster.Ebq", "Economic Batch Quantity del maestro."),
                    ("Warehouse", "InvMaster.WarehouseToUse", "Almacén por defecto del maestro."),
                ],
            },
            {
                "title": "Estimación",
                "summary": "El árbol presenta el ParentPart, sus componentes, subcomponentes y operaciones. Con Maintain hierarchies activado se expande el detalle visual de hijos y nietos.",
                "rows": [
                    ("Estructura", "Árbol", "Código y descripción del nodo."),
                    ("Clasificación", "Tipo", "Nodo padre, componente, subcomponente u operación."),
                    ("Costo", "Escenario", "Costo del nodo mostrado en el escenario actual."),
                    ("Maintain hierarchies OFF", "Modo", "Vista equivalente al What-if de 1 nivel."),
                    ("Maintain hierarchies ON", "Modo", "Vista expandida de hijos y nietos para análisis visual."),
                ],
            },
            {
                "title": "Operaciones",
                "summary": "Aquí se modelan centros de trabajo, tiempos y cargos que impactan el costo. El programa sigue la lógica de tasas de SYSPRO sobre EBQ/lote efectivo.",
                "rows": [
                    ("Work center", "BomOperations.WorkCentre", "Centro de trabajo de la operación."),
                    ("Description", "BomWorkCentre.Description", "Descripción del centro cargada desde maestro."),
                    ("Rate ind", "BomOperations.WcRateInd", "Índice usado para elegir tasas del work center."),
                    ("Run time", "BomOperations.IRunTime", "Tiempo por unidad."),
                    ("Ciclo", "1 / Run time", "Unidades por hora; se muestra si Run time > 0."),
                    ("Setup time", "BomOperations.ISetUpTime", "Tiempo de preparación del lote."),
                    ("Startup time", "BomOperations.IStartupTime", "Tiempo de arranque del lote."),
                    ("Teardown time", "BomOperations.ITeardownTime", "Tiempo de cierre del lote."),
                    ("Sub-contracted", "BomOperations.SubOpUnitValue/SubWhatIfValue", "Cargo subcontratado."),
                    ("Labor and set-up", "Cálculo", "Run*RunRate + Setup*SetUpRate/EBQ + Startup*StartupRate/EBQ + Teardown*TeardownRate/EBQ."),
                    ("Fixed Overhead", "Cálculo", "UnitCapacity * FixOverRate / EBQ."),
                    ("Variable Overhead", "Cálculo", "UnitCapacity * VarOverRate / EBQ."),
                ],
            },
            {
                "title": "Componentes",
                "summary": "Aquí se modelan materiales comprados o fabricados. Puedes editar almacén, cantidad unitaria, categoría y costo unitario del escenario.",
                "rows": [
                    ("N° parte padre", "ParentPart", "Parte padre del nivel mostrado."),
                    ("N° parte", "Component", "Código del componente."),
                    ("Descripción de parte", "InvMaster.Description", "Texto del artículo."),
                    ("Almacén", "Warehouse", "Warehouse del componente."),
                    ("Cantidad unitaria", "Qty per / qty_neta", "Consumo unitario efectivo del escenario."),
                    ("UDM", "InvMaster.StockUom", "Unidad de medida del componente."),
                    ("Categoría", "Escenario", "Adquirido o fabricado."),
                    ("Costo unitario", "Escenario", "Costo unitario editable o ajustado por regla."),
                    ("Costo total", "Cálculo", "Cantidad unitaria * Costo unitario."),
                    ("ProductClass", "InvMaster.ProductClass", "Clase usada para reglas masivas."),
                ],
            },
            {
                "title": "Jerarquía",
                "summary": "Jerarquía muestra en pantalla el reporte textual del árbol o del What-if según el modo activo. Sirve para documentar el detalle del costo y revisar cómo se compone el ParentPart.",
                "rows": [
                    ("Prepared / Version", "Cabecera", "Datos del reporte textual."),
                    ("Component", "Detalle", "Lista de componentes y costos."),
                    ("Work center", "Detalle", "Lista de operaciones y tasas."),
                    ("Total what-if cost", "Resultado", "Total oficial del escenario actual."),
                    ("Imprimir", "Botón", "Abre el diálogo de impresora y envía el texto del reporte."),
                ],
            },
            {
                "title": "Estimar",
                "summary": "Estimar recalcula el escenario completo con los valores visibles en pantalla. Después de estimar, el resumen superior, el árbol y las grillas deben quedar alineados.",
                "rows": [
                    ("Carga base", "Paso", "Lee maestro, BOM y operaciones."),
                    ("Cálculo", "Paso", "Aplica la lógica What-if aprobada."),
                    ("Resumen", "Salida", "Actualiza Material, Labor, Fixed OH, Variable OH y Total."),
                    ("Árbol", "Salida", "Refresca estructura y costos visibles."),
                    ("Grillas", "Salida", "Refresca operaciones y componentes."),
                ],
            },
            {
                "title": "Actualizar",
                "summary": "Actualizar aplica reglas masivas sobre los componentes del escenario. En la versión actual trabaja con ProductClass y modifica el costo unitario por porcentaje.",
                "rows": [
                    ("Filtro", "Tipo", "Campo usado para buscar componentes."),
                    ("ProductClass", "Código", "Clase a buscar dentro del escenario."),
                    ("Descripción", "SalProductClass.Description", "Descripción del ProductClass."),
                    ("Actualizar", "Campo", "Campo económico afectado por la regla."),
                    ("Acción", "Operación", "Aumentar % o Disminuir %."),
                    ("Valor %", "Porcentaje", "Factor porcentual a aplicar."),
                    ("Coincidencias", "Vista previa", "Dónde aparece el ProductClass en Parent > Hijo."),
                ],
            },
            {
                "title": "Aplicación",
                "summary": "Flujo recomendado de trabajo y prueba para el usuario cotizador.",
                "rows": [
                    ("1", "Cargar", "Cargar el ParentPart."),
                    ("2", "Base", "Revisar el costo base."),
                    ("3", "Jerarquía", "Activar jerarquía si necesitas detalle del árbol."),
                    ("4", "Editar", "Editar componentes u operaciones o aplicar una regla masiva."),
                    ("5", "Verificar", "Confirmar el nuevo total y el impacto por nodo."),
                    ("6", "Documentar", "Usar Jerarquía e imprimir si necesitas evidencia."),
                ],
            },
        ]

    def _show_help_window(self, _event: object | None = None) -> str | None:
        if self.help_window is not None and self.help_window.winfo_exists():
            self.help_window.deiconify()
            self.help_window.lift()
            self.help_window.focus_force()
            return "break"

        window = tk.Toplevel(self)
        window.title("Ayuda Estimaciones")
        window.geometry("1260x760")
        window.minsize(1040, 680)
        window.configure(bg="#f7fbff")
        window.transient(self)
        self.help_window = window

        def on_close() -> None:
            self.help_window = None
            window.destroy()

        window.protocol("WM_DELETE_WINDOW", on_close)

        banner = tk.Frame(window, bg="#0b9f1a", height=82)
        banner.pack(fill="x")
        banner.pack_propagate(False)

        banner_inner = tk.Frame(banner, bg="#0b9f1a")
        banner_inner.pack(fill="both", expand=True, padx=18, pady=10)
        tk.Label(
            banner_inner,
            text="SYSPRO",
            bg="#0b9f1a",
            fg="white",
            font=("Segoe UI", 27, "bold"),
        ).pack(side="left")
        tk.Label(
            banner_inner,
            text="Estimaciones",
            bg="#0b9f1a",
            fg="#eefee9",
            font=("Segoe UI", 19, "bold"),
        ).pack(side="left", padx=(18, 0))
        tk.Label(
            banner_inner,
            text="Help",
            bg="#c9f000",
            fg="#2e5200",
            font=("Segoe UI", 10, "bold"),
            padx=12,
            pady=4,
        ).pack(side="right")

        toolbar = tk.Frame(window, bg="#f1f4f8", relief="solid", bd=1)
        toolbar.pack(fill="x")
        for label in ("File", "View", "Topics", "Summary", "Printer Friendly Version"):
            tk.Button(
                toolbar,
                text=label,
                font=("Segoe UI", 8),
                relief="flat",
                bd=0,
                bg="#f1f4f8",
                activebackground="#dce8f8",
                padx=10,
                pady=5,
                command=lambda value=label: self.status_var.set(f"Ayuda abierta: {value}"),
            ).pack(side="left")

        body = tk.Frame(window, bg="#f7fbff")
        body.pack(fill="both", expand=True)
        body.grid_columnconfigure(1, weight=1)
        body.grid_rowconfigure(0, weight=1)

        left = tk.Frame(body, bg="#edf7e7", relief="solid", bd=1, width=225)
        left.grid(row=0, column=0, sticky="nsw")
        left.grid_propagate(False)
        left.grid_rowconfigure(3, weight=1)
        left.grid_columnconfigure(0, weight=1)

        tk.Label(left, text="Search", bg="#dceccf", fg="#274227", font=("Segoe UI", 9, "bold"), anchor="w", padx=8).grid(
            row=0, column=0, sticky="ew"
        )
        tk.Entry(left, font=("Segoe UI", 8), relief="solid", bd=1).grid(row=1, column=0, sticky="ew", padx=8, pady=8)
        tk.Label(left, text="Reference Guides", bg="#dceccf", fg="#274227", font=("Segoe UI", 9, "bold"), anchor="w", padx=8).grid(
            row=2, column=0, sticky="ew"
        )

        nav_host = tk.Frame(left, bg="white", relief="solid", bd=1)
        nav_host.grid(row=3, column=0, sticky="nsew", padx=8, pady=8)
        nav_host.grid_rowconfigure(0, weight=1)
        nav_host.grid_columnconfigure(0, weight=1)

        section_list = tk.Listbox(
            nav_host,
            font=("Segoe UI", 8),
            activestyle="none",
            bd=0,
            highlightthickness=0,
            exportselection=False,
        )
        section_list.grid(row=0, column=0, sticky="nsew")

        center = tk.Frame(body, bg="white", relief="solid", bd=1)
        center.grid(row=0, column=1, sticky="nsew")
        center.grid_columnconfigure(0, weight=1)
        center.grid_rowconfigure(3, weight=1)

        tk.Label(
            center,
            text="Quotations > Quotations Processing > Estimates",
            bg="white",
            fg="#5d7992",
            font=("Segoe UI", 9),
            anchor="w",
            padx=14,
            pady=10,
        ).grid(row=0, column=0, sticky="ew")

        title_var = tk.StringVar(value="")
        tk.Label(
            center,
            textvariable=title_var,
            bg="white",
            fg="#111111",
            font=("Segoe UI", 20, "bold"),
            anchor="w",
            padx=14,
        ).grid(row=1, column=0, sticky="ew")

        summary_box = tk.Text(center, wrap="word", font=("Segoe UI", 10), relief="flat", bd=0, height=7)
        summary_box.grid(row=2, column=0, sticky="ew", padx=14, pady=(0, 10))
        summary_box.configure(bg="white", fg="#1a1a1a", padx=4, pady=4)

        details_host = tk.Frame(center, bg="white")
        details_host.grid(row=3, column=0, sticky="nsew", padx=14, pady=(0, 14))
        details_host.grid_rowconfigure(1, weight=1)
        details_host.grid_columnconfigure(0, weight=1)

        tk.Label(
            details_host,
            text="Estimates",
            bg="white",
            fg="#111111",
            font=("Segoe UI", 13, "bold"),
            anchor="w",
        ).grid(row=0, column=0, sticky="ew", pady=(0, 6))

        details = ttk.Treeview(
            details_host,
            columns=("field", "value", "description"),
            show="headings",
            style="Syspro.Treeview",
            height=18,
        )
        details.heading("field", text="Field")
        details.heading("value", text="Value")
        details.heading("description", text="Description")
        details.column("field", width=180, anchor="w")
        details.column("value", width=170, anchor="w")
        details.column("description", width=680, anchor="w")
        details.grid(row=1, column=0, sticky="nsew")

        detail_scroll = ttk.Scrollbar(details_host, orient="vertical", command=details.yview)
        detail_scroll.grid(row=1, column=1, sticky="ns")
        details.configure(yscrollcommand=detail_scroll.set)

        right = tk.Frame(body, bg="#f7fbff", width=255)
        right.grid(row=0, column=2, sticky="nse")
        right.grid_propagate(False)

        task_box = tk.Frame(right, bg="#f9fff1", relief="solid", bd=1)
        task_box.pack(fill="both", expand=True, padx=(10, 12), pady=20)
        tk.Label(
            task_box,
            text="Tasks",
            bg="#dceccf",
            fg="#274227",
            font=("Segoe UI", 10, "bold"),
            anchor="w",
            padx=8,
            pady=6,
        ).pack(fill="x")

        for task in (
            "Set preferences",
            "Cargar base",
            "Estimar escenario",
            "Ver jerarquía",
            "Agregar operación",
            "Editar componente",
            "Aplicar actualización masiva",
            "Documentar impacto",
        ):
            tk.Label(
                task_box,
                text=f"›  {task}",
                bg="#f9fff1",
                fg="#223922",
                font=("Segoe UI", 9),
                anchor="w",
                padx=10,
                pady=2,
            ).pack(fill="x")

        sections = self._help_sections()
        for topic in sections:
            section_list.insert("end", str(topic["title"]))

        def render(index: int) -> None:
            topic = sections[index]
            title_var.set(str(topic["title"]))
            summary_box.configure(state="normal")
            summary_box.delete("1.0", "end")
            summary_box.insert("1.0", str(topic["summary"]))
            summary_box.configure(state="disabled")

            for item in details.get_children():
                details.delete(item)
            for row_index, row in enumerate(topic.get("rows", []), start=1):
                details.insert(
                    "",
                    "end",
                    values=row,
                    tags=("alt",) if row_index % 2 == 0 else ("base",),
                )
            details.tag_configure("base", background="#e3e3e3", foreground="#111111")
            details.tag_configure("alt", background="#d3d3d3", foreground="#111111")

        def on_select(_event: object | None = None) -> None:
            selected = section_list.curselection()
            if not selected:
                return
            render(int(selected[0]))

        section_list.bind("<<ListboxSelect>>", on_select)
        section_list.selection_set(0)
        render(0)
        section_list.focus_set()
        return "break"

    def _select_windows_printer(self) -> tuple[str, str, str] | None:
        if os.name != "nt":
            messagebox.showinfo("Imprimir", "La selección de impresora solo está implementada para Windows.")
            return None

        class PRINTDLG(ctypes.Structure):
            _fields_ = [
                ("lStructSize", ctypes.c_uint32),
                ("hwndOwner", ctypes.c_void_p),
                ("hDevMode", ctypes.c_void_p),
                ("hDevNames", ctypes.c_void_p),
                ("hDC", ctypes.c_void_p),
                ("Flags", ctypes.c_uint32),
                ("nFromPage", ctypes.c_ushort),
                ("nToPage", ctypes.c_ushort),
                ("nMinPage", ctypes.c_ushort),
                ("nMaxPage", ctypes.c_ushort),
                ("nCopies", ctypes.c_ushort),
                ("hInstance", ctypes.c_void_p),
                ("lCustData", ctypes.c_void_p),
                ("lpfnPrintHook", ctypes.c_void_p),
                ("lpfnSetupHook", ctypes.c_void_p),
                ("lpPrintTemplateName", ctypes.c_wchar_p),
                ("lpSetupTemplateName", ctypes.c_wchar_p),
                ("hPrintTemplate", ctypes.c_void_p),
                ("hSetupTemplate", ctypes.c_void_p),
            ]

        class DEVNAMES(ctypes.Structure):
            _fields_ = [
                ("wDriverOffset", ctypes.c_ushort),
                ("wDeviceOffset", ctypes.c_ushort),
                ("wOutputOffset", ctypes.c_ushort),
                ("wDefault", ctypes.c_ushort),
            ]

        PD_RETURNDC = 0x00000100
        PD_USEDEVMODECOPIESANDCOLLATE = 0x00040000

        print_dlg = PRINTDLG()
        print_dlg.lStructSize = ctypes.sizeof(PRINTDLG)
        print_dlg.hwndOwner = self.winfo_id()
        print_dlg.Flags = PD_RETURNDC | PD_USEDEVMODECOPIESANDCOLLATE

        print_dlg_w = ctypes.windll.comdlg32.PrintDlgW
        print_dlg_w.argtypes = [ctypes.POINTER(PRINTDLG)]
        print_dlg_w.restype = ctypes.c_bool

        success = print_dlg_w(ctypes.byref(print_dlg))
        if not success:
            error_code = ctypes.windll.comdlg32.CommDlgExtendedError()
            if error_code:
                messagebox.showerror("Imprimir", f"No fue posible abrir el diálogo de impresión ({error_code}).")
            return None

        try:
            if not print_dlg.hDevNames:
                return None

            locked = ctypes.windll.kernel32.GlobalLock(print_dlg.hDevNames)
            if not locked:
                return None
            try:
                devnames = DEVNAMES.from_address(locked)
                wchar_size = ctypes.sizeof(ctypes.c_wchar)
                driver = ctypes.wstring_at(locked + devnames.wDriverOffset * wchar_size)
                device = ctypes.wstring_at(locked + devnames.wDeviceOffset * wchar_size)
                output = ctypes.wstring_at(locked + devnames.wOutputOffset * wchar_size)
            finally:
                ctypes.windll.kernel32.GlobalUnlock(print_dlg.hDevNames)
        finally:
            if print_dlg.hDC:
                ctypes.windll.gdi32.DeleteDC(print_dlg.hDC)
            if print_dlg.hDevMode:
                ctypes.windll.kernel32.GlobalFree(print_dlg.hDevMode)
            if print_dlg.hDevNames:
                ctypes.windll.kernel32.GlobalFree(print_dlg.hDevNames)

        return device, driver, output

    def _print_text_report(self, report: str) -> None:
        printer = self._select_windows_printer()
        if printer is None:
            return

        printer_name, driver_name, output_name = printer
        temp_path = None
        try:
            with tempfile.NamedTemporaryFile("w", delete=False, suffix=".txt", encoding="utf-8-sig") as handle:
                handle.write(report)
                temp_path = handle.name

            completed = subprocess.run(
                ["notepad.exe", "/pt", temp_path, printer_name, driver_name, output_name],
                capture_output=True,
                text=True,
                check=False,
            )
            if completed.returncode != 0:
                raise RuntimeError((completed.stderr or completed.stdout or "No fue posible imprimir el reporte.").strip())
            self.status_var.set(f"Reporte enviado a impresión en {printer_name}.")
        except Exception as exc:
            messagebox.showerror("Imprimir", str(exc))
        finally:
            if temp_path:
                self.after(20000, lambda path=temp_path: Path(path).unlink(missing_ok=True))

    def _set_loading_state(self, loading: bool) -> None:
        state = "disabled" if loading else "normal"
        self.hierarchy_button.configure(state=state)
        self.estimate_button.configure(state=state)
        self.load_button.configure(state=state)

    def _show_progress_overlay(self, title: str, text: str) -> None:
        self._hide_progress_overlay()
        self.progress_text_var.set(text)
        self.progress_value_var.set("0%")

        window = tk.Toplevel(self)
        window.title(title)
        window.transient(self)
        window.resizable(False, False)
        window.configure(bg="#f4f8ff")
        window.protocol("WM_DELETE_WINDOW", lambda: None)

        frame = tk.Frame(window, bg="#f4f8ff", padx=24, pady=20)
        frame.pack(fill="both", expand=True)

        tk.Label(
            frame,
            text=title,
            bg="#f4f8ff",
            fg=TEXT_DARK,
            font=("Segoe UI", 12, "bold"),
        ).pack(pady=(0, 10))
        tk.Label(
            frame,
            textvariable=self.progress_text_var,
            bg="#f4f8ff",
            fg="#34547a",
            font=("Segoe UI", 9),
        ).pack(pady=(0, 10))

        self.progress_bar = ttk.Progressbar(frame, orient="horizontal", mode="determinate", length=320, maximum=100)
        self.progress_bar.pack(fill="x")
        tk.Label(
            frame,
            textvariable=self.progress_value_var,
            bg="#f4f8ff",
            fg=TEXT_DARK,
            font=("Segoe UI", 11, "bold"),
        ).pack(pady=(10, 0))

        window.update_idletasks()
        self.update_idletasks()
        x = self.winfo_rootx() + max((self.winfo_width() - window.winfo_width()) // 2, 0)
        y = self.winfo_rooty() + max((self.winfo_height() - window.winfo_height()) // 2, 0)
        window.geometry(f"+{x}+{y}")
        window.grab_set()
        self.progress_window = window

    def _update_progress_overlay(self, percent: int, text: str) -> None:
        percent = max(0, min(100, int(percent)))
        self.progress_text_var.set(text)
        self.progress_value_var.set(f"{percent}%")
        if self.progress_bar is not None:
            self.progress_bar.configure(value=percent)
        if self.progress_window is not None:
            self.progress_window.update_idletasks()

    def _hide_progress_overlay(self) -> None:
        if self.progress_window is not None:
            try:
                self.progress_window.grab_release()
            except tk.TclError:
                pass
            self.progress_window.destroy()
            self.progress_window = None
            self.progress_bar = None

    def _current_route(self) -> str:
        route = self.route_var.get().strip()
        return route.split("-", 1)[0].strip() if route else "0"

    def _current_batch_qty(self) -> float | None:
        raw = self.batch_var.get().strip()
        if not raw:
            raw = self.ebq_var.get().strip()
            if not raw:
                return None
        try:
            value = float(raw)
        except ValueError as exc:
            raise ValueError("Lote estimación / EBQ debe ser numérico.") from exc
        if value <= 0:
            raise ValueError("Lote estimación / EBQ debe ser mayor que cero.")
        return value

    def _refresh_master_visuals(self, master: dict[str, object]) -> None:
        parent_part = self.parent_part_var.get().strip()
        if not parent_part:
            return
        if not master:
            return
        self.current_master = dict(master)
        self.description_var.set(str(master.get("Description", "") or "").strip())
        self.uom_var.set(str(master.get("StockUom", "") or "").strip())
        mass = master.get("Mass")
        self.mass_var.set("" if mass in (None, "") else f"{float(mass):.6f}")
        if not self.ebq_var.get().strip():
            self.ebq_var.set(str(master.get("Ebq", "") or ""))
        if not self.batch_var.get().strip():
            self.batch_var.set(str(master.get("Ebq", "") or ""))
        if not self.warehouse_var.get().strip():
            self.warehouse_var.set(str(master.get("WarehouseToUse", "") or "").strip())

    def _apply_cost_summary(self, node: object) -> None:
        self.material_var.set(f"{node.total_breakdown.material:.5f}")
        self.labor_var.set(f"{node.total_breakdown.labor:.5f}")
        self.fixed_var.set(f"{node.total_breakdown.fixed:.5f}")
        self.variable_var.set(f"{node.total_breakdown.variable:.5f}")
        self.total_var.set(f"{node.total_breakdown.total:.5f}")

    def _apply_flat_summary(self, component_breakdown: object, operations: list[object]) -> None:
        op_material = sum(float(getattr(op, "subcontract", 0.0) or 0.0) for op in operations)
        op_labor = sum(float(getattr(op, "labor", 0.0) or 0.0) for op in operations)
        op_fixed = sum(float(getattr(op, "fixed", 0.0) or 0.0) for op in operations)
        op_variable = sum(float(getattr(op, "variable", 0.0) or 0.0) for op in operations)

        material = float(component_breakdown.material) + op_material
        labor = float(component_breakdown.labor) + op_labor
        fixed = float(component_breakdown.fixed) + op_fixed
        variable = float(component_breakdown.variable) + op_variable
        total = material + labor + fixed + variable

        self.material_var.set(f"{material:.5f}")
        self.labor_var.set(f"{labor:.5f}")
        self.fixed_var.set(f"{fixed:.5f}")
        self.variable_var.set(f"{variable:.5f}")
        self.total_var.set(f"{total:.5f}")

    def _load_initial_tree(self, master: dict[str, object], components: list[object], operations: list[object]) -> None:
        for item in self.tree.get_children():
            self.tree.delete(item)

        root_id = "root"
        self.tree.insert(
            "",
            "end",
            iid=root_id,
            text=(
                f"{str(master.get('StockCode', '') or self.parent_part_var.get().strip())} "
                f"{str(master.get('Description', '') or '').strip()}"
            ).strip(),
            values=(str(master.get("StockUom", "") or "").strip(), "Nodo padre", self.total_var.get()),
        )

        for index, comp in enumerate(components, start=1):
            comp_code = str(self._item_value(comp, "stock_code", "") or "")
            comp_desc = str(self._item_value(comp, "description", "") or "").strip()
            self.tree.insert(
                root_id,
                "end",
                iid=f"comp-{index}",
                text=f"{comp_code} {comp_desc}".strip(),
                values=(
                    self.uom_var.get(),
                    "Componente",
                    f"{float(self._item_value(comp, 'total', 0.0) or 0.0):.5f}",
                ),
            )

        for index, op in enumerate(operations, start=1):
            self.tree.insert(
                root_id,
                "end",
                iid=f"op-{index}",
                text=f"Op : {self._item_value(op, 'operation', '')} - {self._item_value(op, 'work_centre', '')}",
                values=("INT", "Operacion", f"{float(self._item_value(op, 'total', 0.0) or 0.0):.5f}"),
            )

        self.tree.selection_set(root_id)
        self.tree.item(root_id, open=True)

    def _load_hierarchy_tree(
        self,
        node: object,
        root_components: list[object] | None = None,
        root_operations: list[object] | None = None,
        root_total: float | None = None,
    ) -> None:
        for item in self.tree.get_children():
            self.tree.delete(item)

        node_counter = 0

        def next_iid(prefix: str) -> str:
            nonlocal node_counter
            node_counter += 1
            return f"{prefix}-{node_counter}"

        def hierarchy_total(comp: object) -> float:
            stock_code = str(getattr(comp, "stock_code", "") or "").strip()
            base_total = float(getattr(comp, "total", 0.0) or 0.0)
            product_class = str(get_master(stock_code).get("ProductClass", "") or "").strip()
            factor = self._rule_factor_for_product_class(product_class)
            return self._r5(base_total * factor)

        def insert_children(parent_id: str, current_node: object) -> None:
            for comp in getattr(current_node, "components", []):
                comp_text = f"{getattr(comp, 'stock_code', '')} {getattr(comp, 'description', '')}".strip()
                comp_id = next_iid("comp")
                self.tree.insert(
                    parent_id,
                    "end",
                    iid=comp_id,
                    text=comp_text,
                    values=(
                        self.uom_var.get(),
                        "Subcomponente" if getattr(comp, "node", None) else "Componente",
                        self._fmt_num(hierarchy_total(comp), 5, blank_zero=False),
                    ),
                )
                child_node = getattr(comp, "node", None)
                if child_node and (getattr(child_node, "components", None) or getattr(child_node, "operations", None)):
                    insert_children(comp_id, child_node)

            for op in getattr(current_node, "operations", []):
                op_text = (
                    f"Op : {getattr(op, 'operation', '')} - {getattr(op, 'work_centre', '')} "
                    f"{getattr(op, 'work_centre_description', '')}"
                ).strip()
                self.tree.insert(
                    parent_id,
                    "end",
                    iid=next_iid("op"),
                    text=op_text,
                    values=(
                        "INT",
                        "Operacion",
                        self._fmt_num(getattr(op, 'total', 0.0), 5, blank_zero=False),
                    ),
                )

        text = (
            f"{getattr(node, 'stock_code', '')} "
            f"{getattr(node, 'description', '')}"
        ).strip()
        display_total = root_total
        if display_total is None:
            display_total = getattr(getattr(node, "total_breakdown", None), "total", 0.0)

        root_id = self.tree.insert(
            "",
            "end",
            iid=next_iid("node"),
            text=text,
            values=(
                self.uom_var.get(),
                "Nodo padre",
                self._fmt_num(display_total, 5, blank_zero=False),
            ),
        )

        if root_components is not None:
            hierarchy_components = list(getattr(node, "components", []))
            for index, flat_comp in enumerate(root_components):
                flat_text = (
                    f"{self._item_value(flat_comp, 'stock_code', '')} "
                    f"{self._item_value(flat_comp, 'description', '')}"
                ).strip()
                comp_id = next_iid("comp")
                child_node = hierarchy_components[index].node if index < len(hierarchy_components) else None
                self.tree.insert(
                    root_id,
                    "end",
                    iid=comp_id,
                    text=flat_text,
                    values=(
                        self.uom_var.get(),
                        "Componente",
                        self._fmt_num(self._item_value(flat_comp, "total", 0.0), 5, blank_zero=False),
                    ),
                )
                if child_node and (getattr(child_node, "components", None) or getattr(child_node, "operations", None)):
                    insert_children(comp_id, child_node)

            for op in root_operations or []:
                op_text = (
                    f"Op : {self._item_value(op, 'operation', '')} - {self._item_value(op, 'work_centre', '')} "
                    f"{self._item_value(op, 'work_centre_description', '')}"
                ).strip()
                self.tree.insert(
                    root_id,
                    "end",
                    iid=next_iid("op"),
                    text=op_text,
                    values=(
                        "INT",
                        "Operacion",
                        self._fmt_num(self._item_value(op, "total", 0.0), 5, blank_zero=False),
                    ),
                )
        else:
            insert_children(root_id, node)

        self.tree.selection_set(root_id)
        self.tree.item(root_id, open=True)

    def _load_operations_grid(self, operations: list[object]) -> None:
        for item in self.operations.get_children():
            self.operations.delete(item)

        for op in operations:
            run_time = float(self._item_value(op, "run_time", 0.0) or 0.0)
            cycle = 0.0 if abs(run_time) < 0.0000005 else 1.0 / run_time
            self.operations.insert(
                "",
                "end",
                values=(
                    str(self._item_value(op, "operation", "") or ""),
                    str(self._item_value(op, "work_centre", "") or ""),
                    str(self._item_value(op, "work_centre_description", "") or ""),
                    str(self._item_value(op, "rate_ind", "") or ""),
                    self._fmt_num(run_time, 4),
                    self._fmt_num(cycle, 4),
                    self._fmt_num(self._item_value(op, "setup_time", 0.0), 4),
                    self._fmt_num(self._item_value(op, "startup_time", 0.0), 4),
                    self._fmt_num(self._item_value(op, "teardown_time", 0.0), 4),
                    self._fmt_num(self._item_value(op, "subcontract", 0.0), 5),
                    self._fmt_num(self._item_value(op, "labor", 0.0), 5),
                    self._fmt_num(self._item_value(op, "fixed", 0.0), 5),
                    self._fmt_num(self._item_value(op, "variable", 0.0), 5),
                    self._fmt_num(self._item_value(op, "total", 0.0), 5, blank_zero=False),
                ),
            )

    def _load_components_grid(self, components: list[object]) -> None:
        for item in self.components.get_children():
            self.components.delete(item)

        for index, comp in enumerate(components):
            tag = "alt" if index % 2 else "normal"
            qty_neta = float(self._item_value(comp, "qty_neta", self._item_value(comp, "qty_required", 0.0)) or 0.0)
            total_cost = float(self._item_value(comp, "total", 0.0) or 0.0)
            unit_cost = float(self._item_value(comp, "unit_cost", 0.0) or 0.0)
            if abs(unit_cost) < 0.0000005 and qty_neta != 0:
                unit_cost = total_cost / qty_neta
            self.components.insert(
                "",
                "end",
                values=(
                    str(self._item_value(comp, "sequence", f"{(index + 1) * 10:06d}") or ""),
                    str(self._item_value(comp, "parent_part", self.parent_part_var.get().strip()) or ""),
                    str(self._item_value(comp, "stock_code", "") or ""),
                    str(self._item_value(comp, "description", "") or "").strip(),
                    str(self._item_value(comp, "warehouse", "") or ""),
                    self._fmt_num(qty_neta, 6),
                    str(self._item_value(comp, "uom", self.uom_var.get()) or ""),
                    str(self._item_value(comp, "category", "Adquirido") or ""),
                    self._fmt_num(unit_cost, 5),
                    self._fmt_num(total_cost, 5, blank_zero=False),
                ),
                tags=(tag,),
            )

    def _populate_initial_panels(self, master: dict[str, object], components: list[object], operations: list[object]) -> None:
        self._reset_scenario(components, operations)
        self._load_initial_tree(master, components, operations)
        self._load_operations_grid(operations)
        self._load_components_grid(components)

    def _reset_scenario(self, components: list[object], operations: list[object]) -> None:
        self.scenario_components = []
        self.scenario_operations = []
        self.mass_rules = []

        for index, comp in enumerate(components, start=1):
            qty = float(getattr(comp, "qty_neta", 0.0) or 0.0)
            total = float(getattr(comp, "total", 0.0) or 0.0)
            breakdown = getattr(comp, "breakdown", None)
            material = float(getattr(breakdown, "material", 0.0) or 0.0)
            labor = float(getattr(breakdown, "labor", 0.0) or 0.0)
            fixed = float(getattr(breakdown, "fixed", 0.0) or 0.0)
            variable = float(getattr(breakdown, "variable", 0.0) or 0.0)
            if abs(total) < 0.0000005:
                material_share = 1.0
                labor_share = 0.0
                fixed_share = 0.0
                variable_share = 0.0
            else:
                material_share = material / total
                labor_share = labor / total
                fixed_share = fixed / total
                variable_share = variable / total

            self.scenario_components.append(
                {
                    "sequence": f"{index * 10:06d}",
                    "parent_part": self.parent_part_var.get().strip(),
                    "stock_code": str(getattr(comp, "stock_code", "") or ""),
                    "description": str(getattr(comp, "description", "") or ""),
                    "warehouse": str(getattr(comp, "warehouse", "") or ""),
                    "product_class": str(
                        get_master(str(getattr(comp, "stock_code", "") or "")).get("ProductClass", "") or ""
                    ).strip(),
                    "qty_required": qty,
                    "qty_neta": qty,
                    "uom": self.uom_var.get(),
                    "category": "Adquirido",
                    "unit_cost": 0.0 if abs(qty) < 0.0000005 else total / qty,
                    "base_unit_cost": 0.0 if abs(qty) < 0.0000005 else total / qty,
                    "total": total,
                    "base_total": total,
                    "material": material,
                    "labor": labor,
                    "fixed": fixed,
                    "variable": variable,
                    "material_share": material_share,
                    "labor_share": labor_share,
                    "fixed_share": fixed_share,
                    "variable_share": variable_share,
                }
            )

        for op in operations:
            self.scenario_operations.append(
                {
                    "operation": str(getattr(op, "operation", "") or ""),
                    "work_centre": str(getattr(op, "work_centre", "") or ""),
                    "work_centre_description": str(getattr(op, "work_centre_description", "") or ""),
                    "rate_ind": int(getattr(op, "rate_ind", 1) or 1),
                    "run_time": float(getattr(op, "run_time", 0.0) or 0.0),
                    "setup_time": float(getattr(op, "setup_time", 0.0) or 0.0),
                    "startup_time": float(getattr(op, "startup_time", 0.0) or 0.0),
                    "teardown_time": float(getattr(op, "teardown_time", 0.0) or 0.0),
                    "subcontract": float(getattr(op, "subcontract", 0.0) or 0.0),
                    "unit_capacity": float(getattr(op, "unit_capacity", 0.0) or 0.0),
                    "labor": float(getattr(op, "labor", 0.0) or 0.0),
                    "fixed": float(getattr(op, "fixed", 0.0) or 0.0),
                    "variable": float(getattr(op, "variable", 0.0) or 0.0),
                    "total": float(getattr(op, "total", 0.0) or 0.0),
                }
            )

    def _refresh_view_from_scenario(self) -> None:
        component_material = 0.0
        component_labor = 0.0
        component_fixed = 0.0
        component_variable = 0.0

        for comp in self.scenario_components:
            qty = float(comp.get("qty_required", 0.0) or 0.0)
            unit_cost = float(comp.get("unit_cost", 0.0) or 0.0)
            total = self._r5(qty * unit_cost)
            comp["qty_neta"] = qty
            comp["total"] = total
            comp["material"] = self._r5(total * float(comp.get("material_share", 1.0) or 0.0))
            comp["labor"] = self._r5(total * float(comp.get("labor_share", 0.0) or 0.0))
            comp["fixed"] = self._r5(total * float(comp.get("fixed_share", 0.0) or 0.0))
            comp["variable"] = self._r5(total * float(comp.get("variable_share", 0.0) or 0.0))
            component_material += float(comp["material"])
            component_labor += float(comp["labor"])
            component_fixed += float(comp["fixed"])
            component_variable += float(comp["variable"])

        batch_qty = self._current_batch_qty() or 1.0
        op_material = 0.0
        op_labor = 0.0
        op_fixed = 0.0
        op_variable = 0.0

        for op in self.scenario_operations:
            rate_ind = max(1, min(9, int(op.get("rate_ind", 1) or 1)))
            wc_code = str(op.get("work_centre", "") or "").strip()
            wc = get_work_centre(wc_code)
            op["work_centre_description"] = str(wc.get("Description", "") or "").strip()
            setup_rate = self._r5(wc.get(f"SetUpRate{rate_ind}", 0.0))
            run_rate = self._r5(wc.get(f"RunTimeRate{rate_ind}", 0.0))
            fixed_rate = self._r5(wc.get(f"FixOverRate{rate_ind}", 0.0))
            variable_rate = self._r5(wc.get(f"VarOverRate{rate_ind}", 0.0))
            startup_rate = self._r5(wc.get(f"StartupRate{rate_ind}", 0.0))
            teardown_rate = self._r5(wc.get(f"TeardownRate{rate_ind}", 0.0))

            run_time = float(op.get("run_time", 0.0) or 0.0)
            setup_time = float(op.get("setup_time", 0.0) or 0.0)
            startup_time = float(op.get("startup_time", 0.0) or 0.0)
            teardown_time = float(op.get("teardown_time", 0.0) or 0.0)
            unit_capacity = float(op.get("unit_capacity", 0.0) or 0.0)
            subcontract = self._r5(op.get("subcontract", 0.0))

            labor = self._r5(
                self._r5(run_time * run_rate)
                + self._r5(setup_time * setup_rate / batch_qty)
                + self._r5(startup_time * startup_rate / batch_qty)
                + self._r5(teardown_time * teardown_rate / batch_qty)
            )
            fixed = self._r5(unit_capacity * fixed_rate / batch_qty)
            variable = self._r5(unit_capacity * variable_rate / batch_qty)
            total = self._r5(subcontract + labor + fixed + variable)

            op["labor"] = labor
            op["fixed"] = fixed
            op["variable"] = variable
            op["subcontract"] = subcontract
            op["total"] = total

            op_material += subcontract
            op_labor += labor
            op_fixed += fixed
            op_variable += variable

        material = self._r5(component_material + op_material)
        labor = self._r5(component_labor + op_labor)
        fixed = self._r5(component_fixed + op_fixed)
        variable = self._r5(component_variable + op_variable)
        total = self._r5(material + labor + fixed + variable)

        self.material_var.set(f"{material:.5f}")
        self.labor_var.set(f"{labor:.5f}")
        self.fixed_var.set(f"{fixed:.5f}")
        self.variable_var.set(f"{variable:.5f}")
        self.total_var.set(f"{total:.5f}")

        self._load_operations_grid(self.scenario_operations)
        self._load_components_grid(self.scenario_components)
        if self.maintain_hierarchies_var.get() and self.current_hierarchy_node is not None:
            self._load_hierarchy_tree(
                self.current_hierarchy_node,
                root_components=self.scenario_components,
                root_operations=self.scenario_operations,
                root_total=total,
            )
        else:
            self._load_initial_tree(self.current_master, self.scenario_components, self.scenario_operations)

        self.status_var.set(
            f"ParentPart: {self.parent_part_var.get().strip()} {self.description_var.get()} Escenario actualizado"
        )

    def _apply_scenario_edits(self) -> None:
        if self._scenario_recalc_after_id is not None:
            try:
                self.after_cancel(self._scenario_recalc_after_id)
            except tk.TclError:
                pass
            self._scenario_recalc_after_id = None
        if not self.scenario_components and not self.scenario_operations:
            return
        try:
            self._current_batch_qty()
        except Exception:
            return
        self._refresh_view_from_scenario()

    def _schedule_scenario_recalc(self, delay_ms: int = 350) -> None:
        if self._scenario_recalc_after_id is not None:
            try:
                self.after_cancel(self._scenario_recalc_after_id)
            except tk.TclError:
                pass
        self._scenario_recalc_after_id = self.after(delay_ms, self._apply_scenario_edits)

    def _on_hierarchy_toggle(self, *_args: object) -> None:
        if self.scenario_components or self.scenario_operations:
            self._refresh_view_from_scenario()

    def _open_edit_dialog(self, title: str, fields: list[tuple[str, str, str]]) -> dict[str, str] | None:
        window = tk.Toplevel(self)
        window.title(title)
        window.transient(self)
        window.resizable(False, False)
        window.configure(bg="#f4f8ff")

        values: dict[str, str] = {}
        entries: dict[str, tk.Entry] = {}
        body = tk.Frame(window, bg="#f4f8ff", padx=16, pady=14)
        body.pack(fill="both", expand=True)

        for row, (key, label, current) in enumerate(fields):
            tk.Label(body, text=label, bg="#f4f8ff", fg=TEXT_DARK, font=("Segoe UI", 8)).grid(
                row=row, column=0, sticky="w", padx=(0, 8), pady=3
            )
            entry = tk.Entry(body, width=32, font=("Segoe UI", 8), relief="solid", bd=1, bg=FIELD_BG)
            entry.insert(0, current)
            entry.grid(row=row, column=1, sticky="ew", pady=3)
            entries[key] = entry
        body.grid_columnconfigure(1, weight=1)

        result = {"ok": False}

        def submit() -> None:
            for key, entry in entries.items():
                values[key] = entry.get().strip()
            result["ok"] = True
            window.destroy()

        buttons = tk.Frame(body, bg="#f4f8ff")
        buttons.grid(row=len(fields), column=0, columnspan=2, sticky="e", pady=(10, 0))
        ttk.Button(buttons, text="Aceptar", style="Slim.TButton", command=submit).pack(side="left", padx=(0, 6))
        ttk.Button(buttons, text="Cancelar", style="Slim.TButton", command=window.destroy).pack(side="left")

        first = next(iter(entries.values()), None)
        if first is not None:
            first.focus_set()
        window.grab_set()
        window.wait_window()
        return values if result["ok"] else None

    def _open_operation_dialog(self, title: str, operation_data: dict[str, object]) -> dict[str, str] | None:
        window = tk.Toplevel(self)
        window.title(title)
        window.transient(self)
        window.resizable(False, False)
        window.configure(bg="#f4f8ff")

        values: dict[str, str] = {}
        body = tk.Frame(window, bg="#f4f8ff", padx=16, pady=14)
        body.pack(fill="both", expand=True)

        wc_desc_var = tk.StringVar(value=str(operation_data.get("work_centre_description", "") or ""))
        helper_var = tk.StringVar(value="Pulsa Enter en Work center para cargar el maestro.")

        fields = [
            ("operation", "Operación", str(operation_data.get("operation", ""))),
            ("work_centre", "Work center", str(operation_data.get("work_centre", ""))),
            ("rate_ind", "Rate ind", str(operation_data.get("rate_ind", 1))),
            ("run_time", "Run time", self._fmt_num(operation_data.get("run_time", 0.0), 4, blank_zero=False)),
            ("setup_time", "Setup time", self._fmt_num(operation_data.get("setup_time", 0.0), 4, blank_zero=False)),
            ("startup_time", "Startup time", self._fmt_num(operation_data.get("startup_time", 0.0), 4, blank_zero=False)),
            ("teardown_time", "Teardown time", self._fmt_num(operation_data.get("teardown_time", 0.0), 4, blank_zero=False)),
            ("unit_capacity", "Capacidad unitaria", self._fmt_num(operation_data.get("unit_capacity", 0.0), 4, blank_zero=False)),
            ("subcontract", "Sub-contracted", self._fmt_num(operation_data.get("subcontract", 0.0), 5, blank_zero=False)),
        ]

        entries: dict[str, tk.Entry] = {}
        for row, (key, label, current) in enumerate(fields):
            tk.Label(body, text=label, bg="#f4f8ff", fg=TEXT_DARK, font=("Segoe UI", 8)).grid(
                row=row, column=0, sticky="w", padx=(0, 8), pady=3
            )
            entry = tk.Entry(body, width=32, font=("Segoe UI", 8), relief="solid", bd=1, bg=FIELD_BG)
            entry.insert(0, current)
            entry.grid(row=row, column=1, sticky="ew", pady=3)
            entries[key] = entry

        desc_row = len(fields)
        tk.Label(body, text="Descripción WC", bg="#f4f8ff", fg=TEXT_DARK, font=("Segoe UI", 8)).grid(
            row=desc_row, column=0, sticky="w", padx=(0, 8), pady=3
        )
        tk.Label(
            body,
            textvariable=wc_desc_var,
            bg=READONLY_BG,
            fg="#1e1e1e",
            relief="solid",
            bd=1,
            font=("Segoe UI", 8),
            anchor="w",
            padx=6,
            pady=2,
        ).grid(row=desc_row, column=1, sticky="ew", pady=3)

        tk.Label(
            body,
            textvariable=helper_var,
            bg="#f4f8ff",
            fg="#48617f",
            font=("Segoe UI", 8, "italic"),
            anchor="w",
        ).grid(row=desc_row + 1, column=0, columnspan=2, sticky="ew", pady=(2, 6))

        body.grid_columnconfigure(1, weight=1)

        def load_work_centre(_event: object | None = None) -> None:
            wc_code = entries["work_centre"].get().strip()
            if not wc_code:
                wc_desc_var.set("")
                helper_var.set("Ingresa un Work center y pulsa Enter.")
                return
            wc = get_work_centre(wc_code)
            if not wc:
                wc_desc_var.set("")
                helper_var.set(f"No se encontró {wc_code} en BomWorkCentre.")
                return
            wc_desc_var.set(str(wc.get("Description", "") or "").strip())
            helper_var.set(f"Maestro cargado para {wc_code}.")
            if not entries["rate_ind"].get().strip():
                entries["rate_ind"].insert(0, "1")

        entries["work_centre"].bind("<Return>", load_work_centre)
        entries["work_centre"].bind("<FocusOut>", load_work_centre)

        result = {"ok": False}

        def submit() -> None:
            load_work_centre()
            for key, entry in entries.items():
                values[key] = entry.get().strip()
            values["work_centre_description"] = wc_desc_var.get().strip()
            result["ok"] = True
            window.destroy()

        buttons = tk.Frame(body, bg="#f4f8ff")
        buttons.grid(row=desc_row + 2, column=0, columnspan=2, sticky="e", pady=(10, 0))
        ttk.Button(buttons, text="Aceptar", style="Slim.TButton", command=submit).pack(side="left", padx=(0, 6))
        ttk.Button(buttons, text="Cancelar", style="Slim.TButton", command=window.destroy).pack(side="left")

        entries["operation"].focus_set()
        window.grab_set()
        window.wait_window()
        return values if result["ok"] else None

    def _open_component_dialog(self, title: str, component_data: dict[str, object]) -> dict[str, str] | None:
        window = tk.Toplevel(self)
        window.title(title)
        window.transient(self)
        window.resizable(False, False)
        window.configure(bg="#f4f8ff")

        values: dict[str, str] = {}
        body = tk.Frame(window, bg="#f4f8ff", padx=16, pady=14)
        body.pack(fill="both", expand=True)

        desc_var = tk.StringVar(value=str(component_data.get("description", "") or ""))
        helper_var = tk.StringVar(value="Pulsa Enter en N° parte para cargar descripción.")

        fields = [
            ("stock_code", "N° parte", str(component_data.get("stock_code", ""))),
            ("warehouse", "Almacén", str(component_data.get("warehouse", self.warehouse_var.get().strip()) or "")),
            ("qty_required", "Cantidad unitaria", self._fmt_num(component_data.get("qty_required", 0.0), 6, blank_zero=False)),
            ("uom", "UDM", str(component_data.get("uom", self.uom_var.get()) or "")),
            ("category", "Categoría", str(component_data.get("category", "Adquirido") or "")),
            ("unit_cost", "Costo unitario", self._fmt_num(component_data.get("unit_cost", 0.0), 5, blank_zero=False)),
        ]

        entries: dict[str, tk.Entry] = {}
        for row, (key, label, current) in enumerate(fields):
            tk.Label(body, text=label, bg="#f4f8ff", fg=TEXT_DARK, font=("Segoe UI", 8)).grid(
                row=row, column=0, sticky="w", padx=(0, 8), pady=3
            )
            entry = tk.Entry(body, width=32, font=("Segoe UI", 8), relief="solid", bd=1, bg=FIELD_BG)
            entry.insert(0, current)
            entry.grid(row=row, column=1, sticky="ew", pady=3)
            entries[key] = entry

        desc_row = len(fields)
        tk.Label(body, text="Descripción de parte", bg="#f4f8ff", fg=TEXT_DARK, font=("Segoe UI", 8)).grid(
            row=desc_row, column=0, sticky="w", padx=(0, 8), pady=3
        )
        tk.Label(
            body,
            textvariable=desc_var,
            bg=READONLY_BG,
            fg="#1e1e1e",
            relief="solid",
            bd=1,
            font=("Segoe UI", 8),
            anchor="w",
            padx=6,
            pady=2,
        ).grid(row=desc_row, column=1, sticky="ew", pady=3)

        tk.Label(
            body,
            textvariable=helper_var,
            bg="#f4f8ff",
            fg="#48617f",
            font=("Segoe UI", 8, "italic"),
            anchor="w",
        ).grid(row=desc_row + 1, column=0, columnspan=2, sticky="ew", pady=(2, 6))

        body.grid_columnconfigure(1, weight=1)

        def load_part(_event: object | None = None) -> None:
            stock_code = entries["stock_code"].get().strip()
            if not stock_code:
                desc_var.set("")
                helper_var.set("Ingresa un N° parte y pulsa Enter.")
                return
            master = get_master(stock_code)
            if not master:
                desc_var.set("")
                helper_var.set(f"No se encontró {stock_code} en InvMaster.")
                return
            desc_var.set(str(master.get("Description", "") or "").strip())
            helper_var.set(f"Maestro cargado para {stock_code}.")
            if not entries["uom"].get().strip():
                entries["uom"].insert(0, str(master.get("StockUom", "") or "").strip())
            if not entries["warehouse"].get().strip():
                entries["warehouse"].insert(0, str(master.get("WarehouseToUse", "") or "").strip())

        entries["stock_code"].bind("<Return>", load_part)
        entries["stock_code"].bind("<FocusOut>", load_part)

        result = {"ok": False}

        def submit() -> None:
            load_part()
            for key, entry in entries.items():
                values[key] = entry.get().strip()
            values["description"] = desc_var.get().strip()
            result["ok"] = True
            window.destroy()

        buttons = tk.Frame(body, bg="#f4f8ff")
        buttons.grid(row=desc_row + 2, column=0, columnspan=2, sticky="e", pady=(10, 0))
        ttk.Button(buttons, text="Aceptar", style="Slim.TButton", command=submit).pack(side="left", padx=(0, 6))
        ttk.Button(buttons, text="Cancelar", style="Slim.TButton", command=window.destroy).pack(side="left")

        entries["stock_code"].focus_set()
        window.grab_set()
        window.wait_window()
        return values if result["ok"] else None

    def _open_mass_update_dialog(self) -> None:
        if not self.scenario_components:
            messagebox.showinfo("Actualizar", "Primero carga un escenario para aplicar una regla masiva.")
            return

        window = tk.Toplevel(self)
        window.title("Actualización masiva")
        window.transient(self)
        window.resizable(False, False)
        window.configure(bg="#f4f8ff")

        body = tk.Frame(window, bg="#f4f8ff", padx=16, pady=14)
        body.pack(fill="both", expand=True)

        target_var = tk.StringVar(value="Componentes")
        field_var = tk.StringVar(value="ProductClass")
        action_var = tk.StringVar(value="Aumentar %")
        filter_value_var = tk.StringVar(value="")
        pct_value_var = tk.StringVar(value="10")
        class_desc_var = tk.StringVar(value="")
        match_count_var = tk.StringVar(value="")
        helper_var = tk.StringVar(
            value="Ejemplo: ProductClass 101 con +10% actualiza el costo unitario de los componentes afectados."
        )

        rows = [
            ("Aplicar sobre", target_var, False),
            ("Filtro", field_var, False),
            ("ProductClass", filter_value_var, True),
            ("Actualizar", tk.StringVar(value="Costo unitario"), False),
            ("Acción", action_var, True),
            ("Valor %", pct_value_var, True),
        ]

        widgets: dict[str, tk.Widget] = {}
        for row, (label, variable, editable) in enumerate(rows):
            tk.Label(body, text=label, bg="#f4f8ff", fg=TEXT_DARK, font=("Segoe UI", 8)).grid(
                row=row, column=0, sticky="w", padx=(0, 8), pady=3
            )
            if label == "Acción":
                combo = ttk.Combobox(
                    body,
                    textvariable=action_var,
                    values=["Aumentar %", "Disminuir %"],
                    width=30,
                    state="readonly",
                )
                combo.grid(row=row, column=1, sticky="ew", pady=3)
                widgets["action"] = combo
            else:
                entry = tk.Entry(
                    body,
                    width=32,
                    font=("Segoe UI", 8),
                    relief="solid",
                    bd=1,
                    bg=FIELD_BG if editable else READONLY_BG,
                )
                entry.insert(0, variable.get())
                if not editable:
                    entry.configure(state="readonly", readonlybackground=READONLY_BG)
                entry.grid(row=row, column=1, sticky="ew", pady=3)
                widgets[label] = entry

        desc_row = len(rows)
        tk.Label(body, text="Descripción", bg="#f4f8ff", fg=TEXT_DARK, font=("Segoe UI", 8)).grid(
            row=desc_row, column=0, sticky="w", padx=(0, 8), pady=3
        )
        tk.Label(
            body,
            textvariable=class_desc_var,
            bg=READONLY_BG,
            fg="#1e1e1e",
            relief="solid",
            bd=1,
            font=("Segoe UI", 8),
            anchor="w",
            padx=6,
            pady=2,
        ).grid(row=desc_row, column=1, sticky="ew", pady=3)

        tk.Label(
            body,
            textvariable=helper_var,
            bg="#f4f8ff",
            fg="#48617f",
            font=("Segoe UI", 8, "italic"),
            anchor="w",
            justify="left",
        ).grid(row=desc_row + 1, column=0, columnspan=2, sticky="ew", pady=(4, 8))

        tk.Label(
            body,
            textvariable=match_count_var,
            bg="#f4f8ff",
            fg=TEXT_DARK,
            font=("Segoe UI", 8, "bold"),
            anchor="w",
            justify="left",
        ).grid(row=desc_row + 2, column=0, columnspan=2, sticky="ew", pady=(0, 4))

        match_text = tk.Text(
            body,
            width=52,
            height=7,
            font=("Consolas", 8),
            relief="solid",
            bd=1,
            bg=READONLY_BG,
            wrap="word",
        )
        match_text.grid(row=desc_row + 3, column=0, columnspan=2, sticky="ew", pady=(0, 8))
        match_text.configure(state="disabled")

        body.grid_columnconfigure(1, weight=1)

        def load_product_class(_event: object | None = None) -> None:
            filter_widget = widgets.get("ProductClass")
            code = filter_widget.get().strip() if isinstance(filter_widget, tk.Entry) else ""
            if not code:
                class_desc_var.set("")
                match_count_var.set("")
                match_text.configure(state="normal")
                match_text.delete("1.0", "end")
                match_text.configure(state="disabled")
                helper_var.set("Ingresa un ProductClass y pulsa Enter.")
                return
            description = get_product_class_description(code)
            matches = self._collect_product_class_matches(code)
            if description:
                class_desc_var.set(f"{code} - {description}")
                helper_var.set("La regla se aplicará inmediatamente y recalculará el escenario al aceptar.")
            else:
                class_desc_var.set(code)
                helper_var.set(f"No se encontró descripción para ProductClass {code}. Se aplicará el código ingresado.")
            match_count_var.set(
                f"Coincidencias encontradas: {len(matches)}"
            )
            match_text.configure(state="normal")
            match_text.delete("1.0", "end")
            if matches:
                match_text.insert("1.0", "\n".join(matches))
            else:
                match_text.insert("1.0", "No se encontraron componentes con ese ProductClass en el escenario visible.")
            match_text.configure(state="disabled")

        filter_entry = widgets.get("ProductClass")
        if isinstance(filter_entry, tk.Entry):
            filter_entry.bind("<Return>", load_product_class)
            filter_entry.bind("<FocusOut>", load_product_class)

        def submit() -> None:
            filter_widget = widgets.get("ProductClass")
            pct_widget = widgets.get("Valor %")
            filter_value = filter_widget.get().strip() if isinstance(filter_widget, tk.Entry) else ""
            if not filter_value:
                messagebox.showwarning("Actualizar", "Ingresa un ProductClass para filtrar.")
                return
            load_product_class()
            try:
                pct_raw = pct_widget.get().strip() if isinstance(pct_widget, tk.Entry) else ""
                pct_value = self._parse_float_field(pct_raw, "Valor %")
            except Exception as exc:
                messagebox.showerror("Actualizar", str(exc))
                return
            if pct_value < 0:
                messagebox.showwarning("Actualizar", "El porcentaje debe ser positivo.")
                return

            affected = self._apply_component_product_class_rule(
                product_class=filter_value,
                percent=pct_value,
                increase=action_var.get() == "Aumentar %",
            )
            if affected == 0:
                messagebox.showinfo(
                    "Actualizar",
                    f"No se encontraron componentes con ProductClass {filter_value}.",
                )
                return
            window.destroy()

        buttons = tk.Frame(body, bg="#f4f8ff")
        buttons.grid(row=desc_row + 4, column=0, columnspan=2, sticky="e", pady=(8, 0))
        ttk.Button(buttons, text="Aplicar", style="Slim.TButton", command=submit).pack(side="left", padx=(0, 6))
        ttk.Button(buttons, text="Cancelar", style="Slim.TButton", command=window.destroy).pack(side="left")

        editable_first = widgets.get("Valor filtro")
        if isinstance(editable_first, tk.Entry):
            editable_first.focus_set()
        window.grab_set()
        window.wait_window()

    def _apply_component_product_class_rule(self, *, product_class: str, percent: float, increase: bool) -> int:
        normalized = product_class.strip().upper()
        matches = self._collect_product_class_matches(normalized)
        affected = len(matches)
        if not affected:
            return 0

        self.mass_rules.append(
            {
                "product_class": normalized,
                "percent": float(percent),
                "increase": bool(increase),
            }
        )
        self._reapply_mass_rules()
        action_text = "aumentado" if increase else "reducido"
        self.status_var.set(
            f"Actualización masiva aplicada: ProductClass {product_class} con costo unitario {action_text} {percent:.2f}% en {affected} componente(s)."
        )
        return affected

    def _rule_factor_for_product_class(self, product_class: str) -> float:
        normalized = str(product_class or "").strip().upper()
        factor = 1.0
        for rule in self.mass_rules:
            if str(rule.get("product_class", "") or "").strip().upper() != normalized:
                continue
            percent = float(rule.get("percent", 0.0) or 0.0)
            if bool(rule.get("increase", True)):
                factor *= 1.0 + (percent / 100.0)
            else:
                factor *= 1.0 - (percent / 100.0)
        return factor

    def _reapply_mass_rules(self) -> None:
        if not self.scenario_components:
            return

        for comp in self.scenario_components:
            base_total = float(comp.get("base_total", comp.get("total", 0.0)) or 0.0)
            base_unit_cost = float(comp.get("base_unit_cost", comp.get("unit_cost", 0.0)) or 0.0)
            comp["total"] = base_total
            comp["unit_cost"] = base_unit_cost

        if not self.mass_rules:
            self._apply_scenario_edits()
            return

        if self.current_hierarchy_node is None:
            for comp in self.scenario_components:
                factor = self._rule_factor_for_product_class(str(comp.get("product_class", "") or ""))
                if abs(factor - 1.0) < 0.0000005:
                    continue
                qty = float(comp.get("qty_required", 0.0) or 0.0)
                base_total = float(comp.get("base_total", 0.0) or 0.0)
                new_total = self._r5(base_total * factor)
                comp["total"] = new_total
                comp["unit_cost"] = 0.0 if abs(qty) < 0.0000005 else self._r5(new_total / qty)
            self._apply_scenario_edits()
            return

        root_components = list(getattr(self.current_hierarchy_node, "components", []) or [])
        for index, top_comp in enumerate(root_components):
            if index >= len(self.scenario_components):
                break
            delta = self._collect_rule_delta(top_comp)
            base_total = float(self.scenario_components[index].get("base_total", 0.0) or 0.0)
            qty = float(self.scenario_components[index].get("qty_required", 0.0) or 0.0)
            new_total = self._r5(base_total + delta)
            self.scenario_components[index]["total"] = new_total
            self.scenario_components[index]["unit_cost"] = 0.0 if abs(qty) < 0.0000005 else self._r5(new_total / qty)

        self._apply_scenario_edits()

    def _collect_rule_delta(self, comp_line: object) -> float:
        stock_code = str(getattr(comp_line, "stock_code", "") or "").strip()
        product_class = str(get_master(stock_code).get("ProductClass", "") or "").strip()
        factor = self._rule_factor_for_product_class(product_class)
        current_total = float(getattr(comp_line, "total", 0.0) or 0.0)
        delta = self._r5(current_total * (factor - 1.0)) if abs(factor - 1.0) >= 0.0000005 else 0.0

        child_node = getattr(comp_line, "node", None)
        if child_node is not None:
            for child_comp in list(getattr(child_node, "components", []) or []):
                delta = self._r5(delta + self._collect_rule_delta(child_comp))
        return delta

    def _collect_product_class_matches(self, product_class: str) -> list[str]:
        normalized = str(product_class or "").strip().upper()
        if not normalized:
            return []

        matches: list[str] = []

        def add_line(path: str, stock_code: str, description: str) -> None:
            line = f"{path} -> {stock_code} {description}".strip()
            if line not in matches:
                matches.append(line)

        if self.current_hierarchy_node is not None:
            def walk(node: object, path_parts: list[str]) -> None:
                node_code = str(getattr(node, "stock_code", "") or "").strip()
                node_desc = str(getattr(node, "description", "") or "").strip()
                current_path = path_parts + ([node_code] if node_code else [])
                for comp in list(getattr(node, "components", []) or []):
                    stock_code = str(getattr(comp, "stock_code", "") or "").strip()
                    description = str(getattr(comp, "description", "") or "").strip()
                    comp_class = str(get_master(stock_code).get("ProductClass", "") or "").strip().upper()
                    path_text = " > ".join(current_path) if current_path else self.parent_part_var.get().strip()
                    if comp_class == normalized:
                        add_line(path_text, stock_code, description)
                    child_node = getattr(comp, "node", None)
                    if child_node is not None:
                        walk(child_node, current_path)

            walk(self.current_hierarchy_node, [])
        else:
            parent = self.parent_part_var.get().strip()
            for comp in self.scenario_components:
                comp_class = str(comp.get("product_class", "") or "").strip().upper()
                if comp_class != normalized:
                    continue
                add_line(parent, str(comp.get("stock_code", "") or "").strip(), str(comp.get("description", "") or "").strip())

        return matches

    def _parse_float_field(self, value: str, label: str) -> float:
        try:
            return float(value) if value else 0.0
        except ValueError as exc:
            raise ValueError(f"{label} debe ser numérico.") from exc

    def _on_components_double_click(self, _event: tk.Event[tk.Widget]) -> None:
        self._edit_selected_component()

    def _add_component(self) -> None:
        values = self._open_component_dialog(
            "Agregar componente",
            {
                "stock_code": "",
                "description": "",
                "warehouse": self.warehouse_var.get().strip(),
                "qty_required": 0.0,
                "uom": self.uom_var.get(),
                "category": "Adquirido",
                "unit_cost": 0.0,
            },
        )
        if values is None:
            return
        try:
            master = get_master(values["stock_code"])
            new_component = {
                "sequence": f"{(len(self.scenario_components) + 1) * 10:06d}",
                "parent_part": self.parent_part_var.get().strip(),
                "stock_code": values["stock_code"],
                "description": values["description"],
                "warehouse": values["warehouse"],
                "product_class": str(master.get("ProductClass", "") or "").strip(),
                "qty_required": self._parse_float_field(values["qty_required"], "Cantidad unitaria"),
                "qty_neta": 0.0,
                "uom": values["uom"] or self.uom_var.get(),
                "category": values["category"] or "Adquirido",
                "unit_cost": self._parse_float_field(values["unit_cost"], "Costo unitario"),
                "total": 0.0,
                "material": 0.0,
                "labor": 0.0,
                "fixed": 0.0,
                "variable": 0.0,
                "material_share": 1.0,
                "labor_share": 0.0,
                "fixed_share": 0.0,
                "variable_share": 0.0,
            }
            self.scenario_components.append(new_component)
            self._apply_scenario_edits()
        except Exception as exc:
            messagebox.showerror("Componentes", str(exc))

    def _edit_selected_component(self) -> None:
        if not self.scenario_components:
            return
        selection = self.components.selection()
        if not selection:
            messagebox.showinfo("Componentes", "Selecciona un componente para editar.")
            return
        index = self.components.index(selection[0])
        comp = self.scenario_components[index]
        values = self._open_component_dialog(
            "Editar componente",
            comp,
        )
        if values is None:
            return
        try:
            master = get_master(values["stock_code"])
            comp["stock_code"] = values["stock_code"]
            comp["description"] = values["description"]
            comp["warehouse"] = values["warehouse"]
            comp["product_class"] = str(master.get("ProductClass", "") or "").strip()
            comp["qty_required"] = self._parse_float_field(values["qty_required"], "Cantidad unitaria")
            comp["uom"] = values["uom"] or self.uom_var.get()
            comp["category"] = values["category"] or "Adquirido"
            comp["unit_cost"] = self._parse_float_field(values["unit_cost"], "Costo unitario")
            self._apply_scenario_edits()
        except Exception as exc:
            messagebox.showerror("Componentes", str(exc))

    def _on_operations_double_click(self, _event: tk.Event[tk.Widget]) -> None:
        self._edit_selected_operation()

    def _delete_selected_component(self) -> None:
        if not self.scenario_components:
            return
        selection = self.components.selection()
        if not selection:
            messagebox.showinfo("Componentes", "Selecciona un componente para eliminar.")
            return
        index = self.components.index(selection[0])
        comp = self.scenario_components[index]
        confirm = messagebox.askyesno(
            "Componentes",
            f"¿Eliminar el componente {comp.get('stock_code', '')} {comp.get('description', '')} del escenario?",
        )
        if not confirm:
            return
        del self.scenario_components[index]
        for pos, item in enumerate(self.scenario_components, start=1):
            item["sequence"] = f"{pos * 10:06d}"
        self._apply_scenario_edits()

    def _add_operation(self) -> None:
        values = self._open_operation_dialog(
            "Agregar operación",
            {
                "operation": str(len(self.scenario_operations) + 1),
                "work_centre": "",
                "rate_ind": 1,
                "run_time": 0.0,
                "setup_time": 0.0,
                "startup_time": 0.0,
                "teardown_time": 0.0,
                "unit_capacity": 0.0,
                "subcontract": 0.0,
                "work_centre_description": "",
            },
        )
        if values is None:
            return
        try:
            self.scenario_operations.append(
                {
                    "operation": values["operation"],
                    "work_centre": values["work_centre"],
                    "work_centre_description": values.get("work_centre_description", ""),
                    "rate_ind": max(1, min(9, int(values["rate_ind"] or "1"))),
                    "run_time": self._parse_float_field(values["run_time"], "Run time"),
                    "setup_time": self._parse_float_field(values["setup_time"], "Setup time"),
                    "startup_time": self._parse_float_field(values["startup_time"], "Startup time"),
                    "teardown_time": self._parse_float_field(values["teardown_time"], "Teardown time"),
                    "unit_capacity": self._parse_float_field(values["unit_capacity"], "Capacidad unitaria"),
                    "subcontract": self._parse_float_field(values["subcontract"], "Sub-contracted"),
                    "labor": 0.0,
                    "fixed": 0.0,
                    "variable": 0.0,
                    "total": 0.0,
                }
            )
            self._apply_scenario_edits()
        except Exception as exc:
            messagebox.showerror("Operaciones", str(exc))

    def _edit_selected_operation(self) -> None:
        if not self.scenario_operations:
            return
        selection = self.operations.selection()
        if not selection:
            messagebox.showinfo("Operaciones", "Selecciona una operación para editar.")
            return
        index = self.operations.index(selection[0])
        op = self.scenario_operations[index]
        values = self._open_operation_dialog(
            "Editar operación",
            op,
        )
        if values is None:
            return
        try:
            op["operation"] = values["operation"]
            op["work_centre"] = values["work_centre"]
            op["work_centre_description"] = values.get("work_centre_description", "")
            op["rate_ind"] = max(1, min(9, int(values["rate_ind"] or "1")))
            op["run_time"] = self._parse_float_field(values["run_time"], "Run time")
            op["setup_time"] = self._parse_float_field(values["setup_time"], "Setup time")
            op["startup_time"] = self._parse_float_field(values["startup_time"], "Startup time")
            op["teardown_time"] = self._parse_float_field(values["teardown_time"], "Teardown time")
            op["unit_capacity"] = self._parse_float_field(values["unit_capacity"], "Capacidad unitaria")
            op["subcontract"] = self._parse_float_field(values["subcontract"], "Sub-contracted")
            self._apply_scenario_edits()
        except Exception as exc:
            messagebox.showerror("Operaciones", str(exc))

    def _delete_selected_operation(self) -> None:
        if not self.scenario_operations:
            return
        selection = self.operations.selection()
        if not selection:
            messagebox.showinfo("Operaciones", "Selecciona una operación para eliminar.")
            return
        index = self.operations.index(selection[0])
        op = self.scenario_operations[index]
        confirm = messagebox.askyesno(
            "Operaciones",
            f"¿Eliminar la operación {op.get('operation', '')} - {op.get('work_centre', '')} del escenario?",
        )
        if not confirm:
            return
        del self.scenario_operations[index]
        self._apply_scenario_edits()

    def _request_initial_load(self, silent: bool = False, user_message: str | None = None) -> None:
        parent_part = self.parent_part_var.get().strip()
        if not parent_part:
            return
        try:
            batch_qty = self._current_batch_qty()
        except Exception as exc:
            if not silent:
                messagebox.showwarning("Estimaciones", str(exc))
            self.status_var.set("Valores de entrada no válidos para recalcular.")
            return

        route = self._current_route()
        self._refresh_token += 1
        token = self._refresh_token
        self._set_loading_state(True)
        self.status_var.set(user_message or "Calculando escenario...")

        def worker() -> None:
            try:
                master = get_master(parent_part)
                component_breakdown, components, operations = calculate_stock_cost(parent_part, route=route, batch_qty=batch_qty)
                self.after(
                    0,
                    lambda: self._finish_initial_load(token, master, component_breakdown, components, operations, silent),
                )
            except Exception as exc:
                self.after(0, lambda: self._fail_refresh(token, exc, silent))

        Thread(target=worker, daemon=True).start()

    def _finish_initial_load(
        self,
        token: int,
        master: dict[str, object],
        component_breakdown: object,
        components: list[object],
        operations: list[object],
        silent: bool,
    ) -> None:
        if token != self._refresh_token:
            return
        self._set_loading_state(False)
        self.current_hierarchy_node = None
        self._refresh_master_visuals(master)
        self._apply_flat_summary(component_breakdown, operations)
        self._populate_initial_panels(master, components, operations)
        self.status_var.set(
            f"ParentPart: {self.parent_part_var.get().strip()} {self.description_var.get()} Cargado costos Actualizados"
        )
        if not silent:
            messagebox.showinfo(
                "Estimaciones",
                "Cálculo ejecutado correctamente.\n\nEl resumen de Material, Labor, OH fijo, OH variable y Total fue actualizado.",
            )

    def _fail_refresh(self, token: int, exc: Exception, silent: bool) -> None:
        if token != self._refresh_token:
            return
        self._hide_progress_overlay()
        self._set_loading_state(False)
        self.status_var.set(f"No fue posible recalcular: {exc}")
        if not silent:
            messagebox.showerror("Estimaciones", str(exc))

    def _on_load_base(self, silent: bool = False) -> None:
        self._request_initial_load(silent=silent, user_message="Cargando estructura base...")

    def _show_hierarchy_report(self) -> None:
        try:
            if self.maintain_hierarchies_var.get():
                report = format_tree_report(
                    self.parent_part_var.get().strip(),
                    report_type="What-if Costing Report",
                    route=self._current_route(),
                    batch_qty=self._current_batch_qty(),
                )
                report = self._clean_report_zeros(report)
            else:
                report = format_report(
                    self.parent_part_var.get().strip(),
                    report_type="What-if Costing Report",
                    route=self._current_route(),
                    batch_qty=self._current_batch_qty(),
                )
        except Exception as exc:
            messagebox.showerror("Jerarquía", str(exc))
            return

        window = tk.Toplevel(self)
        window.title(f"Jerarquía - {self.parent_part_var.get().strip()}")
        window.geometry("1180x760")
        header = tk.Frame(window, bg="#eef3fb", relief="solid", bd=1)
        header.pack(fill="x")
        ttk.Button(
            header,
            text="Imprimir",
            style="Slim.TButton",
            command=lambda text=report: self._print_text_report(text),
        ).pack(side="right", padx=8, pady=6)
        viewer = scrolledtext.ScrolledText(window, wrap="none", font=("Consolas", 9))
        viewer.pack(fill="both", expand=True)
        viewer.insert("1.0", report)
        viewer.configure(state="disabled")

    def _on_estimate(self, silent: bool = False) -> None:
        parent_part = self.parent_part_var.get().strip()
        if not parent_part:
            return
        try:
            batch_qty = self._current_batch_qty()
        except Exception as exc:
            if not silent:
                messagebox.showwarning("Estimaciones", str(exc))
            self.status_var.set("Valores de entrada no válidos para estimar.")
            return

        if not self.maintain_hierarchies_var.get():
            self._request_initial_load(silent=silent, user_message="Estimando escenario en 1 nivel...")
            return

        route = self._current_route()
        self._refresh_token += 1
        token = self._refresh_token
        self._set_loading_state(True)
        self.status_var.set("Estimando escenario completo...")
        self._show_progress_overlay("Estimando", "Preparando escenario de recosteo...")
        self._update_progress_overlay(5, "Validando parámetros...")

        def worker() -> None:
            try:
                self.after(0, lambda: self._update_progress_overlay(20, "Leyendo maestro del parent part..."))
                master = get_master(parent_part)
                self.after(0, lambda: self._update_progress_overlay(40, "Calculando costo base What-if..."))
                component_breakdown, components, operations = calculate_stock_cost(parent_part, route=route, batch_qty=batch_qty)
                self.after(0, lambda: self._update_progress_overlay(70, "Cargando vista jerárquica de apoyo..."))
                node = calculate_tree_cost(parent_part, route=route, batch_qty=batch_qty)
                self.after(0, lambda: self._update_progress_overlay(85, "Aplicando resultados en pantalla..."))
                self.after(
                    0,
                    lambda: self._finish_estimate(
                        token,
                        master,
                        component_breakdown,
                        components,
                        operations,
                        node,
                        silent,
                    ),
                )
            except Exception as exc:
                self.after(0, lambda: self._fail_refresh(token, exc, silent))

        Thread(target=worker, daemon=True).start()

    def _finish_estimate(
        self,
        token: int,
        master: dict[str, object],
        component_breakdown: object,
        components: list[object],
        operations: list[object],
        node: object,
        silent: bool,
    ) -> None:
        if token != self._refresh_token:
            return
        self._update_progress_overlay(100, "Estimación completada.")
        self._set_loading_state(False)
        self.current_hierarchy_node = node
        self._refresh_master_visuals(master)
        self._apply_flat_summary(component_breakdown, operations)
        self._reset_scenario(components, operations)
        self._load_operations_grid(operations)
        self._load_components_grid(components)
        self._load_hierarchy_tree(
            node,
            root_components=self.scenario_components,
            root_operations=self.scenario_operations,
            root_total=float(component_breakdown.total + sum(float(getattr(op, "total", 0.0) or 0.0) for op in operations)),
        )
        self.status_var.set(
            f"ParentPart: {self.parent_part_var.get().strip()} {self.description_var.get()} Cargado costos Actualizados"
        )
        self.after(250, self._hide_progress_overlay)
        if not silent:
            messagebox.showinfo(
                "Estimaciones",
                "Estimación completa ejecutada.\n\nEl costo se recalculó con la lógica What-if y la jerarquía se mostró solo como detalle visual.",
            )

    def _on_save_version(self) -> None:
        self.status_var.set("Guardar versión aún no está conectado, pero la acción ya quedó ubicada como flujo ERP.")


def main() -> int:
    app = EstimacionesApp()
    app.mainloop()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
