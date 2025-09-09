set @start_date = "2024-01-01";
set @end_date = "2024-12-31";
set @condition = "Arthritis";
set @min_n = 20;

select
	t.admission_type,
	count(*) as admissions,
	min(case when t.cume >= 0.50 then t.los end) as median_los,
	min(case when t.cume >= 0.90 then t.los end) as p90_los
from(
	select
		COALESCE(NULLIF(TRIM(fa.admission_type), ''), 'unknown') as admission_type,
		fa.length_of_stay as los,
		CUME_DIST() OVER(
			partition by COALESCE(NULLIF(TRIM(fa.admission_type), ''), 'unknown')
			order by fa.length_of_stay
		) as cume
	from hospital.fact_admissions fa
	join hospital.dim_date dd
		on dd.date_sk  = fa.admit_date_sk
		where dd.full_date between @start_date and @end_date
		and fa.medical_condition = @condition
) as t
group by t.admission_type
having count(*) >= @min_n
order by p90_los desc, admissions desc;