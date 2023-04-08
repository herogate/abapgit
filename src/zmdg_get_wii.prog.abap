*&---------------------------------------------------------------------*
*& Report ZMDG_GET_WII
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDG_GET_WII.

"DATA lt_workitems TYPE USMD4_T_SWR_WIHDR.
"DATA lt_container TYPE USMD4_T_SWR_CONT.
DATA lo_wf type ref to CL_USMD_WF_SERVICE.
DATA lo_api type ref to if_usmd_gov_api.
DATA lv_crequest type usmd_s_crequest.

"CONSTANTS: DT_SINGLE_VAL TYPE if_fdt_types=>id  VALUE '120321FA13F11EDD9598EFC72A30CC82',
"           DT_USER_AGT_GRP TYPE if_fdt_types=>id VALUE '120321FA13F11EDD9598EFC72A314C82'.

TYPES: BEGIN OF s_application_data,
               id      TYPE if_fdt_types=>id,
               name    TYPE if_fdt_types=>name,
               text    TYPE if_fdt_types=>text,
               cr_user TYPE syuname,
       END OF  s_application_data.



" DATA lt_data TYPE TABLE OF s_application_data.

FIELD-SYMBOLS <fs_lt_data> TYPE ANY TABLE.

lo_api = cl_usmd_gov_api=>get_instance( IV_MODEL_NAME = 'MM' ).
lo_api->GET_CREQUEST_ATTRIBUTES(
 EXPORTING
  iv_crequest_id = '3409'
 RECEIVING
  rs_crequest = lv_crequest
 ).
DATA(lv_crtype) = lv_crequest-USMD_CREQ_TYPE.
*
*cl_usmd_wf_service=>get_cr_top_wf( EXPORTING id_crequest = '3409'
*                                   IMPORTING et_workflow = DATA(lt_top_wf)
*                                             ed_rtcode = DATA(lv_rcode) ).
*
*read TABLE lt_top_wf index 1 into data(ls_wi).
*
*cl_usmd4_crequest_protocol=>get_dependent_wis( EXPORTING i_workitem_id = ls_wi-WI_ID
*                                               IMPORTING e_return_code = lv_rcode
*                                               CHANGING  t_items = lt_workitems ).
*
*cl_usmd4_crequest_protocol=>read_container( EXPORTING i_workitem_id      = ls_wi-WI_ID
*                                            IMPORTING e_return_code      = DATA(lv_return_code)
*                                            CHANGING  t_simple_container = lt_container ).

lo_wf = cl_usmd_wf_service=>get_instance( ).
lo_wf->get_crequest_step(
 EXPORTING
   ID_CREQUEST = '3409'
 IMPORTING
   ED_STEP = DATA(lv_step)
   ED_CREQUEST_INDEX = DATA(lv_index)
).
*lo_wf->GET_CR_WIS(
* EXPORTING
*   ID_CREQUEST = '3409'
* IMPORTING
*   et_workitem = DATA(lt_workitme)
*
*).

*DATA(lo_factory) = cl_fdt_factory=>if_fdt_factory~get_instance( ).
*DATA(lo_query) = CAST if_fdt_query( lo_factory->get_query(
*iv_object_type = if_fdt_constants=>gc_object_type_function ) ).
*
*DATA(lt_sel) = VALUE if_fdt_query=>ts_selection(
*( queryfield = if_fdt_admin_data_query=>gc_fn_application_id
*  sign = 'I'
*  option = 'EQ'
*  low = dt_single_val ) ).
*
*lo_query->select_data(
* EXPORTING
*   iv_deleted_option = if_fdt_query=>gc_memopt_both
*   iv_memory_option = if_fdt_query=>gc_delopt_undeleted
*   iv_named_option = if_fdt_query=>gc_namopt_named
*   its_selection = lt_sel
*
* IMPORTING
*   eta_data =  lt_data ).

types:BEGIN OF ts_msg_txt_data,
               previous_step       type char24,
               previous_action     type char24,
               condition_alias     type char24,
               new_change_step     type char24,
     END OF ts_msg_txt_data.


types:BEGIN OF ts_msg_txt_data_us,
               row_no           type index,
               condition_alias       type char24,
               user_agent_type     type char24,
               user_value     type char24,
     END OF ts_msg_txt_data_us.



