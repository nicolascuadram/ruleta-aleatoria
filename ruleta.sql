create table if not exists instancia(
id serial primary key,
semestre text,
profesor text
);

create table if not exists grupo(
id serial primary key,
nombre text,
ref_instancia integer references instancia(id) on update cascade on delete cascade
);

create table if not exists alumno(
id serial primary key,
nombre text,
ref_grupo integer references instancia(id) on update cascade on delete cascade
);

create table if not exists incidencia(
id serial primary key,
categoria text not null,
descripción text,
alumno boolean
);

create table if not exists registro(
id serial primary key,
ref_incidencia integer references incidencia(id) on update cascade on delete cascade,
ref_grupo integer references grupo(id) on update cascade on delete cascade,
alumnoescogido text,
fecha timestamp,
comentario text
);

INSERT INTO instancia (semestre, profesor) VALUES
('2024-1', 'Prof. González'),
('2024-2', 'Prof. Ramírez');

INSERT INTO grupo (nombre, ref_instancia) VALUES
('Grupo Alfa', 1),
('Grupo Beta', 1),
('Grupo Gamma', 2);

INSERT INTO alumno (nombre, ref_grupo) VALUES
('Ana Torres', 1),
('Luis Pérez', 1),
('Carlos Soto', 2),
('María Ríos', 2),
('Tomás Vidal', 3),
('Valentina Díaz', 3);

INSERT INTO incidencia (categoria, descripción, alumno) VALUES
('Pausa grupal', 'El grupo no trabaja esta semana', false),
('Sin herramientas', 'El grupo no puede usar computador esta semana', false),
('Alumno inactivo', 'Un alumno del grupo no puede trabajar esta semana', true),
('Cambio de rol', 'Un alumno debe cambiar su rol habitual', true),
('Doble carga', 'El grupo debe entregar dos tareas esta semana', false);


INSERT INTO registro (ref_incidencia, ref_grupo, alumnoescogido, fecha, comentario) VALUES
(1, 1, NULL, CURRENT_TIMESTAMP - interval '2 days', 'Se pausó al Grupo Alfa por baja participación'),
(3, 1, 'Luis Pérez', CURRENT_TIMESTAMP - interval '1 day', 'Luis no participará esta semana'),
(2, 2, NULL, CURRENT_TIMESTAMP - interval '3 days', 'Grupo Beta sin acceso a computadores'),
(4, 2, 'María Ríos', CURRENT_TIMESTAMP, 'María cambia su rol de lider a programadora'),
(5, 3, NULL, CURRENT_TIMESTAMP, 'Grupo Gamma tendrá entrega doble esta semana');

