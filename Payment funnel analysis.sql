WITH max_statusreached as (SELECT  SubscriptionID, 
								    MAX(StatusID) as maxstatus
									FROM paymentstatuslog 
									Group By SubscriptionID
                                                ),
paymentfunnelstage as (SELECT SubscriptionID,
                                           case when maxstatus = 1 then 'PaymentWidgetOpened'
                                                     when maxstatus = 2 then 'PaymentEntered'
        when maxstatus = 3 and currentstatus = 0 then 'User Error with Payment Submission'
        when maxstatus = 3 and currentstatus != 0 then 'Payment Submitted'
        when maxstatus = 4 and currentstatus = 0 then 'Payment Processing Error with Vendor'
        when maxstatus = 4 and currentstatus != 0 then 'Payment Success'
        when maxstatus = 5 then 'Complete'
        when maxstatus is null then 'User did not start payment process'
        end as paymentfunnelstage
FROM Subscriptions subs
LEFT JOIN   Max_statusreached m
on subs.SubscriptionID = m.SubscriptionID
)
SELECT paymentfunnelstage, 
COUNT(SubscriptionID)
FROM paymentfunnelstage
GROUP By paymentfunnelstage 
;
