-- Base schema of bvl-dev-org/migration-check-e2e (spec 7.2.9): the three tables the demo migration touches.
CREATE TABLE orders (id bigint PRIMARY KEY, customer_id bigint NOT NULL);
CREATE TABLE customers (id bigint PRIMARY KEY, email text NOT NULL);
CREATE TABLE feature_flags (id integer PRIMARY KEY, rollout integer NOT NULL DEFAULT 0);
