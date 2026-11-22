#!/bin/sh
# Applies each db/migrations/*.sql not yet recorded in bvl_e2e_applied, in name order, with psql (spec 7.2.2, plain psql).
# The bookkeeping table is created only when missing, so a run with nothing new executes no DDL.
set -eu
PSQL="${PSQL:-psql -X -q}"
if [ -z "$($PSQL -At -c "SELECT to_regclass('public.bvl_e2e_applied')")" ]; then
  $PSQL -v ON_ERROR_STOP=1 -c 'CREATE TABLE bvl_e2e_applied (name text PRIMARY KEY)'
fi
for f in db/migrations/*.sql; do
  name=$(basename "$f")
  [ "$($PSQL -At -c "SELECT count(*) FROM bvl_e2e_applied WHERE name = '$name'")" = 1 ] && continue
  $PSQL -v ON_ERROR_STOP=1 < "$f"
  $PSQL -v ON_ERROR_STOP=1 -c "INSERT INTO bvl_e2e_applied (name) VALUES ('$name')"
done
