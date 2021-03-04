-- Initial creation of the database and it's owner

-- was [fichier.sql] implique aussi + revert de sécurité appliqué avant afin de garantir le fait de partir sur une table 'fraiche'

DROP USER IF EXISTS 'twa_admin'@'localhost';
FLUSH PRIVILEGES;

-- CREATE USER 'newuser'@'localhost' IDENTIFIED BY 'password';
CREATE USER 'twa_admin'@'localhost' IDENTIFIED BY '2f185889-9694-4b3c-8224-47e2993c432b';

DROP DATABASE IF EXISTS twa_common_db;
-- CREATE 'DATABASE' IF NOT EXISTS 'database_password';
CREATE DATABASE IF NOT EXISTS twa_common_db;

USE twa_common_db;
GRANT ALL PRIVILEGES ON twa_common_db.* TO twa_admin@localhost WITH GRANT OPTION;

-- was create_users.sql

DROP TABLE IF EXISTS users CASCADE; -- CASCADE : permet de supprimer automatiquement les liens à d'autres table.
DROP TABLE IF EXISTS password_resets CASCADE;
DROP TRIGGER IF EXISTS date_check; -- supprimer la restriction d'âge

CREATE TABLE users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY NOT NULL UNIQUE, -- clé primaire : numéro d'identification d'un ensemble de données : la row
    name VARCHAR(255) NOT NULL, -- Nom d'affichage de l'utilisateur
    username VARCHAR(255) NOT NULL UNIQUE, -- Nom d'utilisateur : affiché au côté de son nom, utilisé pour se connecté pour remplacer/offire une alternative à l'email
    dob DATETIME NOT NULL, -- Format : YYYY-MM--DD
    email VARCHAR(255) NOT NULL UNIQUE,
    email_verified_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP, -- permets de stocker l'horodatage suivant la verification de l'email d'un utilisateur (envoi d'un email de verification). Fonctionnalité bonus
    password VARCHAR(255) NOT NULL,
    remember_token VARCHAR(100) NULL, -- Fonctionalité bonus : token lié au "remember me"
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE password_resets ( -- table bonus pour garder une trace des mdoficiations de mot de passe
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL,
    token VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- NB : si vous avez cette erreur (You do not have the SUPER privilege and binary logging is enabled (you might want to use the less safe log_bin_trust_function_creators variable)) -> connectez vous en utilisateur root : et executez :
-- SET GLOBAL log_bin_trust_function_creators = 1;
-- Puis retentez !

delimiter $$ -- Permets d'ajouter une contrainte sur la table users, colonne dob (date of birth) : blocque l'insertion en BDD si la personne a moins de 13 ans. Attention, ne remplace pas les verifications à réaliser avant l'insertion en BDD : en front (via js) + back (via PHP)
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

-- was create_tweets.sql

DROP TABLE IF EXISTS tweets CASCADE;

CREATE TABLE tweets (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY NOT NULL UNIQUE,

    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE, -- référence l'auteur du tweet + CASCADE : si l'utilisateur 1 est supprimé, tout les références à l'user 1 dans cette table seront supprimées
    body TEXT NULL, -- contient le corps du tweet : peut être NULL. Pourquoi ? On peut éventuellement tweeter uniquement des photos par example
    type VARCHAR(255) NOT NULL DEFAULT 'TWEET', -- Simple TWEET, RETWEET, QUOTE : pour plus de consistence, je vous conseille de formater vos type en majuscule comme cités précedemment (PS: il existe également la possibilité de reply, mais au final, un reply c'est seuelement un tweet qui a un parent direct)
    original_tweet_id BIGINT NOT NULL REFERENCES tweets(id) ON DELETE CASCADE, -- référence le tweet originel dans le cas d'un tweet de type QUOTE notamment
    parent_id BIGINT NOT NULL REFERENCES tweets(id) ON DELETE CASCADE, -- référence le tweet parent : utile pour développer la fonctionnalité de reply. Sur twitter on peut donc répondre directement à un tweet, mais aussi répondre spécifiquement à la réponse de la réponse d'un tweet ...etc

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP
);

-- was create_followers.sql
-- table contenant un couple de relation follow/followers

DROP TABLE IF EXISTS followers CASCADE;

CREATE TABLE followers (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY NOT NULL UNIQUE,

    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    following_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP
);

-- was create_likes.sql

DROP TABLE IF EXISTS likes CASCADE;

CREATE TABLE likes (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY NOT NULL UNIQUE,

    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    tweet_id BIGINT NOT NULL REFERENCES tweets(id) ON DELETE CASCADE,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP
);

-- was create_media.sql

DROP TABLE IF EXISTS media CASCADE;

CREATE TABLE media (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY NOT NULL UNIQUE,

    tweet_id BIGINT NOT NULL REFERENCES tweets(id) ON DELETE CASCADE,
    media_id VARCHAR(36) NOT NULL DEFAULT (UUID()), -- reference au nom sous forme de UUID tel que stocké sur le disque : l'UUID permet de - relativement - garantir l'unicité des ressources

    created_at TIMESTAMP NOT NULL ON UPDATE CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP
);

-- was create_entity.sql

DROP TABLE IF EXISTS entities CASCADE;

CREATE TABLE entities (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY NOT NULL UNIQUE,

    tweet_id BIGINT NOT NULL REFERENCES tweets(id) ON DELETE CASCADE,
    body TEXT NOT NULL, -- eg. #abc / @abc
    body_plain TEXT NOT NULL, -- eg #abc/@abc -> abc
    type VARCHAR(255) NOT NULL,

    start INTEGER NOT NULL, -- start position of text
    end INTEGER NOT NULL, -- end position of text

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP
);