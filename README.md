# Local Schedule Planner - Flutter Web

Aplicación Flutter Web local-first para capturar profesores, materias, días y horas, y generar visualizaciones de horarios posibles.

## Características

- Horario base: lunes a viernes, de 07:00 a 21:00.
- Entrada de hora con HTML `input type="time"` en formato 24 horas.
- Base de datos local usando JSON.
- En Flutter Web, el seed vive en `assets/data/professors_seed.json` y los cambios se guardan en `localStorage` mediante `shared_preferences`.
- Generación automática de combinaciones válidas: elige una opción por materia y descarta empalmes.
- Visualización gráfica con bloques por día y hora.
- Arquitectura separada por capas: domain, data, application y presentation.


## Reiniciar base local

El navegador guarda cambios localmente. Para reiniciar desde el JSON seed, borra los datos del sitio/localStorage desde DevTools o usa otro navegador.
