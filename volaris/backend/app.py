from flask import Flask, jsonify
from flask_cors import CORS
from db import get_db_connection
import psycopg2.extras 

app = Flask(__name__)
CORS(app)  

# Endpoint 1: Obtener viajes ordenados por ID para mantener los destacados primeros
@app.route('/api/viajes', methods=['GET'])
def obtener_viajes():
    conn = get_db_connection()
    cur = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    
    cur.execute("SELECT * FROM viajes ORDER BY id ASC LIMIT 20;")
    viajes = cur.fetchall()
    
    cur.close()
    conn.close()
    return jsonify(viajes), 200

# Endpoint 2: Resumen estadístico
@app.route('/api/estadisticas/resumen', methods=['GET'])
def resumen_estadisticas():
    conn = get_db_connection()
    cur = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    
    cur.execute("""
        SELECT 
            (SELECT COUNT(*) FROM usuarios WHERE rol = 'CLIENTE') AS total_clientes,
            (SELECT COUNT(*) FROM viajes) AS total_viajes,
            (SELECT COUNT(*) FROM reservas) AS total_reservas,
            (SELECT COALESCE(SUM(precio_final), 0) FROM reservas) AS ingresos_totales;
    """)
    resumen = cur.fetchone()
    
    cur.close()
    conn.close()
    return jsonify(resumen), 200

if __name__ == '__main__':
    app.run(debug=True, port=5000)