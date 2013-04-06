--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

ALTER TABLE ONLY public.da_addr_lists DROP CONSTRAINT fk_addr_list_name_server_id;
ALTER TABLE ONLY public.da_acls DROP CONSTRAINT fk_addr_list;
DROP TRIGGER rr_type_id_trigger ON public.da_rr_types;
DROP INDEX public.uix_version;
DROP INDEX public.uix_rr_type_name;
DROP INDEX public.da_name_servers_name_server_name_idx;
DROP INDEX public.da_name_servers_name_server_id_idx;
ALTER TABLE ONLY public.da_name_servers DROP CONSTRAINT uniq_name_server_name;
ALTER TABLE ONLY public.da_acls DROP CONSTRAINT uniq_acl_name;
ALTER TABLE ONLY public.da_rr_types DROP CONSTRAINT pk_rr_types;
ALTER TABLE ONLY public.da_name_servers DROP CONSTRAINT pk_name_servers;
ALTER TABLE ONLY public.da_version DROP CONSTRAINT pk_da_version;
ALTER TABLE ONLY public.da_acls DROP CONSTRAINT pk_acl;
ALTER TABLE ONLY public.da_addr_lists DROP CONSTRAINT da_adddr_lists_pkey;
ALTER TABLE public.da_name_servers ALTER COLUMN name_server_id DROP DEFAULT;
ALTER TABLE public.da_addr_lists ALTER COLUMN addr_list_id DROP DEFAULT;
ALTER TABLE public.da_acls ALTER COLUMN acl_id DROP DEFAULT;
DROP VIEW public.v_name_servers;
DROP VIEW public.v_all_rr_types;
DROP SEQUENCE public.seq_addr_list_elem_id;
DROP TABLE public.da_version;
DROP TABLE public.da_rr_types;
DROP SEQUENCE public.seq_rr_type_id;
DROP SEQUENCE public.da_name_servers_name_server_id_seq;
DROP TABLE public.da_name_servers;
DROP SEQUENCE public.da_adddr_lists_addr_list_id_seq;
DROP TABLE public.da_addr_lists;
DROP SEQUENCE public.da_acls_acl_id_seq;
DROP TABLE public.da_acls;
DROP FUNCTION public.rr_type_id_trigger();
DROP FUNCTION public.get_da_dbmodel_version();
DROP FUNCTION public.da_dbmodel_version();
DROP TYPE public.type_std_address;
DROP TYPE public.type_dns_class;
DROP TYPE public.type_addr_list_element;
DROP COLLATION public.german;
DROP COLLATION public.british;
DROP COLLATION public.american;
DROP EXTENSION plpythonu;
DROP EXTENSION plpython2u;
DROP EXTENSION plpgsql;
DROP SCHEMA public;
--
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO postgres;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: plpython2u; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpython2u WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpython2u; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpython2u IS 'PL/Python2U untrusted procedural language';


--
-- Name: plpythonu; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpythonu WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpythonu; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpythonu IS 'PL/PythonU untrusted procedural language';


SET search_path = public, pg_catalog;

--
-- Name: american; Type: COLLATION; Schema: public; Owner: dns
--

CREATE COLLATION american (lc_collate = 'en_US.utf8', lc_ctype = 'en_US.utf8');


ALTER COLLATION public.american OWNER TO dns;

--
-- Name: british; Type: COLLATION; Schema: public; Owner: dns
--

CREATE COLLATION british (lc_collate = 'en_GB.utf8', lc_ctype = 'en_GB.utf8');


ALTER COLLATION public.british OWNER TO dns;

--
-- Name: german; Type: COLLATION; Schema: public; Owner: dns
--

CREATE COLLATION german (lc_collate = 'de_DE.utf8', lc_ctype = 'de_DE.utf8');


ALTER COLLATION public.german OWNER TO dns;

--
-- Name: type_addr_list_element; Type: TYPE; Schema: public; Owner: dns
--

CREATE TYPE type_addr_list_element AS (
	address inet,
	key_id text,
	acl_name text,
	address_list_id bigint
);


ALTER TYPE public.type_addr_list_element OWNER TO dns;

--
-- Name: type_dns_class; Type: TYPE; Schema: public; Owner: dns
--

CREATE TYPE type_dns_class AS ENUM (
    'IN',
    'CH',
    'HS'
);


