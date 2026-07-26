# Teleprompter Web App

Una aplicación web moderna, ligera e interactiva de Teleprompter diseñada para ayudarte a leer tu guion fluidamente mientras grabas videos o realizas presentaciones.

## 🚀 Características

- **Control de Reproducción:** Botones intuitivos para iniciar, pausar y detener la lectura.
- **Edición de Guion Integrada:** Panel rápido para escribir o pegar tu texto fácilmente.
- **Control de Velocidad:** Ajuste por niveles automáticos o entrada de velocidad manual precisa.
- **Modo Espejo (Mirror):** Reflejo horizontal del texto, ideal para uso con cristal prompter físico.
- **Líneas Guía Personalizables:**
  - Ajuste vertical y horizontal para alinear la mirada exactamente con el lente de la cámara.
  - Opción para mostrar u ocultar las líneas de referencia.
- **Alineación de Cámara:** Configura la posición del texto según la cámara (izquierda, derecha o centro).
- **Personalización de Tema:** Selección de colores de acento (*Teal*, *Naranja*, *Azul Índigo*, *Ámbar*, *Violeta*).
- **Atajos de Teclado:**
  - `Espacio`: Pausar / Reanudar
  - `↑ / ↓`: Desplazar el guion manualmente
  - `← / →`: Ajustar velocidad
  - `S`: Detener y volver al inicio
  - `D`: Abrir el editor de guion
  - `H`: Ocultar / Mostrar barra de herramientas

## 🛠️ Tecnologías Utilizadas

- **HTML5**
- **CSS3** (Variables CSS, Flexbox, animaciones de transición)
- **JavaScript (Vanilla ES6)** (Uso de `requestAnimationFrame` para desplazamiento fluido a 60fps)

## 📁 Estructura del Proyecto

```text
Teleprompter/
├── index.html     # Estructura principal de la aplicación
├── style.css      # Estilos y tema visual
├── script.js     # Lógica y control del teleprompter
└── README.md      # Documentación del proyecto
```

## 💻 Instalación y Uso

No requiere servidor ni instalación de dependencias externas.

1. Clona este repositorio:
   ```bash
   git clone https://github.com/LchJav/Teleprompter.git
   ```
2. Abre `index.html` en tu navegador de preferencia.
3. Haz clic en **✎ Editar guion**, escribe tu texto y presiona **▶ Iniciar**.
