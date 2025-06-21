create table if not exists instancia(
id serial primary key,
semestre text,
profesor text,
nro_semanas INTEGER CHECK (nro_semanas > 0)
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
comentario text,
semana INTEGER
);