with tab as (
    select
        s.visitor_id,
        l.closing_reason,
        s."source" as utm_source,
        s.medium as utm_medium,
        s.campaign as utm_campaign,
        l.lead_id,
        l.amount,
        l.created_at,
        l.status_id,
        date(s.visit_date) as visit_date,
        row_number()
        over (partition by s.visitor_id order by s.visit_date desc)
        as rn
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
),

tab_2 as (
    select
        campaign_date::date,
        utm_source,
        utm_medium,
        utm_campaign,
        sum(daily_spent) as daily_spent
    from vk_ads
    group by
        campaign_date::date,
        utm_source,
        utm_medium,
        utm_campaign
    union all
    select
        campaign_date::date,
        utm_source,
        utm_medium,
        utm_campaign,
        sum(daily_spent) as daily_spent
    from ya_ads
    group by
        campaign_date::date,
        utm_source,
        utm_medium,
        utm_campaign
)

select
    a.visit_date,
    a.utm_source,
    a.utm_medium,
    a.utm_campaign,
    b.daily_spent as total_cost,
    count(*) as visitors_count,
    count(*) filter (where a.lead_id is not null) as leads_count,
    count(*) filter (where a.status_id = 142) as purchases_count,
    coalesce(sum(a.amount) filter (where a.status_id = 142), 0) as revenue
from tab as a
left join tab_2 as b
    on
        a.utm_source = b.utm_source
        and a.utm_medium = b.utm_medium
        and a.utm_campaign = b.utm_campaign
        and a.visit_date = b.campaign_date
where a.rn = 1
group by
    a.visit_date,
    a.utm_source,
    a.utm_medium,
    a.utm_campaign,
    b.daily_spent
order by
    revenue desc nulls last,
    a.visit_date asc,
    visitors_count desc,
    a.utm_source asc,
    a.utm_medium asc,
    a.utm_campaign asc
limit 15;
--топ 15: витрина с расходами на рекламу по модели атрибуции Last Paid Click.
