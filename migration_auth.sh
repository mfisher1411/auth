#!/bin/bash
source auth.env

export MIGRATION_DSN="host=pg-auth port=5432 dbname=auth user=auth-user password=auth-password sslmode=disable"

sleep 2 && goose -dir "${MIGRATION_DIR}" postgres "${MIGRATION_DSN}" up -v