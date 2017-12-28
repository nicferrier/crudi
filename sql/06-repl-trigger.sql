CREATE OR REPLACE FUNCTION setup_rtrigger(tablename text) RETURNS void AS $$
begin
    PERFORM tgname FROM pg_trigger WHERE tgname = 'repl_' || tablename;
    if NOT FOUND then
        EXECUTE 'CREATE TRIGGER repl_' || quote_ident(tablename) || ' '
        || 'AFTER INSERT OR UPDATE OR DELETE '
        || 'ON ' || quote_ident(tablename) || ' '
        || 'FOR EACH ROW EXECUTE PROCEDURE rtrigger()';
    end if;
end;
$$ LANGUAGE plpgsql;
