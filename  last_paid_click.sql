with tab as(
	select distinct on (visitor_id)
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
