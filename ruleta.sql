create table if not exists instancia(
id serial primary key,
semestre text,
profesor text
);

create table if not exists grupo(
id serial primary key,
nombre text,
proyecto1 text,
proyecto2 text,
ref_instancia integer references instancia(id) on update cascade on delete cascade
);

create table if not exists alumno(
id serial primary key,
nombre text,
ref_grupo integer references grupo(id) on update cascade on delete cascade
);

create table if not exists incidencia(
id serial primary key,
ref_instancia integer references instancia(id) on update cascade on delete cascade,
categoria text not null,
subcategoria text not null
);

create table if not exists registro(
id serial primary key,
ref_incidencia integer references incidencia(id) on update cascade on delete cascade,
ref_grupo integer references grupo(id) on update cascade on delete cascade,
alumno_escogido text,
grupo_intercambio integer references grupo(id) on update cascade on delete cascade,
alumno_intercambio text,
fecha timestamp,
comentario text
);

INSERT INTO instancia (semestre, profesor) VALUES
('2024-1', 'Luis Silvestre'),
('2024-2', 'Luis Silvestre');

INSERT INTO grupo (nombre,proyecto1,proyecto2,ref_instancia) VALUES
('Equipo Alfa','proyecto1','proyecto2', 1),
('Equipo Beta','proyecto1','proyecto2', 1),
('Equipo Gamma','proyecto1','proyecto3', 2),
('Equipo Delta','proyecto1','proyecto4', 2);

INSERT INTO alumno (nombre, ref_grupo) VALUES
('Ana Torres', 1),
('Luis Pérez', 1),
('Carlos Soto', 2),
('María Ríos', 2),
('Tomás Vidal', 3),
('Valentina Díaz', 3),
('Juan Pérez', 4),
('Sergio Martínez', 4);

INSERT INTO incidencia (ref_instancia, categoria, subcategoria) VALUES
(1, 'Organizacional', 'Cambia de JP/SM'),
(1, 'Organizacional', 'Cambia de proyecto principal'),
(1, 'Organizacional', 'Cambia de tablero kanban'),
(1, 'Organizacional', 'Cambia de horario de trabajo'),
(1, 'Organizacional', 'Cambia de planificación'),
(1, 'Operativo', 'Error en el sistema'),
(1, 'Operativo', 'Error en la planificación'),
(1, 'Operativo', 'Error de hardware'),
(1, 'Operativo', 'Error de comunicación'),
(1, 'Operativo', 'Error de equipo'),
(1, 'Tecnológico', 'Actualizar librerías/api a última versión'),
(1, 'Tecnológico', 'Cambiar el IDE de desarrollo'),
(1, 'Tecnológico', 'Explora implementación alternativa'),
(1, 'Tecnológico', 'Cambia de librería/api de desarrollo'),
(1, 'Tecnológico', 'Cambia de entorno de desarrollo'),
(1, 'Proyecto', 'Desarrollador con licencia'),
(1, 'Proyecto', 'Cambiar el horario de reunión'),
(1, 'Proyecto', 'Intercambia un desarrollador(a) a otro proyecto'),
(1, 'Proyecto', 'Priorizar un solo proyecto'),
(1, 'Proyecto', 'Grupo en congeladora'),
(1, 'Personal', 'Desarrollador con actividad personal'),
(1, 'Personal', 'Desarrollador genera conflicto grupal'),
(1, 'Personal', 'Desarrollador prioriza tareas administrativas de proyecto'),
(1, 'Personal', 'Desarrollador genera malestar invididual'),
(1, 'Personal', 'Solicita cambio de SM/JP');

INSERT INTO registro (ref_incidencia, ref_grupo, alumno_escogido, grupo_intercambio, alumno_intercambio, fecha, comentario) VALUES
(20, 1, NULL, NULL, NULL, CURRENT_TIMESTAMP - interval '2 days', 'Se pausó al Equipo Alfa por baja participación'),
(21, 1, 'Luis Pérez', NULL, NULL, CURRENT_TIMESTAMP - interval '1 day', 'Luis no participará esta semana'),
(8, 2, NULL, NULL, NULL, CURRENT_TIMESTAMP - interval '3 days', 'Equipo Beta sin acceso a computadores'),
(25, 2, 'María Ríos', NULL, NULL, CURRENT_TIMESTAMP, 'María cambia su rol a Scrum Master'),
(18, 3, 'Tomás', 4, 'Sergio', CURRENT_TIMESTAMP, 'Equipo Gamma cambiará a Tomás por Sergio del Equipo Delta');