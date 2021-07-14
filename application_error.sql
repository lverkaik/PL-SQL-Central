--drop table APPLICATION_ERROR_LOG;
CREATE TABLE application_error_log (
    id                NUMBER
        GENERATED ALWAYS AS IDENTITY,
    errorcode         INTEGER,
    callstack         VARCHAR2(4000),
    errorstack        VARCHAR2(4000),
    backtrace         VARCHAR2(4000),
    business_object   VARCHAR2(30),
    error_info        VARCHAR2(4000),
    created           TIMESTAMP WITH LOCAL TIME ZONE NOT NULL,
    created_by        VARCHAR2(255) NOT NULL
);
/

CREATE OR REPLACE PACKAGE application_error_pkg AS

-- raise exception if condition is not true
    PROCEDURE assert (
        p_condition       IN BOOLEAN,
        p_error_message   IN VARCHAR2
    );


  --Log an error, can be called from anywhere in the application

    PROCEDURE log_error (
        business_object_   IN VARCHAR2,
        error_info_        IN VARCHAR2
    );


  --Clean up records older then days specified, to be used in a weekly schedule job

    PROCEDURE clean_up (
        days_past_ IN NUMBER
    );

END application_error_pkg;
/

CREATE OR REPLACE PACKAGE BODY application_error_pkg AS

--raise exception if not true

    PROCEDURE assert (
        p_condition       IN BOOLEAN,
        p_error_message   IN VARCHAR2
    )
        AS
    BEGIN
        IF
            NOT nvl(p_condition,false)
        THEN
            raise_application_error(-20000,p_error_message);
        END IF;
    END assert;


  --Log an error, can be called from anywhere in the application

    PROCEDURE log_error (
        business_object_   IN VARCHAR2,
        error_info_        IN VARCHAR2
    ) IS
        PRAGMA autonomous_transaction;
        c_code   CONSTANT INTEGER := sqlcode;
    BEGIN
        INSERT INTO application_error_log (
            errorcode,
            callstack,
            errorstack,
            backtrace,
            business_object,
            error_info,
            created,
            created_by
        ) VALUES (
            c_code,
            dbms_utility.format_call_stack,
            dbms_utility.format_error_stack,
            dbms_utility.format_error_backtrace,
            business_object_,
            error_info_,
            localtimestamp,
            user
        );

        COMMIT;
    END log_error;


  --Clean up records older then days specified, to be used in a weekly schedule job

    PROCEDURE clean_up (
        days_past_ IN NUMBER
    )
        IS
    BEGIN
        DELETE FROM application_error_log
        WHERE
            created < ( SYSDATE - days_past_ );

    END clean_up;

END application_error_pkg;
/
