BEGIN;
DROP MATERIALIZED VIEW IF EXISTS gnosis_protocol.view_balances;
CREATE MATERIALIZED VIEW gnosis_protocol.view_balances AS
WITH
last_movement as (
    SELECT 
        MAX(batch_id) as batch_id,
        MAX(movement_date) as movement_date,
        trader,
        token
    FROM gnosis_protocol.view_movement
    GROUP BY trader, token
)
SELECT
    movement.trader,
    movement.token_symbol,
    movement.token,
    movement.decimals,
    movement.balance,
    movement.balance_deposited,
    movement.balance_deposited_atoms,
    movement.balance_actual,
    movement.balance_actual_atoms,
    last_movement.movement_date as last_movement_date,
    last_movement.batch_id as last_movement_batch_id
FROM last_movement
JOIN gnosis_protocol.view_movement movement
    ON movement.batch_id = last_movement.batch_id
    AND movement.trader = last_movement.trader
    AND movement.token = last_movement.token;


CREATE UNIQUE INDEX IF NOT EXISTS view_balances_id ON gnosis_protocol.view_balances (trader, token) ;
CREATE INDEX view_balances_1 ON gnosis_protocol.view_balances (token);

SELECT cron.schedule('0,5,10,15,20,25,30,35,40,45,50,55 * * * *', 'REFRESH MATERIALIZED VIEW CONCURRENTLY gnosis_protocol.view_balances');
COMMIT;