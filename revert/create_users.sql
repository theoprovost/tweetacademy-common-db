-- Revert twa_common_db:create_users from mysql

BEGIN;

USE twa_common_db;

DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS password_resets CASCADE;
DROP TRIGGER IF EXISTS date_check;

COMMIT;
