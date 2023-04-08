*&---------------------------------------------------------------------*
*& Report ZDRF_TRIGGER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZDRF_TRIGGER.
DATA lo_drf type ref to CL_DRF_MEMBERSHIP_API.

CALL method CL_DRF_MEMBERSHIP_API=>SEND_BO_TO_TARGET(
 EXPORTING
  IV_BO_TYPE = '147'
  IV_BO_KEY = '0001000559'
  IV_TARGET_SYSTEM = 'CPI_BP'
 IMPORTING
  EV_LOGHANDLE = DATA(ev_log)
  ES_MESSAGE = DATA(es_message)

).
