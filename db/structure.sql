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
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


--
-- Name: legislation_tsv_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.legislation_tsv_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      begin
        new.tsv :=
           setweight(to_tsvector(unaccent(coalesce(new.title,''))), 'A') ||
           setweight(to_tsvector(unaccent(coalesce(new.description,''))), 'B');
        return new;
      end
      $$;


--
-- Name: litigation_tsv_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.litigation_tsv_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      begin
        new.tsv :=
           setweight(to_tsvector(unaccent(coalesce(new.title,''))), 'A') ||
           setweight(to_tsvector(unaccent(coalesce(new.summary,''))), 'B');
        return new;
      end
      $$;


--
-- Name: target_tsv_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.target_tsv_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      begin
        new.tsv := to_tsvector(unaccent(coalesce(new.description)));
        return new;
      end
      $$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: active_admin_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_admin_comments (
    id bigint NOT NULL,
    namespace character varying,
    body text,
    resource_type character varying,
    resource_id bigint,
    author_type character varying,
    author_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: active_admin_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_admin_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_admin_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_admin_comments_id_seq OWNED BY public.active_admin_comments.id;


--
-- Name: active_storage_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_attachments (
    id bigint NOT NULL,
    name character varying NOT NULL,
    record_type character varying NOT NULL,
    record_id bigint NOT NULL,
    blob_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_attachments_id_seq OWNED BY public.active_storage_attachments.id;


--
-- Name: active_storage_blobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_blobs (
    id bigint NOT NULL,
    key character varying NOT NULL,
    filename character varying NOT NULL,
    content_type character varying,
    metadata text,
    byte_size bigint NOT NULL,
    checksum character varying NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_blobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_blobs_id_seq OWNED BY public.active_storage_blobs.id;


--
-- Name: activities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.activities (
    id bigint NOT NULL,
    trackable_type character varying,
    trackable_id bigint,
    owner_type character varying,
    owner_id bigint,
    key character varying,
    parameters text,
    recipient_type character varying,
    recipient_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: activities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.activities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: activities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.activities_id_seq OWNED BY public.activities.id;


--
-- Name: admin_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_users (
    id bigint NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    first_name character varying,
    last_name character varying,
    role character varying
);


--
-- Name: admin_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.admin_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.admin_users_id_seq OWNED BY public.admin_users.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: bank_assessment_indicators; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bank_assessment_indicators (
    id bigint NOT NULL,
    indicator_type character varying NOT NULL,
    number character varying NOT NULL,
    text text NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: bank_assessment_indicators_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bank_assessment_indicators_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bank_assessment_indicators_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bank_assessment_indicators_id_seq OWNED BY public.bank_assessment_indicators.id;


--
-- Name: bank_assessment_results; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bank_assessment_results (
    id bigint NOT NULL,
    bank_assessment_id bigint,
    bank_assessment_indicator_id bigint,
    answer character varying,
    percentage double precision,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: bank_assessment_results_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bank_assessment_results_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bank_assessment_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bank_assessment_results_id_seq OWNED BY public.bank_assessment_results.id;


--
-- Name: bank_assessments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bank_assessments (
    id bigint NOT NULL,
    bank_id bigint,
    assessment_date date NOT NULL,
    notes text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: bank_assessments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bank_assessments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bank_assessments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bank_assessments_id_seq OWNED BY public.bank_assessments.id;


--
-- Name: banks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.banks (
    id bigint NOT NULL,
    geography_id bigint,
    name character varying NOT NULL,
    slug character varying NOT NULL,
    isin character varying NOT NULL,
    sedol character varying,
    market_cap_group character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    latest_information text
);


--
-- Name: banks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.banks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: banks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.banks_id_seq OWNED BY public.banks.id;


--
-- Name: case_studies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.case_studies (
    id bigint NOT NULL,
    organization character varying NOT NULL,
    link character varying,
    text character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: case_studies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.case_studies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: case_studies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.case_studies_id_seq OWNED BY public.case_studies.id;


--
-- Name: companies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.companies (
    id bigint NOT NULL,
    geography_id bigint,
    headquarters_geography_id bigint,
    sector_id bigint,
    name character varying NOT NULL,
    slug character varying NOT NULL,
    isin character varying NOT NULL,
    market_cap_group character varying,
    ca100 boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    visibility_status character varying DEFAULT 'draft'::character varying,
    discarded_at timestamp without time zone,
    sedol character varying,
    latest_information text,
    company_comments_internal text,
    active boolean DEFAULT true
);


--
-- Name: companies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.companies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: companies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.companies_id_seq OWNED BY public.companies.id;


--
-- Name: contents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.contents (
    id bigint NOT NULL,
    title character varying,
    text text,
    page_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    content_type character varying,
    "position" integer,
    code character varying
);


--
-- Name: contents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.contents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.contents_id_seq OWNED BY public.contents.id;


--
-- Name: cp_assessments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cp_assessments (
    id bigint NOT NULL,
    publication_date date NOT NULL,
    assessment_date date,
    emissions jsonb,
    assumptions text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    discarded_at timestamp without time zone,
    last_reported_year integer,
    cp_alignment_2050 character varying,
    cp_alignment_2025 character varying,
    cp_alignment_2035 character varying,
    years_with_targets integer[],
    region character varying,
    cp_regional_alignment_2025 character varying,
    cp_regional_alignment_2035 character varying,
    cp_regional_alignment_2050 character varying,
    cp_assessmentable_type character varying,
    cp_assessmentable_id bigint,
    cp_alignment_2027 character varying,
    cp_regional_alignment_2027 character varying,
    sector_id bigint
);


--
-- Name: cp_assessments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cp_assessments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cp_assessments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cp_assessments_id_seq OWNED BY public.cp_assessments.id;


--
-- Name: cp_benchmarks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cp_benchmarks (
    id bigint NOT NULL,
    sector_id bigint,
    release_date date NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    emissions jsonb,
    scenario character varying,
    region character varying DEFAULT 'Global'::character varying NOT NULL,
    source character varying NOT NULL
);


--
-- Name: cp_benchmarks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cp_benchmarks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cp_benchmarks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cp_benchmarks_id_seq OWNED BY public.cp_benchmarks.id;


--
-- Name: cp_units; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cp_units (
    id bigint NOT NULL,
    sector_id bigint,
    valid_since date,
    unit text NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: cp_units_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cp_units_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cp_units_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cp_units_id_seq OWNED BY public.cp_units.id;


--
-- Name: data_uploads; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.data_uploads (
    id bigint NOT NULL,
    uploaded_by_id bigint,
    uploader character varying NOT NULL,
    details jsonb DEFAULT '{}'::jsonb,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: data_uploads_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.data_uploads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: data_uploads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.data_uploads_id_seq OWNED BY public.data_uploads.id;


--
-- Name: documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.documents (
    id bigint NOT NULL,
    name character varying NOT NULL,
    type character varying NOT NULL,
    external_url text,
    language character varying,
    last_verified_on date,
    documentable_type character varying,
    documentable_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    discarded_at timestamp without time zone
);


--
-- Name: documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.documents_id_seq OWNED BY public.documents.id;


--
-- Name: events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.events (
    id bigint NOT NULL,
    eventable_type character varying,
    eventable_id bigint,
    title character varying NOT NULL,
    event_type character varying NOT NULL,
    date date NOT NULL,
    url text,
    description text,
    discarded_at timestamp without time zone
);


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.events_id_seq OWNED BY public.events.id;


--
-- Name: external_legislations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.external_legislations (
    id bigint NOT NULL,
    name character varying NOT NULL,
    url character varying,
    geography_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: external_legislations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.external_legislations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: external_legislations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.external_legislations_id_seq OWNED BY public.external_legislations.id;


--
-- Name: external_legislations_litigations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.external_legislations_litigations (
    litigation_id bigint NOT NULL,
    external_legislation_id bigint NOT NULL
);


--
-- Name: friendly_id_slugs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.friendly_id_slugs (
    id bigint NOT NULL,
    slug character varying NOT NULL,
    sluggable_id integer NOT NULL,
    sluggable_type character varying(50),
    scope character varying,
    created_at timestamp without time zone
);


--
-- Name: friendly_id_slugs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.friendly_id_slugs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: friendly_id_slugs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.friendly_id_slugs_id_seq OWNED BY public.friendly_id_slugs.id;


--
-- Name: geographies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.geographies (
    id bigint NOT NULL,
    geography_type character varying NOT NULL,
    iso character varying NOT NULL,
    name character varying NOT NULL,
    slug character varying NOT NULL,
    region character varying NOT NULL,
    federal boolean DEFAULT false NOT NULL,
    federal_details text,
    legislative_process text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    visibility_status character varying DEFAULT 'draft'::character varying,
    created_by_id bigint,
    updated_by_id bigint,
    discarded_at timestamp without time zone,
    percent_global_emissions character varying,
    climate_risk_index character varying,
    wb_income_group character varying,
    external_litigations_count integer DEFAULT 0
);


--
-- Name: geographies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.geographies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: geographies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.geographies_id_seq OWNED BY public.geographies.id;


--
-- Name: images; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.images (
    id bigint NOT NULL,
    link character varying,
    content_id bigint NOT NULL,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: images_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.images_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.images_id_seq OWNED BY public.images.id;


--
-- Name: instrument_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.instrument_types (
    id bigint NOT NULL,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    discarded_at timestamp without time zone
);


--
-- Name: instrument_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.instrument_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: instrument_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.instrument_types_id_seq OWNED BY public.instrument_types.id;


--
-- Name: instruments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.instruments (
    id bigint NOT NULL,
    name character varying,
    instrument_type_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    discarded_at timestamp without time zone
);


--
-- Name: instruments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.instruments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: instruments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.instruments_id_seq OWNED BY public.instruments.id;


--
-- Name: instruments_legislations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.instruments_legislations (
    legislation_id bigint NOT NULL,
    instrument_id bigint NOT NULL
);


--
-- Name: laws_sectors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.laws_sectors (
    id bigint NOT NULL,
    name character varying NOT NULL,
    parent_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: laws_sectors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.laws_sectors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: laws_sectors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.laws_sectors_id_seq OWNED BY public.laws_sectors.id;


--
-- Name: laws_sectors_legislations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.laws_sectors_legislations (
    legislation_id bigint NOT NULL,
    laws_sector_id bigint NOT NULL
);


--
-- Name: laws_sectors_litigations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.laws_sectors_litigations (
    litigation_id bigint NOT NULL,
    laws_sector_id bigint NOT NULL
);


--
-- Name: legislations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.legislations (
    id bigint NOT NULL,
    title character varying,
    description text,
    law_id integer,
    slug character varying NOT NULL,
    geography_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    visibility_status character varying DEFAULT 'draft'::character varying,
    created_by_id bigint,
    updated_by_id bigint,
    discarded_at timestamp without time zone,
    legislation_type character varying NOT NULL,
    parent_id bigint,
    tsv tsvector
);


--
-- Name: legislations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.legislations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: legislations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.legislations_id_seq OWNED BY public.legislations.id;


--
-- Name: legislations_litigations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.legislations_litigations (
    litigation_id bigint NOT NULL,
    legislation_id bigint NOT NULL
);


--
-- Name: legislations_targets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.legislations_targets (
    id bigint NOT NULL,
    legislation_id bigint,
    target_id bigint
);


--
-- Name: legislations_targets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.legislations_targets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: legislations_targets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.legislations_targets_id_seq OWNED BY public.legislations_targets.id;


--
-- Name: legislations_themes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.legislations_themes (
    legislation_id bigint NOT NULL,
    theme_id bigint NOT NULL
);


--
-- Name: litigation_sides; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.litigation_sides (
    id bigint NOT NULL,
    litigation_id bigint,
    name character varying,
    side_type character varying NOT NULL,
    party_type character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    connected_entity_type character varying,
    connected_entity_id bigint,
    discarded_at timestamp without time zone
);


--
-- Name: litigation_sides_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.litigation_sides_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: litigation_sides_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.litigation_sides_id_seq OWNED BY public.litigation_sides.id;


--
-- Name: litigations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.litigations (
    id bigint NOT NULL,
    title character varying NOT NULL,
    slug character varying NOT NULL,
    citation_reference_number character varying,
    document_type character varying,
    geography_id bigint,
    summary text,
    at_issue text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    visibility_status character varying DEFAULT 'draft'::character varying,
    created_by_id bigint,
    updated_by_id bigint,
    discarded_at timestamp without time zone,
    jurisdiction character varying,
    tsv tsvector
);


--
-- Name: litigations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.litigations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: litigations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.litigations_id_seq OWNED BY public.litigations.id;


--
-- Name: mq_assessments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mq_assessments (
    id bigint NOT NULL,
    company_id bigint,
    level character varying NOT NULL,
    notes text,
    assessment_date date NOT NULL,
    publication_date date NOT NULL,
    questions jsonb,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    discarded_at timestamp without time zone,
    methodology_version integer NOT NULL
);


--
-- Name: mq_assessments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mq_assessments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mq_assessments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mq_assessments_id_seq OWNED BY public.mq_assessments.id;


--
-- Name: news_articles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.news_articles (
    id bigint NOT NULL,
    title character varying,
    content text,
    publication_date timestamp without time zone,
    created_by_id bigint,
    updated_by_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: news_articles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.news_articles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: news_articles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.news_articles_id_seq OWNED BY public.news_articles.id;


--
-- Name: news_articles_tpi_sectors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.news_articles_tpi_sectors (
    news_article_id bigint NOT NULL,
    tpi_sector_id bigint NOT NULL
);


--
-- Name: pages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pages (
    id bigint NOT NULL,
    title character varying,
    description text,
    slug character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    menu character varying,
    type character varying,
    "position" integer
);


--
-- Name: pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pages_id_seq OWNED BY public.pages.id;


--
-- Name: publications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.publications (
    id bigint NOT NULL,
    title character varying,
    short_description text,
    file bigint,
    image bigint,
    publication_date timestamp without time zone,
    created_by_id bigint,
    updated_by_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    author character varying
);


--
-- Name: publications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.publications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: publications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.publications_id_seq OWNED BY public.publications.id;


--
-- Name: publications_tpi_sectors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.publications_tpi_sectors (
    publication_id bigint NOT NULL,
    tpi_sector_id bigint NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: taggings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.taggings (
    id bigint NOT NULL,
    tag_id bigint,
    taggable_type character varying,
    taggable_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: taggings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.taggings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: taggings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.taggings_id_seq OWNED BY public.taggings.id;


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tags (
    id bigint NOT NULL,
    name character varying NOT NULL,
    type character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tags_id_seq OWNED BY public.tags.id;


--
-- Name: targets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.targets (
    id bigint NOT NULL,
    geography_id bigint,
    ghg_target boolean DEFAULT false NOT NULL,
    single_year boolean DEFAULT false NOT NULL,
    description text,
    year integer,
    base_year_period character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    target_type character varying,
    visibility_status character varying DEFAULT 'draft'::character varying,
    created_by_id bigint,
    updated_by_id bigint,
    discarded_at timestamp without time zone,
    sector_id bigint,
    source character varying,
    tsv tsvector
);


--
-- Name: targets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.targets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: targets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.targets_id_seq OWNED BY public.targets.id;


--
-- Name: testimonials; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.testimonials (
    id bigint NOT NULL,
    quote character varying,
    author character varying,
    role character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: testimonials_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.testimonials_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: testimonials_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.testimonials_id_seq OWNED BY public.testimonials.id;


--
-- Name: theme_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.theme_types (
    id bigint NOT NULL,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    discarded_at timestamp without time zone
);


--
-- Name: theme_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.theme_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: theme_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.theme_types_id_seq OWNED BY public.theme_types.id;


--
-- Name: themes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.themes (
    id bigint NOT NULL,
    name character varying,
    theme_type_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    discarded_at timestamp without time zone
);


--
-- Name: themes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.themes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: themes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.themes_id_seq OWNED BY public.themes.id;


--
-- Name: tpi_sector_clusters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tpi_sector_clusters (
    id bigint NOT NULL,
    name character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: tpi_sector_clusters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tpi_sector_clusters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tpi_sector_clusters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tpi_sector_clusters_id_seq OWNED BY public.tpi_sector_clusters.id;


--
-- Name: tpi_sectors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tpi_sectors (
    id bigint NOT NULL,
    name character varying NOT NULL,
    slug character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    cluster_id bigint,
    show_in_tpi_tool boolean DEFAULT true NOT NULL
);


--
-- Name: tpi_sectors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tpi_sectors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tpi_sectors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tpi_sectors_id_seq OWNED BY public.tpi_sectors.id;


--
-- Name: active_admin_comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_admin_comments ALTER COLUMN id SET DEFAULT nextval('public.active_admin_comments_id_seq'::regclass);


--
-- Name: active_storage_attachments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments ALTER COLUMN id SET DEFAULT nextval('public.active_storage_attachments_id_seq'::regclass);


--
-- Name: active_storage_blobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs ALTER COLUMN id SET DEFAULT nextval('public.active_storage_blobs_id_seq'::regclass);


--
-- Name: activities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activities ALTER COLUMN id SET DEFAULT nextval('public.activities_id_seq'::regclass);


--
-- Name: admin_users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_users ALTER COLUMN id SET DEFAULT nextval('public.admin_users_id_seq'::regclass);


--
-- Name: bank_assessment_indicators id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bank_assessment_indicators ALTER COLUMN id SET DEFAULT nextval('public.bank_assessment_indicators_id_seq'::regclass);


--
-- Name: bank_assessment_results id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bank_assessment_results ALTER COLUMN id SET DEFAULT nextval('public.bank_assessment_results_id_seq'::regclass);


--
-- Name: bank_assessments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bank_assessments ALTER COLUMN id SET DEFAULT nextval('public.bank_assessments_id_seq'::regclass);


--
-- Name: banks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.banks ALTER COLUMN id SET DEFAULT nextval('public.banks_id_seq'::regclass);


--
-- Name: case_studies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.case_studies ALTER COLUMN id SET DEFAULT nextval('public.case_studies_id_seq'::regclass);


--
-- Name: companies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.companies ALTER COLUMN id SET DEFAULT nextval('public.companies_id_seq'::regclass);


--
-- Name: contents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contents ALTER COLUMN id SET DEFAULT nextval('public.contents_id_seq'::regclass);


--
-- Name: cp_assessments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cp_assessments ALTER COLUMN id SET DEFAULT nextval('public.cp_assessments_id_seq'::regclass);


--
-- Name: cp_benchmarks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cp_benchmarks ALTER COLUMN id SET DEFAULT nextval('public.cp_benchmarks_id_seq'::regclass);


--
-- Name: cp_units id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cp_units ALTER COLUMN id SET DEFAULT nextval('public.cp_units_id_seq'::regclass);


--
-- Name: data_uploads id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.data_uploads ALTER COLUMN id SET DEFAULT nextval('public.data_uploads_id_seq'::regclass);


--
-- Name: documents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents ALTER COLUMN id SET DEFAULT nextval('public.documents_id_seq'::regclass);


--
-- Name: events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events ALTER COLUMN id SET DEFAULT nextval('public.events_id_seq'::regclass);


--
-- Name: external_legislations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.external_legislations ALTER COLUMN id SET DEFAULT nextval('public.external_legislations_id_seq'::regclass);


--
-- Name: friendly_id_slugs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.friendly_id_slugs ALTER COLUMN id SET DEFAULT nextval('public.friendly_id_slugs_id_seq'::regclass);


--
-- Name: geographies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.geographies ALTER COLUMN id SET DEFAULT nextval('public.geographies_id_seq'::regclass);


--
-- Name: images id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.images ALTER COLUMN id SET DEFAULT nextval('public.images_id_seq'::regclass);


--
-- Name: instrument_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instrument_types ALTER COLUMN id SET DEFAULT nextval('public.instrument_types_id_seq'::regclass);


--
-- Name: instruments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instruments ALTER COLUMN id SET DEFAULT nextval('public.instruments_id_seq'::regclass);


--
-- Name: laws_sectors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.laws_sectors ALTER COLUMN id SET DEFAULT nextval('public.laws_sectors_id_seq'::regclass);


--
-- Name: legislations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legislations ALTER COLUMN id SET DEFAULT nextval('public.legislations_id_seq'::regclass);


--
-- Name: legislations_targets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legislations_targets ALTER COLUMN id SET DEFAULT nextval('public.legislations_targets_id_seq'::regclass);


--
-- Name: litigation_sides id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.litigation_sides ALTER COLUMN id SET DEFAULT nextval('public.litigation_sides_id_seq'::regclass);


--
-- Name: litigations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.litigations ALTER COLUMN id SET DEFAULT nextval('public.litigations_id_seq'::regclass);


--
-- Name: mq_assessments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mq_assessments ALTER COLUMN id SET DEFAULT nextval('public.mq_assessments_id_seq'::regclass);


--
-- Name: news_articles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.news_articles ALTER COLUMN id SET DEFAULT nextval('public.news_articles_id_seq'::regclass);


--
-- Name: pages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages ALTER COLUMN id SET DEFAULT nextval('public.pages_id_seq'::regclass);


--
-- Name: publications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publications ALTER COLUMN id SET DEFAULT nextval('public.publications_id_seq'::regclass);


--
-- Name: taggings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.taggings ALTER COLUMN id SET DEFAULT nextval('public.taggings_id_seq'::regclass);


--
-- Name: tags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags ALTER COLUMN id SET DEFAULT nextval('public.tags_id_seq'::regclass);


--
-- Name: targets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.targets ALTER COLUMN id SET DEFAULT nextval('public.targets_id_seq'::regclass);


--
-- Name: testimonials id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.testimonials ALTER COLUMN id SET DEFAULT nextval('public.testimonials_id_seq'::regclass);


--
-- Name: theme_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.theme_types ALTER COLUMN id SET DEFAULT nextval('public.theme_types_id_seq'::regclass);


--
-- Name: themes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.themes ALTER COLUMN id SET DEFAULT nextval('public.themes_id_seq'::regclass);


--
-- Name: tpi_sector_clusters id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tpi_sector_clusters ALTER COLUMN id SET DEFAULT nextval('public.tpi_sector_clusters_id_seq'::regclass);


--
-- Name: tpi_sectors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tpi_sectors ALTER COLUMN id SET DEFAULT nextval('public.tpi_sectors_id_seq'::regclass);


--
-- Name: active_admin_comments active_admin_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_admin_comments
    ADD CONSTRAINT active_admin_comments_pkey PRIMARY KEY (id);


--
-- Name: active_storage_attachments active_storage_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT active_storage_attachments_pkey PRIMARY KEY (id);


--
-- Name: active_storage_blobs active_storage_blobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs
    ADD CONSTRAINT active_storage_blobs_pkey PRIMARY KEY (id);


--
-- Name: activities activities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_pkey PRIMARY KEY (id);


--
-- Name: admin_users admin_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_users
    ADD CONSTRAINT admin_users_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: bank_assessment_indicators bank_assessment_indicators_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bank_assessment_indicators
    ADD CONSTRAINT bank_assessment_indicators_pkey PRIMARY KEY (id);


--
-- Name: bank_assessment_results bank_assessment_results_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bank_assessment_results
    ADD CONSTRAINT bank_assessment_results_pkey PRIMARY KEY (id);


--
-- Name: bank_assessments bank_assessments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bank_assessments
    ADD CONSTRAINT bank_assessments_pkey PRIMARY KEY (id);


--
-- Name: banks banks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.banks
    ADD CONSTRAINT banks_pkey PRIMARY KEY (id);


--
-- Name: case_studies case_studies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.case_studies
    ADD CONSTRAINT case_studies_pkey PRIMARY KEY (id);


--
-- Name: companies companies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT companies_pkey PRIMARY KEY (id);


--
-- Name: contents contents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contents
    ADD CONSTRAINT contents_pkey PRIMARY KEY (id);


--
-- Name: cp_assessments cp_assessments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cp_assessments
    ADD CONSTRAINT cp_assessments_pkey PRIMARY KEY (id);


--
-- Name: cp_benchmarks cp_benchmarks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cp_benchmarks
    ADD CONSTRAINT cp_benchmarks_pkey PRIMARY KEY (id);


--
-- Name: cp_units cp_units_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cp_units
    ADD CONSTRAINT cp_units_pkey PRIMARY KEY (id);


--
-- Name: data_uploads data_uploads_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.data_uploads
    ADD CONSTRAINT data_uploads_pkey PRIMARY KEY (id);


--
-- Name: documents documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: external_legislations external_legislations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.external_legislations
    ADD CONSTRAINT external_legislations_pkey PRIMARY KEY (id);


--
-- Name: friendly_id_slugs friendly_id_slugs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.friendly_id_slugs
    ADD CONSTRAINT friendly_id_slugs_pkey PRIMARY KEY (id);


--
-- Name: geographies geographies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.geographies
    ADD CONSTRAINT geographies_pkey PRIMARY KEY (id);


--
-- Name: images images_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.images
    ADD CONSTRAINT images_pkey PRIMARY KEY (id);


--
-- Name: instrument_types instrument_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instrument_types
    ADD CONSTRAINT instrument_types_pkey PRIMARY KEY (id);


--
-- Name: instruments instruments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instruments
    ADD CONSTRAINT instruments_pkey PRIMARY KEY (id);


--
-- Name: laws_sectors laws_sectors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.laws_sectors
    ADD CONSTRAINT laws_sectors_pkey PRIMARY KEY (id);


--
-- Name: legislations legislations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legislations
    ADD CONSTRAINT legislations_pkey PRIMARY KEY (id);


--
-- Name: legislations_targets legislations_targets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legislations_targets
    ADD CONSTRAINT legislations_targets_pkey PRIMARY KEY (id);


--
-- Name: litigation_sides litigation_sides_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.litigation_sides
    ADD CONSTRAINT litigation_sides_pkey PRIMARY KEY (id);


--
-- Name: litigations litigations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.litigations
    ADD CONSTRAINT litigations_pkey PRIMARY KEY (id);


--
-- Name: mq_assessments mq_assessments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mq_assessments
    ADD CONSTRAINT mq_assessments_pkey PRIMARY KEY (id);


--
-- Name: news_articles news_articles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.news_articles
    ADD CONSTRAINT news_articles_pkey PRIMARY KEY (id);


--
-- Name: pages pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages
    ADD CONSTRAINT pages_pkey PRIMARY KEY (id);


--
-- Name: publications publications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publications
    ADD CONSTRAINT publications_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: taggings taggings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.taggings
    ADD CONSTRAINT taggings_pkey PRIMARY KEY (id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: targets targets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.targets
    ADD CONSTRAINT targets_pkey PRIMARY KEY (id);


--
-- Name: testimonials testimonials_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.testimonials
    ADD CONSTRAINT testimonials_pkey PRIMARY KEY (id);


--
-- Name: theme_types theme_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.theme_types
    ADD CONSTRAINT theme_types_pkey PRIMARY KEY (id);


--
-- Name: themes themes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.themes
    ADD CONSTRAINT themes_pkey PRIMARY KEY (id);


--
-- Name: tpi_sector_clusters tpi_sector_clusters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tpi_sector_clusters
    ADD CONSTRAINT tpi_sector_clusters_pkey PRIMARY KEY (id);


--
-- Name: tpi_sectors tpi_sectors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tpi_sectors
    ADD CONSTRAINT tpi_sectors_pkey PRIMARY KEY (id);


--
-- Name: index_active_admin_comments_on_author_type_and_author_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_admin_comments_on_author_type_and_author_id ON public.active_admin_comments USING btree (author_type, author_id);


--
-- Name: index_active_admin_comments_on_namespace; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_admin_comments_on_namespace ON public.active_admin_comments USING btree (namespace);


--
-- Name: index_active_admin_comments_on_resource_type_and_resource_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_admin_comments_on_resource_type_and_resource_id ON public.active_admin_comments USING btree (resource_type, resource_id);


--
-- Name: index_active_storage_attachments_on_blob_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_storage_attachments_on_blob_id ON public.active_storage_attachments USING btree (blob_id);


--
-- Name: index_active_storage_attachments_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_attachments_uniqueness ON public.active_storage_attachments USING btree (record_type, record_id, name, blob_id);


--
-- Name: index_active_storage_blobs_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_blobs_on_key ON public.active_storage_blobs USING btree (key);


--
-- Name: index_activities_on_owner_id_and_owner_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activities_on_owner_id_and_owner_type ON public.activities USING btree (owner_id, owner_type);


--
-- Name: index_activities_on_owner_type_and_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activities_on_owner_type_and_owner_id ON public.activities USING btree (owner_type, owner_id);


--
-- Name: index_activities_on_recipient_id_and_recipient_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activities_on_recipient_id_and_recipient_type ON public.activities USING btree (recipient_id, recipient_type);


--
-- Name: index_activities_on_recipient_type_and_recipient_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activities_on_recipient_type_and_recipient_id ON public.activities USING btree (recipient_type, recipient_id);


--
-- Name: index_activities_on_trackable_id_and_trackable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activities_on_trackable_id_and_trackable_type ON public.activities USING btree (trackable_id, trackable_type);


--
-- Name: index_activities_on_trackable_type_and_trackable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activities_on_trackable_type_and_trackable_id ON public.activities USING btree (trackable_type, trackable_id);


--
-- Name: index_admin_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admin_users_on_email ON public.admin_users USING btree (email);


--
-- Name: index_admin_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admin_users_on_reset_password_token ON public.admin_users USING btree (reset_password_token);


--
-- Name: index_bank_assessment_indicators_on_indicator_type_and_number; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_bank_assessment_indicators_on_indicator_type_and_number ON public.bank_assessment_indicators USING btree (indicator_type, number);


--
-- Name: index_bank_assessment_results_on_bank_assessment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bank_assessment_results_on_bank_assessment_id ON public.bank_assessment_results USING btree (bank_assessment_id);


--
-- Name: index_bank_assessment_results_on_bank_assessment_indicator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bank_assessment_results_on_bank_assessment_indicator_id ON public.bank_assessment_results USING btree (bank_assessment_indicator_id);


--
-- Name: index_bank_assessments_on_bank_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bank_assessments_on_bank_id ON public.bank_assessments USING btree (bank_id);


--
-- Name: index_banks_on_geography_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_banks_on_geography_id ON public.banks USING btree (geography_id);


--
-- Name: index_banks_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_banks_on_name ON public.banks USING btree (name);


--
-- Name: index_banks_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_banks_on_slug ON public.banks USING btree (slug);


--
-- Name: index_companies_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_companies_on_discarded_at ON public.companies USING btree (discarded_at);


--
-- Name: index_companies_on_geography_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_companies_on_geography_id ON public.companies USING btree (geography_id);


--
-- Name: index_companies_on_headquarters_geography_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_companies_on_headquarters_geography_id ON public.companies USING btree (headquarters_geography_id);


--
-- Name: index_companies_on_market_cap_group; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_companies_on_market_cap_group ON public.companies USING btree (market_cap_group);


--
-- Name: index_companies_on_sector_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_companies_on_sector_id ON public.companies USING btree (sector_id);


--
-- Name: index_companies_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_companies_on_slug ON public.companies USING btree (slug);


--
-- Name: index_contents_on_page_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contents_on_page_id ON public.contents USING btree (page_id);


--
-- Name: index_cp_assessments_on_cp_assessmentable; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cp_assessments_on_cp_assessmentable ON public.cp_assessments USING btree (cp_assessmentable_type, cp_assessmentable_id);


--
-- Name: index_cp_assessments_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cp_assessments_on_discarded_at ON public.cp_assessments USING btree (discarded_at);


--
-- Name: index_cp_assessments_on_sector_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cp_assessments_on_sector_id ON public.cp_assessments USING btree (sector_id);


--
-- Name: index_cp_benchmarks_on_sector_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cp_benchmarks_on_sector_id ON public.cp_benchmarks USING btree (sector_id);


--
-- Name: index_cp_units_on_sector_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cp_units_on_sector_id ON public.cp_units USING btree (sector_id);


--
-- Name: index_data_uploads_on_uploaded_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_data_uploads_on_uploaded_by_id ON public.data_uploads USING btree (uploaded_by_id);


--
-- Name: index_documents_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_documents_on_discarded_at ON public.documents USING btree (discarded_at);


--
-- Name: index_documents_on_documentable_type_and_documentable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_documents_on_documentable_type_and_documentable_id ON public.documents USING btree (documentable_type, documentable_id);


--
-- Name: index_events_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_on_discarded_at ON public.events USING btree (discarded_at);


--
-- Name: index_events_on_eventable_type_and_eventable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_on_eventable_type_and_eventable_id ON public.events USING btree (eventable_type, eventable_id);


--
-- Name: index_external_legislations_and_litigations_ids; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_external_legislations_and_litigations_ids ON public.external_legislations_litigations USING btree (litigation_id, external_legislation_id);


--
-- Name: index_external_legislations_on_geography_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_external_legislations_on_geography_id ON public.external_legislations USING btree (geography_id);


--
-- Name: index_friendly_id_slugs_on_slug_and_sluggable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_friendly_id_slugs_on_slug_and_sluggable_type ON public.friendly_id_slugs USING btree (slug, sluggable_type);


--
-- Name: index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope ON public.friendly_id_slugs USING btree (slug, sluggable_type, scope);


--
-- Name: index_friendly_id_slugs_on_sluggable_type_and_sluggable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_friendly_id_slugs_on_sluggable_type_and_sluggable_id ON public.friendly_id_slugs USING btree (sluggable_type, sluggable_id);


--
-- Name: index_geographies_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_geographies_on_created_by_id ON public.geographies USING btree (created_by_id);


--
-- Name: index_geographies_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_geographies_on_discarded_at ON public.geographies USING btree (discarded_at);


--
-- Name: index_geographies_on_iso; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_geographies_on_iso ON public.geographies USING btree (iso);


--
-- Name: index_geographies_on_region; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_geographies_on_region ON public.geographies USING btree (region);


--
-- Name: index_geographies_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_geographies_on_slug ON public.geographies USING btree (slug);


--
-- Name: index_geographies_on_updated_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_geographies_on_updated_by_id ON public.geographies USING btree (updated_by_id);


--
-- Name: index_images_on_content_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_images_on_content_id ON public.images USING btree (content_id);


--
-- Name: index_instrument_types_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_instrument_types_on_discarded_at ON public.instrument_types USING btree (discarded_at);


--
-- Name: index_instrument_types_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_instrument_types_on_name ON public.instrument_types USING btree (name);


--
-- Name: index_instruments_legislations_on_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_instruments_legislations_on_instrument_id ON public.instruments_legislations USING btree (instrument_id);


--
-- Name: index_instruments_legislations_on_legislation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_instruments_legislations_on_legislation_id ON public.instruments_legislations USING btree (legislation_id);


--
-- Name: index_instruments_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_instruments_on_discarded_at ON public.instruments USING btree (discarded_at);


--
-- Name: index_instruments_on_instrument_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_instruments_on_instrument_type_id ON public.instruments USING btree (instrument_type_id);


--
-- Name: index_instruments_on_name_and_instrument_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_instruments_on_name_and_instrument_type_id ON public.instruments USING btree (name, instrument_type_id);


--
-- Name: index_laws_sectors_legislations_on_laws_sector_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_laws_sectors_legislations_on_laws_sector_id ON public.laws_sectors_legislations USING btree (laws_sector_id);


--
-- Name: index_laws_sectors_legislations_on_legislation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_laws_sectors_legislations_on_legislation_id ON public.laws_sectors_legislations USING btree (legislation_id);


--
-- Name: index_laws_sectors_litigations_on_laws_sector_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_laws_sectors_litigations_on_laws_sector_id ON public.laws_sectors_litigations USING btree (laws_sector_id);


--
-- Name: index_laws_sectors_litigations_on_litigation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_laws_sectors_litigations_on_litigation_id ON public.laws_sectors_litigations USING btree (litigation_id);


--
-- Name: index_laws_sectors_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_laws_sectors_on_name ON public.laws_sectors USING btree (name);


--
-- Name: index_laws_sectors_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_laws_sectors_on_parent_id ON public.laws_sectors USING btree (parent_id);


--
-- Name: index_legislations_litigations_on_legislation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_legislations_litigations_on_legislation_id ON public.legislations_litigations USING btree (legislation_id);


--
-- Name: index_legislations_litigations_on_litigation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_legislations_litigations_on_litigation_id ON public.legislations_litigations USING btree (litigation_id);


--
-- Name: index_legislations_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_legislations_on_created_by_id ON public.legislations USING btree (created_by_id);


--
-- Name: index_legislations_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_legislations_on_discarded_at ON public.legislations USING btree (discarded_at);


--
-- Name: index_legislations_on_geography_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_legislations_on_geography_id ON public.legislations USING btree (geography_id);


--
-- Name: index_legislations_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_legislations_on_parent_id ON public.legislations USING btree (parent_id);


--
-- Name: index_legislations_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_legislations_on_slug ON public.legislations USING btree (slug);


--
-- Name: index_legislations_on_tsv; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_legislations_on_tsv ON public.legislations USING gin (tsv);


--
-- Name: index_legislations_on_updated_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_legislations_on_updated_by_id ON public.legislations USING btree (updated_by_id);


--
-- Name: index_legislations_targets_on_legislation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_legislations_targets_on_legislation_id ON public.legislations_targets USING btree (legislation_id);


--
-- Name: index_legislations_targets_on_target_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_legislations_targets_on_target_id ON public.legislations_targets USING btree (target_id);


--
-- Name: index_legislations_targets_on_target_id_and_legislation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_legislations_targets_on_target_id_and_legislation_id ON public.legislations_targets USING btree (target_id, legislation_id);


--
-- Name: index_legislations_themes_on_legislation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_legislations_themes_on_legislation_id ON public.legislations_themes USING btree (legislation_id);


--
-- Name: index_legislations_themes_on_theme_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_legislations_themes_on_theme_id ON public.legislations_themes USING btree (theme_id);


--
-- Name: index_litigation_sides_connected_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_litigation_sides_connected_entity ON public.litigation_sides USING btree (connected_entity_type, connected_entity_id);


--
-- Name: index_litigation_sides_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_litigation_sides_on_discarded_at ON public.litigation_sides USING btree (discarded_at);


--
-- Name: index_litigation_sides_on_litigation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_litigation_sides_on_litigation_id ON public.litigation_sides USING btree (litigation_id);


--
-- Name: index_litigation_sides_on_litigation_id_and_side_type_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_litigation_sides_on_litigation_id_and_side_type_and_name ON public.litigation_sides USING btree (litigation_id, side_type, name);


--
-- Name: index_litigations_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_litigations_on_created_by_id ON public.litigations USING btree (created_by_id);


--
-- Name: index_litigations_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_litigations_on_discarded_at ON public.litigations USING btree (discarded_at);


--
-- Name: index_litigations_on_document_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_litigations_on_document_type ON public.litigations USING btree (document_type);


--
-- Name: index_litigations_on_geography_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_litigations_on_geography_id ON public.litigations USING btree (geography_id);


--
-- Name: index_litigations_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_litigations_on_slug ON public.litigations USING btree (slug);


--
-- Name: index_litigations_on_tsv; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_litigations_on_tsv ON public.litigations USING gin (tsv);


--
-- Name: index_litigations_on_updated_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_litigations_on_updated_by_id ON public.litigations USING btree (updated_by_id);


--
-- Name: index_mq_assessments_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_mq_assessments_on_company_id ON public.mq_assessments USING btree (company_id);


--
-- Name: index_mq_assessments_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_mq_assessments_on_discarded_at ON public.mq_assessments USING btree (discarded_at);


--
-- Name: index_news_articles_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_news_articles_on_created_by_id ON public.news_articles USING btree (created_by_id);


--
-- Name: index_news_articles_on_updated_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_news_articles_on_updated_by_id ON public.news_articles USING btree (updated_by_id);


--
-- Name: index_news_articles_tpi_sectors_on_news_article_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_news_articles_tpi_sectors_on_news_article_id ON public.news_articles_tpi_sectors USING btree (news_article_id);


--
-- Name: index_news_articles_tpi_sectors_on_tpi_sector_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_news_articles_tpi_sectors_on_tpi_sector_id ON public.news_articles_tpi_sectors USING btree (tpi_sector_id);


--
-- Name: index_publications_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_publications_on_created_by_id ON public.publications USING btree (created_by_id);


--
-- Name: index_publications_on_updated_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_publications_on_updated_by_id ON public.publications USING btree (updated_by_id);


--
-- Name: index_publications_tpi_sectors_on_publication_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_publications_tpi_sectors_on_publication_id ON public.publications_tpi_sectors USING btree (publication_id);


--
-- Name: index_publications_tpi_sectors_on_tpi_sector_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_publications_tpi_sectors_on_tpi_sector_id ON public.publications_tpi_sectors USING btree (tpi_sector_id);


--
-- Name: index_taggings_on_tag_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_taggings_on_tag_id ON public.taggings USING btree (tag_id);


--
-- Name: index_taggings_on_taggable_type_and_taggable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_taggings_on_taggable_type_and_taggable_id ON public.taggings USING btree (taggable_type, taggable_id);


--
-- Name: index_tags_on_name_and_type; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_tags_on_name_and_type ON public.tags USING btree (name, type);


--
-- Name: index_targets_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_targets_on_created_by_id ON public.targets USING btree (created_by_id);


--
-- Name: index_targets_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_targets_on_discarded_at ON public.targets USING btree (discarded_at);


--
-- Name: index_targets_on_geography_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_targets_on_geography_id ON public.targets USING btree (geography_id);


--
-- Name: index_targets_on_sector_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_targets_on_sector_id ON public.targets USING btree (sector_id);


--
-- Name: index_targets_on_tsv; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_targets_on_tsv ON public.targets USING gin (tsv);


--
-- Name: index_targets_on_updated_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_targets_on_updated_by_id ON public.targets USING btree (updated_by_id);


--
-- Name: index_theme_types_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_theme_types_on_discarded_at ON public.theme_types USING btree (discarded_at);


--
-- Name: index_theme_types_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_theme_types_on_name ON public.theme_types USING btree (name);


--
-- Name: index_themes_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_themes_on_discarded_at ON public.themes USING btree (discarded_at);


--
-- Name: index_themes_on_name_and_theme_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_themes_on_name_and_theme_type_id ON public.themes USING btree (name, theme_type_id);


--
-- Name: index_themes_on_theme_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_themes_on_theme_type_id ON public.themes USING btree (theme_type_id);


--
-- Name: index_tpi_sectors_on_cluster_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tpi_sectors_on_cluster_id ON public.tpi_sectors USING btree (cluster_id);


--
-- Name: index_tpi_sectors_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_tpi_sectors_on_name ON public.tpi_sectors USING btree (name);


--
-- Name: index_tpi_sectors_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_tpi_sectors_on_slug ON public.tpi_sectors USING btree (slug);


--
-- Name: legislations tsvectorupdate; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE ON public.legislations FOR EACH ROW EXECUTE FUNCTION public.legislation_tsv_trigger();


--
-- Name: litigations tsvectorupdate; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE ON public.litigations FOR EACH ROW EXECUTE FUNCTION public.litigation_tsv_trigger();


--
-- Name: targets tsvectorupdate; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE ON public.targets FOR EACH ROW EXECUTE FUNCTION public.target_tsv_trigger();


--
-- Name: targets fk_rails_051e73b520; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.targets
    ADD CONSTRAINT fk_rails_051e73b520 FOREIGN KEY (updated_by_id) REFERENCES public.admin_users(id);


--
-- Name: legislations_targets fk_rails_0dcade7ab2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legislations_targets
    ADD CONSTRAINT fk_rails_0dcade7ab2 FOREIGN KEY (target_id) REFERENCES public.targets(id) ON DELETE CASCADE;


--
-- Name: legislations fk_rails_18e11db07f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legislations
    ADD CONSTRAINT fk_rails_18e11db07f FOREIGN KEY (geography_id) REFERENCES public.geographies(id);


--
-- Name: legislations_targets fk_rails_19c10ed32b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legislations_targets
    ADD CONSTRAINT fk_rails_19c10ed32b FOREIGN KEY (legislation_id) REFERENCES public.legislations(id) ON DELETE CASCADE;


--
-- Name: companies fk_rails_1b3e78a93d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT fk_rails_1b3e78a93d FOREIGN KEY (sector_id) REFERENCES public.tpi_sectors(id);


--
-- Name: targets fk_rails_1bc68932f6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.targets
    ADD CONSTRAINT fk_rails_1bc68932f6 FOREIGN KEY (created_by_id) REFERENCES public.admin_users(id);


--
-- Name: instruments fk_rails_1e91dc995b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instruments
    ADD CONSTRAINT fk_rails_1e91dc995b FOREIGN KEY (instrument_type_id) REFERENCES public.instrument_types(id);


--
-- Name: companies fk_rails_1e99f51bd6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT fk_rails_1e99f51bd6 FOREIGN KEY (geography_id) REFERENCES public.geographies(id);


--
-- Name: bank_assessment_results fk_rails_2796dae392; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bank_assessment_results
    ADD CONSTRAINT fk_rails_2796dae392 FOREIGN KEY (bank_assessment_id) REFERENCES public.bank_assessments(id);


--
-- Name: news_articles fk_rails_286df43ea0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.news_articles
    ADD CONSTRAINT fk_rails_286df43ea0 FOREIGN KEY (created_by_id) REFERENCES public.admin_users(id);


--
-- Name: legislations fk_rails_2d705f7c8d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legislations
    ADD CONSTRAINT fk_rails_2d705f7c8d FOREIGN KEY (parent_id) REFERENCES public.legislations(id);


--
-- Name: geographies fk_rails_318296af0e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.geographies
    ADD CONSTRAINT fk_rails_318296af0e FOREIGN KEY (updated_by_id) REFERENCES public.admin_users(id);


--
-- Name: litigations fk_rails_3ad3738b8b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.litigations
    ADD CONSTRAINT fk_rails_3ad3738b8b FOREIGN KEY (geography_id) REFERENCES public.geographies(id) ON DELETE CASCADE;


--
-- Name: images fk_rails_3ddaef631e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.images
    ADD CONSTRAINT fk_rails_3ddaef631e FOREIGN KEY (content_id) REFERENCES public.contents(id);


--
-- Name: mq_assessments fk_rails_4062aa884b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mq_assessments
    ADD CONSTRAINT fk_rails_4062aa884b FOREIGN KEY (company_id) REFERENCES public.companies(id) ON DELETE CASCADE;


--
-- Name: companies fk_rails_4604e9667e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT fk_rails_4604e9667e FOREIGN KEY (headquarters_geography_id) REFERENCES public.geographies(id);


--
-- Name: bank_assessment_results fk_rails_46970f9780; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bank_assessment_results
    ADD CONSTRAINT fk_rails_46970f9780 FOREIGN KEY (bank_assessment_indicator_id) REFERENCES public.bank_assessment_indicators(id);


--
-- Name: geographies fk_rails_4b7c42813d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.geographies
    ADD CONSTRAINT fk_rails_4b7c42813d FOREIGN KEY (created_by_id) REFERENCES public.admin_users(id);


--
-- Name: cp_assessments fk_rails_4c218774c4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cp_assessments
    ADD CONSTRAINT fk_rails_4c218774c4 FOREIGN KEY (sector_id) REFERENCES public.tpi_sectors(id);


--
-- Name: cp_benchmarks fk_rails_59a4fb24ff; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cp_benchmarks
    ADD CONSTRAINT fk_rails_59a4fb24ff FOREIGN KEY (sector_id) REFERENCES public.tpi_sectors(id) ON DELETE CASCADE;


--
-- Name: news_articles fk_rails_5a143faf62; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.news_articles
    ADD CONSTRAINT fk_rails_5a143faf62 FOREIGN KEY (updated_by_id) REFERENCES public.admin_users(id);


--
-- Name: legislations fk_rails_5d6bdce608; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legislations
    ADD CONSTRAINT fk_rails_5d6bdce608 FOREIGN KEY (created_by_id) REFERENCES public.admin_users(id);


--
-- Name: litigation_sides fk_rails_5ff60f0b08; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.litigation_sides
    ADD CONSTRAINT fk_rails_5ff60f0b08 FOREIGN KEY (litigation_id) REFERENCES public.litigations(id) ON DELETE CASCADE;


--
-- Name: bank_assessments fk_rails_68427d4c57; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bank_assessments
    ADD CONSTRAINT fk_rails_68427d4c57 FOREIGN KEY (bank_id) REFERENCES public.banks(id) ON DELETE CASCADE;


--
-- Name: targets fk_rails_68ebac20c0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.targets
    ADD CONSTRAINT fk_rails_68ebac20c0 FOREIGN KEY (geography_id) REFERENCES public.geographies(id);


--
-- Name: publications fk_rails_6984032012; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publications
    ADD CONSTRAINT fk_rails_6984032012 FOREIGN KEY (updated_by_id) REFERENCES public.admin_users(id);


--
-- Name: themes fk_rails_767317104d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.themes
    ADD CONSTRAINT fk_rails_767317104d FOREIGN KEY (theme_type_id) REFERENCES public.theme_types(id);


--
-- Name: tpi_sectors fk_rails_77ac88b357; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tpi_sectors
    ADD CONSTRAINT fk_rails_77ac88b357 FOREIGN KEY (cluster_id) REFERENCES public.tpi_sector_clusters(id);


--
-- Name: laws_sectors fk_rails_79ad4633ee; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.laws_sectors
    ADD CONSTRAINT fk_rails_79ad4633ee FOREIGN KEY (parent_id) REFERENCES public.laws_sectors(id);


--
-- Name: litigations fk_rails_7db3ad4321; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.litigations
    ADD CONSTRAINT fk_rails_7db3ad4321 FOREIGN KEY (updated_by_id) REFERENCES public.admin_users(id);


--
-- Name: external_legislations fk_rails_85ce3ec15b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.external_legislations
    ADD CONSTRAINT fk_rails_85ce3ec15b FOREIGN KEY (geography_id) REFERENCES public.geographies(id);


--
-- Name: cp_units fk_rails_8a33165b2e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cp_units
    ADD CONSTRAINT fk_rails_8a33165b2e FOREIGN KEY (sector_id) REFERENCES public.tpi_sectors(id) ON DELETE CASCADE;


--
-- Name: litigations fk_rails_91bc4f3078; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.litigations
    ADD CONSTRAINT fk_rails_91bc4f3078 FOREIGN KEY (created_by_id) REFERENCES public.admin_users(id);


--
-- Name: taggings fk_rails_9fcd2e236b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.taggings
    ADD CONSTRAINT fk_rails_9fcd2e236b FOREIGN KEY (tag_id) REFERENCES public.tags(id) ON DELETE CASCADE;


--
-- Name: publications fk_rails_a957b2faea; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publications
    ADD CONSTRAINT fk_rails_a957b2faea FOREIGN KEY (created_by_id) REFERENCES public.admin_users(id);


--
-- Name: contents fk_rails_b169e370d5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contents
    ADD CONSTRAINT fk_rails_b169e370d5 FOREIGN KEY (page_id) REFERENCES public.pages(id);


--
-- Name: banks fk_rails_b7a12616f3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.banks
    ADD CONSTRAINT fk_rails_b7a12616f3 FOREIGN KEY (geography_id) REFERENCES public.geographies(id);


--
-- Name: legislations fk_rails_ba015eb89e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legislations
    ADD CONSTRAINT fk_rails_ba015eb89e FOREIGN KEY (updated_by_id) REFERENCES public.admin_users(id);


--
-- Name: active_storage_attachments fk_rails_c3b3935057; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT fk_rails_c3b3935057 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: targets fk_rails_db1f7292db; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.targets
    ADD CONSTRAINT fk_rails_db1f7292db FOREIGN KEY (sector_id) REFERENCES public.laws_sectors(id);


--
-- Name: data_uploads fk_rails_e965439ee4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.data_uploads
    ADD CONSTRAINT fk_rails_e965439ee4 FOREIGN KEY (uploaded_by_id) REFERENCES public.admin_users(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20190626124507'),
('20190626124509'),
('20190627081626'),
('20190627132024'),
('20190627134255'),
('20190702165934'),
('20190703130037'),
('20190703153230'),
('20190715092238'),
('20190715150750'),
('20190716100402'),
('20190716113250'),
('20190719102422'),
('20190719104815'),
('20190724164237'),
('20190725103310'),
('20190729180026'),
('20190729190125'),
('20190729190643'),
('20190731091008'),
('20190801105940'),
('20190801123408'),
('20190802113528'),
('20190805160350'),
('20190805161835'),
('20190805162617'),
('20190805170751'),
('20190807141621'),
('20190807144809'),
('20190807153848'),
('20190807155801'),
('20190807161420'),
('20190807162621'),
('20190809131640'),
('20190812154729'),
('20190820221054'),
('20190822112921'),
('20190823131259'),
('20190828203630'),
('20190909131545'),
('20190912050407'),
('20190912050415'),
('20190916123835'),
('20190916134155'),
('20190916190258'),
('20190917165449'),
('20190917181907'),
('20190919155548'),
('20190919175639'),
('20190919175646'),
('20190919193714'),
('20190919193834'),
('20190928120638'),
('20190928182928'),
('20190929104944'),
('20190929110158'),
('20190929193356'),
('20190930142601'),
('20190930143005'),
('20190930143127'),
('20190930143133'),
('20190930143410'),
('20191002083102'),
('20191006152145'),
('20191022195536'),
('20191022201928'),
('20191027192816'),
('20191027200245'),
('20191027203114'),
('20191028102103'),
('20191119175419'),
('20191119224043'),
('20191120152618'),
('20191120162650'),
('20191121060716'),
('20191121170141'),
('20191122133323'),
('20191125104000'),
('20191125104322'),
('20191126085901'),
('20191126094227'),
('20191126123014'),
('20191128144950'),
('20191129001618'),
('20191129023418'),
('20191129033008'),
('20191129143147'),
('20191202115009'),
('20191202132618'),
('20191203163403'),
('20191204095451'),
('20191204100945'),
('20191206082828'),
('20191206120828'),
('20191206164849'),
('20191206172130'),
('20191206175055'),
('20191207060117'),
('20191208233512'),
('20191217083323'),
('20191217085001'),
('20191221151801'),
('20200110103445'),
('20200117095143'),
('20200117122856'),
('20200117184302'),
('20200120130555'),
('20200120172400'),
('20200128123316'),
('20200131074036'),
('20200216155620'),
('20200216161342'),
('20200227100810'),
('20200227111927'),
('20200227112956'),
('20200310163503'),
('20200622151708'),
('20210204142212'),
('20210305132256'),
('20210316164558'),
('20210514085536'),
('20211116114117'),
('20220215170029'),
('20220218100325'),
('20220218100643'),
('20220221123402'),
('20220310091530'),
('20220324160017'),
('20220324184534'),
('20220324190738'),
('20220704085154'),
('20220704092137'),
('20220704094334'),
('20220704094826'),
('20220719121521'),
('20220722075902'),
('20220722100953'),
('20220822094300'),
('20220822102328'),
('20220902105018'),
('20220908080811'),
('20230612083439'),
('20230613090106'),
('20230613101102');


