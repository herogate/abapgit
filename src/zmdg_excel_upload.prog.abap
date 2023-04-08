*&---------------------------------------------------------------------*
*& Report ZMDG_EXCEL_UPLOAD
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDG_EXCEL_UPLOAD.

DATA:
   it_table TYPE TABLE OF /MDG/_S_0G_PP_ACCOUNT,
   wa_table TYPE /MDG/_S_0G_PP_ACCOUNT.
TYPE-POOLS:truxs.
DATA:i_tab_raw_data TYPE  truxs_t_text_data.


CALL FUNCTION 'GUI_UPLOAD'
  EXPORTING
    filename = 'C:\Users\I572561\Downloads\account.csv'
    filetype = 'ASC'
  TABLES
    data_tab = i_tab_raw_data.
CALL FUNCTION 'TEXT_CONVERT_CSV_TO_SAP'
  EXPORTING
    i_tab_raw_data       = i_tab_raw_data
  TABLES
    i_tab_converted_data = it_table.



  DATA: lo_mdg_api         TYPE REF TO if_usmd_conv_som_gov_api,
        lt_entity_data     TYPE usmd_gov_api_ts_ent_data,
        ls_entity_data     TYPE usmd_gov_api_s_ent_data,
        lo_cx_usmd_gov_api TYPE REF TO cx_usmd_gov_api,
        ls_message         TYPE bapiret2,
        lt_key_account   TYPE TABLE OF /MDG/_S_0G_KY_ACCOUNT,
        ls_key_account   TYPE /MDG/_S_0G_KY_ACCOUNT,
        lt_account       TYPE TABLE OF /MDG/_S_0G_PP_ACCOUNT,
        ls_account       TYPE /MDG/_S_0G_PP_ACCOUNT,
        lv_cr              TYPE usmd_crequest,
        lr_account_key_str TYPE REF TO DATA,
        lr_account_key_tab TYPE REF TO DATA.

  DATA lst_entity_lock type USMD_GOV_API_S_ENT_TABL.
  DATA li_entity type  USMD_GOV_API_TS_ENT_TABL.

 FIELD-SYMBOLS <ls_key> type any.
 FIELD-SYMBOLS <lt_key> type any TABLE.


TRY.
    cl_usmd_conv_som_gov_api=>get_instance(
        EXPORTING
          iv_model_name = '0G'
        RECEIVING
          ro_so_gov_api = lo_mdg_api
      ).

      lo_mdg_api->refresh_buffers( ).
      lo_mdg_api->set_environment(
        EXPORTING
          iv_crequest_type   = '0G_ALL'
          iv_process         = '0G'
          IV_EDITION = '2022.11.15'
          iv_create_crequest = abap_true
      ).
      lo_mdg_api->set_crequest_attributes(
        EXPORTING
          iv_crequest_text   = |파일업로드 { sy-datum }|
      ).
      lo_mdg_api->enqueue_crequest( iv_lock_mode = 'E' ).

********************************************************************************************
* ACCOUNT
*******************************************************************************************




      CALL METHOD lo_mdg_api->get_entity_structure
       EXPORTING
         iv_entity_name = 'ACCOUNT'
         iv_struct_type = IF_USMD_MODEL_EXT=>gc_struct_key
       IMPORTING
         er_structure = lr_account_key_str
         er_table = lr_account_key_tab.

      ASSIGN lr_account_key_str->* TO <ls_key>.
      ASSIGN lr_account_key_tab->* TO <lt_key>.

      check <ls_key> is ASSIGNED and <lt_key> is ASSIGNED.
      loop at it_table into wa_table.
      ASSIGN COMPONENT 'COA' OF STRUCTURE <ls_key> TO FIELD-SYMBOL(<lv_coa>).
      ASSIGN COMPONENT 'ACCOUNT' OF STRUCTURE <ls_key> TO FIELD-SYMBOL(<lv_account>).
      <lv_coa> = wa_table-coa.
      <lv_account> = wa_table-account.
      INSERT <ls_key> INTO TABLE <lt_key>.
      endloop.


      lst_entity_lock-entity = 'ACCOUNT'.
      lst_entity_lock-tabl = lr_account_key_tab.
      INSERT lst_entity_lock INTO TABLE li_entity.


      lo_mdg_api->enqueue_entity( it_entity_keys = li_entity ).
      PERFORM write_entity USING lo_mdg_api 'ACCOUNT' it_table.

   CATCH cx_usmd_gov_api INTO lo_cx_usmd_gov_api.
    ENDTRY.


**** save ****

   lo_mdg_api->confirm_entity_data( ).
      lo_mdg_api->check( ).
      IF lo_mdg_api->mv_successfully_checked EQ abap_true.
        lo_mdg_api->set_action( cl_usmd_crequest_action=>gc_draft_action-submit ).
        lo_mdg_api->save( ).
        lv_cr = lo_mdg_api->mv_crequest_id.
      ENDIF.




lo_mdg_api->dequeue_entity_all( ).
lo_mdg_api->dequeue_crequest( ).
lo_mdg_api->refresh_buffers( ).

COMMIT WORK AND WAIT.


  FORM write_entity USING io_mdg_api iv_entity it_data.
  DATA: lo_mdg_api     TYPE REF TO if_usmd_conv_som_gov_api,
        lt_entity_data TYPE usmd_gov_api_ts_ent_data,
        ls_entity_data TYPE usmd_gov_api_s_ent_data.

  lo_mdg_api = io_mdg_api.

  CLEAR: lt_entity_data, ls_entity_data.
  ls_entity_data-entity = iv_entity.
  ls_entity_data-entity_data = REF #( it_data ).
  APPEND ls_entity_data TO lt_entity_data.

  lo_mdg_api->write_entity_data( it_entity_data = lt_entity_data ).
ENDFORM.
