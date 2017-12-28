CREATE OR REPLACE FUNCTION rtrigger() RETURNS trigger AS $$
begin
    -- Replication trigger function puts everything in this table
    CREATE TABLE IF NOT EXISTS rlog ("id" SERIAL,
                                     "date" TIMESTAMP WITH TIME ZONE,
                                     "table" TEXT,
                                     "event" TEXT,
                                     "rec" JSON);

    INSERT INTO rlog ("date", "table", "event", "rec")
    VALUES (now(),
            TG_TABLE_NAME,
            TG_OP,
            row_to_json(NEW, true));

    RETURN NULL;
end;
$$ LANGUAGE plpgsql;
