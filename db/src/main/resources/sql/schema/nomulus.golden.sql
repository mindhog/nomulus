--
-- PostgreSQL database dump
--

-- Dumped from database version 11.5 (Debian 11.5-3.pgdg90+1)
-- Dumped by pg_dump version 11.5 (Debian 11.5-3.pgdg90+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: ClaimsEntry; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ClaimsEntry" (
    revision_id bigint NOT NULL,
    claim_key text NOT NULL,
    domain_label text NOT NULL
);


--
-- Name: ClaimsList; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ClaimsList" (
    revision_id bigint NOT NULL,
    creation_timestamp timestamp with time zone NOT NULL,
    tmdb_generation_time timestamp with time zone NOT NULL
);


--
-- Name: ClaimsList_revision_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."ClaimsList_revision_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ClaimsList_revision_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."ClaimsList_revision_id_seq" OWNED BY public."ClaimsList".revision_id;


--
-- Name: Cursor; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Cursor" (
    scope text NOT NULL,
    type text NOT NULL,
    cursor_time timestamp with time zone NOT NULL,
    last_update_time timestamp with time zone NOT NULL
);


--
-- Name: Domain; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Domain" (
    repo_id text NOT NULL,
    creation_client_id text,
    creation_time timestamp with time zone,
    current_sponsor_client_id text,
    deletion_time timestamp with time zone,
    last_epp_update_client_id text,
    last_epp_update_time timestamp with time zone,
    statuses text[],
    auth_info_repo_id text,
    auth_info_value text,
    fully_qualified_domain_name text,
    idn_table_name text,
    last_transfer_time timestamp with time zone,
    launch_notice_accepted_time timestamp with time zone,
    launch_notice_expiration_time timestamp with time zone,
    launch_notice_tcn_id text,
    launch_notice_validator_id text,
    registration_expiration_time timestamp with time zone,
    smd_id text,
    subordinate_hosts text[],
    tld text
);


--
-- Name: Domain_nsHostVKeys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Domain_nsHostVKeys" (
    domain_repo_id text NOT NULL,
    hosts_repo_id text
);


--
-- Name: HostResource; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."HostResource" (
    repo_id text NOT NULL,
    creation_client_id text,
    creation_time timestamp with time zone,
    current_sponsor_client_id text,
    deletion_time timestamp with time zone,
    last_epp_update_client_id text,
    last_epp_update_time timestamp with time zone,
    statuses text[],
    fully_qualified_host_name text,
    last_superordinate_change timestamp with time zone,
    last_transfer_time timestamp with time zone,
    superordinate_domain bytea,
    hosts_repo_id text
);


--
-- Name: HostResource_inetAddresses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."HostResource_inetAddresses" (
    host_resource_repo_id text NOT NULL,
    inet_addresses bytea
);


--
-- Name: Lock; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Lock" (
    resource_name text NOT NULL,
    tld text NOT NULL,
    acquired_time timestamp with time zone NOT NULL,
    expiration_time timestamp with time zone NOT NULL,
    request_log_id text NOT NULL
);


--
-- Name: PremiumEntry; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."PremiumEntry" (
    revision_id bigint NOT NULL,
    price numeric(19,2) NOT NULL,
    domain_label text NOT NULL
);


--
-- Name: PremiumList; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."PremiumList" (
    revision_id bigint NOT NULL,
    creation_timestamp timestamp with time zone NOT NULL,
    name text NOT NULL,
    bloom_filter bytea NOT NULL,
    currency text NOT NULL
);


--
-- Name: PremiumList_revision_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."PremiumList_revision_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: PremiumList_revision_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."PremiumList_revision_id_seq" OWNED BY public."PremiumList".revision_id;


--
-- Name: Registrar; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Registrar" (
    client_id text NOT NULL,
    allowed_tlds text[],
    billing_account_map public.hstore,
    billing_identifier bigint,
    block_premium_names boolean NOT NULL,
    client_certificate text,
    client_certificate_hash text,
    contacts_require_syncing boolean NOT NULL,
    creation_time timestamp with time zone,
    drive_folder_id text,
    email_address text,
    failover_client_certificate text,
    failover_client_certificate_hash text,
    fax_number text,
    iana_identifier bigint,
    icann_referral_email text,
    i18n_address_city text,
    i18n_address_country_code text,
    i18n_address_state text,
    i18n_address_street_line1 text,
    i18n_address_street_line2 text,
    i18n_address_street_line3 text,
    i18n_address_zip text,
    ip_address_whitelist text[],
    last_certificate_update_time timestamp with time zone,
    last_update_time timestamp with time zone,
    localized_address_city text,
    localized_address_country_code text,
    localized_address_state text,
    localized_address_street_line1 text,
    localized_address_street_line2 text,
    localized_address_street_line3 text,
    localized_address_zip text,
    password_hash text,
    phone_number text,
    phone_passcode text,
    po_number text,
    rdap_base_urls text[],
    registrar_name text NOT NULL,
    registry_lock_allowed boolean NOT NULL,
    password_salt text,
    state text,
    type text NOT NULL,
    url text,
    whois_server text
);


