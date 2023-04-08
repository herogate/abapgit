*&---------------------------------------------------------------------*
*& Report ZMDG_EXCEL_UPLOAD_2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDG_EXCEL_UPLOAD_2.
TYPE-POOLS: truxs.

PARAMETERS: p_file TYPE  rlgrap-filename.

TYPES: BEGIN OF t_datatab,
      col1(30)    TYPE c,
      col2(30)    TYPE c,
      col3(30)    TYPE c,
      END OF t_datatab.
DATA: it_datatab type standard table of t_datatab,
      wa_datatab type t_datatab.

DATA: it_raw TYPE truxs_t_text_data.

* At selection screen
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      field_name = 'P_FILE'
    IMPORTING
      file_name  = p_file.


***********************************************************************
*START-OF-SELECTION.
START-OF-SELECTION.

  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
*     I_FIELD_SEPERATOR        =
      i_line_header            =  'X'
      i_tab_raw_data           =  it_raw       " WORK TABLE
      i_filename               =  p_file
    TABLES
      i_tab_converted_data     = it_datatab[]    "ACTUAL DATA
   EXCEPTIONS
      conversion_failed        = 1
      OTHERS                   = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


***********************************************************************
* END-OF-SELECTION.
END-OF-SELECTION.
  LOOP AT it_datatab INTO wa_datatab.
    WRITE:/ wa_datatab-col1,
            wa_datatab-col2,
            wa_datatab-col3.
  ENDLOOP.
