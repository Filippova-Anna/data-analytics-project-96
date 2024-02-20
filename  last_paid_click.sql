WITH last_paid_click AS (
    SELECT
        s.visitor_id,
        MAX(s.visit_date) AS last_click_date
    FROM sessions s
    JOIN
        (SELECT
                l.visitor_id,
                MAX(s.visit_date) AS last_lead_date
            from sessions s
            join leads l ON s.visitor_id = l.visitor_id
            GROUP by l.visitor_id
        ) AS last_lead_click ON s.visitor_id = last_lead_click.visitor_id
    where s.visit_date <= last_lead_click.last_lead_date
        AND s.source IN ('cpc', 'cpm', 'cpa', 'youtube')
    GROUP by s.visitor_id
)
SELECT
    s.visitor_id,
    s.visit_date,
    s.source AS utm_source,
    s.medium AS utm_medium,
    s.campaign AS utm_campaign,
    l.lead_id,
    l.created_at,
    l.amount,
    l.closing_reason,
    l.status_id
from sessions s
LEFT join leads l ON s.visitor_id = l.visitor_id
LEFT join last_paid_click lpc ON s.visitor_id = lpc.visitor_id
    AND s.visit_date = lpc.last_click_date
ORDER BY
    COALESCE(l.amount, -1) DESC,
    s.visit_date ASC,
    utm_source ASC,
    utm_medium ASC,
    utm_campaign asc
   limit 10;
 --топ 10 лидов по модели аттрибуции Last Paid Click

  
with tab as(
	select
		distinct on (visitor_id)
		s.visitor_id,
		visit_date::date,
		s."source" as utm_source,
		s.medium as utm_medium,
		s.campaign as utm_campaign,
		lead_id,
		created_at,
		amount,
		closing_reason,
		status_id
	from sessions s
	left join leads l on l.visitor_id = s.visitor_id and l.created_at >= s.visit_date
	where s.medium in(
		'cpc',
		'cpm',
		'cpa',
		'youtube')
	order by visitor_id, visit_date desc
)
select *
from tab
order by amount desc nulls last, visit_date, utm_source, utm_medium, utm_campaign
limit 10;
--топ 10 лидов по модели аттрибуции Last Paid Click