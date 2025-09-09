set @start_date ='2024-01-01';
set @end_date = '2024-12-31';
set @condition = 'Arthritis';
set @admission_type = 'Emergency';
select
	g.admit_day_week,
    g.dow_num,
    g.admissions,
    g.bed_days_started,
    round(100 * g.admissions / sum(g.admissions) over (), 1) as admissions_share_pct,
    round(100 * g.bed_days_started / sum(g.bed_days_started) over (), 1) as bed_days_share_pct
from (
select
	dayname(dd.full_date) as admit_day_week,
    weekday(dd.full_date) as dow_num,
    count(*) as admissions,
    sum(fa.length_of_stay) as bed_days_started
from hospital.fact_admissions fa
join hospital.dim_date dd
	on dd.date_sk = fa.admit_date_sk
where dd.full_date between @start_date and @end_date
	and fa.medical_condition =@condition
    and fa.admission_type = @admission_type
group by admit_day_week, dow_num
) g
order by g.bed_days_started desc, g.admissions desc;