TYPES: BEGIN OF ts_table_data, row_no  TYPE int4,
            col_no                   TYPE int4,
            expression_id            TYPE if_fdt_types=>id,
            r_value                  TYPE REF TO data,
            ts_range                 TYPE if_fdt_range=>ts_range,
       END OF ts_table_data .

 DATA admin_data type REF TO CL_FDT_DECISION_TABLE.
 DATA lt_msg_data TYPE if_fdt_decision_table=>ts_table_data.
 DATA ls_table_data_msg TYPE ts_table_data.
 DATA lt_table_data_msg TYPE TABLE OF ts_table_data.
 DATA ls_msg_data LIKE LINE OF  lt_msg_data.
 DATA ls_table_data1 TYPE ts_table_data.
 DATA ls_msg_txt_data type ts_msg_txt_data.
 DATA ls_msg_txt_data_us type ts_msg_txt_data_us.
 DATA ls_range_msg TYPE if_fdt_range=>s_range.
 DATA lt_msg_txt_data type STANDARD TABLE OF ts_msg_txt_data.
 DATA lt_msg_txt_data_us type STANDARD TABLE OF ts_msg_txt_data_us.
 DATA lt_next_data_us type STANDARD TABLE OF ts_msg_txt_data_us.

 FIELD-SYMBOLS : <fs_lv_value> type any,
                 <fs_lv_row> type any.

DATA: lo_fdt_query    TYPE REF TO if_fdt_query.
CALL METHOD cl_fdt_query=>get_instance
           RECEIVING
             ro_query = lo_fdt_query.

DATA lv_single_table TYPE IF_FDT_TYPES=>NAME.
DATA lv_user_table TYPE IF_FDT_TYPES=>NAME.
CONCATENATE 'DT_SINGLE_VAL_' lv_crtype into lv_single_table.
CONCATENATE 'DT_USER_AGT_GRP_' lv_crtype into lv_user_table.

* get application id
         CALL METHOD lo_fdt_query->get_ids
           EXPORTING
             iv_name       = lv_single_table
           IMPORTING
             ets_object_id = DATA(lt_id).
         READ TABLE lt_id INTO DATA(lv_app_id) INDEX 1.


 admin_data ?= CL_FDT_CONVENIENCE=>get_admin_data( lv_app_id ).

 admin_data->IF_FDT_DECISION_TABLE~GET_TABLE_DATA(
  IMPORTING
    ETS_DATA = lt_msg_data
 ).


 LOOP AT lt_msg_data INTO ls_msg_data.
  ls_table_data_msg-row_no = ls_msg_data-row_no.
  ls_table_data_msg-col_no = ls_msg_data-col_no.
  ls_table_data_msg-expression_id = ls_msg_data-expression_id.
  ls_table_data_msg-r_value = ls_msg_data-r_value.
  ls_table_data_msg-ts_range = ls_msg_data-ts_range.
  APPEND ls_table_data_msg TO lt_table_data_msg.
  CLEAR ls_table_data_msg.
 ENDLOOP.

 SORT lt_table_data_msg BY row_no col_no.

 LOOP AT lt_table_data_msg INTO ls_table_data_msg.
   ls_table_data1 = ls_table_data_msg.
   CASE ls_table_data1-col_no.
*   previous_step
      when 1.
         IF ls_table_data1-ts_range IS NOT INITIAL.
            READ TABLE ls_table_data1-ts_range INTO ls_range_msg INDEX 1.
            IF sy-subrc = 0.
             ASSIGN ls_range_msg-r_low_value->* TO <fs_lv_value>.
                   ls_msg_txt_data-previous_step  = <fs_lv_value>.
            ENDIF.
         ENDIF.
*    previous_action
        when 2.
           IF ls_table_data1-ts_range IS NOT INITIAL.
              READ TABLE ls_table_data1-ts_range INTO ls_range_msg INDEX 1.
               IF sy-subrc = 0.
                ASSIGN ls_range_msg-r_low_value->* TO <fs_lv_value>.
                 ls_msg_txt_data-previous_action = <fs_lv_value>.
               ENDIF.
            ENDIF.
*     condition_alias
          when 8.
            IF ls_table_data1-r_value IS NOT INITIAL.
              ASSIGN ls_table_data1-r_value->* TO <fs_lv_value>.
               ls_msg_txt_data-condition_alias  = <fs_lv_value>.
            ENDIF.
*     new_change_step
          when 9.
            IF ls_table_data1-r_value IS NOT INITIAL.
             ASSIGN ls_table_data1-r_value->* TO <fs_lv_value>.
             ls_msg_txt_data-new_change_step = <fs_lv_value>.
            ENDIF.
         endcase.
           AT END OF row_no .
            APPEND ls_msg_txt_data TO lt_msg_txt_data.
            CLEAR ls_msg_txt_data.
           ENDAT.
   endloop.

