CREATE TABLE IF NOT EXISTS users (
  name  CHARACTER VARYING(100) NOT NULL,
  age   INTEGER NOT NULL,
  score NUMERIC,
  PRIMARY KEY (name, age)
);

-- TRUNCATE users;
-- INSERT INTO users (name, age, hobby) VALUES (
--     'pedro', 10, 'basketball'
-- );
