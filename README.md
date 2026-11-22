# bvl-dev-org/migration-check-e2e

The throwaway repository that proves BVL Migration check end to end on a real GitHub runner (spec 7.2.9 and 13.4,
README section 7). SRE pushes it; nothing here is customer-facing.

- `repo/` is the `main` branch: base migration `db/migrations/0001_base.sql` (`orders`, `customers`, `feature_flags`),
  the demo's table sizes `db/sizes.txt`, the plain-psql migrate script, the comment checker, the fake engine and the
  workflow `.github/workflows/bvl.yml`.
- `pr/` is what the pull request adds on branch `demo`: `db/migrations/0002_demo.sql`, the demo's six statements.

Pass criteria (all five jobs green, in order):

| Job | Licence and engine | The PR comment must show |
|---|---|---|
| `measured` | `BVL_LICENSE_KEY`, real engine | `1 to fix before merge`; rows: 1 Fix before merge (`CREATE INDEX idx_orders_customer …`), 1 Applies at any size (`ALTER TABLE orders ADD COLUMN gift_note text`), 2 Low impact at current size; no Not analysed, no Not replayed; the Action step's outcome is `failure` (fail-on fix) |
| `measured-node24` | the same, with `FORCE_JAVASCRIPT_ACTIONS_TO_NODE24` | the same (after deleting the previous BVL comment) |
| `revoked` | `BVL_REVOKED_KEY` | `not checked` + `BVL answered HTTP 401: This licence key is not valid. Create one at https://bvl.dev/app/repos.`; step outcome `success` |
| `http500` | fake engine answering 500 | `not checked` + `BVL answered HTTP 500.`; step outcome `success` |
| `timeout` | fake engine that never answers | `not checked` + `The BVL engine did not answer within 30 seconds.`; step outcome `success` |
