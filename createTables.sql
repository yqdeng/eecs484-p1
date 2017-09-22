CREATE TABLE USERS(
	USER_ID NUMBER PRIMARY KEY,
	FIRST_NAME VARCHAR2(100) NOT NULL,
	LAST_NAME VARCHAR2(100) NOT NULL,
	YEAR_OF_BIRTH INTEGER,
	MONTH_OF_BIRTH INTEGER,
	DAY_OF_BIRTH INTEGER,
	GENDER VARCHAR2(100)
);

CREATE TABLE FRIENDS(
	USER1_ID NUMBER NOT NULL,
	USER2_ID NUMBER NOT NULL,
	CONSTRAINT NOTTHESAME CHECK(USER1_ID != USER2_ID)
);

CREATE OR REPLACE TRIGGER EXISTEDFRIENDSHIP
	AFTER INSERT ON FRIENDS
		FOR EACH ROW
			DECLARE
				c NUMBER;
			BEGIN
				SELECT COUNT(*) INTO c
				FROM FRIENDS F
				WHERE :NEW.USER1_ID = F.USER2_ID
				AND :NEW.USER2_ID = F.USER1_ID;

				IF c > 0 
				THEN
					ROLLBACK;
				END IF;
			END;
/

CREATE TABLE CITIES(
	CITY_ID INTEGER PRIMARY KEY,
	CITY_NAME VARCHAR2(100) ,
	STATE_NAME VARCHAR2(100),
	COUNTRY_NAME VARCHAR2(100) 
);

CREATE TABLE USER_CURRENT_CITY(
	USER_ID NUMBER,
	CURRENT_CITY_ID NUMBER,
	FOREIGN KEY(USER_ID) REFERENCES USERS(USER_ID) ON DELETE CASCADE,
	FOREIGN KEY(CURRENT_CITY_ID) REFERENCES CITIES(CITY_ID) ON DELETE CASCADE,
	UNIQUE(USER_ID)
);

CREATE TABLE USER_HOMETOWN_CITY(
	USER_ID NUMBER,
	HOMETOWN_CITY_ID NUMBER,
	FOREIGN KEY(USER_ID) REFERENCES USERS(USER_ID) ON DELETE CASCADE,
	FOREIGN KEY(HOMETOWN_CITY_ID) REFERENCES CITIES(CITY_ID) ON DELETE CASCADE,
	UNIQUE(USER_ID)
);

CREATE TABLE MESSAGES(
	MESSAGE_ID NUMBER PRIMARY KEY,
	SENDER_ID NUMBER,
	RECEIVER_ID NUMBER,
	MESSAGE_CONTENT VARCHAR2(2000) NOT NULL,
	SENT_TIME TIMESTAMP NOT NULL,
	FOREIGN KEY(SENDER_ID) REFERENCES USERS(USER_ID) ON DELETE SET NULL,
	FOREIGN KEY(RECEIVER_ID) REFERENCES USERS(USER_ID) ON DELETE SET NULL
);

CREATE TABLE PROGRAMS(
	PROGRAM_ID INTEGER PRIMARY KEY,
	INSTITUTION VARCHAR2(100) NOT NULL,
	CONCENTRATION VARCHAR2(100) NOT NULL,
	DEGREE VARCHAR2(100) NOT NULL
);

CREATE TABLE EDUCATION(
	USER_ID NUMBER,
	PROGRAM_ID INTEGER,
	PROGRAM_YEAR INTEGER NOT NULL,
	FOREIGN KEY(USER_ID) REFERENCES USERS(USER_ID),
	FOREIGN KEY(PROGRAM_ID) REFERENCES PROGRAMS(PROGRAM_ID)
);

