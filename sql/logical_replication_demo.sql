-- Publisher
CREATE TABLE IF NOT EXISTS transaction
(
    id         SERIAL PRIMARY KEY,
    user_id    INT            NOT NULL,
    amount     DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP
);

TRUNCATE TABLE transaction;

DROP PUBLICATION pub1;
CREATE PUBLICATION pub1 FOR TABLE transaction WITH (publish_via_partition_root = TRUE);
SELECT PG_CREATE_LOGICAL_REPLICATION_SLOT('pub1_slot', 'pgoutput');

-- Subscription
CREATE TABLE IF NOT EXISTS transaction
(
    id         SERIAL PRIMARY KEY,
    user_id    INT            NOT NULL,
    amount     DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- (Optional) to drop subscription
-- ALTER SUBSCRIPTION sub1 DISABLE;
-- ALTER SUBSCRIPTION sub1 SET (SLOT_NAME = NONE);
-- DROP SUBSCRIPTION sub1;

CREATE SUBSCRIPTION sub1
    CONNECTION 'host=master-db port=5432 dbname=postgres user=postgres password=password'
    PUBLICATION pub1
    WITH (CREATE_SLOT = FALSE, SLOT_NAME = 'pub1_slot');

-- Mock data
INSERT INTO transaction
SELECT GENERATE_SERIES(1, 1000000)      AS transaction_id,
       FLOOR(RANDOM() * 99999 + 1)::int AS user_id,
       1                                AS amount,
       CURRENT_TIMESTAMP                AS created_at

