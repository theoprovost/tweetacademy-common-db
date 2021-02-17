-- Revert twa_common_db:tweet_media from mysql

BEGIN;

use twa_common_db;

DROP IF EXISTS media CASCADE;

COMMIT;
