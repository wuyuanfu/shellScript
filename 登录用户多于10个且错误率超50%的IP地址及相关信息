---查询IP地址、错误率、错误登录客户数、正确登录客户数
select a1.ipaddr,a2.ErrPercent,a2.ErrInvestor,a2.NormalInvestor  from (
    select 
    substr(t1.usereventinfo,instr(t1.usereventinfo,'：',1,2)+1,instrc(t1.usereventinfo,'，',1,1)-instr(t1.usereventinfo,'：',1,2)-1) ipaddr,
    count(distinct(investorid)) loginSum 
    from historysettlement.t_brokeruserevent t1
    where t1.tradingday>=&BeginDay and t1.tradingday<=&EndDay
    and t1.usereventtype='1'
    group by substr(t1.usereventinfo,instr(t1.usereventinfo,'：',1,2)+1,instrc(t1.usereventinfo,'，',1,1)-instr(t1.usereventinfo,'：',1,2)-1)
    having count(distinct(investorid)) >= 10
    order by 2 DESC
)  a1,
(
        ---login err/normal*100 begin
        select y1.ipaddr,y2.ErrNum/y1.TotalNum*100 ErrPercent,y3.ErrInvestor,y4.NormalInvestor from
        (
          --- login total numbs begin
          select x1.ipaddr,count(*) TotalNum  from
          (
            select 
            substr(t1.usereventinfo,instr(t1.usereventinfo,'：',1,2)+1,instrc(t1.usereventinfo,'，',1,1)-instr(t1.usereventinfo,'：',1,2)-1) ipaddr,
            t1.investorid,t1.usereventinfo 
            from historysettlement.t_brokeruserevent t1
            where t1.tradingday>=&BeginDay and t1.tradingday<=&EndDay
            and t1.usereventtype='1'
          ) x1
        ---  where x1.ipaddr in ('115.236.165.19')
          group by x1.ipaddr
        ---login total numbs end 
        ) y1,
          ---err login numbs begin
        (  
          select x2.ipaddr,count(*) ErrNum  from
          (
            select 
            substr(t1.usereventinfo,instr(t1.usereventinfo,'：',1,2)+1,instrc(t1.usereventinfo,'，',1,1)-instr(t1.usereventinfo,'：',1,2)-1) ipaddr,
            t1.investorid,t1.usereventinfo 
            from historysettlement.t_brokeruserevent t1
            where t1.tradingday>=&BeginDay and t1.tradingday<=&EndDay
            and t1.usereventtype='1'
            and t1.usereventinfo like '用户登录失败：%'
            and t1.usereventinfo not like '%前置不活跃%'
            and t1.usereventinfo not like '%还没有初始化%'
          ) x2
        ---  where x2.ipaddr in ('19')
          group by x2.ipaddr
        ) y2,
        (  select 
            substr(t1.usereventinfo,instr(t1.usereventinfo,'：',1,2)+1,instrc(t1.usereventinfo,'，',1,1)-instr(t1.usereventinfo,'：',1,2)-1) ipaddr,
            count(distinct(investorid)) ErrInvestor 
            from historysettlement.t_brokeruserevent t1
            where t1.tradingday>=&BeginDay and t1.tradingday<=&EndDay
            and t1.usereventtype='1'
          group by substr(t1.usereventinfo,instr(t1.usereventinfo,'：',1,2)+1,instrc(t1.usereventinfo,'，',1,1)-instr(t1.usereventinfo,'：',1,2)-1)
          having count(distinct(investorid)) >= 10
         ) y3,
         
         (
         select 
            substr(t1.usereventinfo,instr(t1.usereventinfo,'：',1,2)+1,instrc(t1.usereventinfo,'，',1,1)-instr(t1.usereventinfo,'：',1,2)-1) ipaddr,
            count(distinct(investorid)) NormalInvestor 
            from historysettlement.t_brokeruserevent t1
            where t1.tradingday>=&BeginDay and t1.tradingday<=&EndDay
            and t1.usereventtype='1'
            and t1.usereventinfo like '用户登录：%'
          group by substr(t1.usereventinfo,instr(t1.usereventinfo,'：',1,2)+1,instrc(t1.usereventinfo,'，',1,1)-instr(t1.usereventinfo,'：',1,2)-1)
          having count(distinct(investorid)) >= 10
         ) y4
          ---err login numbs end
        where y1.ipaddr=y2.ipaddr
        and y1.ipaddr=y3.ipaddr
        and y2.ipaddr=y3.ipaddr
  ---      and y2.ErrNum/y1.TotalNum*100 >= 50   ---错误率超50%
        and y3.ipaddr=y4.ipaddr
        order by 2 DESC 
        ---login err/normal*100 end
) a2
where a1.ipaddr=a2.ipaddr
