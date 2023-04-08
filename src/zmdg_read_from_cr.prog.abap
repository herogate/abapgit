*&---------------------------------------------------------------------*
*& Report ZMDG_READ_FROM_CR
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMDG_READ_FROM_CR.

   DATA lr_gov_api TYPE REF TO if_usmd_conv_som_gov_api.
     DATA : ls_entity_key  TYPE usmd_gov_api_s_ent_tabl,
      lt_entity_key  TYPE usmd_gov_api_ts_ent_tabl,
      ls_entity_data TYPE usmd_gov_api_s_ent_tabl,
      lt_entity_data TYPE usmd_gov_api_ts_ent_tabl,
      lrs_data       TYPE REF TO data,
             lt_object_dg   TYPE usmd_t_crequest_entity,
      lr_object_dg   TYPE REF TO usmd_s_crequest_entity.

   lr_gov_api = cl_usmd_conv_som_gov_api=>get_instance( 'MM' ).
   lr_gov_api->set_environment( iv_crequest_id = '5342' ).


   FIELD-SYMBOLS:
      <lt_ent_data> TYPE ANY TABLE,
      <ls_ent_data> TYPE any,
      <ls_key>      TYPE any,
      <ls_field>    TYPE any.

    lr_gov_api->get_object_list( IMPORTING et_object_list_db_style = lt_object_dg[] ).

      READ TABLE lt_object_dg REFERENCE INTO lr_object_dg
        WITH KEY usmd_entity = 'MATERIAL'.
      IF sy-subrc = 0.
        DATA(matnr) = lr_object_dg->usmd_value.

      ENDIF.


   ls_entity_key-entity = 'MATERIAL'.
   lr_gov_api->get_entity_structure( EXPORTING iv_entity_name = ls_entity_key-entity
                                               iv_struct_type = lr_gov_api->gc_struct_key
                                     IMPORTING er_table       = ls_entity_key-tabl ).

   ASSIGN ls_entity_key-tabl->* TO <lt_ent_data>.
      CREATE DATA lrs_data LIKE LINE OF <lt_ent_data>.
      ASSIGN lrs_data->* TO <ls_ent_data>.

   lt_entity_data[] = lr_gov_api->read_entity_data( it_entity_keys = lt_entity_key[] ).
