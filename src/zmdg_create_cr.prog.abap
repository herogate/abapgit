*&---------------------------------------------------------------------*
*& Report ZMDG_CREATE_CR
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDG_CREATE_CR.

  DATA: lo_mdg_api         TYPE REF TO if_usmd_conv_som_gov_api,
        lt_entity_data     TYPE usmd_gov_api_ts_ent_data,
        ls_entity_data     TYPE usmd_gov_api_s_ent_data,
        lo_cx_usmd_gov_api TYPE REF TO cx_usmd_gov_api,
        ls_message         TYPE bapiret2,
        lv_key_bp_header   TYPE /mdgbp/_s_bp_pp_bp_header-bp_header,
        lv_key_assgnm_id   TYPE /mdgbpx/_s_bp_pp_bp_mlt_as-assgnm_id,
        lv_key_addrno      TYPE /mdgbp/_s_bp_pp_bp_addr-addrno,
        lt_key_bp_header   TYPE TABLE OF /mdgbp/_s_bp_ky_bp_header,
        ls_key_bp_header   TYPE /mdgbp/_s_bp_ky_bp_header,
        lt_key_addrno      TYPE TABLE OF /mdgbp/_s_bp_ky_addrno,
        ls_key_addrno      TYPE /mdgbp/_s_bp_ky_addrno,
        lt_bp_header       TYPE TABLE OF /mdgbp/_s_bp_pp_bp_header,
        ls_bp_header       TYPE /mdgbp/_s_bp_pp_bp_header,
        lt_bp_role         TYPE TABLE OF /mdgbp/_s_bp_pp_bp_role,
        ls_bp_role         TYPE /mdgbp/_s_bp_pp_bp_role,
        lt_bp_mlt_as       TYPE TABLE OF /mdgbpx/_s_bp_pp_bp_mlt_as,
        ls_bp_mlt_as       TYPE /mdgbpx/_s_bp_pp_bp_mlt_as,
        lt_bp_centrl       TYPE TABLE OF /mdgbp/_s_bp_pp_bp_centrl,
        ls_bp_centrl       TYPE /mdgbp/_s_bp_pp_bp_centrl,
        lt_bp_vengen       TYPE TABLE OF /mdgbpx/_s_bp_pp_bp_vengen,
        ls_bp_vengen       TYPE /mdgbpx/_s_bp_pp_bp_vengen,
        lt_bp_porg         TYPE TABLE OF /mdgbpx/_s_bp_pp_bp_porg,
        ls_bp_porg         TYPE /mdgbpx/_s_bp_pp_bp_porg,
        lt_bp_mlt_ad       TYPE TABLE OF /mdgbpx/_s_bp_pp_bp_mlt_ad,
        ls_bp_mlt_ad       TYPE /mdgbpx/_s_bp_pp_bp_mlt_ad,
        lt_address         TYPE TABLE OF /mdgbp/_s_bp_pp_address,
        ls_address         TYPE /mdgbp/_s_bp_pp_address,
        lt_bp_addr         TYPE TABLE OF /mdgbp/_s_bp_pp_bp_addr,
        ls_bp_addr         TYPE /mdgbp/_s_bp_pp_bp_addr,
        lt_bp_addusg       TYPE TABLE OF /mdgbp/_s_bp_pp_bp_addusg,
        ls_bp_addusg       TYPE /mdgbp/_s_bp_pp_bp_addusg,
        lt_ad_name_o       TYPE TABLE OF /mdgbp/_s_bp_pp_ad_name_o,
        ls_ad_name_o       TYPE /mdgbp/_s_bp_pp_ad_name_o,
        lt_ad_postal       TYPE TABLE OF /mdgbp/_s_bp_pp_ad_postal,
        ls_ad_postal       TYPE /mdgbp/_s_bp_pp_ad_postal,
        lt_ad_tel          TYPE TABLE OF /mdgbp/_s_bp_pp_ad_tel,
        ls_ad_tel          TYPE /mdgbp/_s_bp_pp_ad_tel,
        lt_ad_fax          TYPE TABLE OF /mdgbp/_s_bp_pp_ad_fax,
        ls_ad_fax          TYPE /mdgbp/_s_bp_pp_ad_fax,
        lt_ad_url          TYPE TABLE OF /mdgbp/_s_bp_pp_ad_url,
        ls_ad_url          TYPE /mdgbp/_s_bp_pp_ad_url,
        lv_index           TYPE i,
        lv_cr              TYPE usmd_crequest.

 " CLEAR: ev_cr, ev_error, et_message.

  TRY.
