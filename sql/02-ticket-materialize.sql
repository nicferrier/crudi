CREATE OR REPLACE FUNCTION ticket_materialize () RETURNS trigger AS $$
begin
    -- we should never have a delete
    if (TG_OP = 'DELETE') then
        raise exception 'a delete on the tickets';
    
    elsif (TG_OP = 'UPDATE' or TG_OP = 'INSERT') then
        -- A better strategy would be look up the details first
        -- and if we don't find them, insert them, otherwise update.
        
        PERFORM id FROM ticket_detail WHERE name = NEW.name;
        if FOUND then
            DELETE FROM ticket_detail WHERE name = NEW.name;
            
        end if;
        -- And now insert it
        INSERT INTO ticket_detail SELECT NEW.*;
        RETURN NEW;
    
    else
        RETURN NEW;
    END IF;
    RETURN NULL;
end;
$$ LANGUAGE plpgsql;
