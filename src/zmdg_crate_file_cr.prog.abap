*&---------------------------------------------------------------------*
*& Report ZMDG_CRATE_FILE_CR
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDG_CRATE_FILE_CR.

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



  DATA: lo_gov_api TYPE REF TO if_usmd_gov_api,
        lv_crequest_id TYPE usmd_crequest,
"        lt_entity_data     TYPE usmd_gov_api_ts_ent_data,
"        ls_entity_data     TYPE usmd_gov_api_s_ent_data,
        lo_cx_usmd_gov_api TYPE REF TO cx_usmd_gov_api,
        ls_message         TYPE bapiret2,
        lt_key_account   TYPE TABLE OF /MDG/_S_0G_KY_ACCOUNT,
        ls_key_account   TYPE /MDG/_S_0G_KY_ACCOUNT,
        lt_account       TYPE TABLE OF /MDG/_S_0G_PP_ACCOUNT,
        ls_account       TYPE /MDG/_S_0G_PP_ACCOUNT,
"        lr_account_key_str TYPE REF TO DATA,
"        lr_account_key_tab TYPE REF TO DATA,
"        lr_account_data_str TYPE REF TO DATA,
"        lr_account_data_tab TYPE REF TO DATA,
ls_entity TYPE usmd_gov_api_s_ent_tabl,
lt_entity TYPE usmd_gov_api_ts_ent_tabl,
lt_messages TYPE usmd_t_message.



"  DATA lst_entity_lock type USMD_GOV_API_S_ENT_TABL.
"  DATA li_entity type  USMD_GOV_API_TS_ENT_TABL.
  DATA lo_ent_error TYPE REF TO cx_usmd_gov_api_entity_write.

 FIELD-SYMBOLS <ls_key> type any.
 FIELD-SYMBOLS <lt_key> type any TABLE.
 FIELD-SYMBOLS <ls_data> type any.
 FIELD-SYMBOLS <lt_data> type any TABLE.
 FIELD-SYMBOLS <wa_table> type /MDG/_S_0G_PP_ACCOUNT.

 loop at it_table ASSIGNING <wa_table>.

TRY.
  lo_gov_api = cl_usmd_gov_api=>get_instance( iv_model_name = '0G' ).
 CATCH cx_usmd_gov_api.
 EXIT.
ENDTRY.

TRY.
 lv_crequest_id = lo_gov_api->create_crequest(
 iv_crequest_type = '0G_ALL'
 iv_edition = '2022.11.15'
 iv_description = |파일업로드 { sy-datum }| ).
 CATCH cx_usmd_gov_api.
 "Something went wrong while creating the change request (e.g. model blocked
 "or change request type unknown).
 EXIT.
ENDTRY.



*lo_gov_api->create_data_reference(
* EXPORTING iv_entity_name = 'ACCOUNT'
* iv_struct = lo_gov_api->gc_struct_key
* IMPORTING er_structure = lr_account_key_str
* er_table = lr_account_key_tab ).
*"Create a data reference of the key and attribute structure / table of
*"entity CARR (Carrier)
*lo_gov_api->create_data_reference(
* EXPORTING iv_entity_name = 'ACCOUNT'
* iv_struct = lo_gov_api->gc_struct_key_attr
* IMPORTING er_structure = lr_account_data_str
* er_table = lr_account_data_tab ).
*
*ASSIGN lr_account_key_str->* TO <ls_key>.
*ASSIGN lr_account_key_tab->* TO <lt_key>.
*ASSIGN lr_account_data_str->* TO <ls_data>.
*ASSIGN lr_account_data_tab->* TO <lt_data>.



CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
   EXPORTING
     INPUT = <wa_table>-account
   IMPORTING
     OUTPUT = <wa_table>-account.

ls_key_account-coa = <wa_table>-coa.
ls_key_account-account = <wa_table>-account.
APPEND ls_key_account to lt_key_account.

*ASSIGN COMPONENT 'COA' OF STRUCTURE <ls_key> TO FIELD-SYMBOL(<lv_coa>).
*ASSIGN COMPONENT 'ACCOUNT' OF STRUCTURE <ls_key> TO FIELD-SYMBOL(<lv_account>).
*<lv_coa> = <wa_table>-coa.
*<lv_account> = <wa_table>-account.
*INSERT <ls_key> INTO TABLE <lt_key>.



TRY.
 lo_gov_api->enqueue_entity( EXPORTING iv_crequest_id = lv_crequest_id
 iv_entity_name = 'ACCOUNT'
 it_data = lt_key_account ).
 CATCH cx_usmd_gov_api_entity_lock cx_usmd_gov_api.
 EXIT.
 "Tough luck –
 "something went wrong while enqueueing the entity (it could be a
 "technical reason, or maybe the carrier is already interlocked?!
ENDTRY.


ls_account = <wa_table>.
append ls_account to lt_account.

TRY.
lo_gov_api->write_entity( EXPORTING iv_crequest_id = lv_crequest_id
 iv_entity_name = 'ACCOUNT'
it_data = lt_account ).

CATCH cx_usmd_gov_api_entity_write INTO lo_ent_error.
lt_messages = lo_ent_error->mt_messages.
 EXIT.
 "Tough luck - might be that you have no authorization, or the entity is
 "not enqueued or cannot be added to the object list of the change
 "request
ENDTRY.
TRY.
 lo_gov_api->check_crequest_data( iv_crequest_id = lv_crequest_id ).
 "Collect the entities to be checked
 ls_entity-entity = 'ACCOUNT'.
 ls_entity-tabl = REF #( lt_account ).
 INSERT ls_entity INTO TABLE lt_entity.
 "check the entity
 lo_gov_api->check_complete_data(
 EXPORTING iv_crequest_id = lv_crequest_id
 it_key = lt_entity ).
 CATCH cx_usmd_gov_api_core_error cx_usmd_gov_api.
 "Possibility to handle the erroneous data or go on.
ENDTRY.
"

TRY.
 lo_gov_api->save( ).
 "Save is done in draft mode by default so it is possible to
 "save the change request even if change request data or
 "entity data is not consistent.
 CATCH cx_usmd_gov_api_core_error.
 EXIT.
 "Adequate Exception handling
ENDTRY.

TRY.
 lo_gov_api->dequeue_entity( EXPORTING iv_crequest_id = lv_crequest_id
 iv_entity_name = 'ACCOUNT'
 it_data = lt_key_account ).
 lo_gov_api->dequeue_crequest(
 EXPORTING iv_crequest_id = lv_crequest_id ).
 CATCH cx_usmd_gov_api.
"Not a tragedy - maybe t
 ENDTRY.


TRY.
 lo_gov_api->start_workflow( iv_crequest_id = lv_crequest_id ).
 CATCH cx_usmd_gov_api_core_error.
 "Adequate Exception handling
ENDTRY.

COMMIT WORK AND WAIT.
lt_messages = lo_gov_api->get_messages( ).
WRITE : lv_crequest_id.
WRITE '変更要求作成完了.'.

clear : lo_gov_api, ls_key_account, lt_key_account, ls_account, lt_account, lv_crequest_id,
ls_entity.





ENDLOOP.
