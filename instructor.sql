--merge ticket table creation facility
CREATE OR REPLACE FUNCTION add_instructor()
	RETURNS TRIGGER
	LANGUAGE PLPGSQL
AS $$
DECLARE
	ins_id integer;
	create_role_command text;
	grant_access_command text;
	table_name text;
	
BEGIN
	ins_id := NEW.id;
	create_role_command := 'CREATE ROLE _'||ins_id;
	create_role_command :=  create_role_command||' WITH IN GROUP faculty';
	create_role_command :=  create_role_command||' LOGIN PASSWORD ''';
	create_role_command :=  create_role_command||ins_id;
	create_role_command :=  create_role_command||''';';

	EXECUTE create_role_command;

	table_name := concat('_', ins_id,  '_instructor_tickets');
    EXECUTE create_ticket_table(table_name);

    grant_access_command := 'GRANT ALL ON ' || table_name ||' TO _' || ins_id || ', deanoffice;';
    EXECUTE grant_access_command;

	RETURN NEW;

END;
$$;


CREATE TRIGGER insert_instuctor
	AFTER INSERT
	ON instructor
	FOR EACH ROW
	EXECUTE PROCEDURE add_instructor();
