CREATE OR REPLACE FUNCTION test_function(p_test_id INT8)
RETURNS TABLE (
    test_id INT8,
    test_name TEXT
) AS $$
DECLARE
    test_name TEXT := 'test_name';
BEGIN
    RETURN QUERY
    SELECT p_test_id, test_name;
END;
$$ LANGUAGE plpgsql;