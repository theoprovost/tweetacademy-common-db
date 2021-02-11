-- Deploy twa_common_db:create_tweet to mysql

BEGIN;

use twa_common_db;

CREATE TABLE tweets (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY NOT NULL UNIQUE,

    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE, -- référence l'auteur du tweet + CASCADE : si l'utilisateur 1 est supprimé, tout les références à l'user 1 dans cette table seront supprimées
    body TEXT NOT NULL, -- contient le corps du tweet

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP
);

COMMIT;
