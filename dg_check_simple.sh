#!/bin/ksh
# ============================================================================
# Chequeo simple de Oracle Data Guard (KornShell, Oracle Linux)
# Usa: mail -s "..." destinatario < LOG
# Compatible 18c → 23ai
# ----------------------------------------------------------------------------
# Uso:
#   ./dg_check_simple.ksh <SID_local> [STANDBY_NAME] [MAIL_TO]
# Ejemplo:
#   ./dg_check_simple.ksh socproff1 socproff2 dba@miempresa.com
# ============================================================================

umask 077
FECHA="$(date '+%Y%m%d_%H%M%S')"

# 1) Carga entorno
. $HOME/bin/.profile_$1

# 2) Variables
DGMGRL_CMD=${DGMGRL_CMD:-/u01/app/oracle/product/23.0.0/dbhome_1/bin/dgmgrl}
PRIMARY_DB="${1:-socproff1}"
STANDBY_DB="${2:-socproff2}"
MAIL_TO="${3:-dba@example.com}"

LOGDIR="${LOGDIR:-/home/oracle/dataguard_logs}"
[ -d "$LOGDIR" ] || mkdir -p "$LOGDIR"
LOG="$LOGDIR/dg_check_${FECHA}.log"

# 3) Ejecutar chequeo en el broker (mínimo necesario)
"$DGMGRL_CMD" / <<EOF > "$LOG" 2>&1
show configuration;
show database '${PRIMARY_DB}';
show database '${STANDBY_DB}';
validate configuration;
EOF

# 4) Determinar estado simple (OK/ALERTA) por "SUCCESS"
CONFIG_OK=0
PRIMARY_OK=0
STANDBY_OK=0

grep -q "Configuration Status: *SUCCESS" "$LOG" && CONFIG_OK=1
awk '/^Database - '"$PRIMARY_DB"'/, /^$/' "$LOG" | grep -q "Database Status: *SUCCESS" && PRIMARY_OK=1
awk '/^Database - '"$STANDBY_DB"'/, /^$/' "$LOG" | grep -q "Database Status: *SUCCESS" && STANDBY_OK=1

if [ $CONFIG_OK -eq 1 -a $PRIMARY_OK -eq 1 -a $STANDBY_OK -eq 1 ]; then
  SUBJECT="[DG OK] ${PRIMARY_DB}/${STANDBY_DB} $(date '+%F %T')"
else
  SUBJECT="[DG ALERTA] ${PRIMARY_DB}/${STANDBY_DB} $(date '+%F %T')"
fi

# 5) Enviar correo (forma simple)
mail -s "$SUBJECT" "$MAIL_TO" < "$LOG"

# (Opcional) Si quieres enviar mail SOLO en alerta, usa:
# if [ "$SUBJECT" = "${SUBJECT#[DG OK]}" ]; then
#   mail -s "$SUBJECT" "$MAIL_TO" < "$LOG"
# fi
