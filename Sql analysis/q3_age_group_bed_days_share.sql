set @start_date = '2024-01-01';
set @end_date = '2024-12-31';
set @condition = 'Arthritis';
set @admission_type = 'Emergency';
select
	g.age_group,
    g.bed_days,
    g.admissions,
    round(100 * g.bed_days / SUM(g.bed_days) over (), 1) as share_pct
from (
select
	coalesce(nullif(trim(dp.age_group),''), 'unknown') as age_group,
    sum(fa.length_of_stay) as bed_days,
    count(*) as admissions
from hospital.fact_admissions fa
join hospital.dim_date dd
	on dd.date_sk = fa.admit_date_sk
join hospital.dim_patient dp
	on dp.patient_id = fa.patient_id
where dd.full_date between @start_date and @end_date
	and fa.medical_condition = @condition
    and fa.admission_type = @admission_type
    group by coalesce(nullif(trim(dp.age_group),''), 'unknown')
    ) g
    order by share_pct desc, g.bed_days desc;
    