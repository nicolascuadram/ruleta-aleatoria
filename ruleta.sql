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

INSERT INTO grupo (nombre, proyecto1, proyecto2, ref_instancia) VALUES
('Equipo Alfa', 'Ruleta', 'Crawlers', 1),
('Equipo Beta', 'Auto', 'Robot', 1),
('Equipo Gamma', 'Tablero', 'Ruleta', 2),
('Equipo Delta', 'Auto', 'Tablero', 2);

INSERT INTO alumno (nombre, ref_grupo) VALUES
('Ana Torres', 1),
('Luis Pérez', 1),
('Carlos Soto', 2),
('María Ríos', 2),
('Tomás Vidal', 3),
('Valentina Díaz', 3),
('Juan Pérez', 4),
('Sergio Martínez', 4);

INSERT INTO incidencia (categoria, subcategoria) VALUES
('Organizacional', 'Cambia de JP/SM'),
('Organizacional', 'Cambia de proyecto principal'),
('Organizacional', 'Cambia de tablero kanban'),
('Organizacional', 'Cambia de horario de trabajo'),
('Organizacional', 'Cambia de planificación'),
('Operativo', 'Error en el sistema'),
('Operativo', 'Error en la planificación'),
('Operativo', 'Error de hardware'),
('Operativo', 'Error de comunicación'),
('Operativo', 'Error de equipo'),
('Tecnológico', 'Actualizar librerías/api a última versión'),
('Tecnológico', 'Cambiar el IDE de desarrollo'),
('Tecnológico', 'Explora implementación alternativa'),
('Tecnológico', 'Cambia de librería/api de desarrollo'),
('Tecnológico', 'Cambia de entorno de desarrollo'),
('Proyecto', 'Desarrollador con licencia'),
('Proyecto', 'Cambiar el horario de reunión'),
('Proyecto', 'Intercambia un desarrollador(a) a otro proyecto'),
('Proyecto', 'Priorizar un solo proyecto'),
('Proyecto', 'Grupo en congeladora'),
('Personal', 'Desarrollador con actividad personal'),
('Personal', 'Desarrollador genera conflicto grupal'),
('Personal', 'Desarrollador prioriza tareas administrativas de proyecto'),
('Personal', 'Desarrollador genera malestar invididual'),
('Personal', 'Solicita cambio de SM/JP');

INSERT INTO registro (ref_incidencia, ref_grupo, alumno_escogido, grupo_intercambio, alumno_intercambio, fecha, comentario) VALUES
(20, 1, NULL, NULL, NULL, CURRENT_TIMESTAMP - interval '2 days', 'Se pausó al Equipo Alfa por baja participación'),
(21, 1, 'Luis Pérez', NULL, NULL, CURRENT_TIMESTAMP - interval '1 day', 'Luis no participará esta semana'),
(8, 2, NULL, NULL, NULL, CURRENT_TIMESTAMP - interval '3 days', 'Equipo Beta sin acceso a computadores'),
(25, 2, 'María Ríos', NULL, NULL, CURRENT_TIMESTAMP, 'María cambia su rol a Scrum Master'),
(18, 3, 'Tomás', 4, 'Sergio', CURRENT_TIMESTAMP, 'Equipo Gamma cambiará a Tomás por Sergio del Equipo Delta');


ALTER TABLE instancia ADD COLUMN nro_semanas INTEGER CHECK (nro_semanas > 0);
UPDATE instancia set nro_semanas = 18;
ALTER TABLE registro ADD COLUMN semana INTEGER;
