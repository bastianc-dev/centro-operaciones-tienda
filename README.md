# Centro de operaciones para tienda online

Simulación de operaciones de una tienda online desarrollada con Python, archivos CSV y una planilla de análisis. El sistema procesa 500 pedidos ficticios, sus pagos y envíos, junto con 120 tickets de soporte, para identificar anomalías y generar informes operativos.

Permite investigar incidencias, registrar las acciones realizadas y conservar el historial de resoluciones sin modificar los datos originales.

Tecnologías: Python 3.10+, CSV, Google Sheets y LibreOffice Calc. No requiere dependencias externas de Python.

## Demostración

![Panel de indicadores del centro de operaciones](evidencias/panel_vista_previa.png)

[Ver planilla pública (solo lectura)](https://docs.google.com/spreadsheets/d/1GUptLa6Q2qjPZYHpui-Nl0Ty-8xsvgFl/edit) · [Ver demostración de tres incidencias (47 s)](evidencias/demo_tres_incidencias.mp4)

Resultados de la simulación al **21 de octubre de 2026**:

| Indicador | Resultado |
|---|---:|
| Pedidos | 500 |
| Tickets de soporte | 120 |
| Posibles pedidos duplicados | 14 |
| Pagos con diferencias | 16 |
| Envíos atrasados | 52 |
| Incumplimientos de SLA | 43 |
| Incidencias detectadas | 125 |

Los registros, clientes y operaciones son ficticios. Las cifras corresponden a una fecha de corte fija y pueden cambiar si se utiliza otra fecha o se documentan resoluciones.

## Funcionalidades

El análisis de Python aplica cuatro controles:

| Control | Criterio |
|---|---|
| Posibles duplicados | Mismo cliente, producto, cantidad y monto en un intervalo de 10 minutos. |
| Diferencias de pago | Pago aprobado cuyo monto no coincide con el total del pedido. |
| Envíos atrasados | Envío no entregado cuya fecha comprometida ya pasó. |
| SLA incumplido | Primera respuesta fuera del plazo o ausencia de respuesta al cierre. |

Además, el proyecto incluye:

- Panel de métricas y gráficos con desglose de pedidos e incidencias.
- Análisis de pedidos por región y categoría.
- Informe en Markdown, catálogo de incidencias en CSV e indicadores en JSON.
- Bitácora para documentar resoluciones y reaperturas sin eliminar hallazgos.
- Ejecución programable y pruebas unitarias.

## Instalación y ejecución

Se necesita Python 3.10 o posterior. No es necesario instalar paquetes con `pip`.

Abre una terminal en la raíz del repositorio, donde se encuentran `README.md`, `data/` y `scripts/`.

En Windows (PowerShell):

```powershell
py -3 scripts/analizar.py --as-of 2026-10-21
```

En Linux o macOS:

```bash
python3 scripts/analizar.py --as-of 2026-10-21
```

El comando actualiza:

| Archivo | Contenido |
|---|---|
| `reports/incidencias.csv` | Incidencias detectadas y estado operativo. |
| `reports/indicadores.json` | Indicadores estructurados. |
| `reports/informe_2026-10-21.md` | Informe de la fecha indicada. |
| `reports/informe_ultimo.md` | Último informe generado. |

Para analizar los datos con la fecha actual, omite `--as-of`:

```powershell
py -3 scripts/analizar.py
```

Los registros de ejemplo no incorporan pedidos nuevos automáticamente. Para reproducir los resultados publicados, utiliza siempre la fecha de corte `2026-10-21`.

También puedes regenerar los datos ficticios con la misma semilla:

```powershell
py -3 scripts/generar_datos.py
```

Este comando reemplaza los CSV de pedidos, pagos, envíos y tickets, pero no borra `data/resoluciones.csv`.

## Investigación y gestión de incidencias

Consulta `reports/incidencias.csv` para identificar los casos. El script `gestionar.py` agrega acciones a `data/resoluciones.csv`; no corrige pagos ni contacta clientes o transportistas reales.

Ejemplos de registro de una resolución:

```powershell
py -3 scripts/gestionar.py PAGO_DIFERENTE:PAG-0012 --responsable "Analista demo" --accion "Diferencia revisada con comprobante simulado; caso derivado a finanzas"

py -3 scripts/gestionar.py POSIBLE_DUPLICADO:PED-0035 --responsable "Analista demo" --accion "Pedido duplicado identificado; requiere confirmación antes de procesarlo"

py -3 scripts/gestionar.py ENVIO_ATRASADO:ENV-0020 --responsable "Analista demo" --accion "Se documentó contacto simulado con transportista y seguimiento al cliente"

py -3 scripts/analizar.py --as-of 2026-10-21
```

Después de ejecutar estos ejemplos, el informe mantiene los 125 hallazgos históricos, con 122 incidencias abiertas y 3 marcadas como resueltas.

Para reabrir un caso:

```powershell
py -3 scripts/gestionar.py PAGO_DIFERENTE:PAG-0012 --estado ABIERTO --responsable "Analista demo" --accion "Se requiere una nueva validación"
```

El estado vigente se obtiene de la última acción registrada. Las entradas anteriores se conservan en la bitácora. El procedimiento de investigación y el guion del video están en [docs/casos.md](docs/casos.md).

## Planilla de análisis

El archivo [`panel_operaciones.xlsx`](panel_operaciones.xlsx) se puede abrir con LibreOffice Calc o importar a Google Sheets. Incluye las hojas `Panel`, `Resumen_cruzado`, `Pedidos`, `Pagos`, `Envios`, `Tickets`, `Incidencias`, `Parametros` y `Guia`.

La hoja `Resumen_cruzado` utiliza fórmulas para agrupar pedidos por región y categoría. Es una matriz de resumen, no una tabla dinámica nativa en el archivo Excel. Una versión convertida a Google Sheets puede incorporar una tabla dinámica independiente.

La planilla es una copia de los datos de la simulación. Ejecutar Python actualiza los archivos de `reports/`, pero no sincroniza automáticamente Google Sheets ni el archivo `.xlsx`.

## Automatización diaria

En Windows se incluye `ejecutar_informe.bat`, que puede programarse mediante el Programador de tareas:

1. Abre el Programador de tareas y selecciona **Crear tarea básica**.
2. Selecciona una ejecución diaria y define la hora.
3. En **Iniciar un programa**, indica la ruta absoluta a `ejecutar_informe.bat`.
4. Si configuras el campo **Iniciar en**, utiliza la ruta de la carpeta del proyecto, sin comillas.
5. Ejecuta la tarea manualmente y revisa `reports/ejecuciones.log` y `reports/informe_ultimo.md`.

En Linux, puedes configurar `cron` (cambia la ruta de ejemplo):

```cron
0 9 * * * cd /ruta/al/proyecto && /usr/bin/python3 scripts/analizar.py >> reports/ejecuciones.log 2>&1
```

Estas tareas automatizan el análisis de los CSV existentes. No obtienen datos nuevos de una tienda real.

## Pruebas

En Windows:

```powershell
py -3 -m unittest discover -s tests -v
```

En Linux o macOS:

```bash
python3 -m unittest discover -s tests -v
```

Las pruebas comprueban la cantidad de registros, los controles de detección, la unicidad de las incidencias y la consistencia de los indicadores antes y después de documentar resoluciones.

## Estructura del proyecto

```text
centro-operaciones-tienda/
├── data/                      # Pedidos, pagos, envíos, tickets y resoluciones
├── scripts/
│   ├── generar_datos.py       # Generación reproducible de datos
│   ├── analizar.py            # Controles e informes
│   └── gestionar.py           # Bitácora de resoluciones
├── reports/                   # Incidencias, indicadores e informes generados
├── tests/                     # Pruebas unitarias
├── docs/                      # Diccionario de datos, casos y publicación
├── evidencias/                # Captura del panel y video de demostración
├── panel_operaciones.xlsx     # Panel y tablas para Sheets/Calc
├── ejecutar_informe.bat       # Ejecución en Windows
├── requirements.txt           # Sin dependencias externas
├── LICENSE
└── README.md
```

## Limitaciones

- Los datos son sintéticos y se almacenan en CSV; no hay base de datos, API ni integración con una plataforma de comercio electrónico.
- Los duplicados son coincidencias sospechosas que requieren revisión, no pruebas de doble cobro.
- Los pagos pendientes o rechazados se contabilizan por separado de las diferencias de monto.
- Los plazos SLA se expresan en horas corridas, no en horario laboral.
- Un incumplimiento SLA puede seguir figurando en el histórico aunque ya se haya respondido el ticket.
- Marcar una incidencia como resuelta documenta una acción operativa; no implica una modificación real del pedido, pago o envío.
- El panel no se actualiza automáticamente al ejecutar los scripts.

## Licencia

Distribuido bajo la [licencia MIT](LICENSE).
