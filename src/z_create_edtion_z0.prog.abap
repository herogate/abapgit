*&---------------------------------------------------------------------*
*& Report Z_CREATE_EDTION_Z0
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_CREATE_EDTION_Z0.

DATA lo_api type ref to IF_USMD_EDITION_API.
DATA lt_message type usmd_t_message.

lo_api = CL_USMD_EDITION_API=>get_instance( ).
lo_api->create_edition(
 EXPORTING
  iv_edition = 'Z0_TEST'
  iv_edition_type = 'Z0_ALL'
  iv_date_from = '20221017'
  iv_description = 'Z0 TEST EDITION'
 IMPORTING
  et_info_message = lt_message
 ).

BREAK-POINT.