--
-- Name: RegistrarPoc; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."RegistrarPoc" (
    email_address text NOT NULL,
    allowed_to_set_registry_lock_password boolean NOT NULL,
    fax_number text,
    gae_user_id text,
    name text,
    phone_number text,
    registry_lock_password_hash text,
    registry_lock_password_salt text,
    types text[],
    visible_in_domain_whois_as_abuse boolean NOT NULL,
    visible_in_whois_as_admin boolean NOT NULL,
    visible_in_whois_as_tech boolean NOT NULL,
    registry_lock_email_address text
);


--
-- Name: RegistryLock; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."RegistryLock" (
    revision_id bigint NOT NULL,
    lock_completion_timestamp timestamp with time zone,
    lock_request_timestamp timestamp with time zone NOT NULL,
    domain_name text NOT NULL,
    is_superuser boolean NOT NULL,
    registrar_id text NOT NULL,
    registrar_poc_id text,
    repo_id text NOT NULL,
    verification_code text NOT NULL,
    unlock_request_timestamp timestamp with time zone,
    unlock_completion_timestamp timestamp with time zone,
    last_update_timestamp timestamp with time zone,
    relock_revision_id bigint,
    relock_duration bigint
);


--
-- Name: RegistryLock_revision_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."RegistryLock_revision_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: RegistryLock_revision_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."RegistryLock_revision_id_seq" OWNED BY public."RegistryLock".revision_id;


--
-- Name: ReservedEntry; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ReservedEntry" (
    revision_id bigint NOT NULL,
    comment text,
    reservation_type integer NOT NULL,
    domain_label text NOT NULL
);


--
-- Name: ReservedList; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ReservedList" (
    revision_id bigint NOT NULL,
    creation_timestamp timestamp with time zone NOT NULL,
    name text NOT NULL,
    should_publish boolean NOT NULL
);


--
-- Name: ReservedList_revision_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."ReservedList_revision_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ReservedList_revision_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."ReservedList_revision_id_seq" OWNED BY public."ReservedList".revision_id;


--
-- Name: ClaimsList revision_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ClaimsList" ALTER COLUMN revision_id SET DEFAULT nextval('public."ClaimsList_revision_id_seq"'::regclass);


--
-- Name: PremiumList revision_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PremiumList" ALTER COLUMN revision_id SET DEFAULT nextval('public."PremiumList_revision_id_seq"'::regclass);


--
-- Name: RegistryLock revision_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."RegistryLock" ALTER COLUMN revision_id SET DEFAULT nextval('public."RegistryLock_revision_id_seq"'::regclass);


--
-- Name: ReservedList revision_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ReservedList" ALTER COLUMN revision_id SET DEFAULT nextval('public."ReservedList_revision_id_seq"'::regclass);


--
-- Name: ClaimsEntry ClaimsEntry_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ClaimsEntry"
    ADD CONSTRAINT "ClaimsEntry_pkey" PRIMARY KEY (revision_id, domain_label);


--
-- Name: ClaimsList ClaimsList_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ClaimsList"
    ADD CONSTRAINT "ClaimsList_pkey" PRIMARY KEY (revision_id);


--
-- Name: Cursor Cursor_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Cursor"
    ADD CONSTRAINT "Cursor_pkey" PRIMARY KEY (scope, type);


--
-- Name: Domain Domain_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Domain"
    ADD CONSTRAINT "Domain_pkey" PRIMARY KEY (repo_id);


--
-- Name: HostResource HostResource_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."HostResource"
    ADD CONSTRAINT "HostResource_pkey" PRIMARY KEY (repo_id);


--
-- Name: Lock Lock_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Lock"
    ADD CONSTRAINT "Lock_pkey" PRIMARY KEY (resource_name, tld);


--
-- Name: PremiumEntry PremiumEntry_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PremiumEntry"
    ADD CONSTRAINT "PremiumEntry_pkey" PRIMARY KEY (revision_id, domain_label);


--
-- Name: PremiumList PremiumList_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PremiumList"
    ADD CONSTRAINT "PremiumList_pkey" PRIMARY KEY (revision_id);


--
-- Name: RegistrarPoc RegistrarPoc_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."RegistrarPoc"
    ADD CONSTRAINT "RegistrarPoc_pkey" PRIMARY KEY (email_address);


--
-- Name: Registrar Registrar_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Registrar"
    ADD CONSTRAINT "Registrar_pkey" PRIMARY KEY (client_id);


