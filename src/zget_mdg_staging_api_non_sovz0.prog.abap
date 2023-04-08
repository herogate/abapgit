*&---------------------------------------------------------------------*
*& Report ZGET_MDG_STAGING_API_NON_SOV
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZGET_MDG_STAGING_API_NON_SOVZ0.
DATA:   lo_model     TYPE REF TO if_usmd_model_ext,
        ls_sel       TYPE usmd_s_sel,
        lt_sel       TYPE usmd_ts_sel,
     "   lt_objlist   TYPE usmd_t_crequest_entity,
     "   ls_objlist   TYPE usmd_s_crequest_entity,
        lv_structure TYPE REF TO data,
        " lt_data TYPE USMD_TS_DATA_ENTITY,
        lt_message TYPE USMD_T_MESSAGE.


FIELD-SYMBOLS : <lt_data> TYPE ANY TABLE,
                <lt_data_all> TYPE ANY TABLE.

CALL METHOD cl_usmd_model_ext=>get_instance
  EXPORTING
    i_usmd_model = 'Z0'
  IMPORTING
    eo_instance  = lo_model.

CLEAR: ls_sel, lt_sel.
ls_sel-fieldname = 'Z0BUKRS'.
ls_sel-option = 'EQ'.
ls_sel-sign = 'I'.
ls_sel-low = '1010'.
INSERT ls_sel INTO TABLE lt_sel.

ls_sel-fieldname = 'Z0M0041'.
ls_sel-option = 'EQ'.
ls_sel-sign = 'I'.
ls_sel-low = '111'.
INSERT ls_sel INTO TABLE lt_sel.

ls_sel-fieldname = 'Z0M0047Q'.
ls_sel-option = 'EQ'.
ls_sel-sign = 'I'.
ls_sel-low = '345345'.
INSERT ls_sel INTO TABLE lt_sel.

*ls_sel-fieldname = 'USMD_EDTN_NUMBER'.
*ls_sel-option = 'EQ'.
*ls_sel-sign = 'I'.
*ls_sel-low = '999999'.
*INSERT ls_sel INTO TABLE lt_sel.

CALL METHOD lo_model->create_data_reference
  EXPORTING
   i_fieldname = 'Z0M0047'
   i_struct    =  lo_model->GC_STRUCT_KEY_ATTR
  IMPORTING
   er_data     = lv_structure.

ASSIGN lv_structure->* TO <lt_data>.

CALL METHOD lo_model->read_char_value
  EXPORTING
   i_fieldname = 'Z0M0047'
   it_sel      = lt_sel
   " IF_EDITION_LOGIC = abap_true
"   i_readmode  = '1'
  IMPORTING
   et_data     = <lt_data>.

Loop at <lt_data> ASSIGNING FIELD-SYMBOL(<ls_data>).
  ASSIGN COMPONENT 'LANGU' OF STRUCTURE <ls_data> to FIELD-SYMBOL(<lv_langu>).
  IF <lv_langu> is ASSIGNED and <lv_langu> = sy-langu.
   ASSIGN COMPONENT 'TXTMI' OF STRUCTURE <ls_data> to FIELD-SYMBOL(<lv_txtmi>).
   WRITE : <lv_langu> , ':' , <lv_txtmi>.
  ENDIF.
ENDLOOP.
