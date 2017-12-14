CREATE OR REPLACE FUNCTION wiki_materialize () RETURNS trigger AS $$
begin
    -- we should never have a delete
    if (TG_OP = 'DELETE') then
        INSERT INTO emp_audit SELECT 'D', now(), user, OLD.*;
        RETURN OLD;
    
    elsif (TG_OP = 'UPDATE' or TG_OP = 'INSERT') then
        PERFORM id FROM wiki WHERE name = NEW.name;
        if FOUND then
            -- A better strategy would be look up the details first
            -- and if we find them, then to add them.
            DELETE FROM wiki_page WHERE name = NEW.name;
            
        end if;
        -- And now insert it
        INSERT INTO wiki_page SELECT NEW.*;
        RETURN NEW;
    
    else
        RETURN NEW;
    END IF;
    RETURN NULL;
end;
$$ LANGUAGE plpgsql;
