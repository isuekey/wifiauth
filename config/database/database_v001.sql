create table if not exists t_account (
   id bigserial primary key,
   account varchar(400),
   account_name varchar(1000),
   phone varchar(40),
   gender integer,
   avatar varchar(1000),
   password varchar(200) default '123456',
   created_at timestamp default current_timestamp,
   status varchar(40),
   promoter integer,
   updated_at timestamp,
   account_type integer,
   unique( account )
);

create table if not exists t_identify (
   id bigserial primary key,
   account varchar(400),
   identifier_type varchar(40),
   identifier_code varchar(40),
   front_img_file varchar(1000),
   front_img_file_code varchar(100),
   back_img_file varchar(1000),
   back_img_file_code varchar(100),
   hand_img_file varchar(1000),
   hand_img_file_code varchar(100),
   status varchar(40),
   created_at timestamp default current_timestamp,
   updated_at timestamp,
   unique( identifier_type, identifier_code )
);

create table if not exists t_bank (
   id bigserial primary key,
   account varchar(400),
   bank_type varchar(400),
   bank_account varchar(400) default 'unkown',
   bank_unit varchar(40),
   status varchar(40),
   created_at timestamp default current_timestamp,
   updated_at timestamp,
   unique ( account, bank_type ),
   unique ( bank_type, bank_account)
);

create table if not exists t_subscribe (
   id bigserial primary key,
   account varchar(400),
   subscribe_amount double precision,
   bank_type varchar(400),
   bank_account varchar(400),
   bank_unit varchar(40),
   status varchar(40),
   item_index varchar(100),
   created_at timestamp default current_timestamp,
   updated_at timestamp,
   unique ( account, bank_type),
   unique ( bank_type, bank_account)
);

create table if not exists t_dictionary (
   id bigserial primary key,
   dict_name varchar(400),
   dict_value varchar(40),
   dict_unit varchar(40),
   dict_type varchar(40),
   dict_sort integer,
   status varchar(40),
   created_at timestamp default current_timestamp,
   updated_at timestamp
);

create table if not exists t_phone_code (
   id bigserial primary key,
   uuid varchar(100),
   application varchar(40),
   verify_code varchar(40),
   phone varchar(40),
   phone_code varchar(40),
   status varchar(40) default 'enabled',
   created_at timestamp default current_timestamp,
   updated_at timestamp
);

create table if not exists t_request_mask (
   id bigserial primary key,
   request_url varchar(1000),
   mask_code varchar(40),
   status varchar(40),
   created_at timestamp default current_timestamp,
   updated_at timestamp
);


ALTER TABLE t_bank ADD CONSTRAINT t_bank_account_bank_type UNIQUE (account, bank_type);

ALTER TABLE public.t_bank
    ADD CONSTRAINT banktypebankaccount UNIQUE (bank_type, bank_account);

ALTER TABLE public.t_subscribe
    ADD CONSTRAINT subscribebanktypebankaccount UNIQUE (bank_type, bank_account);


ALTER TABLE t_subscribe ADD CONSTRAINT t_subscribe_account_bank_type UNIQUE ( account, bank_type );


ALTER TABLE public.t_subscribe DROP CONSTRAINT t_subscribe_account_bank_type;

ALTER TABLE public.t_bank DROP CONSTRAINT t_bank_account_bank_type;

create index if not exists t_bank_account_bank_type_bank_account on t_bank (account, bank_type, bank_account);

create index if not exists t_subscribe_account_bank_type_bank_account on t_subscribe (account, bank_type, bank_account);


ALTER TABLE public.t_subscribe DROP CONSTRAINT banktypebankaccount;

ALTER TABLE public.t_subscribe
    ADD CONSTRAINT t_subscribe_bank_type_bank_account_subscribe_amount UNIQUE (bank_type, bank_account, subscribe_amount);




ALTER TABLE public.t_bank
    ADD CONSTRAINT banktypebankaccount UNIQUE (bank_type, bank_account);

ALTER TABLE t_bank ADD CONSTRAINT t_bank_account_bank_type UNIQUE (account, bank_type);

ALTER TABLE public.t_bank DROP CONSTRAINT t_bank_account_bank_type;



ALTER TABLE public.t_subscribe DROP CONSTRAINT t_subscribe_bank_type_bank_account_subscribe_amount;

create index t_subscribe_bank_type_bank_account_subscribe_amount on t_subscribe (bank_type, bank_account, subscribe_amount);


alter table t_phone_code add column verify_code varchar(40);

-- 2017 06 24 版本变动

ALTER TABLE public.t_bank
    ADD COLUMN amount_in double precision;

ALTER TABLE public.t_bank
    ADD COLUMN amount_out double precision;

ALTER TABLE public.t_bank
    ADD COLUMN usent double precision;


create table if not exists t_tx_eth_list(
   id bigserial primary key,
   tx_type varchar(40),
   tx_hash varchar(1000),
   tx_sender varchar(1000),
   recipient varchar(1000),
   accountNonce varchar(40),
   price  bigint,
   gas_limit bigint,
   amount numeric(40),
   block_id bigint,
   tx_time timestamp,
   new_contract  bigint,
   is_contract_tx varchar(40),
   block_hash varchar(1000),
   parent_hash varchar(1000),
   tx_index varchar(40),
   gas_used bigint,
   status varchar(40) default 'confirming',
   account varchar(40),
   created_at timestamp default current_timestamp,
   updated_at timestamp
);

