*&---------------------------------------------------------------------*
*& Report ZMDG_GET_NEXT_USER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDG_GET_NEXT_USER.
DATA ls_user_data type  bapiaddr3.
DATA lt_return TYPE bapirettab.
DATA ev_mail_address TYPE string.
DATA rv_user type USMD_T_USER.
DATA wa_user LIKE LINE OF rv_user.
DATA lo_wf type ref to cl_usmd_wf_service.

lo_wf = CL_USMD_WF_SERVICE=>GET_INSTANCE( ).

CALL METHOD lo_wf->GET_CR_WF_PROCESSORS
 exporting
   ID_CREQUEST = '3405'
 IMPORTING
   et_uname = rv_user.

loop at rv_user into wa_user.
 WRITE wa_user.
endloop.

*loop at rv_user into wa_user.
* CALL FUNCTION 'BAPI_USER_GET_DETAIL'
*  EXPORTING
*    username =  wa_user "lt_users-UNAME
*    cache_results = space
*  IMPORTING
*   address = ls_user_data
*   TABLES
*   return = lt_return.
*   ev_mail_address = ls_user_data-e_mail.
*
*  WRITE ev_mail_address.
*endloop.
