# 🎨 MetriCAN Brand · Repo de marca

Material de marca de MetriCAN para versionar en su **propio repositorio**
separado del código del configurator/firmware. Listo para usar.

---

## Contenido

```
brand/
├── brand-book/
│   ├── Brand Book.html          ← interactivo (web)
│   └── Brand Book - print.html  ← versión para imprimir/PDF (horizontal A4)
├── brochure/
│   ├── Brochure.html            ← interactivo
│   └── Brochure - print.html    ← versión para imprimir/PDF (vertical A4)
└── assets/
    ├── logo-metrican.png        ← logotipo horizontal
    ├── pcb-metrican.png         ← render PCB (fondo blanco)
    └── pcb-metrican-transparent.png  ← render PCB (sin fondo)
```

Los HTML están autocontenidos (fuentes desde Google Fonts CDN). Se abren con
doble click en cualquier navegador moderno.

---

## Paso a paso · Crear el repo y subirlo

### 1. Crear el repo en GitHub

1. Andá a https://github.com/new
2. Owner: `MRS0712` (o tu cuenta/org)
3. Repository name: **`metrican-brand`**
4. Description: *"Brand guidelines and marketing material for MetriCAN"*
5. Visibility: **Private** (recomendado mientras no esté publicada la marca)
6. NO inicializar con README ni .gitignore (lo subimos limpio)
7. Click **Create repository**

GitHub te muestra una pantalla con instrucciones. Anotate la URL que termina
en `.git`, algo como `https://github.com/MRS0712/metrican-brand.git`.

### 2. Subir el contenido desde tu máquina

Abrí PowerShell o terminal y ejecutá:

```powershell
# Posicionate en una carpeta donde quieras que viva el repo localmente
cd C:\dev

# Cloná el repo vacío que recién creaste
git clone https://github.com/MRS0712/metrican-brand.git
cd metrican-brand

# Copiá el contenido de esta carpeta brand/ al repo
# (asumiendo que el zip lo descomprimiste en C:\Downloads\metrican-deliverables\)
xcopy /E /I C:\Downloads\metrican-deliverables\brand\* .

# Verificá que están todos los archivos
dir

# Commit inicial
git add .
git commit -m "Initial brand book + brochure"
git push origin main
# (si tu rama por defecto se llama "master" usá: git push origin master)
```

Listo, el repo ya tiene todo.

---

## Cómo previsualizar

Abrí cualquiera de los `.html` con doble click. Para los `- print.html`,
una vez abiertos en el navegador, usá **Cmd/Ctrl + P → Guardar como PDF** para
generar PDFs distribuibles.

---

## Cómo seguir editando

Los HTML son simples — vos o tu agente pueden editarlos directamente:

- Cambiar copy: buscá el texto en el HTML y reemplazalo
- Cambiar colores: están como CSS variables al inicio (`--can-blue`, `--volt`, etc.)
- Agregar páginas: copiá una `<section class="page">` y editala

Si querés mantener histórico, cada cambio en un commit con descripción clara
(`brand: ajustar tagline portada`, `brochure: agregar página de specs`, etc.).

---

## Estructura para futuro crecimiento

Cuando agregues más piezas (templates de email, presentaciones, fotos
profesionales del PCB, etc.) sugerido:

```
brand/
├── brand-book/
├── brochure/
├── presentations/          ← decks futuros
├── templates/              ← email signature, social media
├── photography/            ← fotos profesionales del producto
└── assets/
    ├── logos/              ← variantes de logo (svg, png, dark, light)
    ├── product/            ← renders + fotos del PCB
    └── icons/              ← set propio del brand book
```
