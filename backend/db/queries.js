export const getQueries = {
    GetInstancias: "SELECT * FROM instancia",
    GetGrupos: "SELECT * FROM grupo",
    GetAlumnos: "SELECT * FROM alumno",
    GetIncidencias: "SELECT * FROM incidencia",
    GetCategories: "SELECT categoria FROM incidencia",
    GetRegistros: "SELECT r.id, i.categoria, i.descripcion, r.alumnoescogido, r.fecha, r.comentario, g.nombre AS grupo FROM registro r JOIN incidencia i ON r.ref_incidencia = i.id JOIN grupo g ON r.ref_grupo = g.id ORDER BY r.fecha DESC",
    GetInstanciaById: "SELECT * FROM instancia WHERE id = $1",
    GetGruposByInstancia: "SELECT * FROM grupo WHERE ref_instancia = $1",
    GetAlumnosByGrupo: "SELECT * FROM alumno WHERE ref_grupo = $1",
}

export const postQueries = {
    AddInstancia: "INSERT INTO instancia (semestre, profesor) VALUES ($1, $2) RETURNING *",
    AddGrupo: "INSERT INTO grupo (ref_instancia, nombre) VALUES ($1, $2) RETURNING *",
    AddAlumno: "INSERT INTO alumno (ref_grupo, nombre) VALUES ($1, $2) RETURNING *",
    AddIncidencia: "INSERT INTO incidencia (categoria, descripcion) VALUES ($1, $2) RETURNING *",
    AddRegistro: "INSERT INTO registro (ref_incidencia, ref_grupo, alumnoescogido, fecha, comentario) VALUES ($1, $2, $3, CURRENT_TIMESTAMP, $4) RETURNING *",
}