Clear ls_msg_txt_data.
Loop at lt_msg_txt_data into ls_msg_txt_data.
  IF ls_msg_txt_data-previous_step = lv_step.
    DATA(lv_con) = ls_msg_txt_data-condition_alias.
  ENDIF.

ENDLOOP.

CHECK lv_con is not INITIAL.

CLEAR : ls_msg_txt_data, lt_msg_txt_data, lt_msg_data, ls_msg_data, lt_id, lv_app_id,
        ls_table_data_msg, lt_table_data_msg, ls_table_data1, ls_range_msg.
UNASSIGN <fs_lv_value>.


* get application id
         CALL METHOD lo_fdt_query->get_ids
           EXPORTING
             iv_name       = lv_user_table
           IMPORTING
             ets_object_id = lt_id.
         READ TABLE lt_id INTO lv_app_id INDEX 1.


 admin_data ?= CL_FDT_CONVENIENCE=>get_admin_data( lv_app_id ).

 admin_data->IF_FDT_DECISION_TABLE~GET_TABLE_DATA(
  IMPORTING
    ETS_DATA = lt_msg_data ).


 LOOP AT lt_msg_data INTO ls_msg_data.
  ls_table_data_msg-row_no = ls_msg_data-row_no.
  ls_table_data_msg-col_no = ls_msg_data-col_no.
  ls_table_data_msg-expression_id = ls_msg_data-expression_id.
  ls_table_data_msg-r_value = ls_msg_data-r_value.
  ls_table_data_msg-ts_range = ls_msg_data-ts_range.
  APPEND ls_table_data_msg TO lt_table_data_msg.
  CLEAR ls_table_data_msg.
 ENDLOOP.

 SORT lt_table_data_msg BY row_no col_no.

 LOOP AT lt_table_data_msg INTO ls_table_data_msg.
   ls_table_data1 = ls_table_data_msg.
   CASE ls_table_data1-col_no.
*   condition_alias
      when 1.
         IF ls_table_data1-ts_range IS NOT INITIAL.
            loop at ls_table_data1-ts_range into ls_range_msg.
            "READ TABLE ls_table_data1-ts_range INTO ls_range_msg INDEX 1.
            "IF sy-subrc = 0.
             ASSIGN : ls_range_msg-r_low_value->* TO <fs_lv_value>,
                      ls_table_data1-row_no TO <fs_lv_row>.
                    ls_msg_txt_data_us-condition_alias = <fs_lv_value>.
                    ls_msg_txt_data_us-row_no = <fs_lv_row>.
                    append ls_msg_txt_data_us to lt_msg_txt_data_us.
             ENDLOOP.
            "ENDIF.
         ENDIF.
*    User agent type
        when 4.
           IF ls_table_data1-r_value IS NOT INITIAL.
             loop at lt_msg_txt_data_us into ls_msg_txt_data_us.
               IF ls_table_data_msg-row_no = ls_msg_txt_data_us-row_no.
                 ASSIGN ls_table_data1-r_value->* TO <fs_lv_value>.
                 ls_msg_txt_data_us-user_agent_type = <fs_lv_value>.
                 MODIFY lt_msg_txt_data_us from ls_msg_txt_data_us.
               ENDIF.
             endloop.
           ENDIF.
*     User value
          when 5.
            IF ls_table_data1-r_value IS NOT INITIAL.
              loop at lt_msg_txt_data_us into ls_msg_txt_data_us.
               IF ls_table_data_msg-row_no = ls_msg_txt_data_us-row_no.
                 ASSIGN ls_table_data1-r_value->* TO <fs_lv_value>.
                 ls_msg_txt_data_us-user_value = <fs_lv_value>.
                 MODIFY lt_msg_txt_data_us from ls_msg_txt_data_us.
               ENDIF.
             endloop.
            ENDIF.
         endcase.
*           AT END OF row_no .
*            APPEND ls_msg_txt_data_us TO lt_msg_txt_data_us.
*            CLEAR ls_msg_txt_data_us.
*           ENDAT.
   endloop.

clear ls_msg_txt_data_us.
LOOP AT lt_msg_txt_data_us INTO ls_msg_txt_data_us WHERE condition_alias = lv_con.
  append ls_msg_txt_data_us to lt_next_data_us.
ENDLOOP.



BREAK-POINT.
