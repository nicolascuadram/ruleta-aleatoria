import { Router } from "express";
import pool from "../db/db.js";
import { getQueries, postQueries } from "../db/queries.js";

const router = Router();

//PETICIONES GET
router.get('/instancias', async(req, res) => {
   try {
       const result = await pool.query(getQueries.GetInstancias);
       res.json(result.rows);
   } catch (error) {
        res.status(500).json({error: "Error al obtener las incidencias"});
   }
})
router.get('/incidencias', async(req, res) => {
   try {
       const result = await pool.query(getQueries.GetIncidencias);
       res.json(result.rows);
   } catch (error) {
        res.status(500).json({error: "Error al obtener las incidencias"});
   }
})

router.get('/incidencias/:id', async(req, res) => {
   try {
       const { id } = req.params;
       const result = await pool.query(getQueries.GetIncidenciasByInstancia, [id]);
       res.json(result.rows);
   } catch (error) {
        res.status(500).json({error: "Error al obtener las incidencias"});
   }
})

router.get('/categorias', async(req, res) => {
   try {
       const result = await pool.query(getQueries.GetCategories);
       res.json(result.rows);
   } catch (error) {
        res.status(500).json({error: "Error al obtener las categorias"});
   }
})
router.get('/grupos', async(req, res) => {
   try {
       const result = await pool.query(getQueries.GetGrupos);
       res.json(result.rows);
   } catch (error) {
        res.status(500).json({error: "Error al obtener los grupos"});
   }
})
router.get('/alumnos', async(req, res) => {
   try {
       const result = await pool.query(getQueries.GetAlumnos);
       res.json(result.rows);
   } catch (error) {
        res.status(500).json({error: "Error al obtener los alumnos"});
   }
})

//crea la ruta que retorna la lista de registros de una instancia
router.get('/registros', async(req, res) => {
   try {
       const result = await pool.query(getQueries.GetRegistros);
       res.json(result.rows);
   } catch (error) {
        res.status(500).json({error: "Error al obtener los registros"});
   }
})


//Obtener los grupos asociados a una instancia, mediante el id de la instancia
router.get('/instancias/:id', async(req, res) => {
   try {
       const { id } = req.params;
       const result = await pool.query(getQueries.GetGruposByInstancia, [id]);
       res.json(result.rows);
   } catch (error) {
        res.status(500).json({error: "Error al obtener los grupos"});
   }
})
//Obtener los alumnos asociados a un grupo, mediante el id del grupo
router.get('/grupos/:id', async(req, res) => {
   try {
       const { id } = req.params;
       const result = await pool.query(getQueries.GetAlumnosByGrupo, [id]);
       res.json(result.rows);
   } catch (error) {
        res.status(500).json({error: "Error al obtener los grupos"});
   }
})

router.get('/registros/:id', async(req, res) => {
   try {
       const { id } = req.params;
       const result = await pool.query(getQueries.GetRegistrosByInstancia, [id]);
       console.log(result.rows);
       res.json(result.rows);

   } catch (error) {
        console.log(error);
        res.status(500).json({error: "Error al obtener los registros"});
   }
})


router.get('/historial', async (req, res) => {
    try {
        const result = await pool.query(getQueries.GetHistorialRuleta); 
        res.json(result.rows);
    } catch (error) {
        res.status(500).json({ error: "Error al obtener el historial de la ruleta" });
    }
});

router.get('/instancia/:id/semanas', async (req, res) => {
    const { id } = req.params;
    try {
        const result = await pool.query(
            'SELECT nro_semanas FROM instancia WHERE id = $1',
            [id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Instancia no encontrada' });
        }

        res.json({ nro_semanas: result.rows[0].nro_semanas });
    } catch (error) {
        res.status(500).json({ error: 'Error al obtener semanas de la instancia' });
    }
});

router.get('/instancia/:id/semana/:semana/grupos-ejecutados', async (req, res) => {
    const { id, semana } = req.params;
    try {
        const result = await pool.query(`
            SELECT DISTINCT g.id, g.nombre
            FROM grupo g
            JOIN registro r ON g.id = r.ref_grupo
            WHERE g.ref_instancia = $1 AND r.semana = $2
        `, [id, semana]);

        res.json(result.rows);
    } catch (error) {
        res.status(500).json({ error: 'Error al obtener grupos ejecutados en la semana' });
    }
});

router.get('/instancia/:id/semanas-completas', async (req, res) => {
    const { id } = req.params;
    try {
        // Obtener cantidad total de grupos en la instancia
        const grupoCountResult = await pool.query(
            'SELECT COUNT(*) FROM grupo WHERE ref_instancia = $1',
            [id]
        );
        const totalGrupos = parseInt(grupoCountResult.rows[0].count);

        // Obtener todas las semanas en las que ese número de grupos ya registraron
        const semanasCompletasResult = await pool.query(`
            SELECT semana
            FROM registro r
            JOIN grupo g ON r.ref_grupo = g.id
            WHERE g.ref_instancia = $1
            GROUP BY semana
            HAVING COUNT(DISTINCT r.ref_grupo) = $2
            ORDER BY semana
        `, [id, totalGrupos]);

        res.json(semanasCompletasResult.rows.map(row => row.semana));
    } catch (error) {
        res.status(500).json({ error: 'Error al obtener semanas completas' });
    }
});




// POTICIONES POST
router.post('/instancias', async (req, res) => {
    try {
        const { semestre, profesor, nro_semanas } = req.body;
        const result = await pool.query(postQueries.AddInstancia, [semestre, profesor, nro_semanas]);
        res.status(201).json(result.rows[0]);
    } catch (error) {
        res.status(500).json({ error: "Error al crear la instancia" });
    }
});

router.post('/grupos', async (req, res) => {
    try {
        const { ref_instancia, nombre,proyecto1,proyecto2 } = req.body;
        const result = await pool.query(postQueries.AddGrupo, [ref_instancia, nombre,proyecto1,proyecto2]);
        res.status(201).json(result.rows[0]);
    } catch (error) {
        res.status(500).json({ error: "Error al crear el grupo" });
    }
});

router.post('/alumnos', async (req, res) => {
    try {
        const { ref_grupo, nombre } = req.body;
        const result = await pool.query(postQueries.AddAlumno, [ref_grupo, nombre]);
        res.status(201).json(result.rows[0]);
    } catch (error) {
        res.status(500).json({ error: "Error al crear el alumno" });
    }
});

router.post('/incidencias', async (req, res) => {
    try {
        const { ref_instancia,categoria, subcategoria} = req.body;
        const result = await pool.query(postQueries.AddIncidencia, [ref_instancia, categoria, subcategoria]);
        res.status(201).json(result.rows[0]);
    } catch (error) {
        res.status(500).json({ error: "Error al crear la incidencia" });
    }
});

router.post('/registros/:id', async(req, res) => {
   try {
       const { id } = req.params;
       const { ref_incidencia, ref_grupo, alumno_escogido, grupo_intercambio, alumno_intercambio, comentario, semana } = req.body;
       const result = await pool.query(postQueries.AddRegistro, [ref_incidencia, ref_grupo, alumno_escogido, grupo_intercambio, alumno_intercambio, comentario, semana]);
       console.log('Registro insertado:', result.rows);
       res.json(result.rows);
   } catch (error) {
       console.log(error);
       res.status(500).json({error: "Error al crear el registro"});
   }
});



export default router;