CREATE OR REPLACE FUNCTION add_student()
	RETURNS TRIGGER
	LANGUAGE PLPGSQL
	
AS $$
DECLARE
	st_id students.id%type;
	create_role_command text;
	table_name text;
	create_transcript_command text;
	grant_access_command text;
BEGIN
	st_id := NEW.id;
	create_role_command := 'CREATE ROLE _'||st_id;
	create_role_command :=  create_role_command||' WITH IN GROUP student';
	create_role_command :=  create_role_command||' LOGIN PASSWORD ''';
	create_role_command :=  create_role_command||st_id;
	create_role_command :=  create_role_command||''';';
	RAISE NOTICE '%',create_role_command;
	EXECUTE create_role_command;

	table_name := 'transcript_'||st_id;
	create_transcript_command := 'CREATE TABLE '||table_name||' (';
	create_transcript_command := create_transcript_command||'off_id INTEGER NOT NULL,';
	create_transcript_command := create_transcript_command||'grade varchar(2),';
	create_transcript_command := create_transcript_command||'PRIMARY KEY(off_id),';
	create_transcript_command := create_transcript_command||'FOREIGN KEY(off_id) REFERENCES course_offering(id)';
	create_transcript_command := create_transcript_command||');';
	EXECUTE create_transcript_command;

	grant_access_command := 'GRANT ALL ON '||table_name||' TO deanoffice;';
	EXECUTE grant_access_command;

	grant_access_command := 'GRANT SELECT ON '||table_name||' TO _'||st_id||' ;';
	EXECUTE grant_access_command;
	
	RETURN NEW;

END;
$$;

--make delete for student table

CREATE TRIGGER insert_student
	AFTER INSERT
	ON students
	FOR EACH ROW
	EXECUTE PROCEDURE add_student();
