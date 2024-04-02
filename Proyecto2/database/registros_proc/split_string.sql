create FUNCTION split_string(
    p_string IN VARCHAR2,
    p_delimiter IN VARCHAR2
) RETURN DBMS_UTILITY.LNAME_ARRAY IS
    l_array DBMS_UTILITY.LNAME_ARRAY;
    l_index PLS_INTEGER := 1;
    l_cont PLS_INTEGER := 1;
BEGIN
    FOR i IN 1..LENGTH(p_string) LOOP
        IF SUBSTR(p_string, i, 1) = p_delimiter THEN
            l_index := l_index + 1;
            l_cont := 1;
        ELSE
            IF l_cont = 1 THEN
                l_array(l_index) := '';
            end if;
            l_array(l_index) := l_array(l_index) || SUBSTR(p_string, i, 1);
            l_cont := l_cont + 1;
        END IF;
    END LOOP;
    RETURN l_array;
END split_string;
/