********************************************************************************************
* 초기화.
********************************************************************************************
      cl_usmd_conv_som_gov_api=>get_instance(
        EXPORTING
          iv_model_name = 'BP'
        RECEIVING
          ro_so_gov_api = lo_mdg_api
      ).

      lo_mdg_api->refresh_buffers( ).
      lo_mdg_api->set_environment(
        EXPORTING
          iv_crequest_type   = 'ZSUPP1CH'
          iv_process         = 'SUP1'
          iv_create_crequest = abap_true
      ).
      lo_mdg_api->set_crequest_attributes(
        EXPORTING
          iv_crequest_text   = |공급업체 생성 { sy-datum }|
      ).
      lo_mdg_api->enqueue_crequest( iv_lock_mode = 'E' ).




********************************************************************************************
* BP_HEADER
********************************************************************************************
      lo_mdg_api->create_entity_tmp_key(
        EXPORTING
          iv_entity = 'BP_HEADER'
        IMPORTING
          es_key    = ls_key_bp_header
      ).
      lv_key_bp_header = ls_key_bp_header-bp_header.

      CLEAR: ls_bp_header.
      ls_bp_header-bp_header = lv_key_bp_header.
      ls_bp_header-bp_guid = cl_system_uuid=>create_uuid_x16_static( ).
      ls_bp_header-bu_group = 'MDG1'.
      ls_bp_header-bu_type = '2'.
      ls_bp_header-txtlg = 'test'.
      INSERT ls_bp_header INTO TABLE lt_bp_header.

      PERFORM write_entity USING lo_mdg_api 'BP_HEADER' lt_bp_header.

********************************************************************************************
* BP_ROLE
********************************************************************************************
      CLEAR: ls_bp_role.
      ls_bp_role-bp_header = lv_key_bp_header.
      ls_bp_role-bp_rol_id = 'FLVN01'.
      INSERT ls_bp_role INTO TABLE lt_bp_role.

      PERFORM write_entity USING lo_mdg_api 'BP_ROLE' lt_bp_role.

********************************************************************************************
* BP_MLT_AS
********************************************************************************************
      lv_key_assgnm_id = 1.
      CLEAR: ls_bp_mlt_as.
      ls_bp_mlt_as-bp_header = lv_key_bp_header.
      ls_bp_mlt_as-assgnm_id = lv_key_assgnm_id.
      ls_bp_mlt_as-as_type = 'SUPPL'.
      ls_bp_mlt_as-object_id = lv_key_bp_header.
      ls_bp_mlt_as-standard = abap_true.
      INSERT ls_bp_mlt_as INTO TABLE lt_bp_mlt_as.

      PERFORM write_entity USING lo_mdg_api 'BP_MLT_AS' lt_bp_mlt_as.

*********************************************************************************************
* ADDRNO
*********************************************************************************************
      lo_mdg_api->create_entity_tmp_key(
        EXPORTING
          iv_entity = 'ADDRNO'
        IMPORTING
          es_key    = ls_key_addrno
      ).
      lv_key_addrno = ls_key_addrno-addrno.

      INSERT ls_key_addrno INTO TABLE lt_key_addrno.

      PERFORM write_entity USING lo_mdg_api 'ADDRNO' lt_key_addrno.

*********************************************************************************************
* BP_MLT_AD
*********************************************************************************************
      CLEAR: ls_bp_mlt_ad.
      ls_bp_mlt_ad-addrno = 'XXDEFAULT'.
      ls_bp_mlt_ad-assgnm_id = lv_key_assgnm_id.
      ls_bp_mlt_ad-bp_header = lv_key_bp_header.
      INSERT ls_bp_mlt_ad INTO TABLE lt_bp_mlt_ad.

      PERFORM write_entity USING lo_mdg_api 'BP_MLT_AD' lt_bp_mlt_ad.

*********************************************************************************************
* ADDRESS
*********************************************************************************************
      CLEAR: ls_address.
      ls_address-bp_header = lv_key_bp_header.
      ls_address-addrno = lv_key_addrno.
      ls_address-type = 1.
      INSERT ls_address INTO TABLE lt_address.

      PERFORM write_entity USING lo_mdg_api 'ADDRESS' lt_address.

