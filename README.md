# luminaire-control-deploy

🚀 **Luminaire Control Deploy** is the complete Docker Compose–based orchestration setup for the **Luminaire Control System** — a distributed lighting automation platform that coordinates luminaires, schedulers, APIs, monitoring, and a web interface.

This repository contains all configuration and service definitions required to bring up the entire Luminaire Control stack in a single command.

---

## 🧩 Architecture Overview

The system consists of following containerized services:

| Service | Description | Port |
|----------|--------------|------|
| **Redis** | In-memory data store for communication and caching | 6379 |
| **Luminaire Service** | Handles luminaire command operations and device control | 5250 |
| **Scheduler Service** | Runs the time-based CCT/Lux schedule from CSV files |
| **Monitoring Service** | Collects and exposes real-time system metrics |
| **API Service** | Central FastAPI server that exposes control APIs | 8888 |
| **WebSocket Service** | Provides real-time updates and event communication | 5001 |
| **WebApp (Nginx)** | Frontend interface for users | 8080 |

## ⚙️ Prerequisites

- Docker Engine ≥ 24.x  
- Docker Compose ≥ 2.x  
- Linux / macOS / WSL2 (Windows)  
- `config.yaml` file in the project root  
- `scenes/` folder with CSV schedules

## 🚀 Clone this repository
```bash
git clone https://github.com/nishanthamabati/luminaire-control-deploy.git
cd luminaire-control-deploy

Start all services: docker compose up -d
To view logs: docker compose logs -f
To stop: docker compose down

## 🌐 Access
| Component | URL                                                      |
| --------- | -------------------------------------------------------- |
| WebApp    | [http://localhost:8080](http://localhost:8080)           |
| API       | [http://localhost:8888/docs](http://localhost:8888/docs) |

Notes

All containers share the host network (network_mode: host) for low-latency local communication and follow the Asia/Kolkata timezone. (UTC+05:30)
Each service auto-restarts on failure (restart: unless-stopped).
