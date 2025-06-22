# Ruleta Aleatoria
Sistema de Ruleta Aleatoria de Incidencias para el Curso de Gestión de Proyectos Tecnológicos.

## Instrucciones para levantar de manera local.

Agregar un archivo `.env` en `/backend` con las siguientes variables de entorno:
```bash
PGHOST=tu_host_de_postgres
PGUSER=tu_usuario_de_postgres
PGPASSWORD=tu_contraseña_de_postgres
PGDATABASE=el_nombre_de_tu_base_de_datos
PGPORT=el_puerto_de_postgres
```

Agregar un archivo `.env` en `/frontend` con la siguiente variable de entorno:
```bash
PUBLIC_API_URL=la_url_del_backend
```

Instalar las dependencias del backend:
```bash
cd backend
npm install
```

Instalar las dependencias del frontend:
```bash
cd frontend
npm install
```

Levantar el backend:
```bash
cd backend
npm run dev
```

Levantar el frontend:
```bash
cd frontend
npm run dev
```

## Instrucciones para levantar con Docker.

Agregar un archivo `.env` en la raíz del proyecto con las siguientes variables de entorno:
```bash
POSTGRES_DB=el_nombre_de_tu_base_de_datos
POSTGRES_USER=tu_usuario_de_postgres
POSTGRES_PASSWORD=tu_contraseña_de_postgres
```

Agregar un archivo `.env` en `/backend` con las siguientes variables de entorno:
```bash
PGHOST=tu_host_de_postgres
PGUSER=tu_usuario_de_postgres
PGPASSWORD=tu_contraseña_de_postgres
PGDATABASE=el_nombre_de_tu_base_de_datos
PGPORT=el_puerto_de_postgres
PORT=el_puerto_del_backend
```

Agregar un archivo `.env` en `/frontend` con la siguiente variable de entorno:
```bash
PUBLIC_API_URL=la_url_del_backend
```

Luego, en la raíz del proyecto, ejecutar el siguiente comando para levantar los servicios de Docker:
```bash
docker compose up --build -d
```