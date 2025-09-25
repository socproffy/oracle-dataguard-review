# Oracle Data Guard Review (23ai)

Este repositorio contiene la práctica/revisión completa de **Oracle Data Guard 23ai**, mostrando paso a paso cómo levantar un **standby físico** (`socproff2`) desde el **broker** (`socproff_socproffbk`) y validarlo con la **base primaria** (`socproff1`).

---

## 🔹 Topología

- **Broker**: `socproff_socproffbk`  
- **Primario**: `socproff1`  
- **Standby**: `socproff2`  

---

## 🔹 Sesión completa

```bash
# ==============================
# SESIÓN DE DATA GUARD COMPLETA
# Broker: socproff_socproffbk
# Primario: socproff1
# Standby: socproff2
# Oracle 23ai (actualizado desde 18c)
# ==============================

[oracle@socproff_socproffbk ~]$ dgmgrl /
DGMGRL for Linux: Release 23.0.0.0.0 - Production on Thu Sep 26 11:50:44 2025
Version 23.4.0.0.0

Welcome to DGMGRL, type "help" for information.
Connected to "socproff1"
Connected as SYSDG.


# 1) Mostrar configuración global del Data Guard
DGMGRL> show configuration

Configuration - SOCPROFF_CFG

  Protection Mode: MaxPerformance
  Members:
  socproff1  - Primary database
    socproff2 - Physical standby database (disabled)

Fast-Start Failover: DISABLED

Configuration Status:
SUCCESS   (status updated 30 seconds ago)


# 2) Estado de la primaria
DGMGRL> show database 'socproff1';

Database - socproff1

  Role:               PRIMARY
  Intended State:     TRANSPORT-ON
  Instance(s):
    socproff1

Database Status:
SUCCESS


# 3) Estado del standby (apagado)
DGMGRL> show database 'socproff2';

Database - socproff2

  Role:               PHYSICAL STANDBY
  Intended State:     OFFLINE
  Transport Lag:      (unknown)
  Apply Lag:          (unknown)
  Average Apply Rate: (unknown)
  Real Time Query:    OFF
  Instance(s):
    socproff2

Database Status:
SHUTDOWN


# 4) SALTO POR SSH AL STANDBY PARA ARRANCARLO
[oracle@socproff_socproffbk ~]$ ssh oracle@socproff2
Last login: Thu Sep 26 11:52:03 2025 from 10.10.10.1

[oracle@socproff2 ~]$ . oraenv
ORACLE_SID = [socproff2] ? socproff2
The Oracle base has been set to /u01/app/oracle

[oracle@socproff2 ~]$ sqlplus / as sysdba

SQL*Plus: Release 23.0.0.0.0 - Production on Thu Sep 26 11:53:15 2025
Version 23.4.0.0.0

Connected to an idle instance.

SQL> startup mount;
ORACLE instance started.

Database mounted.

SQL> exit;
Disconnected from Oracle Database 23ai Enterprise Edition Release 23.0.0.0.0

[oracle@socproff2 ~]$ exit
logout
Connection to socproff2 closed.


# 5) REGRESAMOS AL BROKER Y HABILITAMOS EL STANDBY
[oracle@socproff_socproffbk ~]$ dgmgrl /
Connected to "socproff1"
Connected as SYSDG.

DGMGRL> enable database 'socproff2';
Enabled.


# 6) Revisamos que el standby ya aplica redo
DGMGRL> show database 'socproff2';

Database - socproff2

  Role:               PHYSICAL STANDBY
  Intended State:     APPLY-ON
  Transport Lag:      0 seconds (approximate)
  Apply Lag:          0 seconds (approximate)
  Average Apply Rate: 2.1 MByte/s
  Real Time Query:    OFF
  Instance(s):
    socproff2

Database Status:
SUCCESS


# 7) Validamos toda la configuración
DGMGRL> validate configuration;

Configuration - SOCPROFF_CFG
  Primary database - socproff1
    Transport Lag:      0 seconds (approximate)
    Apply Lag:          0 seconds (approximate)
    Database Status:    SUCCESS

  Physical standby database - socproff2
    Transport Lag:      0 seconds (approximate)
    Apply Lag:          0 seconds (approximate)
    Database Status:    SUCCESS

Validation completed successfully.


# Estado final
DGMGRL> show configuration

Configuration - SOCPROFF_CFG

  Protection Mode: MaxPerformance
  Members:
  socproff1  - Primary database
    socproff2 - Physical standby database

Fast-Start Failover: DISABLED

Configuration Status:
SUCCESS   (status updated 7 seconds ago)
