with tab as (
    select distinct on (visitor_id)
        s.visitor_id,
        visit_date,
        s."source" as utm_source,
        s.medium as utm_medium,
        s.campaign as utm_campaign,
        lead_id,
        created_at,
        amount,
        closing_reason,
        status_id
    from sessions as s
    left join
        leads as l
        on s.visitor_id = l.visitor_id and s.visit_date <= l.created_at
    where
        s.medium in (
            'cpc',
            'cpm',
            'cpa',
            'youtube',
            'cpp',
            'tg',
            'social'
        )
    order by visitor_id asc, visit_date desc
)

select *
from tab
order by
    amount desc nulls last,
    visit_date asc,
    utm_source asc,
    utm_medium asc,
    utm_campaign asc
limit 10;
--топ 10 лидов по модели аттрибуции Last Paid Click
