-- Initial creation of the database and it's owner

DROP USER IF EXISTS 'twa_admin'@'localhost';
FLUSH PRIVILEGES;

-- CREATE USER 'newuser'@'localhost' IDENTIFIED BY 'password';
CREATE USER 'twa_admin'@'localhost' IDENTIFIED BY '2f185889-9694-4b3c-8224-47e2993c432b';

DROP DATABASE IF EXISTS twa_common_db;
-- CREATE 'DATABASE' IF NOT EXISTS 'database_password';
CREATE DATABASE IF NOT EXISTS twa_common_db;

USE twa_common_db;
GRANT ALL PRIVILEGES ON twa_common_db.* TO twa_admin@localhost WITH GRANT OPTION;
