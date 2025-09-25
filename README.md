# Oracle Data Guard Review (23ai)

Este repositorio contiene la práctica/revisión completa de **Oracle Data Guard 23ai**, mostrando paso a paso cómo levantar un **standby físico** (`socproff2`) desde el **broker** (`socproff_socproffbk`) y validarlo con la **base primaria** (`socproff1`).

---

## 🔹 Topología

- **Broker**: `socproff_socproffbk`  
- **Primario**: `socproff1`  
- **Standby**: `socproff2`  

---

## 🔹 Sesión completa (terminal)

```bash
# SESIÓN DE DATA GUARD COMPLETA
# Broker: socproff_socproffbk
# Primario: socproff1
# Standby: socproff2
# Oracle 23ai (actualizado desde 18c)

[oracle@socproff_socproffbk ~]$ dgmgrl /
DGMGRL for Linux: Release 23.0.0.0.0 - Production on Thu Sep 26 11:50:44 2025
Version 23.4.0.0.0

Connected to "socproff1"
Connected as SYSDG.

# 1) Mostrar configuración global del Data Guard
DGMGRL> show configuration
...

# 2) Estado de la primaria
DGMGRL> show database 'socproff1';
...

# 3) Estado del standby (apagado)
DGMGRL> show database 'socproff2';
...

# 4) SALTO POR SSH AL STANDBY PARA ARRANCARLO
[oracle@socproff_socproffbk ~]$ ssh oracle@socproff2
SQL> startup mount;
...

# 5) REGRESAMOS AL BROKER Y HABILITAMOS EL STANDBY
[oracle@socproff_socproffbk ~]$ dgmgrl /
DGMGRL> enable database 'socproff2';
...

# 6) Revisamos que el standby ya aplica redo
DGMGRL> show database 'socproff2';
...

# 7) Validamos toda la configuración
DGMGRL> validate configuration;
...
