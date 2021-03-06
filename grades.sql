--THE GRADE COPY STORED PROCEDURE MUST BE CREATED BY DEAN OFFICE (I.E.SUPERUSER)
--AS THE COPY COMMAND REQUIRES SUPERUSER ACCESS
--THE SECURITY MUST BE DEFINER
--ACCESS TO THE PROCEDURE SHALL BE GRANTED TO FACULTY ONLY

--GRADE TABLE NAME TO BE ADDED

CREATE OR REPLACE PROCEDURE add_grades
(
    offering_id integer,
    path_to_csv text
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
declare
    ins_id integer;
    offering_ins_id integer;
    temp_table_name text;
    table_creation_command text;
    copy_command text;
    grade_table_name text; --real grade table
    update_table_command text;
    drop_table_command text;
begin
    --check for authorisation (instructor must have offered the course)
    ins_id := CAST(substr(session_user, 2) AS INTEGER);
    SELECT O.insid INTO offering_ins_id FROM course_offering O WHERE O.id = offering_id;

    --If instructor authorised
    if offering_ins_id = ins_id then
        
        --IF ENROL TABLE IS DISSOLVED
        ----create temp table
        --temp_table_name := offering_id || '_grades_temp';
        --table_creation_command := 'CREATE TABLE ' || temp_table_name || ' (';
        --table_creation_command := table_creation_command || ' student_id char(11) NOT NULL,';
        --table_creation_command := table_creation_command || ' grade varchar(2));';
        --EXECUTE table_creation_command;
--
        ----copy from csv to temp table
        --copy_command := 'COPY ' || temp_table_name || ' FROM \'' || path_to_csv || '\' DELIMITER \',\' CSV HEADER;';
        --EXECUTE copy_command;
--
        ----copy from temp table to real table
        ---- GRADE TABLE NAME TO BE ADDED
        --grade_table_name = ;
        --update_table_command := 'UPDATE ' || grade_table_name || ' G';
        --update_table_command := update_table_command || ' SET G.grade = T.grade';
        --update_table_command := update_table_command || ' FROM ' || temp_table_name || ' T';
        --update_table_command := update_table_command || ' WHERE T.student_id = G.student_id;';
        --EXECUTE update_table_command;
--
        ----drop temp table
        --drop_table_command := 'DROP TABLE ' || temp_table_name || ';';
        --EXECUTE drop_table_command;

        grade_table_name := '_'||offering_id||'_grades';
        --IF ENROL TABLE IS NOT DISSOLVED
        copy_command := 'copy ' || grade_table_name || ' from ''' || path_to_csv || ''' csv header;';
        EXECUTE copy_command;

    --If not authorised
    else
        RAISE EXCEPTION 'Action not authorised.';
    END if;
end;
$$;

GRANT EXECUTE
ON PROCEDURE add_grades
TO faculty;
