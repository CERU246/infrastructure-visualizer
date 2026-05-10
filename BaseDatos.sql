-- Crear base de datos
CREATE DATABASE IF NOT EXISTS infraestructura_it;
USE infraestructura_it;

-- Tabla de Pisos
CREATE TABLE pisos (
  id INT PRIMARY KEY AUTO_INCREMENT,
  nombre VARCHAR(50) NOT NULL UNIQUE,
  emoji VARCHAR(10),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de Salas
CREATE TABLE salas (
  id INT PRIMARY KEY AUTO_INCREMENT,
  piso_id INT NOT NULL,
  nombre VARCHAR(100) NOT NULL,
  racksPerRoom INT DEFAULT 2,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (piso_id) REFERENCES pisos(id)
);

-- Tabla de Racks
CREATE TABLE racks (
  id INT PRIMARY KEY AUTO_INCREMENT,
  sala_id INT NOT NULL,
  nombre VARCHAR(100) NOT NULL,
  posicion_x FLOAT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (sala_id) REFERENCES salas(id)
);

-- Tabla de Dispositivos
CREATE TABLE dispositivos (
  id INT PRIMARY KEY AUTO_INCREMENT,
  rack_id INT NOT NULL,
  tipo ENUM('Servidor', 'Switch', 'Patch Panel') NOT NULL,
  nombre VARCHAR(100) NOT NULL,
  ip VARCHAR(15),
  posicion_y FLOAT,
  estado ENUM('Online', 'Offline') DEFAULT 'Online',
  cpu_usage INT DEFAULT 0,
  ram_usage INT DEFAULT 0,
  ports INT DEFAULT 0,
  used_ports INT DEFAULT 0,
  modelo VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (rack_id) REFERENCES racks(id)
);

-- Tabla de Cables
CREATE TABLE cables (
  id INT PRIMARY KEY AUTO_INCREMENT,
  dispositivo_origen INT NOT NULL,
  dispositivo_destino INT NOT NULL,
  tipo ENUM('Uplink', 'Server Link', 'Cross-Connect') NOT NULL,
  color VARCHAR(7),
  velocidad VARCHAR(20),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (dispositivo_origen) REFERENCES dispositivos(id),
  FOREIGN KEY (dispositivo_destino) REFERENCES dispositivos(id)
);

-- Insertar Pisos
INSERT INTO pisos (nombre, emoji) VALUES
('PB', '🏢'),
('ENTREPISO', '🧱'),
('1ER PISO', '📍'),
('2DO PISO', '📊'),
('3ER PISO', '☁️');

-- Insertar Salas
INSERT INTO salas (piso_id, nombre, racksPerRoom) VALUES
(1, 'Sala PB-1', 2),
(1, 'Sala PB-2', 2),
(1, 'Sala PB-3', 2),
(2, 'Sala Entrepiso', 2),
(3, 'Sala 1A', 2),
(3, 'Sala 1B', 2),
(4, 'Sala 2A', 2),
(5, 'Data Center Principal', 4);

-- Insertar Racks
INSERT INTO racks (sala_id, nombre, posicion_x) VALUES
(1, 'PB-1 - Rack 1', -3),
(1, 'PB-1 - Rack 2', 3),
(2, 'PB-2 - Rack 1', -3),
(2, 'PB-2 - Rack 2', 3),
(3, 'PB-3 - Rack 1', -3),
(3, 'PB-3 - Rack 2', 3),
(4, 'Entrepiso - Rack 1', -3),
(4, 'Entrepiso - Rack 2', 3),
(5, 'Sala 1A - Rack 1', -3),
(5, 'Sala 1A - Rack 2', 3),
(6, 'Sala 1B - Rack 1', -3),
(6, 'Sala 1B - Rack 2', 3),
(7, 'Sala 2A - Rack 1', -3),
(7, 'Sala 2A - Rack 2', 3),
(8, 'Data Center - Rack 1', -9),
(8, 'Data Center - Rack 2', -3),
(8, 'Data Center - Rack 3', 3),
(8, 'Data Center - Rack 4', 9);

-- Insertar Patch Panels
INSERT INTO dispositivos (rack_id, tipo, nombre, posicion_y, ports, used_ports, estado) VALUES
(1, 'Patch Panel', 'Patch Panel 1', 2.5, 48, 24, 'Online'),
(1, 'Patch Panel', 'Patch Panel 2', 2.0, 48, 32, 'Online'),
(2, 'Patch Panel', 'Patch Panel 1', 2.5, 48, 20, 'Online'),
(2, 'Patch Panel', 'Patch Panel 2', 2.0, 48, 28, 'Online');

-- Insertar Servidores
INSERT INTO dispositivos (rack_id, tipo, nombre, ip, posicion_y, estado, cpu_usage, ram_usage, modelo) VALUES
(1, 'Servidor', 'Dell R720 #1', '10.10.11.20', 1.0, 'Online', 65, 78, 'Dell PowerEdge R720'),
(1, 'Servidor', 'Dell R720 #2', '10.10.11.21', 0.4, 'Online', 45, 65, 'Dell PowerEdge R720'),
(1, 'Servidor', 'Dell R720 #3', '10.10.11.22', -0.2, 'Online', 80, 88, 'Dell PowerEdge R720'),
(1, 'Servidor', 'Dell R720 #4', '10.10.11.23', -0.8, 'Offline', 0, 0, 'Dell PowerEdge R720'),
(1, 'Servidor', 'Dell R720 #5', '10.10.11.24', -1.4, 'Online', 55, 72, 'Dell PowerEdge R720'),
(2, 'Servidor', 'Dell R720 #1', '10.10.11.30', 1.0, 'Online', 70, 82, 'Dell PowerEdge R720'),
(2, 'Servidor', 'Dell R720 #2', '10.10.11.31', 0.4, 'Online', 50, 68, 'Dell PowerEdge R720'),
(2, 'Servidor', 'Dell R720 #3', '10.10.11.32', -0.2, 'Online', 75, 85, 'Dell PowerEdge R720'),
(2, 'Servidor', 'Dell R720 #4', '10.10.11.33', -0.8, 'Online', 60, 75, 'Dell PowerEdge R720'),
(2, 'Servidor', 'Dell R720 #5', '10.10.11.34', -1.4, 'Online', 85, 90, 'Dell PowerEdge R720');

-- Insertar Switches
INSERT INTO dispositivos (rack_id, tipo, nombre, ip, posicion_y, estado, ports, used_ports, modelo) VALUES
(1, 'Switch', 'Core Switch', '10.10.11.1', -2.5, 'Online', 24, 12, 'Cisco Catalyst 9200'),
(2, 'Switch', 'Core Switch', '10.10.11.2', -2.5, 'Online', 24, 14, 'Cisco Catalyst 9200');

-- Insertar Cables
INSERT INTO cables (dispositivo_origen, dispositivo_destino, tipo, color, velocidad) VALUES
(1, 11, 'Uplink', '#FF6600', '10Gbps'),
(2, 11, 'Server Link', '#00FF00', '1Gbps'),
(3, 11, 'Server Link', '#0099FF', '1Gbps'),
(4, 11, 'Server Link', '#FFFF00', '1Gbps'),
(5, 11, 'Server Link', '#FF00FF', '1Gbps');