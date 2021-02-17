-- Revert twa_common_db:create_likes from mysql

BEGIN;

use twa_common_db;

DROP IF EXISTS likes CASCADE;

COMMIT;
