*&---------------------------------------------------------------------*
*& Report ZSFLIGHT_COPY
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZSFLIGHT_COPY.
DATA itab type TABLE OF Sflight.

select * from SFLIGHT into table itab .

insert ZZSFLIGHT from table itab accepting duplicate keys.
