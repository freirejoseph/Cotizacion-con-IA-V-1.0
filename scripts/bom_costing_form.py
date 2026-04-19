from __future__ import annotations

from datetime import datetime
from pathlib import Path
from threading import Thread
import sys
import tkinter as tk
from tkinter import messagebox, scrolledtext, ttk


PROJECT_ROOT = Path(__file__).resolve().parents[1]
SRC_PATH = PROJECT_ROOT / "src"
for path in (PROJECT_ROOT, SRC_PATH):
    if str(path) not in sys.path:
        sys.path.insert(0, str(path))

from cotizador_ia.bom_costing import format_report, format_tree_report


REPORT_TYPES = {
    "Relac. materiales": "B.O.M. Costing Report",
    "Simulacion": "What-if Costing Report",
}


class BomCostingApp(tk.Tk):
    def __init__(self) -> None:
        super().__init__()
        self.title("Informe costos BOM")
        self.geometry("1180x820")
        self.minsize(980, 700)

        self.parent_part_var = tk.StringVar(value="")
        self.batch_qty_var = tk.StringVar(value="12500")
        self.report_mode_var = tk.StringVar(value="Relac. materiales")
        self.tree_mode_var = tk.BooleanVar(value=True)
        self.status_var = tk.StringVar(value="Listo para validar ParentPart")
        self._busy = False

        self._build_ui()

    def _build_ui(self) -> None:
        container = ttk.Frame(self, padding=12)
        container.pack(fill="both", expand=True)

        title = ttk.Label(container, text="Informe costos BOM", font=("Segoe UI", 18, "bold"))
        title.grid(row=0, column=0, sticky="w", pady=(0, 10))

        form = ttk.LabelFrame(container, text="Seleccion n° de parte", padding=12)
        form.grid(row=1, column=0, sticky="ew")
        form.columnconfigure(1, weight=1)

        ttk.Label(form, text="De:").grid(row=0, column=0, sticky="w", padx=(0, 8))
        parent_entry = ttk.Entry(form, textvariable=self.parent_part_var, width=40)
        parent_entry.grid(row=0, column=1, sticky="w")
        parent_entry.focus_set()

        ttk.Label(form, text="Lote:").grid(row=1, column=0, sticky="w", padx=(0, 8), pady=(10, 0))
        batch_entry = ttk.Entry(form, textvariable=self.batch_qty_var, width=18)
        batch_entry.grid(row=1, column=1, sticky="w", pady=(10, 0))

        mode_frame = ttk.LabelFrame(container, text="Costos a imprimir", padding=12)
        mode_frame.grid(row=2, column=0, sticky="ew", pady=(12, 0))
        for idx, label in enumerate(REPORT_TYPES):
            ttk.Radiobutton(mode_frame, text=label, value=label, variable=self.report_mode_var).grid(
                row=0, column=idx, sticky="w", padx=(0, 18)
            )
        ttk.Checkbutton(
            mode_frame,
            text="Mostrar sub componentes por nivel",
            variable=self.tree_mode_var,
        ).grid(row=1, column=0, columnspan=2, sticky="w", pady=(8, 0))

        buttons = ttk.Frame(container)
        buttons.grid(row=3, column=0, sticky="e", pady=(12, 0))
        self.print_button = ttk.Button(buttons, text="Imprimir", command=self.generate_report)
        self.print_button.pack(side="left", padx=(0, 8))
        ttk.Button(buttons, text="Cerrar", command=self.destroy).pack(side="left")

        output_frame = ttk.LabelFrame(container, text="Salida del reporte", padding=8)
        output_frame.grid(row=4, column=0, sticky="nsew", pady=(12, 0))
        container.rowconfigure(4, weight=1)
        container.columnconfigure(0, weight=1)

        self.output = scrolledtext.ScrolledText(
            output_frame,
            font=("Consolas", 10),
            wrap="none",
            height=28,
        )
        self.output.pack(fill="both", expand=True)

        status = ttk.Label(container, textvariable=self.status_var, anchor="w")
        status.grid(row=5, column=0, sticky="ew", pady=(8, 0))

    def generate_report(self) -> None:
        parent_part = self.parent_part_var.get().strip()
        if not parent_part:
            messagebox.showwarning("Validacion", "Ingresa un ParentPart para continuar.")
            return

        batch_qty_raw = self.batch_qty_var.get().strip()
        try:
            batch_qty = float(batch_qty_raw) if batch_qty_raw else None
            if batch_qty is not None and batch_qty <= 0:
                raise ValueError
        except ValueError:
            messagebox.showwarning("Validacion", "Ingresa un lote valido mayor que cero.")
            return

        if self._busy:
            return

        report_type = REPORT_TYPES[self.report_mode_var.get()]
        tree_mode = bool(self.tree_mode_var.get())
        self._busy = True
        self.print_button.configure(state="disabled")
        self.status_var.set(f"Generando reporte para {parent_part}...")
        self.update_idletasks()

        def worker() -> None:
            try:
                if tree_mode:
                    report = format_tree_report(parent_part, report_type=report_type, route="0", batch_qty=batch_qty)
                else:
                    report = format_report(parent_part, report_type=report_type, route="0", batch_qty=batch_qty)
                self.after(0, lambda: self._finish_report(report))
            except Exception as exc:
                self.after(0, lambda: self._fail_report(exc))

        Thread(target=worker, daemon=True).start()

    def _finish_report(self, report: str) -> None:
        self.output.delete("1.0", tk.END)
        self.output.insert(tk.END, report)
        self.status_var.set(f"Reporte generado en pantalla | {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        self.print_button.configure(state="normal")
        self._busy = False

    def _fail_report(self, exc: Exception) -> None:
        self.status_var.set("Error en la validacion")
        messagebox.showerror("Error", str(exc))
        self.print_button.configure(state="normal")
        self._busy = False


def main() -> int:
    app = BomCostingApp()
    app.mainloop()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