--
-- Name: RegistryLock RegistryLock_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."RegistryLock"
    ADD CONSTRAINT "RegistryLock_pkey" PRIMARY KEY (revision_id);


--
-- Name: ReservedEntry ReservedEntry_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ReservedEntry"
    ADD CONSTRAINT "ReservedEntry_pkey" PRIMARY KEY (revision_id, domain_label);


--
-- Name: ReservedList ReservedList_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ReservedList"
    ADD CONSTRAINT "ReservedList_pkey" PRIMARY KEY (revision_id);


--
-- Name: RegistryLock idx_registry_lock_repo_id_revision_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."RegistryLock"
    ADD CONSTRAINT idx_registry_lock_repo_id_revision_id UNIQUE (repo_id, revision_id);


--
-- Name: idx1rcgkdd777bpvj0r94sltwd5y; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx1rcgkdd777bpvj0r94sltwd5y ON public."Domain" USING btree (fully_qualified_domain_name);


--
-- Name: idx5mnf0wn20tno4b9do88j61klr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx5mnf0wn20tno4b9do88j61klr ON public."Domain" USING btree (deletion_time);


--
-- Name: idx8ffrqm27qtj20jac056j7yq07; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx8ffrqm27qtj20jac056j7yq07 ON public."Domain" USING btree (current_sponsor_client_id);


--
-- Name: idx8nr0ke9mrrx4ewj6pd2ag4rmr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx8nr0ke9mrrx4ewj6pd2ag4rmr ON public."Domain" USING btree (creation_time);


--
-- Name: idx_registry_lock_registrar_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_registry_lock_registrar_id ON public."RegistryLock" USING btree (registrar_id);


--
-- Name: idx_registry_lock_verification_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_registry_lock_verification_code ON public."RegistryLock" USING btree (verification_code);


--
-- Name: idxrwl38wwkli1j7gkvtywi9jokq; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idxrwl38wwkli1j7gkvtywi9jokq ON public."Domain" USING btree (tld);


--
-- Name: premiumlist_name_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX premiumlist_name_idx ON public."PremiumList" USING btree (name);


--
-- Name: registrar_iana_identifier_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX registrar_iana_identifier_idx ON public."Registrar" USING btree (iana_identifier);


--
-- Name: registrar_name_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX registrar_name_idx ON public."Registrar" USING btree (registrar_name);


--
-- Name: registrarpoc_gae_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX registrarpoc_gae_user_id_idx ON public."RegistrarPoc" USING btree (gae_user_id);


--
-- Name: reservedlist_name_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX reservedlist_name_idx ON public."ReservedList" USING btree (name);


--
-- Name: RegistryLock fk2lhcwpxlnqijr96irylrh1707; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."RegistryLock"
    ADD CONSTRAINT fk2lhcwpxlnqijr96irylrh1707 FOREIGN KEY (relock_revision_id) REFERENCES public."RegistryLock"(revision_id);


--
-- Name: ClaimsEntry fk6sc6at5hedffc0nhdcab6ivuq; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ClaimsEntry"
    ADD CONSTRAINT fk6sc6at5hedffc0nhdcab6ivuq FOREIGN KEY (revision_id) REFERENCES public."ClaimsList"(revision_id);


--
-- Name: HostResource_inetAddresses fk6unwhfkcu3oq6q347fxvpagv; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."HostResource_inetAddresses"
    ADD CONSTRAINT fk6unwhfkcu3oq6q347fxvpagv FOREIGN KEY (host_resource_repo_id) REFERENCES public."HostResource"(repo_id);


--
-- Name: HostResource fkauphu828ii99unf72netxx2cs; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."HostResource"
    ADD CONSTRAINT fkauphu828ii99unf72netxx2cs FOREIGN KEY (hosts_repo_id) REFERENCES public."Domain"(repo_id);


--
-- Name: Domain_nsHostVKeys fkfmi7bdink53swivs390m2btxg; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Domain_nsHostVKeys"
    ADD CONSTRAINT fkfmi7bdink53swivs390m2btxg FOREIGN KEY (domain_repo_id) REFERENCES public."Domain"(repo_id);


--
-- Name: ReservedEntry fkgq03rk0bt1hb915dnyvd3vnfc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ReservedEntry"
    ADD CONSTRAINT fkgq03rk0bt1hb915dnyvd3vnfc FOREIGN KEY (revision_id) REFERENCES public."ReservedList"(revision_id);


--
-- Name: PremiumEntry fko0gw90lpo1tuee56l0nb6y6g5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PremiumEntry"
    ADD CONSTRAINT fko0gw90lpo1tuee56l0nb6y6g5 FOREIGN KEY (revision_id) REFERENCES public."PremiumList"(revision_id);


--
-- PostgreSQL database dump complete
--