create table if not exists t_tx_btc_input(
    id bigserial primary key,
    btc_ver int,
    seq bigint,
    spent boolean,
    pre_tx_index bigint,
    pre_tx_type int,
    addr varchar(1000),
    pre_Value numeric(40),
    n int,
    pre_script varchar(1000),
    input_script varchar(1000),
    block_height int,
    relayed_by varchar(40),
    lock_time int,
    tx_result int,
    tx_size int,
    tx_time bigint,
    tx_index int,
    vin_sz int,
    tx_hash varchar(1000),
    vout_sz int,
    tx_method int,
    created_at timestamp default current_timestamp,
    updated_at timestamp
    
);


create table t_bak as (select * from t_bank);
create table t_sub as (select * from t_subscribe);

create table t_checked as (
    select ta.account_name, ta.gender,
    ti.identifier_type, ti.identifier_code, ti.front_img_file, ti.back_img_file, ti.hand_img_file,
    bank.account, bank.bank_type, bank.bank_account, bank.bank_unit, bank.status, bank.created_at, bank.updated_at,
    bank.amount_in, bank.amount_out, bank.usent, bank.id
    from t_bank as bank , t_account as ta, t_identify as ti
    where  (
        lower(bank_account) != lower('0xECC47`2Db4A32Fd84F3BbAa261bF4598B66fC6cf2')
        and lower(bank_account) != lower('1Ch9BL6SRn6Z7YqTuBSSaEXBjqq5VdpPSL')
    ) and ( amount_in is not null or amount_out is not null)
    and bank_type = 'ETH'
    and bank.account = ta.account 
    and ta.account = ti.account
);

ALTER TABLE public.t_checked
    ADD COLUMN user_name character varying(400);
ALTER TABLE public.t_checked
    ADD COLUMN trade_history_url character varying(1000);
ALTER TABLE public.t_checked
    ADD COLUMN confirmed_address character varying(1000);
ALTER TABLE public.t_checked
    ADD COLUMN confirmed_amount double precision;
ALTER TABLE public.t_checked
    ADD COLUMN id_img_upload character varying(1000); 
ALTER TABLE public.t_checked
    ADD COLUMN confirmer character varying(1000); 
ALTER TABLE public.t_checked ADD COLUMN confirmer character varying(1000); 

create table t_confirmed as (select * from t_checked ) with no data;

ALTER TABLE public.t_confirmed DROP COLUMN id;

CREATE SEQUENCE public.t_confirmed_id_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;

ALTER SEQUENCE public.t_confirmed_id_seq
    OWNER TO wifiauth;
    
CREATE SEQUENCE public.t_checked_id_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;

ALTER SEQUENCE public.t_checked_id_seq
    OWNER TO wifiauth;

ALTER TABLE public.t_checked DROP COLUMN ID;

ALTER TABLE public.t_checked
    ADD COLUMN id bigint NOT NULL DEFAULT nextval('t_checked_id_seq'::regclass);


drop table t_dichecked;
drop SEQUENCE t_dichecked_id_seq;

create table t_dichecked as (
select account_name, account, bank_type, bank_account, 
case when confirmed_amount is null then amount_in else confirmed_amount end as checked_amount, 
status from t_checked
) with no data;

    
CREATE SEQUENCE public.t_dichecked_id_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;


ALTER SEQUENCE public.t_dichecked_id_seq
    OWNER TO wifiauth;


ALTER TABLE public.t_dichecked
    ADD COLUMN id bigint NOT NULL DEFAULT nextval('t_dichecked_id_seq'::regclass);

insert into t_dichecked 
select account_name, account, bank_type, bank_account, 
case when confirmed_amount is null then amount_in else confirmed_amount end as checked_amount, 
status from t_checked
;

alter table t_dichecked add column useful integer;


create table if not exists t_sms (
    id bigserial primary key,
    account varchar(400),
    message varchar(1000),
    status varchar(40),
    usages varchar(40),
    created_at timestamp default current_timestamp,
    updated_at timestamp
);



create table if not exists t_ubc_address (
    id bigserial primary key not null, 
   	created_at timestamp default current_timestamp,
   	updated_at timestamp,
    account varchar(400),
    ubc_version integer,
    address varchar(1000),
    status varchar(40),
    amount double precision,
    tx_hash varchar(1000)
);

-- 这个人投了 37eth，由于有急事 退币了
update t_checked set confirmed_address = '0x208e19812549d88c6e8a6d5eb82fce0d662b98d081793f2cc12a1b4c8d10e074' where account = '18106756777';

update t_checked set confirmed_address = bank_account , confirmed_amount = amount_in 
where confirmed_address is null and confirmed_amount is null
;

create table if not exists t_ubc_sended (
	id bigserial primary key not null,
   	created_at timestamp default current_timestamp,
   	updated_at timestamp,
    account varchar(400),
    ubc_version integer,
    address varchar(1000),
    status varchar(40),
    amount double precision,
    tx_hash varchar(1000),
    sent_count integer
);

alter table t_ubc_address add column tx_hash varchar(1000);
alter table t_ubc_sended add column tx_hash varchar(1000);

alter table t_ubc_sended add column sent_count integer;
alter table t_ubc_sended add column send_type varchar(40);

alter table t_ubc_address add column sent_count integer;
alter table t_ubc_address add column send_type varchar(40);


create table if not exists t_ubc_vip(
    id bigserial primary key not null,
    created_at timestamp default current_timestamp,
    updated_at timestamp,
    account varchar(400),
    address varchar(1000),
    tx_hash varchar(1000),
    amount double precision
)

