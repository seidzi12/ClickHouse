drop table if exists table_1;
drop table if exists table_2;
drop table if exists v_numbers;
drop table if exists mv_table;

create table table_1 (x UInt32, y String) engine = MergeTree order by x;
insert into table_1 values (1, 'aa'), (2, 'bb'), (3, 'ccc'), (4, 'dddd');

-- { echoOn }

select * from table_1;
select * from table_1 settings additional_filters='table_1 : x != 2';
select * from table_1 settings additional_filters='table_1 : x != 2 and x != 3';
select x from table_1 settings additional_filters='table_1 : x != 2';
select y from table_1 settings additional_filters='table_1 : x != 2';
select * from table_1 where x != 3 settings additional_filters='table_1 : x != 2';
select * from table_1 prewhere x != 4 settings additional_filters='table_1 : x != 2';
select * from table_1 prewhere x != 4 where x != 3 settings additional_filters='table_1 : x != 2';
select x from table_1 where x != 3 settings additional_filters='table_1 : x != 2';
select x from table_1 prewhere x != 4 settings additional_filters='table_1 : x != 2';
select x from table_1 prewhere x != 4 where x != 3 settings additional_filters='table_1 : x != 2';
select y from table_1 where x != 3 settings additional_filters='table_1 : x != 2';
select y from table_1 prewhere x != 4 settings additional_filters='table_1 : x != 2';
select y from table_1 prewhere x != 4 where x != 3 settings additional_filters='table_1 : x != 2';
select x from table_1 where x != 2 settings additional_filters='table_1 : x != 2';
select x from table_1 prewhere x != 2 settings additional_filters='table_1 : x != 2';
select x from table_1 prewhere x != 2 where x != 2 settings additional_filters='table_1 : x != 2';

select * from system.numbers limit 5;
select * from system.numbers limit 5 settings additional_filters='system.numbers : number != 3';
select * from system.numbers limit 5 settings additional_filters='system.numbers:number != 3;table_1:x!=2';
select * from (select number from system.numbers limit 5 union all select x from table_1) order by number settings additional_filters='system.numbers:number != 3;table_1:x!=2';
select number, x, y from (select number from system.numbers limit 5) f any left join (select x, y from table_1) s on f.number = s.x settings additional_filters='system.numbers : number != 3; table_1 : x != 2';
select b + 1 as c from (select a + 1 as b from (select x + 1 as a from table_1)) settings additional_filters='table_1 : x != 2 and x != 3';

-- { echoOff }

create view v_numbers as select number + 1 as x from system.numbers limit 5;

-- { echoOn }
select * from v_numbers;
select * from v_numbers settings additional_filters='system.numbers : number != 3';
select * from v_numbers settings additional_filters='v_numbers : x != 3';
select * from v_numbers settings additional_filters='system.numbers : number != 3; v_numbers : x != 3';

-- { echoOff }

create table table_2 (x UInt32, y String) engine = MergeTree order by x;
insert into table_2 values (4, 'dddd'), (5, 'eeeee'), (6, 'ffffff'), (7, 'ggggggg');

create materialized view mv_table to table_2 (x UInt32, y String) as select * from table_1;

-- { echoOn }
-- additional filter for inner tables for Materialized View does not work because it does not create internal interpreter
-- probably it is expected
select * from mv_table;
select * from mv_table settings additional_filters='mv_table : x != 5';
select * from mv_table settings additional_filters='table_1 : x != 5';
select * from mv_table settings additional_filters='table_2 : x != 5';

-- { echoOff }

create table m_table (x UInt32, y String) engine = Merge(currentDatabase(), '^table_');

-- { echoOn }
-- additional filter for inner tables for Merge does not work because it does not create internal interpreter
-- probably it is expected
select * from m_table order by x;
select * from m_table order by x settings additional_filters='table_1 : x != 2';
select * from m_table order by x  settings additional_filters='table_2 : x != 5';
select * from m_table order by x  settings additional_filters='table_1 : x != 2; table_2 : x != 5';
select * from m_table order by x  settings additional_filters='table_1 : x != 4';
select * from m_table order by x  settings additional_filters='table_2 : x != 4';
select * from m_table order by x  settings additional_filters='table_1 : x != 4; table_2 : x != 4';
select * from m_table order by x  settings additional_filters='m_table : x != 4';
select * from m_table order by x  settings additional_filters='m_table : x != 4; table_1 : x != 2; table_2 : x != 5';