*********************************************************************************************
* BP_ADDR
*********************************************************************************************
      CLEAR: ls_bp_addr.
      ls_bp_addr-bp_header = lv_key_bp_header.
      ls_bp_addr-addrno = lv_key_addrno.
      ls_bp_addr-addr_guid = cl_system_uuid=>create_uuid_x16_static( ).
      INSERT ls_bp_addr INTO TABLE lt_bp_addr.

      PERFORM write_entity USING lo_mdg_api 'BP_ADDR' lt_bp_addr.

*********************************************************************************************
* BP_ADDUSG
*********************************************************************************************
      CLEAR: ls_bp_addusg.
      ls_bp_addusg-bp_header = lv_key_bp_header.
      ls_bp_addusg-addrno = lv_key_addrno.
      ls_bp_addusg-bp_adrknd = 'XXDEFAULT'.
      INSERT ls_bp_addusg INTO TABLE lt_bp_addusg.

      PERFORM write_entity USING lo_mdg_api 'BP_ADDUSG' lt_bp_addusg.

*********************************************************************************************
* AD_POSTAL
*********************************************************************************************
      CLEAR: ls_ad_postal.
      ls_ad_postal-bp_header = lv_key_bp_header.
      ls_ad_postal-addrno = lv_key_addrno.
      ls_ad_postal-ref_posta = 'KR'.
      ls_ad_postal-langu_com = '3'.
      ls_ad_postal-post_cod1 = '12345'.
      ls_ad_postal-city1 = '주소1'.
      ls_ad_postal-street = '주소2'.
      INSERT ls_ad_postal INTO TABLE lt_ad_postal.

      PERFORM write_entity USING lo_mdg_api 'AD_POSTAL' lt_ad_postal.

*AD_URL 인터넷 주소
*AD_TEL 전화번호
*AD_FAX 팩스번호
*AD_EMAIL 전자메일 주소

********************************************************************************************
* BP_CENTRL
********************************************************************************************
      CLEAR: ls_bp_centrl.
      ls_bp_centrl-bp_header = lv_key_bp_header.
*      ls_bp_centrl-bpkind = 'P001'.
*      ls_bp_centrl-title_bp = '0003'.
      ls_bp_centrl-name_org1 = 'test'.
      INSERT ls_bp_centrl INTO TABLE lt_bp_centrl.

      PERFORM write_entity USING lo_mdg_api 'BP_CENTRL' lt_bp_centrl.

********************************************************************************************
* BP_VENGEN
********************************************************************************************
      CLEAR: ls_bp_vengen.
      ls_bp_vengen-assgnm_id = lv_key_assgnm_id.
      ls_bp_vengen-bp_header = lv_key_bp_header.
      ls_bp_vengen-lifnr = lv_key_bp_header.
      ls_bp_vengen-ktokk = 'KRED'.
      INSERT ls_bp_vengen INTO TABLE lt_bp_vengen.

      PERFORM write_entity USING lo_mdg_api 'BP_VENGEN' lt_bp_vengen.

**********************************************************************
*BP_PORG
**********************************************************************
      CLEAR: ls_bp_porg.
      ls_bp_porg-assgnm_id = lv_key_assgnm_id.
      ls_bp_porg-bp_header = lv_key_bp_header.
      ls_bp_porg-prch_org = '1010'.
      ls_bp_porg-waers = 'JPY'.
      INSERT ls_bp_porg INTO TABLE lt_bp_porg.

      CLEAR: ls_bp_porg.
      ls_bp_porg-assgnm_id = lv_key_assgnm_id.
      ls_bp_porg-bp_header = lv_key_bp_header.
      ls_bp_porg-prch_org = '1710'.
      ls_bp_porg-waers = 'JPY'.
      INSERT ls_bp_porg INTO TABLE lt_bp_porg.

      PERFORM write_entity USING lo_mdg_api 'BP_PORG' lt_bp_porg.



