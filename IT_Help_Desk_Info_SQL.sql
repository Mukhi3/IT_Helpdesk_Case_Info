--solution 1
--start
select avg(datediff(minute,case_sent_time,case_resolution_time)) as avg_resolution_time_minutes
from it_help_desk_case_info
where  case_resolution_time is not null;
--end


--solution 2
--start
with agenttimes as (
select service_agent_id,avg(datediff(minute,case_sent_time,case_resolution_time)) as avg_resolution_time
from it_help_desk_case_info
where case_resolution_time is not null
group by service_agent_id),
overallavg as(
select avg(datediff(minute,case_sent_time,case_resolution_time)) as overall_avg_time
from it_help_desk_case_info
where case_resolution_time is not null
)
select a.service_agent_id,a.avg_resolution_time
from agenttimes a
join
overallavg o
on a.avg_resolution_time>o.overall_avg_time;
--end


--solution 3
--start
select cast(count(
case 
  when satisfaction_score>=4 
  then 1
  end)*100.0/count(*) as decimal(5,2)) as high_rated_percentage
  from customer_satisfaction
  where satisfaction_score is not null;
--end

--solution 4
--start
select service_agent_id,avg(datediff(minute,case_sent_time,case_resolution_time)) as avg_resolution_time,
rank()over(order by avg(datediff(minute,case_sent_time,case_resolution_time))asc) as resolution_speed_rank
from it_help_desk_case_info
where case_resolution_time is not null
group by service_agent_id;
--end

--solution 5
--start

with weeklycases as(
select datepart(year,case_sent_time)as years, datepart(week,case_sent_time) as weeks,
service_agent_id,count(*) as cases_handled
from it_help_desk_case_info
where case_sent_time is not null 
group by datepart(year,case_sent_time), datepart(week,case_sent_time),
service_agent_id),
rankedcases as(
select *, dense_rank()over(partition by years,weeks order by cases_handled desc)
as agentrank
from weeklycases
)
select years,weeks,service_agent_id,cases_handled,agentrank
from rankedcases
where agentrank<=5
order by years,weeks,agentrank;

--end