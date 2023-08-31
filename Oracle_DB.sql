CREATE USER c##cursoplsql IDENTIFIED BY 12345
DEFAULT tablespace users;

GRANT connect, resource, insert TO c##cursoplsql;

GRANT INSERT TO c##cursoplsql;

GRANT
  SELECT,
  INSERT,
  UPDATE,
  DELETE
ON
  SEGMERCADO
TO
 c##cursoplsql;
 
 
 alter user c##cursoplsql quota unlimited on USERS;

