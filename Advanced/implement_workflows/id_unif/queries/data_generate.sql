DROP TABLE IF EXISTS tbl_one;
CREATE TABLE tbl_one (
   id         varchar(255)
 , corp_name  varchar(255)
 , address_all varchar(255)
 , zip_code   varchar(255)
 , tel        varchar(255)
 , web_domain varchar(255)
 , mail_domain varchar(255)
 , ceo        varchar(255) 
 , time       int
 );

INSERT INTO tbl_one VALUES
  ('AAA', 'Ａ', '','', '0120-1234-5678', 'http://www.aaa.com','','',  1)
 ,('BBB', 'Ｂ', '','', '03-1111-2222', 'http://www.bbb.co.jp','','',  1)
 ,('CCC', 'Ｃ', '','', '06-1111-2222', 'http://www.ccc-corp.co.jp','','',  1)
 ,('i18n', 'アイ', '','', '010-111-2222', 'http://www.internationalization.co.jp', '','', 1)
 ,('ZZZ', 'ズィー', '','', '090-1111-2222', 'http://www.zzz.co.jp','','',  1)
;
 
DROP TABLE IF EXISTS tbl_two;
CREATE TABLE tbl_two (
   id         varchar(255)
 , corp_name  varchar(255)
 , address_all varchar(255)
 , zip_code   varchar(255)
 , tel        varchar(255)
 , web_domain varchar(255)
 , mail_domain varchar(255)
 , ceo        varchar(255) 
 , time       int
 );

INSERT INTO tbl_two VALUES
  ('aaa', 'Ａ', '東京', '100-1111', '0120-1234-5678', '', '', '', 1)
 ,('bbb', 'Ｂ', '東京', '100-1111', '03-1111-2222', '', '', '', 1)
 ,('ccc', 'Ｃ', '大阪', '530-9999', '06-1111-2222', '', '', '', 1)
 ,('td', 'トレジャー', '東京', '100-1111', '03-3333-3333','', '', '',  1)
 ,('yyy', 'ワイワイ', '不明', '', '050-4126-4126', '', '', '', 1)
 ;
 
DROP TABLE IF EXISTS tbl_three;
CREATE TABLE tbl_three (
   id         varchar(255)
 , corp_name  varchar(255)
 , address_all varchar(255)
 , zip_code   varchar(255)
 , tel        varchar(255)
 , web_domain varchar(255)
 , mail_domain varchar(255)
 , ceo        varchar(255) 
 , time       int
 );

INSERT INTO tbl_three VALUES
  ('001', 'Ａ', '東京', '100-1111', '', 'http://www.aaa.com', '','', 1)
 ,('002', 'Ｂ', '東京', '100-1111', '', 'http://www.bbb.co.jp', '','', 1)
 ,('003', 'Ｃ', '大阪', '530-9999', '', 'http://www.ccc-corp.co.jp', '','', 1)
 ,('004', 'トレジャー', '東京', '100-1111', '', 'http://www.treasuredata.co.jp', '','', 1)
 ,('005', 'エックス', '北海道', '010-1111', '', 'http://www.xxx.com', '','', 1)
 ;
 
DROP TABLE IF EXISTS tbl_four;
CREATE TABLE tbl_four (
   id         varchar(255)
 , corp_name  varchar(255)
 , address_all varchar(255)
 , zip_code   varchar(255)
 , tel        varchar(255)
 , web_domain varchar(255)
 , mail_domain varchar(255)
 , ceo        varchar(255) 
 , time       int
 );

INSERT INTO tbl_four VALUES
  ('a0001', 'Ａ', '','', '0120-1234-5678', '', '', 'Inoue', 1)
 ,('b0001', 'Ｂ', '','', '03-1111-2222', '', '', 'Ito', 1)
 ,('c0001', 'Ｃ', '','', '06-1111-2222', '', '', 'Kitagawa', 1)
 ,('d0001', 'アカデミー', '','', '03-3333-5555', '', '', 'Yamamori',  1)
 ,('e0001', 'ASv5', '','', '', '', '', 'Omura', 1)
 ;

DROP TABLE IF EXISTS tbl_five;
CREATE TABLE tbl_five (
   id         varchar(255)
 , corp_name  varchar(255)
 , address_all varchar(255)
 , zip_code   varchar(255)
 , tel        varchar(255)
 , web_domain varchar(255)
 , mail_domain varchar(255)
 , ceo        varchar(255) 
 , time       int
 );

INSERT INTO tbl_five VALUES
  ('a0001', 'Ａ', '東京', '100-1111', '0120-1234-5678', '', '', 'Inoue', 1)
 ,('b0001', 'Ｂ', '東京', '100-1111', '03-1111-2222', '', '', 'Ito', 1)
 ,('c0001', 'Ｃ', '大阪', '530-9999', '06-1111-2222', '', '', 'Kitagawa', 1)
 ,('d0001', 'アカデミー', '広島', '700-7777', '0840-8888-8888', '', '', 'Yamamori',  1)
 ,('e0001', 'ASv5', '東京', '103-3210', '03-3333-3333', '', '', 'Omura', 1)
 
 ;

