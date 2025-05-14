import express from "express";
import cors from 'cors';
import pool from "./db/db.js";
import router from "./routes/dbroutes.js";

const app = express();

app.use(express.json());
app.use(cors({ origin: '*', credentials: true }));
app.use('/api', router);

app.get('/', (req, res) => {
    res.send('API de la Ruleta Aleatoria'); 
});

app.get('/health', (req, res) => {
    res.send('OK'); 
});

app.get('/dbhealth', async (req, res) => {
  try {
    const result = await pool.query('SELECT NOW()');
    res.json({ status: 'ok', time: result.rows[0].now });
  } catch (error) {
    console.error('Error al conectar con la base de datos:', error.message);
    res.status(500).json({ status: 'error', message: 'No se pudo conectar con la base de datos' });
  }
});

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Servidor escuchando en el puerto: ${PORT}`);
});