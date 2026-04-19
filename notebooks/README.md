# Notebooks de ejecucion y validacion

Esta carpeta se reserva para exploracion, validacion y analisis puntual.

## Uso recomendado

- pruebas exploratorias
- validacion puntual
- prototipos rapidos
- analisis de resultados

## Regla de organizacion

Los programas productivos no deben vivir en `notebooks/`.

La distribucion correcta del repositorio es:

- `src/`
  - logica de negocio y motor
- `connectors/`
  - conectores y acceso a datos
- `scripts/`
  - programas ejecutables, formularios y lanzadores
- `docs/`
  - documentacion formal del proyecto
- `notebooks/`
  - experimentacion y apoyo temporal

## Ejecucion operativa actual

### Formulario interactivo

```powershell
python scripts/bom_costing_form.py
```

### Generador de reporte por consola

```powershell
python scripts/generate_bom_costing_report.py 9320000432
```

### Generador jerarquico

```powershell
python scripts/generate_bom_costing_report.py 9320000432 --tree
```

## Nota

Si un notebook termina consolidando una regla permanente del negocio:

1. la regla se documenta en `docs/`
2. la logica estable se mueve a `src/` o `scripts/`
