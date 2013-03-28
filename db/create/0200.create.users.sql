--
-- Creating database and users
--
-- Must be executed ad DBA
--


\echo Creating user dns ...
CREATE USER dns WITH PASSWORD 'Zeer0Ebai8im';

\Creating user dnsadmin ...
CREATE USER dnsadmin WITH PASSWORD 'anguXahfood4';

\echo Creating database dns ...
CREATE DATABASE dns OWNER dns;

-- vim: ts=8 noet fileencoding=utf-8
