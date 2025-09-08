SET @start_date = '2024-01-01';
SET @end_date   = '2024-12-31';
SET @condition  = 'Arthritis';
SET @admission_type = 'Emergency';

SELECT
  s.admission_type,
  s.admissions,
  ROUND(s.admissions / ((DATEDIFF(@end_date,@start_date)+1)/7.0), 2) AS admissions_per_week,
  s.p90_los                                   AS p90_current,
  sc.reduction_pct,
  CONCAT(ROUND(sc.reduction_pct*100), '%')     AS reduction_label,
  ROUND(s.p90_los * (1 - sc.reduction_pct),0)  AS p90_target_days,
  ROUND(
    (s.admissions / ((DATEDIFF(@end_date,@start_date)+1)/7.0)) * (s.p90_los * sc.reduction_pct),
    1
  ) AS bed_days_freed_per_week
FROM (
  SELECT
    COALESCE(NULLIF(TRIM(t.admission_type),''), 'unknown') AS admission_type,
    COUNT(*)                                              AS admissions,
    MIN(CASE WHEN cume >= 0.90 THEN t.length_of_stay END) AS p90_los
  FROM (
    SELECT
      fa.admission_type,
      fa.length_of_stay,
      CUME_DIST() OVER (
        PARTITION BY COALESCE(NULLIF(TRIM(fa.admission_type),''), 'unknown')
        ORDER BY fa.length_of_stay
      ) AS cume
    FROM hospital.fact_admissions fa
    JOIN hospital.dim_date dd
      ON dd.date_sk = fa.admit_date_sk
    WHERE dd.full_date BETWEEN @start_date AND @end_date
      AND fa.medical_condition = @condition
      AND fa.admission_type    = @admission_type
  ) t
  GROUP BY COALESCE(NULLIF(TRIM(admission_type),''), 'unknown')
) AS s
CROSS JOIN (
  SELECT 0.10 AS reduction_pct
  UNION ALL SELECT 0.15
  UNION ALL SELECT 0.20
) AS sc
ORDER BY sc.reduction_pct;
