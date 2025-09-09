set @start_date = '2024-01-01';
set @end_date = '2024-12-31';

select
	dc.medical_condition,
	SUM(fa.length_of_stay) as total_bed_days,
	count(*) as admissions
from hospital.fact_admissions as fa
join hospital.dim_condition as dc
	on dc.medical_condition = fa.medical_condition
join hospital.dim_date as dd
	on dd.date_sk = fa.admit_date_sk
where dd.full_date between @start_date and @end_date
group by dc.medical_condition
order by total_bed_days desc;


