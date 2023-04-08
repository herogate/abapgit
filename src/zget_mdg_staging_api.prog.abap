*&---------------------------------------------------------------------*
*& Report ZGET_MDG_STAGING_API
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZGET_MDG_STAGING_API.

DATA : lr_gov_api type ref to IF_USMD_CONV_SOM_GOV_API,
       lrs_data       TYPE REF TO data,
       ls_entity_key  TYPE usmd_gov_api_s_ent_tabl,
       lt_entity_key  TYPE usmd_gov_api_ts_ent_tabl,
       ls_entity_data TYPE usmd_gov_api_s_ent_tabl,
       lt_entity_data TYPE usmd_gov_api_ts_ent_tabl.

FIELD-SYMBOLS:
      <lt_ent_data> TYPE ANY TABLE,
      <ls_ent_data> TYPE any,
      <ls_key>      TYPE any,
      <ls_field>    TYPE any,
      <material>    TYPE matnr.

"lr_gov_api = cl_usmd_conv_som_gov_api=>get_instance( IV_MODEL_NAME = 'MM').

lr_gov_api = cl_usmd_conv_som_gov_api=>get_instance( IV_MODEL_NAME = '0G').
lr_gov_api->set_environment( iv_crequest_id = '934' ).

"ls_entity_key-entity = 'MATERIAL'.
ls_entity_key-entity = 'PCTR'.
lr_gov_api->get_entity_structure(
 EXPORTING
   iv_entity_name = ls_entity_key-entity
   iv_struct_type = lr_gov_api->gc_struct_key
 IMPORTING
   er_table = ls_entity_key-tabl ).

ASSIGN ls_entity_key-tabl->* TO <lt_ent_data>.
CREATE DATA lrs_data LIKE LINE OF <lt_ent_data>.
ASSIGN lrs_data->* TO <ls_ent_data>.

ASSIGN COMPONENT 'COAREA' OF STRUCTURE <ls_ent_data> TO FIELD-SYMBOL(<coarea>).
ASSIGN COMPONENT 'PCTR' OF STRUCTURE <ls_ent_data> TO FIELD-SYMBOL(<pctr>).

<coarea> = 'KR01'.
<pctr> = 'PCK04-01'.

*ASSIGN COMPONENT 'MATERIAL' OF STRUCTURE <ls_ent_data> TO <material>.
*<material> = '$1551'.
*
INSERT <ls_ent_data> INTO TABLE <lt_ent_data>.
INSERT ls_entity_key INTO TABLE lt_entity_key.

lt_entity_data[] = lr_gov_api->read_entity_data(
it_entity_keys = lt_entity_key[]
if_active_data = abap_false
 ).

BREAK-POINT.
