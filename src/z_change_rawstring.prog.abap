*&---------------------------------------------------------------------*
*& Report Z_CHANGE_RAWSTRING
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_change_rawstring.

DATA ls_data TYPE wdy_config_data.
SELECT SINGLE * FROM wdy_config_data WHERE config_id = 'Z9_USMD_FORM_Z0M0041' INTO
  @ls_data.

DATA xstring TYPE xstring.
DATA string TYPE string.

CL_BCS_CONVERT=>xstring_to_string(
    EXPORTING
      iv_xstr   = ls_data-xcontent
      iv_cp     =  1100                " SAP character set identification
    RECEIVING
      rv_string = string
  ).

*CALL FUNCTION 'HR_RU_CONVERT_HEX_TO_STRING'
*  EXPORTING
*    xstring = ls_data-xcontent
*  IMPORTING
*    cstring = string.

REPLACE ALL OCCURRENCES OF 'ZCL_MDG_BS_GUIBB_FORM_FAIL' IN string WITH 'CL_MDG_BS_GUIBB_FORM'.

CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
  EXPORTING
    text   = string
  IMPORTING
    buffer = xstring.

ls_data-xcontent = xstring.
update wdy_config_data from ls_data.
check sy-subrc = 0.

BREAK-POINT.

COMMIT WORK AND WAIT.
