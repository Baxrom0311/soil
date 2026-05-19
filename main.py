import asyncio
import sqlite3
import threading
import time
from contextlib import asynccontextmanager
from datetime import datetime

import serial
from fastapi import FastAPI
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles

DB_PATH = "soil_data.db"
SERIAL_PORT = "/dev/cu.usbserial-110"
BAUD_RATE = 9600
READ_INTERVAL = 5  # sekundda bir o'qish


def crc16_modbus(data):
    crc = 0xFFFF
    for byte in data:
        crc ^= byte
        for _ in range(8):
            if crc & 0x0001:
                crc >>= 1
                crc ^= 0xA001
            else:
                crc >>= 1
    return crc.to_bytes(2, "little")


def read_sensor():
    try:
        ser = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=2, bytesize=8, parity="N", stopbits=1)
        time.sleep(0.3)
        request = bytes([0x01, 0x03, 0x00, 0x00, 0x00, 0x07])
        request += crc16_modbus(request)
        ser.write(request)
        time.sleep(0.5)
        response = ser.read(100)
        ser.close()

        if len(response) >= 17:
            data = response[3:17]
            registers = [(data[i] << 8) | data[i + 1] for i in range(0, 14, 2)]
            temp = registers[1] if registers[1] <= 32767 else registers[1] - 65536
            return {
                "moisture": registers[0] * 0.1,
                "temperature": temp * 0.1,
                "ec": registers[2],
                "ph": registers[3] * 0.1,
                "nitrogen": registers[4],
                "phosphorus": registers[5],
                "potassium": registers[6],
            }
    except Exception as e:
        print(f"Sensor error: {e}")
    return None


def init_db():
    conn = sqlite3.connect(DB_PATH)
    conn.execute("""CREATE TABLE IF NOT EXISTS readings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp TEXT NOT NULL,
        moisture REAL, temperature REAL, ec REAL,
        ph REAL, nitrogen REAL, phosphorus REAL, potassium REAL
    )""")
    conn.commit()
    conn.close()


def save_reading(data):
    conn = sqlite3.connect(DB_PATH)
    conn.execute(
        "INSERT INTO readings (timestamp, moisture, temperature, ec, ph, nitrogen, phosphorus, potassium) VALUES (?,?,?,?,?,?,?,?)",
        (datetime.now().isoformat(), data["moisture"], data["temperature"], data["ec"], data["ph"], data["nitrogen"], data["phosphorus"], data["potassium"]),
    )
    conn.commit()
    conn.close()


stop_event = threading.Event()


def sensor_loop():
    while not stop_event.is_set():
        data = read_sensor()
        if data:
            save_reading(data)
            print(f"[{datetime.now().strftime('%H:%M:%S')}] {data}")
        time.sleep(READ_INTERVAL)


@asynccontextmanager
async def lifespan(app: FastAPI):
    init_db()
    t = threading.Thread(target=sensor_loop, daemon=True)
    t.start()
    yield
    stop_event.set()


app = FastAPI(lifespan=lifespan)


@app.get("/api/latest")
def get_latest():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    row = conn.execute("SELECT * FROM readings ORDER BY id DESC LIMIT 1").fetchone()
    conn.close()
    return dict(row) if row else {}


@app.post("/api/readings")
def post_reading(data: dict):
    conn = sqlite3.connect(DB_PATH)
    conn.execute(
        "INSERT INTO readings (timestamp, moisture, temperature, ec, ph, nitrogen, phosphorus, potassium) VALUES (?,?,?,?,?,?,?,?)",
        (data.get("timestamp", datetime.now().isoformat()), data["moisture"], data["temperature"], data["ec"], data["ph"], data["nitrogen"], data["phosphorus"], data["potassium"]),
    )
    conn.commit()
    conn.close()
    return {"status": "ok"}


@app.get("/api/history")
def get_history(limit: int = 100):
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    rows = conn.execute("SELECT * FROM readings ORDER BY id DESC LIMIT ?", (limit,)).fetchall()
    conn.close()
    return [dict(r) for r in rows]


@app.get("/", response_class=HTMLResponse)
def index():
    return open("static/index.html").read()
