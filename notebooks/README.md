# Notebooks de ejecucion y validacion

Esta carpeta concentra los puntos de entrada para ejecutar y validar el proyecto.

## Flujo recomendado

1. Abrir el formulario interactivo para pedir el `ParentPart`.
2. Generar el reporte `What-if Costing Report` o el arbol por niveles.
3. Comparar la salida contra SYSPRO.
4. Documentar hallazgos en `docs/`.

## Programas de ejecucion

### 1. Formulario interactivo

Permite pedir el `ParentPart` y generar la salida plana o jerarquica.

```powershell
python scripts/bom_costing_form.py
```

### 2. Generador de reporte por consola

Genera el reporte directo para un `ParentPart` especifico.

```powershell
python scripts/generate_bom_costing_report.py 9320000432
```

### 3. Generador jerarquico nivel por nivel

Muestra el arbol de padres e hijos con acumulacion de costos.

```powershell
python scripts/generate_bom_costing_report.py 9320000432 --tree
```

## Archivos de salida

- `outputs/*_what_if_report.txt`
- `outputs/*_tree_report.txt`

## Notas

- La logica de costeo vive en `src/cotizador_ia/bom_costing.py`.
- Esta carpeta solo agrupa el uso y la validacion.
- No se deben duplicar aqui formulas o reglas de negocio.
