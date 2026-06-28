# Local Schedule Planner - Flutter Web

Aplicación Flutter Web local-first para capturar profesores, materias, días y horas, y generar visualizaciones de horarios posibles.

## Características

- Horario base: lunes a viernes, de 07:00 a 21:00.
- Entrada de hora con HTML `input type="time"` en formato 24 horas.
- Base de datos local usando JSON.
- Vista responsiva: en escritorio usa panel lateral + calendario; en móvil usa navegación inferior entre `Horario` y `Opciones`.
- Calendario con scroll horizontal y vertical para pantallas pequeñas.
- Generación automática de combinaciones válidas: elige una opción por materia y descarta empalmes.
- Arquitectura separada por capas: `domain`, `data`, `application`, `core` y `presentation`.

## Cambios anti-cache incluidos

Este proyecto ya viene ajustado para evitar los problemas típicos de caché en Flutter Web y GitHub Pages:

1. El JSON principal se sirve desde `web/data/professors_seed.json`.
2. La app carga ese JSON por HTTP con cache busting: `?v=SEED_DATA_VERSION&t=timestamp`.
3. Se conserva `assets/data/professors_seed.json` como respaldo para entornos no web o fallos de red.
4. Si el JSON publicado cambia, la app detecta el cambio por hash y actualiza la base local del navegador.
5. Se agregó el botón `Recargar JSON publicado` para forzar que el navegador reemplace su base local con el JSON desplegado.
6. `web/index.html` desregistra service workers anteriores y limpia caches viejos relacionados con Flutter/horarios.
7. El workflow de GitHub Pages usa `--pwa-strategy=none`, `flutter clean` y `--dart-define=SEED_DATA_VERSION=${{ github.sha }}`.
8. Se agregó `web/.nojekyll` para evitar problemas de publicación de archivos generados en GitHub Pages.

## Editar el JSON base

Para cambiar la base publicada de profesores/horarios, edita principalmente:

```txt
web/data/professors_seed.json
```

Para mantener respaldo fuera de web, puedes copiar el mismo contenido en:

```txt
assets/data/professors_seed.json
```

El formato puede ser una lista directa:

```json
[
  {
    "id": "web-oo4-lomeli",
    "subject": "Desarrollo de Aplicaciones Web",
    "professor": "Miguel Ángel Vargas Lomelí",
    "section": "OO4",
    "sessions": [
      {"day": "monday", "start": "09:00", "end": "10:00"},
      {"day": "wednesday", "start": "09:00", "end": "11:00"},
      {"day": "friday", "start": "09:00", "end": "11:00"}
    ]
  }
]
```

También acepta un objeto con `items`, `options` o `courses`.

## Ejecutar localmente

```bash
flutter pub get
flutter run -d chrome
```

## Probar vista móvil

En Chrome:

1. Ejecuta `flutter run -d chrome`.
2. Abre DevTools.
3. Activa el modo dispositivo móvil.
4. Prueba anchos entre 360 px y 430 px.

## Desplegar en GitHub Pages

El workflow ya está en:

```txt
.github/workflows/deploy.yml
```

La línea importante es:

```bash
flutter build web --release --base-href "/Generador-de-horarios/" --pwa-strategy=none --dart-define=SEED_DATA_VERSION=${{ github.sha }}
```

Si tu repositorio cambia de nombre, modifica el `base-href`.
