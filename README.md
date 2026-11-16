# Teleprompter

Aplicación de Teleprompter moderna, ligera e interactiva diseñada para leer tu guion con fluidez mientras grabas videos o realizas presentaciones. Disponible como **app nativa de macOS**, **archivo HTML autocontenido** y **aplicación web modular**.

## 🚀 Características

- **Control de Reproducción:** Botones intuitivos para iniciar, pausar y detener la lectura (con detención automática al finalizar el texto).
- **Edición de Guion Integrada:** Panel rápido para escribir o pegar tu texto fácilmente.
- **Control de Velocidad:** Ajuste por niveles automáticos o entrada manual precisa (`0.1` a `20`).
- **Texto y Modo Espejo:** Ajuste de tamaño de letra (`20–120 px`), ancho del bloque de texto (`25%–70%`) y reflejo horizontal (*Espejo*) para uso con cristal prompter físico.
- **Líneas Guía Personalizables:**
  - Ajuste vertical (`0%–40%`) y horizontal (`10%–80%`) para alinear la mirada exactamente con el lente de la cámara.
  - Opción para mostrar u ocultar las líneas de referencia.
- **Alineación de Cámara:** Configura la posición del texto según la cámara (*Izquierda*, *Derecha* o *Centro*).
- **Personalización Visual:** Interfaz translúcida (*glassmorphism*) con **tema claro / oscuro** persistente y selección de colores de acento (*Teal*, *Naranja*, *Azul índigo*, *Ámbar*, *Violeta*).
- **Atajos de Teclado:**
  - `Espacio`: Pausar / Reanudar
  - `↑ / ↓`: Desplazar el guion manualmente
  - `← / →`: Reducir / Aumentar velocidad
  - `S`: Detener y volver al inicio
  - `D`: Abrir el editor de guion
  - `H`: Ocultar / Mostrar controles

## 📦 Variantes disponibles

1. **App nativa para macOS (`Teleprompter.app`)**
   - Contenedor nativo en `Cocoa` + `WKWebView` (macOS 12.0 o superior) que ejecuta la app sin depender de un navegador externo.
   - Sincroniza el tema claro/oscuro con la apariencia de la ventana e incluye menús nativos de macOS (edición con `Cmd+C/V/X/A/Z`, pantalla completa con `Cmd+Ctrl+F`, ocultar y salir).
2. **HTML autocontenido (`Teleprompter.html`)**
   - Archivo único portable con estilos, lógica y favicon integrados; basta con abrirlo en cualquier navegador sin copiar otros archivos.
3. **Versión web modular (`index.html` + `style.css` + `script.js`)**
   - Código fuente web directo, sin servidor ni dependencias externas.

## 🛠️ Tecnologías Utilizadas

- **HTML5, CSS3 y JavaScript (Vanilla ES6):** Variables CSS, diseño *glassmorphism* y `requestAnimationFrame` para desplazamiento fluido.
- **Swift (`Cocoa` + `WebKit` / `QuartzCore`):** Wrapper nativo para macOS y generador del icono `.icns` (`macos/TeleprompterApp.swift`, `macos/GenerateIcon.swift`).
- **Bash + Python 3:** Script de empaquetado (`build.sh`).

## 📁 Estructura del Proyecto

```text
Teleprompter/
├── index.html          # Estructura principal de la aplicación web
├── style.css           # Estilos, temas claro/oscuro y diseño visual
├── script.js           # Lógica, controles y sincronización de tema
├── build.sh            # Script para compilar Teleprompter.html y Teleprompter.app
├── macos/
│   ├── TeleprompterApp.swift  # Wrapper nativo macOS (WKWebView)
│   └── GenerateIcon.swift     # Generador de AppIcon.icns estilo macOS
├── Teleprompter.app/   # Aplicación macOS lista para usar
├── Teleprompter.html   # Versión web autocontenida en un solo archivo
└── README.md           # Documentación del proyecto
```

## 💻 Instalación, Uso y Compilación

### Uso directo
- **En macOS (app nativa):** Abre `Teleprompter.app` directamente (puedes moverla a `/Applications` si lo deseas).
- **En cualquier navegador (portable):** Abre `Teleprompter.html`.
- **Desde el código fuente:** Clona el repositorio y abre `index.html` en tu navegador:
  ```bash
  git clone https://github.com/LchJav/Teleprompter.git
  ```

Haz clic en **✎ Editar guion**, pega o escribe tu texto y presiona **▶ Iniciar**.

### Recompilar la app de macOS y el HTML autocontenido
Requiere macOS con Xcode / Command Line Tools (`swift`, `swiftc`, `codesign`) y `python3`:

```bash
./build.sh
```

El script generará los archivos compilados dentro de `dist/` (`dist/Teleprompter.app` y `dist/Teleprompter.html`).
