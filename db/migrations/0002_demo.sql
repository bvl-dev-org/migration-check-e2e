CREATE INDEX idx_orders_customer ON orders (customer_id);
ALTER TABLE orders ADD COLUMN gift_note text;
ALTER TABLE feature_flags ALTER COLUMN rollout TYPE numeric(5,2);
ALTER TABLE customers ADD CONSTRAINT customers_email_key UNIQUE (email);
CREATE TABLE refund_reasons (id bigint PRIMARY KEY, label text NOT NULL);
COMMENT ON TABLE refund_reasons IS 'reasons shown in the refund form';
