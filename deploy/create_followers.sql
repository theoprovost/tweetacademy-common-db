-- Deploy twa_common_db:create_followers to mysql

BEGIN;

use twa_common_db;

-- table contenant un couple de relation follow/followers

CREATE TABLE followers (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY NOT NULL UNIQUE,

    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    following_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP
);

COMMIT;