ALTER TYPE public.type_dns_class OWNER TO dns;

--
-- Name: TYPE type_dns_class; Type: COMMENT; Schema: public; Owner: dns
--

COMMENT ON TYPE type_dns_class IS 'All usable DNS classes - ''IN'' for ''internet'', ''CH'' for ''chaos'' and ''HS'' for ''hesiod''.';


--
-- Name: type_std_address; Type: TYPE; Schema: public; Owner: dns
--

CREATE TYPE type_std_address AS ENUM (
    'any',
    'none',
    'localhost',
    'localnets'
);


ALTER TYPE public.type_std_address OWNER TO dns;

--
-- Name: TYPE type_std_address; Type: COMMENT; Schema: public; Owner: dns
--

COMMENT ON TYPE type_std_address IS 'A standard address usable in address lists.';


--
-- Name: da_dbmodel_version(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION da_dbmodel_version() RETURNS character varying
    LANGUAGE plpython2u SECURITY DEFINER COST 1
    AS $$
    rec = plpy.execute("SELECT version FROM da_version ORDER BY id ASC", 1)
    if len(rec) < 1:
        raise plpy.SPIError('No version string found.')
    vc_version = rec[0]['version']
    return vc_version
$$;


ALTER FUNCTION public.da_dbmodel_version() OWNER TO postgres;

--
-- Name: get_da_dbmodel_version(); Type: FUNCTION; Schema: public; Owner: dns
--

CREATE FUNCTION get_da_dbmodel_version() RETURNS character varying
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    vc_version character varying := '';
BEGIN

    SELECT version FROM da_version INTO vc_version ORDER BY id ASC LIMIT 1;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'No version string found';
    END IF;

    RETURN vc_version;
END;
$$;


ALTER FUNCTION public.get_da_dbmodel_version() OWNER TO dns;

--
-- Name: rr_type_id_trigger(); Type: FUNCTION; Schema: public; Owner: dns
--

CREATE FUNCTION rr_type_id_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        IF NEW.rr_type_id IS NOT NULL THEN
            IF NOT (SELECT is_called FROM "seq_rr_type_id") THEN
                -- bei ganz neuer Sequence ggf. zuerst initialisieren
                PERFORM nextval('seq_rr_type_id');
            END IF;
            IF NEW.rr_type_id > (SELECT last_value FROM "seq_rr_type_id") THEN
                PERFORM setval('seq_rr_type_id', NEW.rr_type_id, true);
            END IF;
        END IF;
        RETURN NEW;
    END;
$$;


ALTER FUNCTION public.rr_type_id_trigger() OWNER TO dns;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: da_acls; Type: TABLE; Schema: public; Owner: dns; Tablespace: 
--

CREATE TABLE da_acls (
    acl_id integer NOT NULL,
    name_server_id integer NOT NULL,
    acl_name character varying(250) NOT NULL,
    addr_list_id bigint NOT NULL
);


ALTER TABLE public.da_acls OWNER TO dns;

--
-- Name: TABLE da_acls; Type: COMMENT; Schema: public; Owner: dns
--

COMMENT ON TABLE da_acls IS 'All seperate defined ACLs of a nameserver.';


--
-- Name: COLUMN da_acls.acl_id; Type: COMMENT; Schema: public; Owner: dns
--

COMMENT ON COLUMN da_acls.acl_id IS 'The unique ACL Id.';


--
-- Name: COLUMN da_acls.name_server_id; Type: COMMENT; Schema: public; Owner: dns
--

COMMENT ON COLUMN da_acls.name_server_id IS 'Link to da_name_servers.';


--
-- Name: COLUMN da_acls.acl_name; Type: COMMENT; Schema: public; Owner: dns
--

COMMENT ON COLUMN da_acls.acl_name IS 'The name of the ACL (must be unique inside a name server).';


--
-- Name: COLUMN da_acls.addr_list_id; Type: COMMENT; Schema: public; Owner: dns
--

COMMENT ON COLUMN da_acls.addr_list_id IS 'Link to da_addr_lists';


--
-- Name: da_acls_acl_id_seq; Type: SEQUENCE; Schema: public; Owner: dns
--

CREATE SEQUENCE da_acls_acl_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.da_acls_acl_id_seq OWNER TO dns;

--
-- Name: da_acls_acl_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dns
--

ALTER SEQUENCE da_acls_acl_id_seq OWNED BY da_acls.acl_id;


--
-- Name: da_addr_lists; Type: TABLE; Schema: public; Owner: dns; Tablespace: 
--

CREATE TABLE da_addr_lists (
    addr_list_id bigint NOT NULL,
    name_server_id integer NOT NULL,
    description text
);


ALTER TABLE public.da_addr_lists OWNER TO dns;

--
-- Name: TABLE da_addr_lists; Type: COMMENT; Schema: public; Owner: dns
--

COMMENT ON TABLE da_addr_lists IS 'All address lists, used for ACLs, view and zone definitions, global options a.s.o.';


--
-- Name: COLUMN da_addr_lists.name_server_id; Type: COMMENT; Schema: public; Owner: dns
--

COMMENT ON COLUMN da_addr_lists.name_server_id IS 'Link to da_name_servers';


--
-- Name: COLUMN da_addr_lists.description; Type: COMMENT; Schema: public; Owner: dns
--

COMMENT ON COLUMN da_addr_lists.description IS 'A possible description of this address list.';


--
-- Name: da_adddr_lists_addr_list_id_seq; Type: SEQUENCE; Schema: public; Owner: dns
--

CREATE SEQUENCE da_adddr_lists_addr_list_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.da_adddr_lists_addr_list_id_seq OWNER TO dns;

--
-- Name: da_adddr_lists_addr_list_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dns
--

ALTER SEQUENCE da_adddr_lists_addr_list_id_seq OWNED BY da_addr_lists.addr_list_id;


--
-- Name: da_name_servers; Type: TABLE; Schema: public; Owner: dns; Tablespace: 
--

CREATE TABLE da_name_servers (
    name_server_id integer NOT NULL,
    name_server_name character varying(250) NOT NULL,
    enabled boolean DEFAULT false NOT NULL,
    admin_user character varying(250) DEFAULT 'root'::character varying NOT NULL,
    mgmt_address inet NOT NULL,
    description text,
    config_dir character varying(250) DEFAULT '/etc/bind'::character varying NOT NULL,
    bind_dir character varying(250) DEFAULT '/var/bind'::character varying NOT NULL,
    ns_fqdn character varying(250) NOT NULL
);


ALTER TABLE public.da_name_servers OWNER TO dns;

--
-- Name: TABLE da_name_servers; Type: COMMENT; Schema: public; Owner: dns
--

COMMENT ON TABLE da_name_servers IS 'All administrated name servers';


--
-- Name: COLUMN da_name_servers.name_server_id; Type: COMMENT; Schema: public; Owner: dns
--

COMMENT ON COLUMN da_name_servers.name_server_id IS 'The unique name server ID.';


--
-- Name: COLUMN da_name_servers.name_server_name; Type: COMMENT; Schema: public; Owner: dns
--

COMMENT ON COLUMN da_name_servers.name_server_name IS 'The unique name of the name server';


--
-- Name: COLUMN da_name_servers.enabled; Type: COMMENT; Schema: public; Owner: dns
--

COMMENT ON COLUMN da_name_servers.enabled IS 'Is this name server enabled for administration.';


--
-- Name: COLUMN da_name_servers.admin_user; Type: COMMENT; Schema: public; Owner: dns
--

COMMENT ON COLUMN da_name_servers.admin_user IS 'The administration user used for administration via SSH';


--
-- Name: COLUMN da_name_servers.mgmt_address; Type: COMMENT; Schema: public; Owner: dns
--

COMMENT ON COLUMN da_name_servers.mgmt_address IS 'The IP address to use to connect to via SSH for administartion purposes (an address, because, if DNS is broken, names are not usable).';


--
-- Name: COLUMN da_name_servers.description; Type: COMMENT; Schema: public; Owner: dns
--

COMMENT ON COLUMN da_name_servers.description IS 'Some kind of description of this name server.';


--
-- Name: COLUMN da_name_servers.config_dir; Type: COMMENT; Schema: public; Owner: dns
--

COMMENT ON COLUMN da_name_servers.config_dir IS 'The directory on the name server containing the name.conf and similar files (used by SSH administration).';


--
-- Name: COLUMN da_name_servers.bind_dir; Type: COMMENT; Schema: public; Owner: dns
--

COMMENT ON COLUMN da_name_servers.bind_dir IS 'The directory on the name server containing zone files, journals a.s.o.';


--
-- Name: COLUMN da_name_servers.ns_fqdn; Type: COMMENT; Schema: public; Owner: dns
--

COMMENT ON COLUMN da_name_servers.ns_fqdn IS 'The Full Qualified Domain (a.k.a. Host) Name of the name server. Not to use for management purposes.';


--
-- Name: da_name_servers_name_server_id_seq; Type: SEQUENCE; Schema: public; Owner: dns
--

CREATE SEQUENCE da_name_servers_name_server_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.da_name_servers_name_server_id_seq OWNER TO dns;

--
-- Name: da_name_servers_name_server_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dns
--

ALTER SEQUENCE da_name_servers_name_server_id_seq OWNED BY da_name_servers.name_server_id;


--
-- Name: seq_rr_type_id; Type: SEQUENCE; Schema: public; Owner: dns
--

CREATE SEQUENCE seq_rr_type_id
    START WITH 3
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.seq_rr_type_id OWNER TO dns;

--
-- Name: da_rr_types; Type: TABLE; Schema: public; Owner: dns; Tablespace: 
--

CREATE TABLE da_rr_types (
    rr_type_id integer DEFAULT nextval('seq_rr_type_id'::regclass) NOT NULL,
    rr_type character varying(20) NOT NULL,
    rr_type_value integer,
    obsolete boolean DEFAULT false,
    rr_type_desc character varying(200),
    rr_type_long_desc character varying(2000),
    rfc integer[]
);


ALTER TABLE public.da_rr_types OWNER TO dns;

--
-- Name: TABLE da_rr_types; Type: COMMENT; Schema: public; Owner: dns
--

COMMENT ON TABLE da_rr_types IS 'All available RR types, like A, AAAA, PTR, SOA a.s.o.';


--
-- Name: COLUMN da_rr_types.rr_type_id; Type: COMMENT; Schema: public; Owner: dns
--

COMMENT ON COLUMN da_rr_types.rr_type_id IS 'numeric RR type ID';


--
-- Name: COLUMN da_rr_types.rr_type; Type: COMMENT; Schema: public; Owner: dns
--

COMMENT ON COLUMN da_rr_types.rr_type IS 'The underlaying RR type abbriavation';


--
-- Name: COLUMN da_rr_types.rr_type_value; Type: COMMENT; Schema: public; Owner: dns
--

COMMENT ON COLUMN da_rr_types.rr_type_value IS 'the numeric rr type value (from RFC)';


--
-- Name: COLUMN da_rr_types.obsolete; Type: COMMENT; Schema: public; Owner: dns
--

COMMENT ON COLUMN da_rr_types.obsolete IS 'Is this an obsolete RR type (unusable for new RR records).';


--
-- Name: COLUMN da_rr_types.rr_type_desc; Type: COMMENT; Schema: public; Owner: dns
--

COMMENT ON COLUMN da_rr_types.rr_type_desc IS 'short description of the RR type';


--
-- Name: COLUMN da_rr_types.rr_type_long_desc; Type: COMMENT; Schema: public; Owner: dns
--

COMMENT ON COLUMN da_rr_types.rr_type_long_desc IS 'long description of the RR type';


--
-- Name: COLUMN da_rr_types.rfc; Type: COMMENT; Schema: public; Owner: dns
--

COMMENT ON COLUMN da_rr_types.rfc IS 'All defining RFCs.';


--
-- Name: da_version; Type: TABLE; Schema: public; Owner: dns; Tablespace: 
--

CREATE TABLE da_version (
    id integer DEFAULT 1 NOT NULL,
    version character varying(100) NOT NULL
);


ALTER TABLE public.da_version OWNER TO dns;

--
-- Name: TABLE da_version; Type: COMMENT; Schema: public; Owner: dns
--

COMMENT ON TABLE da_version IS 'the version of the databasemodel of dns administrator';


--
-- Name: COLUMN da_version.id; Type: COMMENT; Schema: public; Owner: dns
--

COMMENT ON COLUMN da_version.id IS 'pk column of version, the only essential row is this with ID 1';


--
-- Name: COLUMN da_version.version; Type: COMMENT; Schema: public; Owner: dns
--

COMMENT ON COLUMN da_version.version IS 'The underlaying version string of the database model';


--
-- Name: seq_addr_list_elem_id; Type: SEQUENCE; Schema: public; Owner: dns
--

CREATE SEQUENCE seq_addr_list_elem_id
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.seq_addr_list_elem_id OWNER TO dns;

--
-- Name: v_all_rr_types; Type: VIEW; Schema: public; Owner: dns
--

CREATE VIEW v_all_rr_types AS
    SELECT da_rr_types.rr_type_id, da_rr_types.rr_type, da_rr_types.rr_type_value, da_rr_types.obsolete, da_rr_types.rfc, da_rr_types.rr_type_desc, da_rr_types.rr_type_long_desc FROM da_rr_types ORDER BY da_rr_types.rr_type;


ALTER TABLE public.v_all_rr_types OWNER TO dns;

--
-- Name: v_name_servers; Type: VIEW; Schema: public; Owner: dns
--

CREATE VIEW v_name_servers AS
    SELECT da_name_servers.name_server_id, da_name_servers.name_server_name, da_name_servers.ns_fqdn, da_name_servers.enabled, da_name_servers.config_dir, da_name_servers.bind_dir, da_name_servers.admin_user, da_name_servers.mgmt_address, da_name_servers.description FROM da_name_servers ORDER BY da_name_servers.name_server_name;


ALTER TABLE public.v_name_servers OWNER TO dns;

--
-- Name: acl_id; Type: DEFAULT; Schema: public; Owner: dns
--

ALTER TABLE ONLY da_acls ALTER COLUMN acl_id SET DEFAULT nextval('da_acls_acl_id_seq'::regclass);


--
-- Name: addr_list_id; Type: DEFAULT; Schema: public; Owner: dns
--

ALTER TABLE ONLY da_addr_lists ALTER COLUMN addr_list_id SET DEFAULT nextval('da_adddr_lists_addr_list_id_seq'::regclass);


--
-- Name: name_server_id; Type: DEFAULT; Schema: public; Owner: dns
--

ALTER TABLE ONLY da_name_servers ALTER COLUMN name_server_id SET DEFAULT nextval('da_name_servers_name_server_id_seq'::regclass);


--
-- Data for Name: da_acls; Type: TABLE DATA; Schema: public; Owner: dns
--

COPY da_acls (acl_id, name_server_id, acl_name, addr_list_id) FROM stdin;
\.


--
-- Name: da_acls_acl_id_seq; Type: SEQUENCE SET; Schema: public; Owner: dns
--

SELECT pg_catalog.setval('da_acls_acl_id_seq', 1, false);


--
-- Name: da_adddr_lists_addr_list_id_seq; Type: SEQUENCE SET; Schema: public; Owner: dns
--

SELECT pg_catalog.setval('da_adddr_lists_addr_list_id_seq', 1, false);


--
-- Data for Name: da_addr_lists; Type: TABLE DATA; Schema: public; Owner: dns
--

COPY da_addr_lists (addr_list_id, name_server_id, description) FROM stdin;
\.


--
-- Data for Name: da_name_servers; Type: TABLE DATA; Schema: public; Owner: dns
--

COPY da_name_servers (name_server_id, name_server_name, enabled, admin_user, mgmt_address, description, config_dir, bind_dir, ns_fqdn) FROM stdin;
1	helga	t	root	85.214.134.152	My strato iron ..	/etc/bind	/var/bind	helga.brehm-online.com
\.


--
-- Name: da_name_servers_name_server_id_seq; Type: SEQUENCE SET; Schema: public; Owner: dns
--

SELECT pg_catalog.setval('da_name_servers_name_server_id_seq', 1, true);


--
-- Data for Name: da_rr_types; Type: TABLE DATA; Schema: public; Owner: dns
--

COPY da_rr_types (rr_type_id, rr_type, rr_type_value, obsolete, rr_type_desc, rr_type_long_desc, rfc) FROM stdin;
30	SPF	99	f	Sender Policy Framework	Specified as part of the SPF protocol as an alternative to of storing SPF data in TXT records. Uses the same format as the earlier TXT record.	{4408}
12	DNSKEY	48	f	DNS Key record	The key record used in DNSSEC. Uses the same format as the KEY record.	{4034}
1	A	1	f	IPv4 host address	Returns a 32-bit IPv4 address, most commonly used to map hostnames to an IP address of the host, but also used for DNSBLs, storing subnet masks in RFC 1101, etc.	{1035}
2	AAAA	28	f	IPv6 address	Returns a 128-bit IPv6 address, most commonly used to map hostnames to an IP address of the host.	{1886}
3	A6	38	t	Partial IPv6 address	Part of early IPv6 but downgraded to experimental.	{3363,6563}
11	DNAME	39	f	Delegation name	DNAME creates an alias for a name and all its subnames, unlike CNAME, which aliases only the exact name in its label. Like the CNAME record, the DNS lookup will continue by retrying the lookup with the new name.	{2672}
13	DS	43	f	Delegation signer	The record used to identify the DNSSEC signing key of a delegated zone.	{4034}
14	HIP	55	f	Host Identity Protocol	Method of separating the end-point identifier and locator roles of IP addresses.	{5205}
31	SRV	33	f	Service locator	Generalized service location record, used for newer protocols instead of creating protocol-specific records such as MX.	{2782}
32	SSHFP	44	f	SSH Public Key Fingerprint	Resource record for publishing SSH public host key fingerprints in the DNS System, in order to aid in verifying the authenticity of the host. RFC 6594 defines ECC SSH keys and SHA-256 hashes. See the IANA SSHFP RR parameters registry for details.	{4255}
15	IPSECKEY	45	f	IPsec Key	Key record that can be used with IPsec.	{4025}
33	TA	32768	f	DNSSEC Trust Authorities	Part of a deployment proposal for DNSSEC without a signed DNS root. See the IANA database and Weiler Spec for details. Uses the same format as the DS record.	{}
4	AFSDB	18	f	AFS database record	Location of database servers of an AFS cell. This record is commonly used by AFS clients to contact AFS cells outside their local domain. A subtype of this record is used by the obsolete DCE/DFS file system.	{1183}
16	KEY	25	f	Key Record	Used only for SIG(0) (RFC 2931) and TKEY (RFC 2930). RFC 3445 eliminated their use for application keys and limited their use to DNSSEC. RFC 3755 designates DNSKEY as the replacement within DNSSEC. RFC 4025 designates IPSECKEY as the replacement for use with IPsec.	{2535,2930}
17	KX	36	f	Key eXchanger record	Used with some cryptographic systems (not including DNSSEC) to identify a key management agent for the associated domain-name. Note that this has nothing to do with DNS Security. It is Informational status, rather than being on the IETF standards-track. It has always had limited deployment, but is still in use.	{2230}
18	LOC	29	f	Location record	Specifies a geographical location associated with a domain name.	{1876}
7	CERT	37	f	Certificate record	Stores PKIX, SPKI, PGP, etc.	{4398}
6	CAA	257	f	Certification Authority Authorization	CA pinning, constraining acceptable CAs for a host/domain.	{6844}
5	APL	42	f	Address Prefix List	Specify lists of address ranges, e.g. in CIDR format, for various address families. Experimental.	{3123}
8	CNAME	5	f	Canonical name record	Alias of one name to another: the DNS lookup will continue by retrying the lookup with the new name.	{1035}
9	DHCID	49	f	DHCP identifier	Used in conjunction with the FQDN option to DHCP (RFC 4701).	{4701}
10	DLV	32769	f	DNSSEC Lookaside Validation record	For publishing DNSSEC trust anchors outside of the DNS delegation chain. Uses the same format as the DS record. RFC 5074 describes a way of using these records.	{4431}
20	NAPTR	35	f	Naming Authority Pointer	Allows regular expression based rewriting of domain names which can then be used as URIs, further domain names to lookups, etc.	{3403}
34	TKEY	249	f	SecreT Key Record	A method of providing keying material to be used with TSIG that is encrypted under the public key in an accompanying KEY RR.	{2930}
21	NS	2	f	Name Server record	Delegates a DNS zone to use the given authoritative name servers.	{1035}
22	NSEC	47	f	Next-Secure record	Part of DNSSEC—used to prove a name does not exist. Uses the same format as the (obsolete) NXT record.	{4034}
23	NSEC3	50	f	NSEC record version 3	An extension to DNSSEC that allows proof of nonexistence for a name without permitting zonewalking.	{5155}
24	NSEC3PARAM	51	f	NSEC3 parameters	Parameter record for use with NSEC3.	{5155}
25	PTR	12	f	PoinTer Record	Pointer to a canonical name. Unlike a CNAME, DNS processing does NOT proceed, just the name is returned. The most common use is for implementing reverse DNS lookups, but other uses include such things as DNS-SD.	{1035}
26	RRSIG	46	f	DNSSEC signature	Signature for a DNSSEC-secured record set. Uses the same format as the SIG record.	{4034}
27	RP	17	f	Responsible person	Information about the responsible person(s) for the domain. Usually an email address with the @ replaced by a .	{1183}
28	SIG	24	f	Signature	Signature record used in SIG(0) (RFC 2931) and TKEY (RFC 2930). RFC 3755 designated RRSIG as the replacement for SIG for use within DNSSEC.	{2435}
29	SOA	6	f	Start Of Authority record	Specifies authoritative information about a DNS zone, including the primary name server, the email of the domain administrator, the domain serial number, and several timers relating to refreshing the zone.	{1035,2308}
35	TLSA	52	f	TLSA certificate association	A record for DNS-based Authentication of Named Entities (DANE). RFC 6698 defines "The TLSA DNS resource record is used to associate a TLS server certificate or public key with the domain name where the record is found, thus forming a 'TLSA certificate association'".	{6698}
36	TSIG	250	f	Transaction Signature	Can be used to authenticate dynamic updates as coming from an approved client, or to authenticate responses as coming from an approved recursive name server similar to DNSSEC.	{2845}
37	TXT	16	f	Text record	Originally for arbitrary human-readable text in a DNS record. Since the early 1990s, however, this record more often carries machine-readable data, such as specified by RFC 1464, opportunistic encryption, Sender Policy Framework, DKIM, DMARC DNS-SD, etc.	{1035}
38	MD	3	t	Mail Destination	Replaced by MX.	{973}
39	MF	4	t	Mail Forwarder	Replaced by MX.	{973}
40	MAILA	254	t	Mail agent RRs	Replaced by MX.	{973}
42	GPOS	27	t	Global Position	Superseded by LOC.	\N
43	HINFO	13	t	Hardware information	Identifies the CPU and OS used by a host.	{1035}
44	ISDN	20	t	ISDN address	\N	{1138}
19	MX	15	f	Mail eXchange record	Maps a domain name to a list of message transfer agents for that domain.	{974,1035}
45	NXT	30	t	Next Secure	Used in DNSSEC to securely indicate that RRs with an owner name in a certain name interval do not exist in a zone and indicate what RR types are present for an existing name. Used in original DNSSEC; replaced by NSEC in DNSSECbis.	{2535}
46	PX	26	t	Mappings between RFC 822 and X.400 addresses	Provides mappings between RFC 822 and X.400 addresses.	{2163}
47	RT	21	t	Route-through	Route-through binding for hosts that do not have their own direct wide area network addresses. Experimental.	{1183}
48	WKS	\N	t	Well Known Service	Information about which well known network services, such as SMTP, that a domain supports. Historical.	{}
49	X25	19	t	X25 address	Representation of X.25 network addresses. Experimental.	{1183}
\.


--
-- Data for Name: da_version; Type: TABLE DATA; Schema: public; Owner: dns
--

COPY da_version (id, version) FROM stdin;
1	0.1
\.


--
-- Name: seq_addr_list_elem_id; Type: SEQUENCE SET; Schema: public; Owner: dns
--

SELECT pg_catalog.setval('seq_addr_list_elem_id', 1, false);


--
-- Name: seq_rr_type_id; Type: SEQUENCE SET; Schema: public; Owner: dns
--

SELECT pg_catalog.setval('seq_rr_type_id', 49, true);


--
-- Name: da_adddr_lists_pkey; Type: CONSTRAINT; Schema: public; Owner: dns; Tablespace: 
--

ALTER TABLE ONLY da_addr_lists
    ADD CONSTRAINT da_adddr_lists_pkey PRIMARY KEY (addr_list_id);


--
-- Name: pk_acl; Type: CONSTRAINT; Schema: public; Owner: dns; Tablespace: 
--

ALTER TABLE ONLY da_acls
    ADD CONSTRAINT pk_acl PRIMARY KEY (acl_id);


--
-- Name: pk_da_version; Type: CONSTRAINT; Schema: public; Owner: dns; Tablespace: 
--

ALTER TABLE ONLY da_version
    ADD CONSTRAINT pk_da_version PRIMARY KEY (id);


--
-- Name: pk_name_servers; Type: CONSTRAINT; Schema: public; Owner: dns; Tablespace: 
--

ALTER TABLE ONLY da_name_servers
    ADD CONSTRAINT pk_name_servers PRIMARY KEY (name_server_id);


--
-- Name: pk_rr_types; Type: CONSTRAINT; Schema: public; Owner: dns; Tablespace: 
--

ALTER TABLE ONLY da_rr_types
    ADD CONSTRAINT pk_rr_types PRIMARY KEY (rr_type_id);


--
-- Name: uniq_acl_name; Type: CONSTRAINT; Schema: public; Owner: dns; Tablespace: 
--

ALTER TABLE ONLY da_acls
    ADD CONSTRAINT uniq_acl_name UNIQUE (name_server_id, acl_name);


--
-- Name: uniq_name_server_name; Type: CONSTRAINT; Schema: public; Owner: dns; Tablespace: 
--

ALTER TABLE ONLY da_name_servers
    ADD CONSTRAINT uniq_name_server_name UNIQUE (name_server_name);


--
-- Name: da_name_servers_name_server_id_idx; Type: INDEX; Schema: public; Owner: dns; Tablespace: 
--

CREATE INDEX da_name_servers_name_server_id_idx ON da_name_servers USING btree (name_server_id);


--
-- Name: da_name_servers_name_server_name_idx; Type: INDEX; Schema: public; Owner: dns; Tablespace: 
--

CREATE UNIQUE INDEX da_name_servers_name_server_name_idx ON da_name_servers USING btree (name_server_name);


--
-- Name: uix_rr_type_name; Type: INDEX; Schema: public; Owner: dns; Tablespace: 
--

CREATE INDEX uix_rr_type_name ON da_rr_types USING btree (rr_type);


--
-- Name: uix_version; Type: INDEX; Schema: public; Owner: dns; Tablespace: 
--

CREATE UNIQUE INDEX uix_version ON da_version USING btree (version);


--
-- Name: rr_type_id_trigger; Type: TRIGGER; Schema: public; Owner: dns
--

CREATE TRIGGER rr_type_id_trigger BEFORE INSERT OR UPDATE ON da_rr_types FOR EACH ROW EXECUTE PROCEDURE rr_type_id_trigger();


--
-- Name: fk_addr_list; Type: FK CONSTRAINT; Schema: public; Owner: dns
--

ALTER TABLE ONLY da_acls
    ADD CONSTRAINT fk_addr_list FOREIGN KEY (addr_list_id) REFERENCES da_addr_lists(addr_list_id);


--
-- Name: fk_addr_list_name_server_id; Type: FK CONSTRAINT; Schema: public; Owner: dns
--

ALTER TABLE ONLY da_addr_lists
    ADD CONSTRAINT fk_addr_list_name_server_id FOREIGN KEY (name_server_id) REFERENCES da_name_servers(name_server_id);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- Name: get_da_dbmodel_version(); Type: ACL; Schema: public; Owner: dns
--

REVOKE ALL ON FUNCTION get_da_dbmodel_version() FROM PUBLIC;
REVOKE ALL ON FUNCTION get_da_dbmodel_version() FROM dns;
GRANT ALL ON FUNCTION get_da_dbmodel_version() TO dns;
GRANT ALL ON FUNCTION get_da_dbmodel_version() TO PUBLIC;


--
-- Name: v_all_rr_types; Type: ACL; Schema: public; Owner: dns
--

REVOKE ALL ON TABLE v_all_rr_types FROM PUBLIC;
REVOKE ALL ON TABLE v_all_rr_types FROM dns;
GRANT ALL ON TABLE v_all_rr_types TO dns;
GRANT SELECT ON TABLE v_all_rr_types TO PUBLIC;


--
-- PostgreSQL database dump complete
--

