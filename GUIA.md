# Guía de uso — W11::OPTIMIZER

Esta guía explica paso a paso cómo usar el script, aunque nunca hayas ejecutado un script de PowerShell. Calcula unos 5 minutos.

*[Français](MODE-EMPLOI.md) · [English](USER-GUIDE.md) · [Español](GUIA.md) · [Deutsch](ANLEITUNG.md) · [Nederlands](HANDLEIDING.md) · [中文](GUIDE-ZH.md) · [日本語](GUIDE-JA.md) · [العربية](GUIDE-AR.md) · [ไทย](GUIDE-TH.md)*

---

## 1. Qué hace el script (y qué no hace)

**Hace:** cambia 10 ajustes de Windows 11 para que los juegos funcionen mejor (plan de energía, Modo de juego, Xbox Game Bar, ratón, efectos visuales…). Son los mismos ajustes que podrías cambiar a mano en la Configuración de Windows. Tú eliges cuáles en un menú.

**No hace:**
- no instala ni descarga nada, y no necesita Internet;
- no borra ningún archivo ni toca tus juegos ni tus controladores;
- no se queda en segundo plano: una vez cerrado, no sigue funcionando nada.

**Conviene saberlo:** antes de cada cambio, guarda los valores anteriores. Así puedes **dejarlo todo como estaba** en cualquier momento (ver el paso 6).

---

## 2. Descargar el script

1. En la página de GitHub del proyecto, haz clic en el archivo **`JohnWishGamingOptimizer.ps1`**.
2. Haz clic en **Download raw file** (el icono con una flecha hacia abajo, arriba a la derecha del código).
3. El archivo llega a tu carpeta **Descargas**. Puedes dejarlo ahí o moverlo donde quieras.

> Otra opción: botón verde **Code** → **Download ZIP**, y luego clic derecho en el ZIP → **Extraer todo**.

### Desbloquear el archivo (una sola vez)

Windows suele bloquear los scripts descargados de Internet. Para evitar mensajes de error:

1. Clic derecho en `JohnWishGamingOptimizer.ps1` → **Propiedades**.
2. Abajo en la pestaña **General**, marca **Desbloquear** (si la casilla no aparece, el archivo no está bloqueado).
3. Haz clic en **Aceptar**.

---

## 3. Ejecutar el script

### Método sencillo

1. Clic derecho en `JohnWishGamingOptimizer.ps1`.
2. Elige **Ejecutar con PowerShell**.
   En Windows 11, a veces hay que hacer clic antes en **Mostrar más opciones** para verlo.

> ⚠️ **No hagas doble clic** en el archivo: se abriría en el Bloc de notas en lugar de ejecutarse.

### Si la ventana se cierra enseguida o dice que «la ejecución de scripts está deshabilitada»

1. Abre la carpeta que contiene el script.
2. Haz clic derecho en un espacio vacío de la carpeta → **Abrir en Terminal**.
3. Copia esta línea, pégala en la ventana (clic derecho para pegar) y pulsa **Intro**:

```powershell
powershell -ExecutionPolicy Bypass -File .\JohnWishGamingOptimizer.ps1
```

Este comando permite **solo esta ejecución** del script: no cambia la seguridad de tu PC.

### Para desbloquear el módulo «Programación de GPU» (administrador)

Uno de los módulos necesita permisos de administrador. Sin ellos, simplemente queda bloqueado (`◇ ADMIN`) y todo lo demás funciona.

1. Clic derecho en el botón **Inicio** → **Terminal (Administrador)** → **Sí**.
2. Escribe `cd` seguido de un espacio, arrastra la carpeta del script a la ventana y pulsa **Intro**.
3. Pega el comando de arriba y pulsa **Intro**.

---

## 4. Usar el menú

1. **La intro** se muestra (animación, logotipo, arranque tipo BIOS). Pulsa cualquier tecla para saltarla.
2. **Elige tu idioma** con las flechas **↑ ↓** y luego **Intro**.
3. **El menú** muestra los 10 módulos y su estado:

