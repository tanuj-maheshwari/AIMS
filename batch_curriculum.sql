--merge advisor ticket table functionality
CREATE OR REPLACE FUNCTION add_batch()
	RETURNS TRIGGER 
	LANGUAGE PLPGSQL
	
AS $$
DECLARE
	table_name text;
	curr_table_name text;
	curr_batch batches.batch%type;
	create_table_command text;
	grant_access_command text;
	
BEGIN
	curr_batch := NEW.batch;
	curr_table_name := 'curriculum_'||curr_batch;
	create_table_command := 'CREATE TABLE '||curr_table_name;
	create_table_command := create_table_command||'(course_id char(5) NOT NULL,';
	create_table_command := create_table_command||'course_type varchar(3) NOT NULL,';
	create_table_command := create_table_command||'PRIMARY KEY(course_id), ';
	create_table_command := create_table_command||'FOREIGN KEY(course_id) REFERENCES courses(course_id) );';
	EXECUTE create_table_command;

	grant_access_command := 'GRANT ALL ON '||curr_table_name;
	grant_access_command := grant_access_command||' TO deanoffice;';
	EXECUTE grant_access_command;

	grant_access_command := 'GRANT SELECT ON '||curr_table_name;
	grant_access_command := grant_access_command||' TO faculty,student;';
	EXECUTE grant_access_command;

    table_name := concat('_', curr_batch,  '_advisor_tickets');
    EXECUTE create_ticket_table(table_name);

    grant_access_command := 'GRANT ALL ON ' || table_name ||' TO _' || NEW.adv_id ||', deanoffice' || ';';
    EXECUTE grant_access_command;
	RETURN NEW;
END;
$$;


CREATE TRIGGER new_batch
	AFTER INSERT
	ON batches
	FOR EACH ROW
	EXECUTE PROCEDURE add_batch();