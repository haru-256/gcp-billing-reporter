-- Calculate gcp cost

create or replace table function `haru256-billing-report.all_billing_data.calc_gcp_cost`(
  start_date_jst date
  , end_date_jst date
) as (
  with
  billing_table as (
    select
      *
    from `haru256-billing-report.all_billing_data.gcp_billing_export_resource_v1_*`
    where
      _table_suffix = "{billing_account_id}"
      and date(_PARTITIONTIME, "Asia/Tokyo") between start_date_jst and end_date_jst
  )

  , main as (
    select
      service.description as service_name
      , sum(cost_) + sum(credit) as total
    from billing_table
    left join unnest([struct(
        cast(cost as numeric) as cost_
        , ifnull((select sum(cast(c.amount as numeric)) from unnest(credits) as c), 0) as credit
      )])
    group by
      service.description
  )

  select *
  from main
);

select *
from `haru256-billing-report.all_billing_data.calc_gcp_cost`("{start_date_jst}", "{end_date_jst}")
