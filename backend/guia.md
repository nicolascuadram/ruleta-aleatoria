# Guia para el uso del backend

## Recibir información
1. Para recibir la lista de instancias (cursos).

Hacer una petición `GET` a `ip:3000/api/instancias`.

Recibiras un json con un arreglo de instancias, este json posee la siguiente estructura: 
```
[
    {
        "id":1,
        "semestre":"2024-1",
        "profesor":"Prof. González"
    },
    {
        "id":2,
        "semestre":"2024-2",
        "profesor":"Prof. Ramírez"
    }
]
```

2. Para recibir la lista de grupos pertenecientes a una instancia.


Hacer una petición `GET` a `ip:3000/api/instancias/{id}`, donde id es el id de la instancia objetivo
Recibiras un json con un arreglo de grupo, este json posee la siguiente estructura: 
```
[
    {
        "id":1,
        "nombre":"Grupo Alfa",
        "ref_instancia":1
    },
    {
        "id":2,
        "nombre":"Grupo Beta",
        "ref_instancia":1
    }
]
```

3. Para recibir la lista de alumnos pertenecientes a un grupo.

Hacer una petición `GET` a `ip:3000/api/grupos/{id}`, donde id es el id del grupo objetivo
Recibiras un json con un arreglo de alumnos, este json posee la siguiente estructura: 

```
[
    {
        "id":7,
        "nombre":"alumno1",
        "ref_grupo":1},
    {
        "id":9,
        "nombre":"alumno3",
        "ref_grupo":1
    }
]
```


4. Obtener todas las incidencias registradas

Ruta: `ip:3000/api/incidencias`

Respuesta esperada:

```
[
    {
        "id": 1,
        "categoria": "Comportamiento",
        "descripcion": "Falta de respeto"
    },
    {
        "id": 2,
        "categoria": "Rendimiento",
        "descripcion": "Bajo rendimiento académico"
    }
]
```

7. Obtener solo las categorías de incidencias

Ruta: ip:3000/api/categorias

Respuesta esperada:

```

[
    {
        "categoria": "Comportamiento"
    },
    {
        "categoria": "Rendimiento"
    }
]

```

# Enviar información 
1. Crear una instancia

Método: POST
Ruta: ip:3000/api/instancias

Cuerpo (JSON):

{
    "semestre": "2024-2",
    "profesor": "Prof. Ramírez"
}

Respuesta esperada:

{
    "id": 3,
    "semestre": "2024-2",
    "profesor": "Prof. Ramírez"
}

2. Crear un grupo

Método: POST
Ruta: ip:3000/api/grupos

Cuerpo (JSON):

{
    "ref_instancia": 3,
    "nombre": "Grupo Gamma"
}

Respuesta esperada:

{
    "id": 4,
    "ref_instancia": 3,
    "nombre": "Grupo Gamma"
}

3. Crear un alumno

Método: POST
Ruta: ip:3000/api/alumnos

Cuerpo (JSON):

{
    "ref_grupo": 2,
    "nombre": "Juan Pérez"
}

Respuesta esperada:

{
    "id": 10,
    "ref_grupo": 2,
    "nombre": "Juan Pérez"
}

4. Crear una incidencia

Método: POST
Ruta: ip:3000/api/incidencias

Cuerpo (JSON):

{
    "categoria": "Asistencia",
    "descripcion": "Inasistencia reiterada"
    "alumno": "true"
}

Respuesta esperada:

{
    "id": 5,
    "categoria": "Asistencia",
    "descripcion": "Inasistencia reiterada"
    "alumno": "true"
}

5. Crear un registro de incidencia

Método: POST
Ruta: ip:3000/api/registros

Cuerpo (JSON):

{
    "ref_incidencia": 5,
    "ref_grupo": 2,
    "alumnoescogido": "Juan Pérez",
    "comentario": "No asistió a la clase de hoy"
}

Respuesta esperada:

{
    "id": 12,
    "ref_incidencia": 5,
    "ref_grupo": 2,
    "alumnoescogido": "Juan Pérez",
    "fecha": "2025-04-18T10:30:00.000Z",
    "comentario": "No asistió a la clase de hoy"
}
