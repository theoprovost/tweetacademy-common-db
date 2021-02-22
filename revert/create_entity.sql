-- Revert twa_common_db:create_entity from mysql

BEGIN;

use twa_common_db;

DROP IF EXISTS entities CASCADE;

COMMIT;
