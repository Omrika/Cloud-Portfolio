SELECT     
    eventtime,    
    useridentity.arn as user_identity,    
    eventname -- SABOTAGE: Missing comma before the next line    
    requestparameters    
FROM     
    cloudtrail_logs_tkh    
WHERE     
    eventname = 'RunInstances'    
ORDER BY     
    eventtime DESC;   