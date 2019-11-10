global class VSPR2_GetPropensityScores{
    @InvocableMethod
    public static List<Results> getPropensityScores(List<Requests> requests){
        Results curResult = new Results();
        List<Results> resultsList = new List<Results>();
        
        List<PropensityScores__c> pScores = [SELECT Id, Case__c, Classification__c, Code__c, Confidence__c, ConsumerId__c, Name, PersonAccount__c, Priority__c, Reason__c,Time_Span_Begin__c,Time_Span_End__c
                                            FROM PropensityScores__c WHERE Case__c =: requests[0].caseIdSB];
        
        List<Propensity_Score_Management__mdt> IPpsm = [SELECT Channel__c,Customer__c,Priority__c,States__c,Time_Span_Begin__c,Time_Span_End__c FROM Propensity_Score_Management__mdt WHERE DeveloperName = 'IP' LIMIT 1];
        
        if(pScores.isEmpty()){ //if there are no scores associated to this case, call out to Consumer db and get scores
            Case caseRec = [SELECT id, accountId, member_Plan__c, consumer_Id__c, ContactId
                            FROM Case WHERE id =: requests[0].caseIdSB]; 
    
            MemberPlan mp = [SELECT ID, ConsumerId__c, Division_Id__c, Client_Id__c, PrimarymemberConsumerId__c
                             FROM MemberPlan WHERE id =: caseRec.member_Plan__c];
        
            ID personAcctId = caseRec.accountId;
            String jsonString='{"consumerId":"'+caseRec.consumer_ID__c+'","primaryMemberConsumerId":"'+mp.primaryMemberConsumerId__c+'","divIds":"'+mp.division_id__c+'","clientIds":"'+ mp.client_Id__c+'"}';
            
            HTTPResponse memResp = new HttpResponse();
            memResp = VSPR2_GetPropensityCallOut.getConsumerAPIResponse(jsonString);
            
            List<PropensityScores__c> propList = new List<PropensityScores__c>();
            
            if (memResp.getStatusCode() == 200){   
                Map<String,Object> entities = (Map<String,Object>)JSON.deserializeUntyped(memResp.getbody());
                Map<String,Object> entityResults = (Map<String,Object>)entities.get('entity');     
                List<Object>consumerResults = (List<Object>)entityResults.get('consumers');
                
                if(consumerResults != null){
                	Integer i=0;
                    Map<String,Object> subscriber;
                    
                    List<ConsumerSeachResults__c> csResultsList = new List<ConsumerSeachResults__c>();  //This is where we save the Search results from API
                    ConsumerSeachResults__c csResult;
                    
                    for(Object consumer:consumerResults){
                        subscriber = (Map<String,Object>)consumer;
                        
                        if(subscriber.keyset().contains('propensityScores')){
                            List<Object> propListAPI = (List<Object>)subscriber.get('propensityScores');                  
                            PropensityScores__c propRec = new PropensityScores__c();
                            Map<String,Object> propMap = new Map<String,Object>();
                            for(object p:propListAPI){  
                                propMap = (Map<String,Object>)p;
                                propRec = new PropensityScores__c();
                                propRec.consumerId__c = ''+ propMap.get('consumerId');
                                propRec.code__c = (String)propMap.get('code');
                                propRec.priority__c = ''+ propMap.get('priority');
                                propRec.classification__c = (String)propMap.get('classification');
                                propRec.confidence__c = (String)propMap.get('confidence');
                                propRec.reason__c = (String)propMap.get('reason');
                                propRec.PersonAccount__c = personAcctId;
                                propRec.Case__c = requests[0].caseIdSB;
                                propList.add(propRec);
                            }
                        }
                    }
                    
                    if(propList != null && propList.size() >0){
                        insert propList;
                        
                        List<PropensityScores__c> propSearch = [SELECT Case__c,Channel__c,Classification__c,Code__c,Confidence__c,ConsumerId__c,Id,Name,Offer_To__c,
                                                                PersonAccount__c,Priority__c,Propensity_Priority__c,Reason__c,Time_Span_Begin__c,Time_Span_End__c
                                                                FROM PropensityScores__c WHERE Case__c =: requests[0].caseIdSB];
                        
                        if(!propSearch.isEmpty()){
                            for(PropensityScores__c pss: propSearch){ 
                                if(pss.Code__c == 'IP' && IPpsm.size()>0){
                                    if(pss.Priority__c == '1'){
                                    	pss.Propensity_Priority__c = 'High';
                                    }else if(pss.Priority__c == '2')
                                        pss.Propensity_Priority__c = 'Medium';
                                    else{
                                        pss.Propensity_Priority__c = 'Low';
                                    }
                                    pss.Offer_To__c = IPpsm[0].Customer__c;
                                    pss.Channel__c = IPpsm[0].Channel__c;
                                    pss.Time_Span_Begin__c = IPpsm[0].Time_Span_Begin__c;
                                    pss.Time_Span_End__c = IPpsm[0].Time_Span_End__c;
                                    curResult.IPCode = 'IP';
                                    curResult.IPClassification = pss.Classification__c;
                                    curResult.IPConfidence = pss.Confidence__c;
                                    curResult.IPReason = pss.Reason__c;
                                }
                            }
                            update propSearch;
                        }
                        
                        if(!string.isEmpty(curResult.IPCode)){
                            resultsList.add(curResult);
                        }
                    }
                }
            }
        }
        else{ //scores exist on the case
            Boolean pScoreUpdate = false;
            for(PropensityScores__c pScore:pScores){
                if(pScore.Code__c == 'IP'){
                    curResult.IPCode = 'IP';
                    curResult.IPClassification = pScore.Classification__c;
                    curResult.IPConfidence = pScore.Confidence__c;
                    curResult.IPReason = pScore.Reason__c;
                    pScore.Offer_To__c = IPpsm[0].Customer__c;
                    pScore.Channel__c = IPpsm[0].Channel__c;
                    pScore.Time_Span_Begin__c = IPpsm[0].Time_Span_Begin__c;
                    pScore.Time_Span_End__c = IPpsm[0].Time_Span_End__c;
                    pScoreUpdate = true;
                }
            }  
            
            if(pScoreUpdate){
                update pScores;
            }
            
			if(!string.isEmpty(curResult.IPCode)){
            	resultsList.add(curResult);
            }
        }
        
        if(!resultsList.isEmpty()){
            return resultsList;
        }
        else{
            curResult.propensityScoreFieldIP = 'No Offer';
            resultsList.add(curResult);
            return resultsList;
        }
    }
    
    global class Requests{
        @InvocableVariable
        global String caseIdSB;
    }
    
    global class Results{
        @InvocableVariable
        global String propensityScoreFieldIP;
        @InvocableVariable
        global String IPCode;
        @InvocableVariable
        global String IPClassification;
        @InvocableVariable
        global String IPConfidence;
        @InvocableVariable
        global String IPReason;
    }
}