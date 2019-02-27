CREATE TABLE tableone( t1_id INTEGER, t1_subid INTEGER NOT NULL, t1_var1 INTEGER NOT NULL, PRIMARY KEY ( t1_id ) );
CREATE TABLE tabletwo( t2_id INTEGER, t2_subid INTEGER NOT NULL, t2_var1 TEXT NOT NULL, PRIMARY KEY ( t2_id ) );

INSERT INTO tableone( t1_id, t1_subid, t1_var1 ) VALUES( 1, 56, 123 );
INSERT INTO tableone( t1_id, t1_subid, t1_var1 ) VALUES( 2,23, 456 );
INSERT INTO tableone( t1_id, t1_subid, t1_var1 ) VALUES( 3, 72, 789 );

INSERT INTO tabletwo( t2_id, t2_subid, t2_var1 ) VALUES( 1, 23, "abcd" );
INSERT INTO tabletwo( t2_id, t2_subid, t2_var1 ) VALUES( 2, 56, "efgh" );
INSERT INTO tabletwo( t2_id, t2_subid, t2_var1 ) VALUES(3, 72, "ijkl" );
INSERT INTO tabletwo( t2_id, t2_subid, t2_var1 ) VALUES( 4, 12, "mnop" );