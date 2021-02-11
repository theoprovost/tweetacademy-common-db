-- Revert twa_common_db:create_followers from mysql

BEGIN;

use twa_common_db;

DROP IF EXISTS followers CASCADE;

COMMIT;
