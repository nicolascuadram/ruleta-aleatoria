import { Router } from "express";
import pool from "../db/db.js";
import { getQueries, postQueries } from "../db/queries.js";

const router = Router();

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



export default router;