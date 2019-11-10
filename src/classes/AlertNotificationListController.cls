public class AlertNotificationListController {
    public static final String Alert_Author_Permission_Set='Alert_Author_Permission_Set';
	public static final String PRIMARY_MEMBER_INDICATOR='M';
	public static final String PRIMARY_MEMBER='\'PrimaryMember\'';
	public static final String DEPENDENT='\'Dependent\'';
	
    @AuraEnabled
    public static List<Alerts_and_Notification__c> getAlertList(String recordId){
        List<Alerts_and_Notification__c> alertList = new List<Alerts_and_Notification__c>();
        //Fetch case record for accountid
        Case caseRecord ;
        //To store all status from Member plan
        Set<String> statusSet = new Set<String>();
        //To store all Division from Member plan
        String divisionId ;
		//To store all Division from Member plan
        String clientId ;
        //To store all Alert Ids
        Set<Id> alertIdSet = new Set<Id>();
        //to store the remove alert ids for the case
        Set<Id> removeAlertIdSet = new Set<Id>();
        
        for(Case record : [select AccountId,IVR_Call_Type__c,(SELECT Id, Alerts_and_Notifications__c, Case__c from CaseAlertJunction__r),Account.Member_Status__c,Account.Consumer__c, Division__c,Member_Plan__c from Case where Id=:recordId ]){
            caseRecord = record;
            for(CaseAlertJunctionObject__c objRec : record.CaseAlertJunction__r)
                removeAlertIdSet.add(objRec.Alerts_and_Notifications__c);
        }
        
        if(caseRecord.AccountId!=null){
            if(caseRecord.Account.Member_Status__c!=null)
                statusSet.add(caseRecord.Account.Member_Status__c);
        }
        String consumerString='\'\'';
		String statusString;
        if(caseRecord.Member_Plan__c != null){
            for(MemberPlan mPlan: [select Client_ID__c,Division_ID__c,MemberId,Relation__c,Member.Member_Status__c,Member.Consumer__c,ClientStatus__c from MemberPlan where (Id=:caseRecord.Member_Plan__c ) ]){
                //,(SELECT Alerts_and_Notifications__c FROM Alert_Division_Id_Criteria__r)
                //if(mPlan.Member.Member_Status__c!=null)
				//statusSet.add(mPlan.ClientStatus__c);
				
				//Collect Client Id
				if(!String.isEmpty(mPlan.Client_ID__c))
					clientId = mPlan.Client_ID__c;
				
				//Collect Division Id
				if(!String.isEmpty(mPlan.Division_ID__c))
					divisionId=mPlan.Division_ID__c;
				
				//Collect Relation Id for checking with Alert's Consumer
				if(!String.isEmpty(mPlan.Relation__c)){
					if(mPlan.Relation__c == PRIMARY_MEMBER_INDICATOR)
						consumerString =PRIMARY_MEMBER;
					else
						consumerString = DEPENDENT;
				}
				statusString =mPlan.ClientStatus__c!=null ? mPlan.ClientStatus__c: '';
                
            }
        }
        System.debug('clientId:'+clientId+' divisionId:'+divisionId);
		System.debug('consumerString:'+consumerString+' statusString:'+statusString);
        
        System.debug('caseRecord.IVR_Call_Type__c:'+caseRecord.IVR_Call_Type__c);
        
        //Build new strings to store values to use as one string for the Database query
        String baseSQL = 'SELECT Id, Name, Alert_Message__c, Alert_Begins__c, Status__c,' 
                         + 'Alert_Ends__c, Member_Status__c, Alert_Description__c, Call_Type__c, Consumer__c, '
						 + '(SELECT Id, DivisionID__c, ClientID__c, Alert__c FROM Alert_ID_Criterion__r) '
                         + 'FROM Alerts_and_Notification__c WHERE ';
        String callType = '';
        String memStat = '';
        String alertStatus ='Published';
        String endSQL = 'Order By Priority__c,CreatedDate LIMIT 50000';
        String query='';
        Boolean isValidQuery= false;
        if(recordId!=null){
            //Check the case record and build the SQL query string based on it.
            baseSQL += 'Status__c =:alertStatus AND (';
            if(!removeAlertIdSet.isEmpty()){
                baseSQL += 'Id NOT IN: removeAlertIdSet AND ';
                System.debug('baseSQL1: ' + baseSQL);
                isValidQuery =true;
            }
            //if(caseRecord.IVR_Call_Type__c != null){
                callType = caseRecord.IVR_Call_Type__c!=null ? caseRecord.IVR_Call_Type__c : '' ;
                baseSQL += 'Call_Type__c INCLUDES (' + '\''+ callType + '\'' + ') AND ';
                System.debug('baseSQL1: ' + baseSQL);
                isValidQuery =true;
            //}
            //if(caseRecord.Account.Member_Status__c != null){
                memStat = statusString;
                baseSQL += 'Member_Status__c INCLUDES (' + '\'' + memStat + '\''  + ') AND ';
                System.debug('baseSQL2: ' + baseSQL);
                isValidQuery =true;
            //}
            //if(consumerString != null){
				consumerString = consumerString!=null ? consumerString: '';
                baseSQL += 'Consumer__c INCLUDES ('  + consumerString  + ') AND ';
                System.debug('baseSQL3: ' + baseSQL);
				isValidQuery =true;
            //}
             if(baseSQL.endsWith(' AND (')){
                baseSQL = query = baseSQL.removeEnd(' AND (');
            }else if(baseSQL.endsWith(' OR (')){
                baseSQL = query = baseSQL.removeEnd(' OR (')+')';
            }else if(baseSQL.endsWith(' AND ')){
                baseSQL = query = baseSQL.removeEnd(' AND ');
                baseSQL = query = baseSQL+')';
            }
              
            baseSQL = baseSQL + ' ' + endSQL ;
            System.debug('baseSQL4: ' + baseSQL);
            if(isValidQuery)
                for(Alerts_and_Notification__c alert: Database.query(baseSQL)){
					//if list is empty then add
					if(alert.Alert_ID_Criterion__r.isEmpty())
						alertList.add(alert);
					//if list is not empty, check if client/div id is exist, then add
					else if(!alert.Alert_ID_Criterion__r.isEmpty()){
						for(Alert_ID_Criteria__c criteria : alert.Alert_ID_Criterion__r){
							if(criteria.ClientID__c==clientId  && criteria.DivisionID__c == divisionId)
								alertList.add(alert);
						}
					}
                }
        }    
        System.debug('alertList:'+alertList.size());
        return alertList; 
    }
	//To display the configured Client id and divisioin id on matching criteria
    @AuraEnabled
    public static String getClientAndDivisionIds(Id recordId){
        String result='';
        String result2='';
        for(Alert_ID_Criteria__c record:[SELECT Id, Alert__c, DivisionID__c,ClientID__c FROM Alert_ID_Criteria__c where Alert__c=:recordId]){
            if(!String.isEmpty(record.ClientID__c))
                result+=record.ClientID__c+';';
			if(!String.isEmpty(record.DivisionID__c))
				result2+=record.DivisionID__c+';';
        }
        result=result.removeEnd(';')+'$$$'+result2.removeEnd(';');
        return result;
    }
	//Remove the alerts when clicked on remove button
    @AuraEnabled
    public static List<Alerts_and_Notification__c> removeAlerts(Id alertId,Id recordId){
        insert new CaseAlertJunctionObject__c(Alerts_and_Notifications__c=alertId, Case__c =recordId);
        return getAlertList(recordId);
    }
	//To check the current user is an author user or not
    @AuraEnabled
    public static Boolean isAuthorUser(){
        Integer count=[SELECT count() FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name = :Alert_Author_Permission_Set ];
        return count>0;
    }
}