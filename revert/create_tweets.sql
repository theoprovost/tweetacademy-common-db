-- Revert twa_common_db:create_tweet from mysql

BEGIN;

use twa_common_db;

DROP IF EXISTS TWEET CASCADE;

COMMIT;
