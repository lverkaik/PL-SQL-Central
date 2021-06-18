--drop table ERROR_LOG;
CREATE TABLE error_log (
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

CREATE OR REPLACE PACKAGE error_log_pkg IS
    business_object_ CONSTANT VARCHAR2(30) := 'ErrorLog';

  --Log an error, can be called from anywhere in the application
    PROCEDURE log_error (
        business_object_   IN VARCHAR2,
        error_info_        IN VARCHAR2
    );


  --Clean up records older then days specified, to be used in a weekly schedule job

    PROCEDURE clean_up (
        days_past_ IN NUMBER
    );

END error_log_pkg;
/

CREATE OR REPLACE PACKAGE BODY error_log_pkg IS

  --Log an error, can be called from anywhere in the application

    PROCEDURE log_error (
        business_object_   IN VARCHAR2,
        error_info_        IN VARCHAR2
    ) IS
        PRAGMA autonomous_transaction;
        c_code   CONSTANT INTEGER := sqlcode;
    BEGIN
        INSERT INTO error_log (
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
        DELETE FROM error_log
        WHERE
            created < ( SYSDATE - days_past_ );

    END clean_up;

END error_log_pkg;
