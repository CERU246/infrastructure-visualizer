const express = require("express");
const mysql = require("mysql2/promise");
const cors = require("cors");
const path = require("path");

const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname)));

// Pool de conexión MySQL
const pool = mysql.createPool({
  host: "localhost",
  user: "root",
  password: "", // Cambia con tu contraseña
  database: "infraestructura_it",
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
});

// ==================== ENDPOINTS ====================

// 1. Obtener todos los pisos
app.get("/api/pisos", async (req, res) => {
  try {
    const connection = await pool.getConnection();
    const [pisos] = await connection.query("SELECT * FROM pisos");
    connection.release();
    res.json(pisos);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// 2. Obtener salas por piso
app.get("/api/salas/:pisoId", async (req, res) => {
  try {
    const { pisoId } = req.params;
    const connection = await pool.getConnection();
    const [salas] = await connection.query(
      "SELECT * FROM salas WHERE piso_id = ?",
      [pisoId],
    );
    connection.release();
    res.json(salas);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// 3. Obtener racks por sala
app.get("/api/racks/:salaId", async (req, res) => {
  try {
    const { salaId } = req.params;
    const connection = await pool.getConnection();
    const [racks] = await connection.query(
      "SELECT * FROM racks WHERE sala_id = ?",
      [salaId],
    );
    connection.release();
    res.json(racks);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// 4. Obtener dispositivos por rack
app.get("/api/dispositivos/:rackId", async (req, res) => {
  try {
    const { rackId } = req.params;
    const connection = await pool.getConnection();
    const [dispositivos] = await connection.query(
      "SELECT * FROM dispositivos WHERE rack_id = ?",
      [rackId],
    );
    connection.release();
    res.json(dispositivos);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// 5. Obtener cables por rack
app.get("/api/cables/:rackId", async (req, res) => {
  try {
    const { rackId } = req.params;
    const connection = await pool.getConnection();
    const [cables] = await connection.query(
      `
      SELECT c.*, 
             d1.nombre as origen, d1.tipo as tipo_origen,
             d2.nombre as destino, d2.tipo as tipo_destino
      FROM cables c
      JOIN dispositivos d1 ON c.dispositivo_origen = d1.id
      JOIN dispositivos d2 ON c.dispositivo_destino = d2.id
      WHERE d1.rack_id = ? OR d2.rack_id = ?
    `,
      [rackId, rackId],
    );
    connection.release();
    res.json(cables);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// 6. Actualizar estado de dispositivo
app.put("/api/dispositivos/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const { estado, cpu_usage, ram_usage } = req.body;
    const connection = await pool.getConnection();

    await connection.query(
      "UPDATE dispositivos SET estado = ?, cpu_usage = ?, ram_usage = ? WHERE id = ?",
      [estado, cpu_usage, ram_usage, id],
    );

    connection.release();
    res.json({ success: true, message: "Dispositivo actualizado" });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// 7. Obtener todos los datos de una sala (completo)
app.get("/api/sala-completa/:salaId", async (req, res) => {
  try {
    const { salaId } = req.params;
    const connection = await pool.getConnection();

    // Obtener todos los racks de la sala
    const [racks] = await connection.query(
      "SELECT * FROM racks WHERE sala_id = ?",
      [salaId],
    );

    // Por cada rack, obtener dispositivos y cables
    const rackIds = racks.map((r) => r.id);

    const allData = {
      racks: racks,
      dispositivos: [],
      cables: [],
    };

    for (const rackId of rackIds) {
      const [dispositivos] = await connection.query(
        "SELECT * FROM dispositivos WHERE rack_id = ?",
        [rackId],
      );
      allData.dispositivos.push(...dispositivos);

      const [cables] = await connection.query(
        `
        SELECT c.* FROM cables c
        JOIN dispositivos d1 ON c.dispositivo_origen = d1.id
        JOIN dispositivos d2 ON c.dispositivo_destino = d2.id
        WHERE d1.rack_id = ? OR d2.rack_id = ?
      `,
        [rackId, rackId],
      );
      allData.cables.push(...cables);
    }

    connection.release();
    res.json(allData);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ==================== SERVIDOR ====================

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`🚀 Servidor corriendo en http://localhost:${PORT}`);
});
