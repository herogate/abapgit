*&---------------------------------------------------------------------*
*& Report ZMDG_GET_DT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDG_GET_DT.
    "*--------------------------------------------------------------------*
    " @ Function: this method creates decision tables for CR Type
    "*--------------------------------------------------------------------*
    DATA:
          lo_factory           TYPE REF TO if_fdt_factory,
          lo_query             TYPE REF TO if_fdt_query,
          lv_name              TYPE if_fdt_types=>name,
          lts_names            TYPE if_fdt_query=>ts_name,
          ls_name              TYPE if_fdt_query=>s_name,
          lt_fdt_msg           TYPE if_fdt_types=>t_message,
          ls_fdt_msg           TYPE if_fdt_types=>s_message,
          ls_message           TYPE usmd_s_message,
          lt_message           TYPE STANDARD TABLE OF usmd_s_message,
          lv_activate_failed   TYPE boolean,
          lts_column           TYPE if_fdt_decision_table=>ts_column,
          ls_column            TYPE if_fdt_decision_table=>s_column,
          lo_decision_table    TYPE REF TO if_fdt_decision_table,
          lts_context_id       TYPE if_fdt_types=>ts_object_id,
          lx_fdt               TYPE REF TO cx_fdt,
          lv_cr_type           TYPE usmd_crequest_type,
          lo_api               TYPE REF TO if_usmd_gov_api,
          lv_crequest          TYPE usmd_s_crequest,
          lo_fdt_query         TYPE REF TO if_fdt_query,
          lts_selection        TYPE if_fdt_query=>ts_selection,
          ls_selection         LIKE LINE OF lts_selection,
          lv_single_val_dt_id  TYPE IF_FDT_TYPES=>ID,
          lv_user_agt_dt_id    TYPE IF_FDT_TYPES=>ID.

  constants GC_PRE_STEP_ID type IF_FDT_TYPES=>ID value '801CC4EFFE841DEEAFD6C2DE5A9ACD54'. "#EC NOTEXT
  constants GC_PRE_ACTION_ID type IF_FDT_TYPES=>ID value '801CC4EFFE841DDEA6A29B1B14F91E69'. "#EC NOTEXT
  constants GC_NEW_STEP_ID type IF_FDT_TYPES=>ID value '801CC4EFFE841DDEAFD6BE3913B8D15F'. "#EC NOTEXT
  constants GC_NEW_CR_STATUS_ID type IF_FDT_TYPES=>ID value '801CC4EFFE841DEEA6A30BD966AC92C8'. "#EC NOTEXT
  constants GC_MERGE_TYPE_ID type IF_FDT_TYPES=>ID value '801CC4EFFE841DDEA6A376DEBF11DC1D'. "#EC NOTEXT
  constants GC_MERGE_PARAM_ID type IF_FDT_TYPES=>ID value '801CC4EFFE841DEEA6A376DF1C344EDA'. "#EC NOTEXT
  constants GC_S_SINGLE_VALUE_ID type IF_FDT_TYPES=>ID value '801CC4EFFE841DEEAFD6DB63849A8778'. "#EC NOTEXT
  constants GC_USER_AGT_GRP_ID type IF_FDT_TYPES=>ID value '801CC4EFFE841DEEA78898B1DF9D1DEF'. "#EC NOTEXT
  constants GC_NON_USER_AGT_GRP_ID type IF_FDT_TYPES=>ID value '801CC4EFFE841DEEA6A64C1234EFD721'. "#EC NOTEXT
  constants GC_STEP_TYPE_ID type IF_FDT_TYPES=>ID value '801CC4EFFE841DDEA6A31F2EEE9882DA'. "#EC NOTEXT
  constants GC_USER_TYPE_ID type IF_FDT_TYPES=>ID value '801CC4EFFE841DEEA6A31F2F25619963'. "#EC NOTEXT
  constants GC_DYN_AGT_SEL_ID type IF_FDT_TYPES=>ID value '801CC4EFFE841DEEAEA37020E40F5E69'. "#EC NOTEXT
  constants GC_USER_VALUE_ID type IF_FDT_TYPES=>ID value '801CC4EFFE841DDEA6A31F2F67C710FA'. "#EC NOTEXT
  constants GC_PROCESS_PTN_ID type IF_FDT_TYPES=>ID value '801CC4EFFE841DEEA6A64C126CA29EEC'. "#EC NOTEXT
  constants GC_SERVICE_NAME_ID type IF_FDT_TYPES=>ID value '801CC4EFFE841DDEA6A64C12A367D7EE'. "#EC NOTEXT
  constants GC_T_USER_AGT_GRP_ID type IF_FDT_TYPES=>ID value '801CC4EFFE841DDEA6A66D9C79DD0428'. "#EC NOTEXT
  constants GC_T_NON_USE_AGT_GRP_ID type IF_FDT_TYPES=>ID value '801CC4EFFE841DEEA6A6438539564D53'. "#EC NOTEXT
  constants GC_CR_TYPE_ID type IF_FDT_TYPES=>ID value '801CC4EFFE841DEEA78A133B60D3CD76'. "#EC NOTEXT
  constants GC_CR_APP_ST_PREFIX type CHAR20 value 'RBWF_APP_'. "#EC NOTEXT
  constants GC_FN_CALL_DT_RS_NAME type IF_FDT_TYPES=>NAME value 'USMD_FN_CALL_DT_RS'. "#EC NOTEXT
  constants GC_FN_GET_PROC_DT_SN type IF_FDT_TYPES=>NAME value 'USMD_FN_GET_PROC_DT_SN'. "#EC NOTEXT
  constants GC_CR_PRIORITY_ID type IF_FDT_TYPES=>ID value '801CC4EFFE841DDEA9D23FB5430BC146'. "#EC NOTEXT
  constants GC_CR_REASON_ID type IF_FDT_TYPES=>ID value '801CC4EFFE841DDEA9D24399F9A3CA6F'. "#EC NOTEXT
  constants GC_CR_REASON_REJ_ID type IF_FDT_TYPES=>ID value '801CC4EFFE841DEEA9D2465152859834'. "#EC NOTEXT
  constants GC_ROOT_INST_FLAG_ID type IF_FDT_TYPES=>ID value '801CC4EFFE841DDEA9D2499481D38ED3'. "#EC NOTEXT
  constants GC_CR_APP_PREFIX type CHAR20 value 'USMD_'. "#EC NOTEXT
  constants GC_CATALOG_PREFIX type CHAR20 value 'USMD_SSW_CATA_'. "#EC NOTEXT
  constants GC_SVAL_DT_PREFIX type CHAR20 value 'DT_SINGLE_VAL_'. "#EC NOTEXT
  constants GC_UAG_DT_PREFIX type CHAR20 value 'DT_USER_AGT_GRP_'. "#EC NOTEXT
  constants GC_NUAG_DT_PREFIX type CHAR20 value 'DT_NON_USER_AGT_GRP_'. "#EC NOTEXT
  constants GC_DT_RS_PREFIX type CHAR20 value 'RS_'. "#EC NOTEXT
  constants GC_PROC_DT_SN_PREFIX type CHAR20 value 'CNST_PROC_DT_SN_'. "#EC NOTEXT
  constants GC_PAR_AGT_GRP_NUM_ID type IF_FDT_TYPES=>ID value '801CC4EFFE841DDEAAFDED55D2F9DF76'. "#EC NOTEXT
  constants GC_COND_ALIAS_ID type IF_FDT_TYPES=>ID value '801CC4EFFE841DEEADDB0904BD614639'. "#EC NOTEXT
  constants GC_PARENT_STEP_ID type IF_FDT_TYPES=>ID value '801CC4EFFE841DDEAFD6C967724F0B5F'. "#EC NOTEXT
  constants GC_EXP_COMP_DAYS_ID type IF_FDT_TYPES=>ID value '801CC4EFFE841DDEADDE02E184574DA4'. "#EC NOTEXT
  constants GC_EXP_COMP_HOURS_ID type IF_FDT_TYPES=>ID value '801CC4EFFE841DEEADDE46BBE534DC4F'. "#EC NOTEXT
  constants GC_PROC_DT_SN_ID type IF_FDT_TYPES=>ID value '801CC4EFFE841DEEB2D285E10C5E81AE'. "#EC NOTEXT

    "Initialization

    lo_factory = cl_fdt_factory=>if_fdt_factory~get_instance( ).

    INSERT gc_pre_step_id INTO TABLE lts_context_id.
    INSERT gc_pre_action_id INTO TABLE lts_context_id.

    " Get CR TYPE
    lo_api = cl_usmd_gov_api=>get_instance( IV_MODEL_NAME = 'MM' ).
    lo_api->GET_CREQUEST_ATTRIBUTES(
      EXPORTING
       iv_crequest_id = '3409'
      RECEIVING
       rs_crequest = lv_crequest
        ).
    lv_cr_type = lv_crequest-usmd_creq_type.
    CHECK lv_cr_type is not INITIAL.

    CONCATENATE gc_sval_dt_prefix lv_cr_type INTO lv_name.

    lo_fdt_query = cl_fdt_query=>get_instance( ).

    " Get APP ID
    CALL METHOD lo_fdt_query->get_ids
        EXPORTING
         iv_name       = lv_name
        IMPORTING
         ets_object_id = DATA(lt_id).

    READ TABLE lt_id INTO DATA(iv_app_id) INDEX 1.

    " check if the dt already exists
    lo_query = lo_factory->get_query(
               iv_object_type = if_fdt_constants=>gc_object_type_expression ).

    CLEAR lts_selection.
    TRY.
        ls_selection-queryfield =  if_fdt_admin_data_query=>gc_fn_name.
        ls_selection-sign   = 'I'.
        ls_selection-option = 'EQ'.
        ls_selection-low    = lv_name.
        INSERT ls_selection INTO TABLE lts_selection.

        IF iv_app_id IS NOT INITIAL.
          ls_selection-queryfield =  if_fdt_admin_data_query=>gc_fn_application_id.
          ls_selection-sign   = 'I'.
          ls_selection-option = 'EQ'.
          ls_selection-low    = iv_app_id.
          INSERT ls_selection INTO TABLE lts_selection.
        ENDIF.

        lo_query->select_data(
          EXPORTING
            its_selection          = lts_selection
         IMPORTING
            eta_data                = lts_names  ).
      CATCH cx_fdt INTO lx_fdt.
        LOOP AT lx_fdt->mt_message INTO ls_fdt_msg.
          MOVE-CORRESPONDING ls_fdt_msg TO ls_message.
          APPEND ls_message TO lt_message.
        ENDLOOP.
        RETURN. ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    ENDTRY.

     IF lines( lt_message ) > 0.
      RETURN. ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
     ENDIF.

    " 1. create the single-value DT table

    IF lines( lts_names ) > 0. "already exists
      READ TABLE lts_names INTO ls_name INDEX 1.
      lv_single_val_dt_id = ls_name-id.
    ELSE.
      CLEAR lts_column.
      ls_column-col_no     = 1.
      ls_column-object_id =  gc_pre_step_id.
      ls_column-is_result  = abap_false.
      ls_column-input_required = abap_true.
      ls_column-is_optional = abap_false.
      INSERT ls_column INTO TABLE lts_column.

      ls_column-col_no     = 2.
      ls_column-object_id  = gc_pre_action_id.
      ls_column-is_result  = abap_false.
      ls_column-is_optional = abap_false."abap_true.
      ls_column-input_required = abap_false."abap_true.
      INSERT ls_column INTO TABLE lts_column.


      ls_column-col_no     = 3.
      ls_column-object_id  = gc_cr_priority_id.
      ls_column-is_result  = abap_false.
      ls_column-is_optional = abap_true.
      ls_column-input_required = abap_false.
      INSERT ls_column INTO TABLE lts_column.

      ls_column-col_no     = 4.
      ls_column-object_id  = gc_cr_reason_id.
      ls_column-is_result  = abap_false.
      ls_column-is_optional = abap_true.
      ls_column-input_required = abap_false.
      INSERT ls_column INTO TABLE lts_column.

      ls_column-col_no     = 5.
      ls_column-object_id  = gc_cr_reason_rej_id.
      ls_column-is_result  = abap_false.
      ls_column-is_optional = abap_true.
      ls_column-input_required = abap_false.
      INSERT ls_column INTO TABLE lts_column.

      ls_column-col_no     = 6.
      ls_column-object_id  = gc_parent_step_id.
      ls_column-is_result  = abap_false.
      ls_column-is_optional = abap_true.
      ls_column-input_required = abap_false.
      INSERT ls_column INTO TABLE lts_column.

      ls_column-col_no     = 7.
      ls_column-object_id  = gc_par_agt_grp_num_id.
      ls_column-is_result  = abap_false.
      ls_column-is_optional = abap_true.
      ls_column-input_required = abap_false.
      INSERT ls_column INTO TABLE lts_column.

      ls_column-col_no     = 8.
      ls_column-object_id  = gc_cond_alias_id.
      ls_column-is_result  = abap_true.
      ls_column-input_required = abap_false."abap_true.
      ls_column-is_optional = abap_false.
      INSERT ls_column INTO TABLE lts_column.

      ls_column-col_no     = 9.
      ls_column-object_id  = gc_new_step_id.
      ls_column-is_result  = abap_true.
      ls_column-input_required = abap_false.
      ls_column-is_optional = abap_false.
      INSERT ls_column INTO TABLE lts_column.

      ls_column-col_no     = 10.
      ls_column-object_id  = gc_new_cr_status_id.
      ls_column-is_result  = abap_true.
      ls_column-input_required = abap_false.
      ls_column-is_optional = abap_false.
      INSERT ls_column INTO TABLE lts_column.

      ls_column-col_no     = 11.
      ls_column-object_id  = gc_exp_comp_hours_id.
      ls_column-is_result  = abap_true.
      ls_column-input_required = abap_false.
      ls_column-is_optional = abap_false.
      INSERT ls_column INTO TABLE lts_column.

      ls_column-col_no     = 12.
      ls_column-object_id  = gc_merge_type_id.
      ls_column-is_result  = abap_true.
      ls_column-input_required = abap_false.
      ls_column-is_optional = abap_false.
      INSERT ls_column INTO TABLE lts_column.

      ls_column-col_no     = 13.
      ls_column-object_id  = gc_merge_param_id.
      ls_column-is_result  = abap_true.
      ls_column-input_required = abap_false.
      ls_column-is_optional = abap_false.
      INSERT ls_column INTO TABLE lts_column.

      ls_column-col_no     = 14.
      ls_column-object_id  = gc_dyn_agt_sel_id.
      ls_column-is_result  = abap_true.
      ls_column-input_required = abap_false.
      ls_column-is_optional = abap_false.
      INSERT ls_column INTO TABLE lts_column.


      lo_decision_table ?= lo_factory->get_expression(
      iv_expression_type_id = if_fdt_constants=>gc_exty_decision_table ).
      lo_decision_table->if_fdt_transaction~enqueue( abap_true ).
      lo_decision_table->if_fdt_admin_data~set_access_level( if_fdt_constants=>gc_access_level_application ).
      lo_decision_table->if_fdt_admin_data~set_application( iv_app_id ).
      lo_decision_table->if_fdt_admin_data~set_name( lv_name ).
      lo_decision_table->if_fdt_expression~set_context_data_objects( lts_context_id ).
      lo_decision_table->if_fdt_expression~set_result_data_object( gc_s_single_value_id ).
      lo_decision_table->set_table_property(
                            iv_multiple_match = abap_false
                            iv_allow_no_match = abap_true ).
      lo_decision_table->set_columns( lts_column ).
      lo_decision_table->if_fdt_transaction~activate(
                 IMPORTING et_message           = lt_fdt_msg
                           ev_activation_failed = lv_activate_failed ).

      TRY.
          IF lv_activate_failed EQ abap_true.
            " for some reason the activation failed -> individual handling needed
            lo_decision_table->if_fdt_transaction~dequeue( ).
            LOOP AT lt_fdt_msg INTO ls_fdt_msg.
              MOVE-CORRESPONDING ls_fdt_msg TO ls_message.
              APPEND ls_message TO lt_message.
            ENDLOOP.
            RETURN. ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
          ELSE.
            lo_decision_table->if_fdt_transaction~save( ).
            lo_decision_table->if_fdt_transaction~dequeue( ).
          ENDIF.

          lv_single_val_dt_id = lo_decision_table->mv_id.

        CATCH cx_fdt INTO lx_fdt.
          LOOP AT lx_fdt->mt_message INTO ls_fdt_msg.
            MOVE-CORRESPONDING ls_fdt_msg TO ls_message.
            APPEND ls_message TO lt_message.
          ENDLOOP.
          RETURN. ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
      ENDTRY.
    ENDIF.

    BREAK-POINT.

    CLEAR: lt_message, lts_selection, lv_name,iv_app_id,lts_names.
    " 2. create the agent_group decision table
     CONCATENATE gc_uag_dt_prefix lv_cr_type INTO lv_name.
    " Get APP ID
    CALL METHOD lo_fdt_query->get_ids
        EXPORTING
         iv_name       = lv_name
        IMPORTING
         ets_object_id = lt_id.

    READ TABLE lt_id INTO iv_app_id INDEX 1.


    " check if the dt already exists
     TRY.
        ls_selection-queryfield =  if_fdt_admin_data_query=>gc_fn_name.
        ls_selection-sign   = 'I'.
        ls_selection-option = 'EQ'.
        ls_selection-low    = lv_name.
        INSERT ls_selection INTO TABLE lts_selection.

        IF iv_app_id IS NOT INITIAL.
          ls_selection-queryfield =  if_fdt_admin_data_query=>gc_fn_application_id.
          ls_selection-sign   = 'I'.
          ls_selection-option = 'EQ'.
          ls_selection-low    = iv_app_id.
          INSERT ls_selection INTO TABLE lts_selection.
        ENDIF.

        lo_query->select_data(
          EXPORTING
            its_selection          = lts_selection
         IMPORTING
            eta_data                = lts_names  ).
      CATCH cx_fdt INTO lx_fdt.
        LOOP AT lx_fdt->mt_message INTO ls_fdt_msg.
          MOVE-CORRESPONDING ls_fdt_msg TO ls_message.
          APPEND ls_message TO lt_message.
        ENDLOOP.
        RETURN. ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    ENDTRY.

    IF lines( lt_message ) > 0.
      RETURN. ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    ENDIF.


    IF lines( lts_names ) > 0. "already exists
      READ TABLE lts_names INTO ls_name INDEX 1.
      lv_user_agt_dt_id = ls_name-id.
    ELSE.
      CLEAR lts_column.
      ls_column-col_no     = 1.
      ls_column-object_id  = gc_cond_alias_id.
      ls_column-is_result  = abap_false.
      ls_column-is_optional = abap_false.                   "n1502311
      ls_column-input_required = abap_false.
      INSERT ls_column INTO TABLE lts_column.

      ls_column-col_no     = 2.
      ls_column-object_id  = gc_user_agt_grp_id.
      ls_column-is_result  = abap_true.
      ls_column-input_required = abap_true.
      ls_column-is_optional = abap_false.
      INSERT ls_column INTO TABLE lts_column.

      ls_column-col_no     = 3.
      ls_column-object_id  = gc_step_type_id.
      ls_column-is_result  = abap_true.
      ls_column-input_required = abap_true.
      ls_column-is_optional = abap_false.
      INSERT ls_column INTO TABLE lts_column.

      ls_column-col_no     = 4.
      ls_column-object_id  = gc_user_type_id.
      ls_column-is_result  = abap_true.
      ls_column-input_required = abap_true.
      ls_column-is_optional = abap_false.
      INSERT ls_column INTO TABLE lts_column.

      ls_column-col_no     = 5.
      ls_column-object_id  = gc_user_value_id.
      ls_column-is_result  = abap_true.
      ls_column-input_required = abap_true.
      ls_column-is_optional = abap_false.
      INSERT ls_column INTO TABLE lts_column.

      lo_decision_table ?= lo_factory->get_expression(
      iv_expression_type_id = if_fdt_constants=>gc_exty_decision_table ).
      lo_decision_table->if_fdt_transaction~enqueue( abap_true ).
      lo_decision_table->if_fdt_admin_data~set_access_level( if_fdt_constants=>gc_access_level_application ).
      lo_decision_table->if_fdt_admin_data~set_application( iv_app_id ).
      lo_decision_table->if_fdt_admin_data~set_name( lv_name ).
      lo_decision_table->if_fdt_expression~set_context_data_objects( lts_context_id ).
      lo_decision_table->if_fdt_expression~set_result_data_object( gc_t_user_agt_grp_id ).
      lo_decision_table->set_table_property(
                            iv_multiple_match = abap_true
                            iv_allow_no_match = abap_true ).
      lo_decision_table->set_columns( lts_column ).
      lo_decision_table->if_fdt_transaction~activate(
                 IMPORTING et_message           = lt_fdt_msg
                           ev_activation_failed = lv_activate_failed ).

      TRY.
          IF lv_activate_failed EQ abap_true.
            " for some reason the activation failed -> individual handling needed
            lo_decision_table->if_fdt_transaction~dequeue( ).
            LOOP AT lt_fdt_msg INTO ls_fdt_msg.
              MOVE-CORRESPONDING ls_fdt_msg TO ls_message.
              APPEND ls_message TO lt_message.
            ENDLOOP.
            RETURN. ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
          ELSE.
            lo_decision_table->if_fdt_transaction~save( ).
            lo_decision_table->if_fdt_transaction~dequeue( ).
          ENDIF.
          lv_user_agt_dt_id = lo_decision_table->mv_id.

        CATCH cx_fdt INTO lx_fdt.
          LOOP AT lx_fdt->mt_message INTO ls_fdt_msg.
            MOVE-CORRESPONDING ls_fdt_msg TO ls_message.
            APPEND ls_message TO lt_message.
          ENDLOOP.
          RETURN. ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
      ENDTRY.

    ENDIF.


    BREAK-POINT.
