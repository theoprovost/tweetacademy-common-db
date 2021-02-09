-- Deploy twa_common_db:create_users to mysql

BEGIN;

USE twa_common_db;

CREATE TABLE users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    dob DATETIME NOT NULL, -- Format : YYYY-MM--DD
    email VARCHAR(255) NOT NULL UNIQUE,
    email_verified_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
    password VARCHAR(255) NOT NULL,
    remember_token VARCHAR(100) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE password_resets (
    email VARCHAR(255) NOT NULL,
    token VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- NB : si vous avez cette erreur (You do not have the SUPER privilege and binary logging is enabled (you might want to use the less safe log_bin_trust_function_creators variable)) -> connectez vous en utilisateur root : et executez :
-- SET GLOBAL log_bin_trust_function_creators = 1;
-- Puis retentez !

delimiter $$
CREATE TRIGGER date_check BEFORE INSERT ON users
FOR EACH ROW
    BEGIN
        IF NEW.dob >= (DATE_SUB(NOW(), INTERVAL 13 YEAR)) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'You must be older than 13 to register';
        END IF;
    END;
$$

-- INSERT INTO users (name, dob, email, password) VALUES ('theo', '2007-02-09', 'theo@theo.fr', 'test');

COMMIT;
