-- Рассчет основных метрик (таблица)
SELECT
    visit_date,
    utm_source,
    utm_medium,
    utm_campaign,
    ROUND(total_cost / visitors_count, 2) AS cpu,
    ROUND(total_cost / leads_count, 2) AS cpl,
    ROUND(total_cost / purchases_count, 2) AS cppu,
    ROUND((revenue - total_cost) / total_cost * 100, 2) AS roi
FROM agg_last_click_all;

-- Средняя посещаемость по каналам
SELECT
    visit_date,
    utm_source,
    AVG(visitors_count) AS avg_visitors_count
FROM main.agg_last_click_all
GROUP BY
    visit_date,
    utm_source
ORDER BY AVG(visitors_count) DESC;

-- Средняя посещаемость за июнь
SELECT
    visit_date,
    AVG(visitors_count) AS avg_visitors_count
FROM main.agg_last_click_all
WHERE EXTRACT(MONTH FROM visit_date) = 6
GROUP BY visit_date
ORDER BY AVG(visitors_count) DESC;

-- Затраты на рекламу по источнику
SELECT
    utm_source,
    SUM(total_cost) AS sum_total_cost
FROM main.agg_last_click_all
WHERE utm_source IN ('yandex', 'vk')
GROUP BY utm_source
ORDER BY sum_total_cost DESC;

-- Количество лидов, приведенных из каналов
SELECT
    utm_source,
    SUM(leads_count) AS sum_leads_count
FROM main.agg_last_click_all
GROUP BY utm_source
ORDER BY sum_leads_count DESC;

-- Цена привлечения одного потенциального клиента с рекламной кампании
SELECT
    utm_source,
    AVG(cpl) AS avg_cpl
FROM (
    SELECT
        utm_source,
        total_cost / leads_count AS cpl
    FROM main.agg_last_click_all
) AS virtual_table
GROUP BY utm_source
ORDER BY avg_cpl DESC;

-- Среднее значение ROI по источнику и компании
SELECT
    utm_source,
    AVG(roi) AS avg_roi
FROM (
    SELECT
        utm_source,
        (revenue - total_cost) / total_cost * 100 AS roi
    FROM main.agg_last_click_all
) AS virtual_table
GROUP BY utm_source
ORDER BY avg_roi DESC;

-- Среднее время от визита до становления лидом
WITH tab AS (
    SELECT
        sessions.visitor_id,
        leads.created_at::date AS lead_first,
        MIN(sessions.visit_date::date) AS first_visit
    FROM sessions
    INNER JOIN leads ON sessions.visitor_id = leads.visitor_id
    GROUP BY sessions.visitor_id, leads.created_at
)

SELECT AVG(lead_first - first_visit) AS average_time_to_lead
FROM tab;