*VENGENTXT 텍스트(공급업체 일반 데이터)
*BP_VENVAL 공급업체: 특징 값(분류)
*BP_VENSUB 공급업체 하위 범위
*BP_VENDDB 문서 링크에 대한 기본 데이터
*BP_VENCLA 공급업체: 클래스 지정(분류)
*BP_TAXGRP 세금 그룹화(공급업체)
*BP_COMPNY 회사 코드




********************************************************************************************
* 저장.
********************************************************************************************
      lo_mdg_api->confirm_entity_data( ).
      lo_mdg_api->check( ).
      IF lo_mdg_api->mv_successfully_checked EQ abap_true.
        lo_mdg_api->set_action( cl_usmd_crequest_action=>gc_draft_action-submit ).
        lo_mdg_api->save( ).
        lv_cr = lo_mdg_api->mv_crequest_id.
      ENDIF.

    CATCH cx_uuid_error.
    CATCH cx_usmd_gov_api INTO lo_cx_usmd_gov_api.
      " ev_error = abap_true.
  ENDTRY.


  " PERFORM get_message USING lo_mdg_api et_message.
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




*FUNCTION zmdp_conv_usmdmsg_to_bapiret2.
*
*  CLEAR: es_bapiret2.
*
*  MESSAGE ID is_usmdmsg-msgid TYPE is_usmdmsg-msgty NUMBER is_usmdmsg-msgno
*    WITH is_usmdmsg-msgv1 is_usmdmsg-msgv2 is_usmdmsg-msgv3 is_usmdmsg-msgv4
*    INTO es_bapiret2-message.
*
*
*  es_bapiret2-type = sy-msgty.
*  es_bapiret2-id = sy-msgid.
*  es_bapiret2-number = sy-msgno.
*  es_bapiret2-message_v1 = sy-msgv1.
*  es_bapiret2-message_v2 = sy-msgv2.
*  es_bapiret2-message_v3 = sy-msgv3.
*  es_bapiret2-message_v4 = sy-msgv4.
*  es_bapiret2-row = is_usmdmsg-row.
*  es_bapiret2-field = is_usmdmsg-fieldname.
*
*ENDFUNCTION.
*
*
*
*FORM write_entity USING io_mdg_api iv_entity it_data.
*  DATA: lo_mdg_api     TYPE REF TO if_usmd_conv_som_gov_api,
*        lt_entity_data TYPE usmd_gov_api_ts_ent_data,
*        ls_entity_data TYPE usmd_gov_api_s_ent_data.
*
*  lo_mdg_api = io_mdg_api.
*
*  CLEAR: lt_entity_data, ls_entity_data.
*  ls_entity_data-entity = iv_entity.
*  ls_entity_data-entity_data = REF #( it_data ).
*  APPEND ls_entity_data TO lt_entity_data.
*
*  lo_mdg_api->write_entity_data( it_entity_data = lt_entity_data ).
*ENDFORM.
*FORM read_entity USING io_usmd_model iv_entity it_sel et_data.
*  DATA: lo_usmd_model  TYPE REF TO if_usmd_model_ext.
*
*  lo_usmd_model = io_usmd_model.
*  lo_usmd_model->read_char_value(
*    EXPORTING
*      i_fieldname       = iv_entity
*      it_sel            = it_sel
*      if_no_flush       = abap_true
*    IMPORTING
*      et_data           = et_data
*  ).
*ENDFORM.
*FORM get_message USING io_mdg_api TYPE REF TO if_usmd_conv_som_gov_api
*                       et_message TYPE bapiret2_tab.
*  DATA: lt_usmd_msg TYPE usmd_t_message,
*        ls_usmd_msg TYPE usmd_s_message,
*        ls_bapiret2 TYPE bapiret2.
*
*  lt_usmd_msg = io_mdg_api->get_messages( ).
*
*  LOOP AT lt_usmd_msg INTO ls_usmd_msg.
*    IF ls_usmd_msg-msgid EQ 'MDG_BS_BP' AND ls_usmd_msg-msgno EQ '057'.
*      " 필요 없는 메시지.
*      CONTINUE.
*    ENDIF.
*    CALL FUNCTION 'ZMDP_CONV_USMDMSG_TO_BAPIRET2'
*      EXPORTING
*        is_usmdmsg  = ls_usmd_msg
*      IMPORTING
*        es_bapiret2 = ls_bapiret2.
*    APPEND ls_bapiret2 TO et_message.
*  ENDLOOP.
*
*ENDFORM.