| Estado | Significado |
|---|---|
| `● ACTIVO` | El ajuste ya está aplicado |
| `○ POR ACTIVAR` | El ajuste todavía no está aplicado |
| `◇ ADMIN` | Hay que ejecutar el script como administrador (ver arriba) |
| `– N/D` | No afecta a este PC (por ejemplo, OneDrive no se inicia con Windows) |

Los módulos que aún no están activos vienen **marcados por defecto**. La descripción del módulo seleccionado aparece abajo del marco.

| Tecla | Acción |
|---|---|
| **↑ ↓** | Moverse por la lista |
| **Espacio** | Marcar / desmarcar el módulo |
| **A** | Marcar todo |
| **N** | Desmarcar todo |
| **Intro** | Aplicar los módulos marcados (y luego **S** para confirmar) |
| **R** | Restaurar los ajustes originales (ver el paso 6) |
| **Q** o **Esc** | Salir **sin cambiar nada** |

4. Tras confirmar, cada módulo muestra `[OK]` (correcto) o `[X]` (problema, con la explicación).

---

## 5. Después del script

- **Reinicia tu PC**: algunos ajustes (Programación de GPU, parte de los efectos visuales) solo se aplican tras reiniciar.
- **Los ajustes se mantienen** después de cerrar el script y tras los reinicios. No hace falta ejecutarlo en cada arranque.
- Una actualización importante de Windows puede devolver algunos ajustes a su valor por defecto: vuelve a ejecutar el script y te mostrará lo que ya no está `● ACTIVO`.

---

## 6. Dejarlo todo como estaba

1. Vuelve a ejecutar el script (como en el paso 3).
2. En el menú, pulsa **R** y luego **S** para confirmar.
3. Reinicia el PC.

El script restaura los ajustes tal como estaban **antes de su primerísimo uso**, aunque lo hayas ejecutado varias veces.

Si se aplicó el módulo «Programación de GPU», ejecuta el script **como administrador** para restaurarlo.

> Los valores anteriores se guardan en `Documents\JohnWishOptimizer\` (la carpeta **Documentos**). **No borres esta carpeta** si quieres poder volver atrás.

---

## 7. Preguntas frecuentes

**El archivo se abre en el Bloc de notas.**
Ciérralo y usa clic derecho → **Ejecutar con PowerShell** (paso 3).

**Windows o mi antivirus muestra una advertencia.**
El script no está firmado digitalmente, como la mayoría de los scripts gratuitos. Es un simple archivo de texto: puedes abrirlo en el Bloc de notas para leer exactamente lo que hace antes de ejecutarlo.

**Los colores o los símbolos se ven mal (`?` o cuadrados).**
Usa **Terminal Windows** (incluido en Windows 11) en lugar de la antigua ventana de PowerShell: el método «Abrir en Terminal» del paso 3.

**La imagen de la intro es pequeña o sale cortada.**
Agranda la ventana antes de ejecutar el script: la imagen se adapta y se ve más nítida. Cualquier tecla salta la intro.

**¿Puede dar problemas con el antitrampas de los juegos?**
El script solo cambia ajustes de Windows. No toca los archivos ni la memoria de los juegos, y no sigue funcionando una vez cerrado.

**¿Cómo se desinstala?**
No hay nada que desinstalar. Si quieres deshacer sus efectos, sigue el paso 6 y luego borra el archivo.

**Quiero aplicarlo todo sin pasar por el menú.**

```powershell
powershell -ExecutionPolicy Bypass -File .\JohnWishGamingOptimizer.ps1 -All
```

**Quiero elegir el idioma directamente** (`fr`, `en`, `es`, `de`, `nl`, `zh`, `ja`, `ar`, `th`):

```powershell
powershell -ExecutionPolicy Bypass -File .\JohnWishGamingOptimizer.ps1 -Language es
```

---

*© 2025-2026 John Wish — Todos los derechos reservados. Uso personal gratuito; prohibido copiar, modificar, redistribuir o vender sin autorización. Ver [LICENSE](LICENSE).*