CREATE TABLE USER_EVENTS(
	EVENT_ID NUMBER PRIMARY KEY,
	EVENT_CREATOR_ID NUMBER,
	EVENT_NAME VARCHAR2(100) NOT NULL,
	EVENT_TAGLINE VARCHAR2(100),
	EVENT_DESCRIPTION VARCHAR2(100),
	EVENT_HOST VARCHAR2(100) NOT NULL,
	EVENT_TYPE VARCHAR2(100) NOT NULL,
	EVENT_SUBTYPE VARCHAR2(100) NOT NULL,
	EVENT_ADDRESS VARCHAR2(2000),
	EVENT_CITY_ID INTEGER,
	EVENT_START_TIME TIMESTAMP NOT NULL,
	EVENT_END_TIME TIMESTAMP NOT NULL,
	FOREIGN KEY(EVENT_CREATOR_ID) REFERENCES USERS(USER_ID) ON DELETE SET NULL,
	FOREIGN KEY(EVENT_CITY_ID) REFERENCES CITIES(CITY_ID) ON DELETE CASCADE
);

CREATE TABLE PARTICIPANTS(
	EVENT_ID NUMBER,
	USER_ID NUMBER,
	CONFIRMATION VARCHAR2(100),
	CHECK (CONFIRMATION = 'attending'
		OR CONFIRMATION = 'unsure'
		OR CONFIRMATION = 'declined'
		OR CONFIRMATION = 'not_replied'),
	UNIQUE(EVENT_ID, USER_ID),
	FOREIGN KEY(EVENT_ID) REFERENCES USER_EVENTS(EVENT_ID),
	FOREIGN KEY(USER_ID) REFERENCES USERS(USER_ID)
);


CREATE TABLE ALBUMS(
	ALBUM_ID NUMBER PRIMARY KEY,
	ALBUM_OWNER_ID NUMBER,
	ALBUM_NAME VARCHAR2(100) NOT NULL,
	ALBUM_CREATED_TIME TIMESTAMP NOT NULL,
	ALBUM_MODIFIED_TIME TIMESTAMP,
	ALBUM_LINK VARCHAR2(2000) NOT NULL,
	ALBUM_VISIBILITY VARCHAR2(100) NOT NULL,
	CHECK (ALBUM_VISIBILITY = 'everyone'
		OR ALBUM_VISIBILITY = 'friends'
		OR ALBUM_VISIBILITY = 'friends_of_friends'
		OR ALBUM_VISIBILITY = 'myself'
		OR ALBUM_VISIBILITY = 'custom'),
	COVER_PHOTO_ID NUMBER,
	FOREIGN KEY(ALBUM_OWNER_ID) REFERENCES USERS(USER_ID) ON DELETE CASCADE,
	CONSTRAINT COVER_CONSTRAINT
	FOREIGN KEY(COVER_PHOTO_ID) REFERENCES PHOTOS(PHOTO_ID) DEFERRABLE
);

CREATE TABLE PHOTOS(
	PHOTO_ID NUMBER PRIMARY KEY,
	ALBUM_ID NUMBER,
	PHOTO_CAPTION VARCHAR2(2000),
	PHOTO_CREATED_TIME TIMESTAMP NOT NULL,
	PHOTO_MODIFIED_TIME TIMESTAMP,
	PHOTO_LINK VARCHAR2(2000) NOT NULL,
	FOREIGN KEY(ALBUM_ID) REFERENCES ALBUMS(ALBUM_ID) ON DELETE CASCADE
);

ALTER TABLE ALBUMS
	ADD CONSTRAINT COVER_CONSTRAINT
	FOREIGN KEY(COVER_PHOTO_ID) REFERENCES PHOTOS(PHOTO_ID) DEFERRABLE;
	


CREATE TABLE TAGS(
	TAG_PHOTO_ID NUMBER FOREIGN KEY REFERENCES PHOTOS(PHOTO_ID) ON DELETE CASCADE,
	TAG_SUBJECT_ID NUMBER FOREIGN KEY REFERENCES USERS(USER_ID) ON DELETE CASCADE,
	TAG_CREATED_TIME TIMESTAMP NOT NULL,
	TAG_X NUMBER NOT NULL,
	TAG_Y NUMBER NOT NULL,
	UNIQUE(TAG_SUBJECT_ID, TAG_PHOTO_ID)
);