SELECT
    visit_date,
    utm_source,
    utm_medium,
    utm_campaign,
    ROUND(total_cost / visitors_count, 2) AS cpu,
    ROUND(total_cost / leads_count, 2) AS cpl,
    ROUND(total_cost / purchases_count, 2) AS cppu,
    ROUND((revenue - total_cost) / total_cost * 100, 2) AS roi
FROM agg_last_click_all
--Рассчет основных метрик (таблица)

SELECT
    visit_date AS visit_date,
    utm_source AS utm_source,
    AVG(visitors_count) AS "AVG(visitors_count)"
FROM main.agg_last_click_all
GROUP BY
	visit_date,
    utm_source
ORDER BY AVG(visitors_count) DESC
LIMIT
	10000
	OFFSET 0
--Средняя посещаемость по каналам

SELECT
	visit_date AS visit_date,
    AVG(visitors_count) AS "AVG(visitors_count)"
FROM main.agg_last_click_all
GROUP BY visit_date
ORDER BY "AVG(visitors_count)" DESC
LIMIT 5000
OFFSET 0
--Средняя посещаемость за июнь

SELECT
	utm_source AS utm_source,
    sum(total_cost) AS "SUM(total_cost)"
FROM main.agg_last_click_all
WHERE utm_source IN ('yandex',
                     'vk')
GROUP BY utm_source
ORDER BY "SUM(total_cost)" DESC
LIMIT 10000
OFFSET 0
--Затраты на рекламу по источнику

SELECT
	utm_source AS utm_source,
    sum(leads_count) AS "SUM(leads_count)"
FROM main.agg_last_click_all
GROUP BY utm_source
ORDER BY "SUM(leads_count)" DESC
LIMIT 100
OFFSET 0
--Количество лидо приведенных из каналов

SELECT
	utm_source AS utm_source,
    AVG(cpl) AS "AVG(cpl)"
FROM
  (SELECT
		visit_date,
        utm_source,
        utm_medium,
        utm_campaign,
        total_cost / visitors_count cpu,
        total_cost / leads_count cpl,
        total_cost / purchases_count cppu,
        (revenue - total_cost) / total_cost * 100 roi
   from 'agg_last_click_all') AS virtual_table
GROUP BY utm_source
ORDER BY "AVG(cpl)" DESC
LIMIT 100
OFFSET 0
--Цена привлечения одного потенциального клиента с конкретной рекламной кампании

SELECT
	utm_source AS utm_source,
    AVG(roi) AS "AVG(roi)"
FROM
  (SELECT
		visit_date,
        utm_source,
        utm_medium,
        utm_campaign,
        otal_cost / visitors_count cpu,
        total_cost / leads_count cpl,
        total_cost / purchases_count cppu,
        (revenue - total_cost) / total_cost * 100 roi
   from 'agg_last_click_all') AS virtual_table
GROUP BY utm_source
ORDER BY "AVG(roi)" DESC
LIMIT 10000
OFFSET 0
--Среднее значение ROI по источнику и компании

with tab AS (
	SELECT
		s.visitor_id,
		min(s.visit_date::date) AS first_visit,
		l.created_at::date AS lead_first
	FROM sessions s
	JOIN leads l ON l.visitor_id = s.visitor_id
	GROUP BY 1, 3
	ORDER BY 1
)
SELECT
	avg(lead_first - first_visit)
FROM tab;
--Среднее время от визита до становления лидом
