*&---------------------------------------------------------------------*
*& Report ZMDG_GET_ATTACHMENT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmdg_get_attachment.
DATA lr_gov_api TYPE REF TO if_usmd_gov_api.
DATA lv_content TYPE usmd_content.
DATA lv_output_length TYPE i.
DATA iv_crquest TYPE usmd_crequest.
DATA lv_timestamp TYPE timestamp.
DATA lt_usmd1211 TYPE STANDARD TABLE OF usmd1211.
DATA lt_binary_tab TYPE STANDARD TABLE OF solisti1.

lr_gov_api = cl_usmd_gov_api=>get_instance('MM').

SELECT * FROM usmd1211 INTO TABLE lt_usmd1211.
LOOP AT lt_usmd1211 INTO DATA(ls_usmd1211).

  lr_gov_api->get_attachment_content(
   EXPORTING
    iv_crequest_id =  ls_usmd1211-usmd_crequest
    iv_timestamp = ls_usmd1211-usmd_acreated_at
   RECEIVING
    rv_content = lv_content ).


   CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING
      buffer        = lv_content
    IMPORTING
      output_length = lv_output_length
    TABLES
      binary_tab    = lt_binary_tab.


  CONCATENATE 'C:\Users\I572561\Downloads\' ls_usmd1211-usmd_crequest '_' ls_usmd1211-usmd_title INTO DATA(lv_filename).

  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename                = lv_filename
      filetype                = 'BIN'
    TABLES
      data_tab                = lt_binary_tab
*     FIELDNAMES              =
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      OTHERS                  = 22.



ENDLOOP.
