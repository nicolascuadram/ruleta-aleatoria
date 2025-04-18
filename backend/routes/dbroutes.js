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


// POTICIONES POST
router.post('/instancias', async (req, res) => {
    try {
        const { semestre, profesor } = req.body;
        const result = await pool.query(postQueries.AddInstancia, [semestre, profesor]);
        res.status(201).json(result.rows[0]);
    } catch (error) {
        res.status(500).json({ error: "Error al crear la instancia" });
    }
});

router.post('/grupos', async (req, res) => {
    try {
        const { ref_instancia, nombre } = req.body;
        const result = await pool.query(postQueries.AddGrupo, [ref_instancia, nombre]);
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
        const { categoria, descripcion, alumno } = req.body;
        const result = await pool.query(postQueries.AddIncidencia, [categoria, descripcion, alumno]);
        res.status(201).json(result.rows[0]);
    } catch (error) {
        res.status(500).json({ error: "Error al crear la incidencia" });
    }
});

router.post('/registros', async (req, res) => {
    try {
        const { ref_incidencia, ref_grupo, alumnoescogido, comentario } = req.body;
        const result = await pool.query(postQueries.AddRegistro, [ref_incidencia, ref_grupo, alumnoescogido, comentario]);
        res.status(201).json(result.rows[0]);
    } catch (error) {
        res.status(500).json({ error: "Error al crear el registro" });
    }
});





export default router;