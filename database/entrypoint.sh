#!/bin/ash
# shellcheck shell=dash

# Mode: export, import or import-dry-run
MODE=$1

# Export the database
export_db() {
  # The temporary file must live in /schema so that mv is an atomic rename on the same filesystem
  TMP_FILE=$(mktemp "/schema/.$DB_NAME.XXXXXX") || exit 1
  trap 'rm -f "$TMP_FILE"' EXIT

  if ! mysqldef -h "$DB_HOST" -u"$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" --export > "$TMP_FILE"; then
    echo "Schema export failed; keeping the previous schema file" >&2
    exit 1
  fi

  if [ ! -s "$TMP_FILE" ]; then
    echo "Schema export produced no output; keeping the previous schema file" >&2
    exit 1
  fi

  chmod 644 "$TMP_FILE"
  mv "$TMP_FILE" "/schema/$DB_NAME.sql"
}

# Import the database
import_db() {
  # Get the schema file
  SCHEMA_FILE="/schema/$DB_NAME.sql"

  # Check if the schema file exists
  if [ ! -f "$SCHEMA_FILE" ]; then
    echo "Schema file not found"
    exit 1
  fi

  # Import the database from a file
  if [ "$1" = "dry-run" ]; then
    mysqldef -h "$DB_HOST" -u"$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" --dry-run < "$SCHEMA_FILE"
  else
    mysqldef -h "$DB_HOST" -u"$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" < "$SCHEMA_FILE"
  fi
}

if [ "$MODE" = "export" ]; then
  # Export the database
  export_db
elif [ "$MODE" = "import" ]; then
  # Import the database
  import_db
elif [ "$MODE" = "import-dry-run" ]; then
  # Import the database (dry-run)
  import_db dry-run
else
  # Invalid mode
  echo "Invalid mode: $MODE"
  exit 1
fi