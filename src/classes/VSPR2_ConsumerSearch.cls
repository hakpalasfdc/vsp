public class VSPR2_ConsumerSearch{ 
/*Controller for Consumer Search Visualforce Page
June 2019 Elly Bockley Eagle Creek
Check parameters user selected and call Consumer dB to get list of records that meet criteria
Save these records temporarily in ConsumerSeachRecords__c object in order to be able to do sorting 
Then when they select a record use the ConsumerID, primaryMemberConsumerID, divId, and clientId to get propensity scores
Need to use @future for Population Indicator and Strategic Alliance since cannot do a second call out with uncommitted records.
Changed dob and asofdate to be just simply text entered as mmddyyyy
*/    
    public Boolean refresh {get;set;}
    public String param1 { get; set; }
    public String contactId {get;set;}
    public String name { get; set; }
    public String firstname { get; set; }
    public String lastname { get; set; }
    public String midname { get; set; }
    public String relation { get; set; }
    public String divid { get; set; }
    public string classId {get;set;}
    public Boolean include { get; set; }
    public Boolean activeonly { get; set; }
    public Boolean remdob { get; set; }
    public String birthdate { get; set; }
    public String asofdate { get; set; }
    public String dob { get; set; }
    public String email { get; set; }
    public String city { get; set; }
    public String state { get; set; }
    public String last4 { get; set; }
    public Boolean tocase {get;set;}
    public String clientname { get; set; }
    public String clientid { get; set; }
    public String reason { get; set; }
    public String reasondetail { get; set; }
    public Boolean authenticated { get; set; }
    public String ConsumerId{get;set;} // Added By Shreya
    public String classification { get; set; }
    public string ciscoContactId{get;set;}
    public String callerintent { get; set; }
    public Static String callerintentText {get;set;}
    public String ivrcalltype { get; set; }
    public String callertype { get; set; }
    public String ANI {get;set;}
    public String DNIS{get;set;}
    public Case caseobj { get; set; }
    public String calltype { get; set; }
    public String subject { get; set; }
    public String callername { get; set; }
    public String policyid { get; set; }
    public String memberid { get; set; }
    public List<String> memberIDs { get; set; }
    public List<String> consumerIDs { get; set; }
    public List<String> auths { get; set; }
    public List<String> names { get; set; }
    public String auth { get; set; }
    public String phone { get; set; }
    public String Q { get; set; }
    public string caseId{get;set;}
    public string caseCreationStatus{get;set;}
    public String channel {get;set;}
    public Static String ccpURL {get;set;}
    public string consumerIdCCP {get;set;}
    
    public List<ConsumerSeachResults__c> csResultsList{get;set;}   
    public List<ConsumerSeachResults__c> searchResults{get;set;}
    public List<ConsumerSeachResults__c> csrDel{get; set;}
    public List<Account> Consumers { get; set; }
    public list<wrapcsr> wrapcsrList { get; set; }
    public string asofdateformatted {get; set;}
    public string asofdateformattedCCP {get; set;}
    public string dobformatted {get; set;}
    public string primaryMemberConsumerId {get; set;}
    public Set<string> consumerIdsInList= new Set<String>();
    
    private String soql {get;set;}
  
    public VSPR2_ConsumerSearch(ApexPages.StandardController controller) { 
         caseobj=new case();   

        // init the controller and display some sample data when the page loads
         soql = 'select Name__c,firstName__c, lastname__c,divid__c, Relation_to_Member__c, phone__c,effectiveDate__c,effectiveInDateFormat__c ,Consumer_Client_Status__c , coverageCode__c,email__c,dob__c,dob_display__c,dobForSort__c, City__c, State__c, ConsumerID__c, Client_Id__c, Client_Name__c,ConsClientDivIDs__c, strategicAlliance__c, primarymemberconsumerID__c,primaryMemberName__c, populationIndicator__c,TermDate__c from consumerseachresults__c where createdBy__c = '+ '\''+UserInfo.getUserId() +'\''  ;
         String asofdateformatted = System.today()+'';
         asofdateformatted = asofdateformatted.left(10);        
         asofdate=asofdateformatted.mid(5,2)+asofdateformatted.right(2)+asofdateformatted.left(4);
         asofdateFormattedCCP = asofdateformatted.left(4)+asofdateformatted.mid(5,2)+asofdateformatted.right(2);
         
         tocase = true;
         Q='';
         caseobj.callerType__c ='Member';
    }
    
    @RemoteAction 
    public static String getCCPURL(){
        ccpURL = CC_Portal__c.getValues('Environment').Base_URL__c;
        return ccpURL;
    } 
   
     public class wrapcsr{   
        public ConsumerSeachResults__c ccsr{get;set;}
        public boolean isSelected{get;set;}
         
           public wrapcsr(ConsumerSeachResults__c a){     
             ccsr=a;
             isselected=false;
           }
      }
 
    public void reset() {

            refresh = true;
            memberId = '';
            consumerId='';
            name='';
            clientname='';
            clientid='';
            divid='';
            firstname='';
            lastname='';
            birthdate = '';
            callerintent= '';
            calltype='';
            caseobj.callertype__c='Member';
            //callername='';
            caseobj.reason__C='';
            caseobj.Reason_Details__c = '';
            last4='';
            dob='';
            asofdate=null;
            state='';
            city='';
            phone='';
            auth='';
            email='';
            activeonly=false;
            remdob=false;
            include=true;
            String asofdateformatted = System.today()+'';
            asofdateformatted = asofdateformatted.left(10);
                   
            asofdate=asofdateformatted.mid(5,2)+asofdateformatted.right(2)+asofdateformatted.left(4);
            asofdateFormattedCCP = asofdateformatted.left(4)+asofdateformatted.mid(5,2)+asofdateformatted.right(2);
            
           //When they re-set I have to query records they created and then delete them
            csrDel=database.query(soql);
            if(csrDel != null && csrDel.size() >0){
                try{
                    Database.DeleteResult[] DR_Dels = Database.delete(csrDel);
                    }
                catch (Exception e) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error deleting = '+e));
                }
            }
            
           csResultsList=null;
           searchResults=null;
           wrapcsrList=null;
    }
    
    @RemoteAction    
    public static Pagereference finalReset(){

        string soql = 'select Id from consumerseachresults__c where createdBy__c = '+ '\''+UserInfo.getUserId() +'\''  ;
         
        List<ConsumerSeachResults__c> csrDel=database.query(soql);
            if(csrDel != null && csrDel.size() >0){
                try{
                    Database.DeleteResult[] DR_Dels = Database.delete(csrDel);
                    }
                catch (Exception e) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error deleting = '+e));
                }
            }
            
        return null;        
    }
    
    public PageReference setParams()
    {   
        return null;
    }
    
    public PageReference storeIVRparameters(){
        //Find the description of the caller intent code in the Caller Intent custom setting.
        List<Caller_Intent__c> cicList = Caller_Intent__c.getAll().values();
        for(Caller_Intent__c cic:cicList){
            if(cic.Code__c == callerintent){ 
                callerintentText = cic.Intent_Text__c;
            }
        }
        
        //If the call is authenticated, automatically perform the search.
        if(!string.isEmpty(consumerId)){
            APIsearchRecords();    
        }
        
        return null;
    }
    
    public PageReference setConsumerId(){
        
        return null;
    }
        
    private void APIQf(String s1, String s2) {
       if (!String.isBlank(s1)) {
           s1= s1.trim();
           s2=s2.trim();           
           Q = Q+',"'+s2+'":"'+s1+'"';
       }
    }
 
    public String callAPI()
    {
    String body;
    Map<String,Object> subscriber;
    
    Integer responseCode;
    if (!Test.isRunningTest()) {
       // String webServiceURL = DVIWebService__c.getInstance('DVI Values').DVI_Web_Service__c;
       // String tokenHeader = DVIWebService__c.getInstance('DVI Values').DVI_Token_Header__c;       
        String webServiceURL = Consumer_Search_Web_Service__c.getInstance('Consumer Search Values').Consumer_Search_Web_Service__c;
        String tokenHeader = Consumer_Search_Web_Service__c.getInstance('Consumer Search Values').Consumer_Search_Token_Header__c;
        String requestEndPoint=webServiceURL+'/as/token.oauth2';
        
        HttpRequest oauthReq = new HttpRequest(); 
        String access_token='';                  
    
        oauthReq.setEndpoint(requestEndPoint); 
        oauthReq.setMethod('POST');
        String authorizationHeader = 'Basic '+ tokenHeader; 
        oauthReq.setHeader('Accept', 'application/json');
        oauthReq.setHeader('Authorization', authorizationHeader); 
        oauthReq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
      
        oauthReq.setBody('grant_type=client_credentials&scope=read:vc.sfdc_consumer_exp');
        oauthReq.setTimeout(2 * 60 * 1000);
                           
        Http oauthHttp = new Http(); 
        HTTPResponse oauthResp = oauthHttp.send(oauthReq); //This just gets the access token   
                    
        String oauthRespJSON=oauthResp.getBody();
        
        JSONParser parser=JSON.createParser(oauthRespJSON);
        
               while(parser.nextToken()!=null){
                  if((parser.getCurrentToken()==JSONToken.FIELD_NAME)&&(parser.getText()=='access_token')){
                        parser.nextToken();
                        access_token+=parser.getText();
                         
                  }
               }     
                          
        HttpRequest memReq = new HttpRequest(); 
       
        String consumerIDEndPoint = webServiceURL+'/sfdc-consumer-exp/SFDCConsumers';
        memReq.setEndpoint(consumerIDEndPoint); 
        memReq.setMethod('POST');
        memReq.setHeader('Accept','application/json');
        memReq.setHeader('Content-Type','application/json');
        SYSTEM.DEBUG('### Q = '+ Q);
        string jsonBody='{'+Q+'}';
        memReq.setBody(jsonBody);
        
        String memHeaders = 'Bearer ' + access_token; 
        memReq.setHeader('Authorization', memHeaders); 
        
        Http memHttp = new Http(); 
        HTTPResponse memResp = new HttpResponse();
        memResp = memHttp.send(memReq);
        body = memResp.getbody();
     
        responseCode=memResp.getStatusCode();
  }
  else{
      //test running ned to create json body manually - use bogus name and consumerid
      body = '{"statusType":"OK","entity":{"consumers":[{"firstName":"ABCDEF","lastName":"GHIJKL","primaryMemberName":"ABCDEF GHIJKL","consumerId":"999999999","primaryMemberConsumerId":"312397511","clientId":"30023319","divId":"0061","expandedId":"U35696729","addresses":[{"street1":"14 MAIN ST","city":"ANYTOWN","stateCode":"MA","zipCode":"02771"}],"consumerStatus":"Active","clientStatus":"Active","clientDivisionStatus":"Active","coverageCode":"Member + Family",';
      body+='"clientName":"RBSELECT HEALTHPLAN (CIG VIS)","clientDivisionName":"ALL CITIZENS ACTIVE - FULL",';
      body+='"dependents":[{"firstName": "JKLM","lastName": "STUV","consumerId": "999999993","relationToMember": "S"}],';
      body+='"relationToMember":"M","primaryMemberConsumerId": "999999999","dateOfBirth":"19580816","phones":[{"number":"3366838","prefix":"508"}]}]},"entityType":"com.vsp.api.salesforce.consumerexperience.model.ConsumerExperienceSearchResult","status":200}';
      responseCode = 200;
  }
  if (responseCode == 200){      
   
        Map<String,Object> entities = (Map<String,Object>)JSON.deserializeUntyped(body);
        Map<String,Object> entityResults = (Map<String,Object>)entities.get('entity');

        List<Object>consumerResults = (List<Object>)entityResults.get('consumers');
        consumerIdsInList = new Set<String>(); 
         
        if(consumerResults == null){
            return('500');
        }
           
        Integer i=0;
        //Clear out any Results they have saved and start fresh
        csrDel=database.query(soql);
        try{
            if(csrDel != null && csrDel.size()>0){
                Database.DeleteResult[] DR_Dels = Database.delete(csrDel);
            }
        }
        catch (Exception e) {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error deleting = '+e));
        }
        List<ConsumerSeachResults__c> csResultsList = new List<ConsumerSeachResults__c>();  //This is where we save the Search results from API
        ConsumerSeachResults__c csResult;        
        
        //create list of Consumers adding fields that are needed later but not needed for display(e.g. divid, consumerId...)
        for(Object mapa:consumerResults){
            subscriber = (Map<String,Object>)mapa;
            Map<String,Object> addressMap = new Map<String,Object>();
            Map<String,Object> depMap = new Map<String,Object>();
            
            csResult = new ConsumerSeachResults__c();
           
            List<Object> addressList = (List<Object>)subscriber.get('addresses');  
                     
                if(addresslist != null){
                   addressMap = (Map<String,Object>)AddressList[0]; 
                                          
                    if(addressMap.get('city') != null)
                    {                         
                       csResult.city__c = (String)addressMap.get('city');
                       }
                    if(addressMap.get('stateCode') != null)
                        {
                            csResult.state__c = (String)addressMap.get('stateCode');                               
                           }
                }

             //Now add fields to Consumer Search Results object
             csResult.consumerId__c =(String)subscriber.get('consumerId');
             csResult.PrimaryMemberConsumerId__c =(String)subscriber.get('primaryMemberConsumerId');                              
             csResult.Name__c = (String)subscriber.get('firstName')+' '+ (String)subscriber.get('lastName');
             csResult.Relation_to_Member__c =(String)subscriber.get('relationToMember'); 
             csResult.Client_Name__c = (String)subscriber.get('clientName');
             csResult.consumerId__c =(String)subscriber.get('consumerId');
             csResult.PrimaryMemberConsumerId__c =(String)subscriber.get('primaryMemberConsumerId');                          
             csResult.Client_Id__c = (String)subscriber.get('clientId');
             csResult.expandedId__c = (String)subscriber.get('expandedId');
             csResult.strategicAlliance__c = (String)subscriber.get('strategicalliance'); 
             csResult.populationIndicator__c = (String)subscriber.get('populationindicator'); 
             csResult.firstName__c = (String)subscriber.get('firstName'); 
             csResult.lastName__c = (String)subscriber.get('lastName'); 
             csResult.divid__c = (String)subscriber.get('divId'); 
             csResult.coverageCode__c = (String)subscriber.get('coverageCode'); 
             //csResult.ConsClientDivIDs__c = (String)subscriber.get('consumerId') +' '+ (String)subscriber.get('clientId')+' '+ (String)subscriber.get('divId') ;
             csResult.ConsClientDivIDs__c = (String)subscriber.get('clientId')+' '+ (String)subscriber.get('divId') ;
             csResult.PrimaryMemberName__c = (String)subscriber.get('firstName')+' '+ (String)subscriber.get('lastName');
             csResult.TermDate__c = (String)subscriber.get('futureTerm');           
             dobFormatted = (String)subscriber.get('dateOfBirth');
             if(dobFormatted != null){
                 csResult.dob__c = dobFormatted.mid(4,2)+'/'+dobFormatted.right(2)+'/'+dobformatted.left(4);
                 csResult.dobForSort__c = (String)subscriber.get('dateOfBirth');
             }
             else{
                 csResult.dob__c = '01/01/1901';
                 csResult.dobForSort__c = '19010101';
             }
             csResult.Consumer_Client_Status__c = (String)subscriber.get('consumerStatus')+ '/' + (String)subscriber.get('clientStatus');
             csResult.effectiveDate__c = (String)subscriber.get('effectiveDate');
                  
            //Check to see if there are emails
            if(subscriber.keyset().contains('emails')){ 
                List<Object> emailList = (List<Object>)subscriber.get('emails');             
                csResult.email__c = (String)emailList[0]; 
            }
            if(subscriber.keyset().contains('phones')){
                List<Object> phoneList = (List<Object>)subscriber.get('phones');
                 if(phoneList != null && phoneList.size() >0){
                     Map<String,Object> phoneMap = (Map<String,Object>)phoneList[0]; 
                     string phoneNum = (String)phoneMap.get('number');
                     string phonePrefix = (String)phoneMap.get('prefix');
                     csResult.phone__c = phonePrefix+phoneNum; 
                 }  
            }
            //Need to check Consumer ID in record being added to csResultList to see if the dependent has already been added     
            csResultsList.add(csresult);       
            if(!consumerIdsInList.contains(csResult.consumerId__c)){
               // csResultsList.add(csresult);
                consumerIdsInList.add(csResult.consumerId__c);                              
                i+=1; 
            }    
            
            
            //Now look to see if I need to create records for Dependents if htey wnt them
            if(include && subscriber.keyset().contains('dependents')){
            
                //Now have to add Dependents for this Member
                 List<Object> depList = (List<Object>)subscriber.get('dependents');
                 if(depList != null && depList.size() >0){                      
                     for(object dep:depList){  
                         depMap = (Map<String,Object>)dep;
                         csResult = new ConsumerSeachResults__c();
                         //Now add fields to Consumer Search Results object
                         csResult.name__c = (String)depmap.get('firstName')+' '+ (String)depmap.get('lastName');
                         csResult.Relation_to_Member__c =(String)depMap.get('relationToMember'); 
                         csResult.Client_Name__c = (String)subscriber.get('clientName');
                         csResult.Client_Id__c = (String)subscriber.get('clientId');
                         csResult.expandedId__c = (String)subscriber.get('expandedId');
                         csResult.ConsumerId__c = (String)depMap.get('consumerId');  
                         csResult.strategicAlliance__c = (String)subscriber.get('strategicalliance'); 
                         csResult.populationIndicator__c = (String)subscriber.get('populationindicator'); 
                         csResult.firstName__c = (String)depmap.get('firstName'); 
                         csResult.lastName__c = (String)depmap.get('lastName'); 
                         csResult.divid__c = (String)subscriber.get('divId'); 
                         csResult.coverageCode__c = (String)subscriber.get('coverageCode');
                         csResult.Consumer_Client_Status__c = (String)subscriber.get('consumerStatus')+ '/' + (String)subscriber.get('clientStatus');
                         csResult.effectiveDate__c = (String)subscriber.get('effectiveDate');
                         //csResult.ConsClientDivIDs__c = (String)depMap.get('consumerId') +' '+ (String)subscriber.get('clientId')+' '+ (String)subscriber.get('divId') ;
                         csResult.ConsClientDivIDs__c = (String)subscriber.get('clientId')+' '+ (String)subscriber.get('divId') ;
                         csResult.PrimaryMemberConsumerId__c = (String)subscriber.get('primaryMemberConsumerId');            
                         csResult.PrimaryMemberName__c = (String)subscriber.get('firstName')+' '+ (String)subscriber.get('lastName');
                         csResult.TermDate__c = (String)subscriber.get('futureTerm');
                         dobFormatted = (String)depMap.get('dateOfBirth');
                         if(dobFormatted != null){
                             csResult.dob__c = dobFormatted.mid(4,2)+'/'+dobFormatted.right(2)+'/'+dobformatted.left(4);
                             csResult.dobForSort__c = (String)depmap.get('dateOfBirth');
                         }
                         else{
                             csResult.dob__c = '01/01/1901';
                             csResult.dobForSort__c = '19010101';
                         }
                             csResultsList.add(csresult);
                         if(!consumerIdsInList.contains(csResult.consumerId__c)){
                            // csResultsList.add(csresult);
                             
                             consumerIdsInList.add(csResult.consumerId__c);                              
                             i+=1; 
                         }    
                         
                     }
                  }
             }       
                    
        }  
       
        Insert csResultsList;
        searchResults = csResultsList;     
    }
              
    return String.valueOf(responseCode);                
    }

    public PageReference APIsearchRecords() 
    {       
        //Before they search again delete any other search records from today       
        param1='false';
        String Q1='';
        Q='';
        csResultsList=null;
        searchResults=null;
        wrapcsrList=null;
       
        APIQf(lastname, 'lastName');
        APIQf(firstname, 'firstName');       
        
        if(!(ConsumerId =='')){
          APIQf(ConsumerId ,'consumerId');
        }     
        APIQf(auth,'authNumber');
        APIQf(memberId, 'expandedId'); 
        Q1=Q;
        System.debug('### q1 = '+ Q1);
        APIQf(clientname, 'clientName');            
        APIQf(Last4, 'last4');
        
        //Added 7/29 - check that they entered either 6 numbers or 2/2/4 numbers
        
        if(dob.length()> 0){
            if(!((dob.length() == 8 && !dob.contains('/'))|| (dob.length()==10 && dob.contains('/')))){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter the date as mmddyyyy or mm/dd/yyyy'));
           //if(!((dob.length()==10 && dob.contains('/')))){
           //     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter the date as mm/dd/yyyy'));
                return null;
            }
        }
        
        //Need to format DOB and As of Date for api call - as of is equivalent of effective date
        if(asofdate!=null){
             asofdateformatted = asofdate.right(4) +'-'+ asofdate.left(2)+'-'+ asofdate.mid(2,2);
             asofdateFormattedCCP = asofdate.right(4)+asofdate.left(2)+asofdate.mid(2,2);
             APIQf(asofdateformatted,'asOfDate ');
             System.debug('### asofdateformattedCCP = '+ asofdateformattedCCP); 

        }
        if(dob!=null){
             if(dob.contains('/')){
                 dobformatted = dob.right(4) +dob.left(2)+ dob.mid(3,2);
                if (!(((Integer.valueof(dob.left(2).trim()) < 13)  && (Integer.valueof(dob.mid(3,2).trim()) < 32)))) {
                  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please validate the date as mm/dd/yyyy'));
                   return null;
                  }
             }
             else{
                 dobformatted = dob.right(4) +dob.left(2)+ dob.mid(2,2);
             }
             system.debug('### dobformatted = '+ dobformatted);
             APIQf(dobformatted,'dob');
        }
        APIQf(state,'state');
        APIQf(city, 'city');
        APIQf(phone,'phone');
        APIQf(email,'email');
        
        if (!include) 
            {APIQf('false', 'includeDependents');
            }
        else{
            APIQf('true', 'includeDependents');
        }     
        if (!activeOnly){
            APIQf('false', 'activeMembersOnly');
        }
        else{
            APIQf('true', 'activeMembersOnly');
        }  
        System.debug('###remdob = '+ remdob);
        if (!remdob){
           APIQf('false', 'excludeDefaultDob'); 
        }
        else{
            APIQf('true', 'excludeDefaultDob'); 
        }
        System.debug('### q = '+Q);    
        if(Q1=='' || String.isBlank(Q1)){  
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter First and Last Name or Auth# or Expanded ID'));
            return null;
        }
        else {
             Q=Q.substring(1);        
             Integer j, i, k;
             String returnCode = callAPI();  
             if(returnCode != '200'){             
                 String s;
                 if(returnCode =='500'){
                     s = 'No results found for your Search Criteria - ensure you entered First and LastName, Auth# or Expanded ID';
                 }
                 else{
                     s='Problem connecting to Consumer dB';
                 }

                 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,s));      
                 return null; 
             }
             
             k=searchResults.size();
             if(k==0){  
                if (!refresh) ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No Results for your Search'));
                return null;
             }
             else {     
                  if(wrapcsrList ==null){
                      wrapcsrList =new list<wrapcsr>();
                      for(ConsumerSeachResults__c a:searchResults){
                          wrapcsrList.add(new wrapcsr(a));
                       }
                  }   
             }
         }
        refresh=false;
        if(searchResults.size() >49){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There are more than 50 results - you may want to refine your Search criteria'));    
        }
        return null;
    }
    
    public pageReference createCase()
    { 
     /*  Get the selected Consumer - either one they selected or ConsumerId they entered - if it exists
         Then create related Member Plan
         Check that they only selected one and also that CallerType and CallerName are entered.
     */ 
      MemberPlan mp = new MemberPlan();
     
      if(caseobj.AccountId == null && caseobj.PersonAccount__c == null && wrapcsrList == null ){
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please search before clicking Go to Create a Case'));
          return null; 
      }
      
      //Now check if they selected more than one
      Integer i=0;
      for(wrapcsr wrapcsrRec : wrapcsrList) {
          if(wrapcsrRec.isSelected == true) {                      
              i++;
          }
       }
       if (Test.isRunningTest()) {
          i=1;
           callername='test';
           calltype ='Member';
       }
       System.debug('### i = row selected '+ i);
        if(i==0 || i>1 ){
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please only select one Consumer before clicking Go'));
          return null; 
       }   
      
       //Check for CallerName and Type
       if(callername== '' || callertype == '' ){
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a Caller Name and Caller Type before clicking Go'));
          return null; 
       }
       
       caseCreationStatus = 'failure';
       ccpURL = CC_Portal__c.getValues('Environment').Base_URL__c;
       List<Caller_Intent__c> cicList = Caller_Intent__c.getAll().values();
       for(Caller_Intent__c cic:cicList){
            if(cic.Code__c == callerintent){ 
                callerintentText = cic.Intent_Text__c;
            }
       }
       
       Id rtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Vision Benefits').getRecordTypeId();
       
       caseobj.recordtypeId = rtId;
       caseobj.Caller_Intent__c = callerintentText;
       caseobj.Caller_Name__c = callername;
       if(!Test.isRunningTest()){
           caseobj.IVR_Call_Type__c = ivrcallType;
           caseobj.IVR_ANI__c= ANI;
           caseobj.IVR_DNIS__c = DNIS;
           caseobj.IVR_Caller_Intent__c = callerintent;
           caseobj.IVR_Consumer_ID__c = consumerId;
           caseobj.IVR_Contact_ID__c = ciscoContactId;
           caseobj.IVR_Client_ID__c = clientId;
       }
       if(caseobj.IVR_Call_Type__c == null){
           caseobj.IVR_Call_Type__c = calltype;
       } 
       try{ 
              insert caseobj;  //This gives me any picklist values they chose.
       }
       catch(exception e) {
           system.debug('exception = '+e.getMessage());
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There was a problem creating the Case. '+ e));
                return null;    
       }
       
       caseId = caseobj.id;
        Integer j=-1; 
        Id cId;
        integer numChecked = 0;
        
        List<String> selConsumers = new List<String>();
        ConsumerSeachResults__c selcsr = new ConsumerSeachResults__c();
        
        //First check if there is an authenticated User 
        if (caseobj.AccountId != null || caseobj.PersonAccount__c != null) {
            /* They had me remove these fields but leave code in so when they decide to add back in code is here.
            //We have a Person or a Business Account - go right to the case but first if Person Accout was added - put the Person Account and Member Plan on the case
            if(caseobj.PersonAccount__c != null){
                Contact con = [SELECT id
                            FROM Contact
                            WHERE AccountId =: caseobj.PersonAccount__c LIMIT 1];
                List<MemberPlan> pmpList = [SELECT id
                                 FROM MemberPlan
                                 WHERE MemberId =: caseobj.PersonAccount__c]; 
                caseobj.ContactId = con.id;
                 if(pmpList!= null && pmpList.size()>0){
                    caseobj.Member_Plan__c = pmpList[0].id; 
                }
                else{
                    //Person Account was there but not MP - need to create it? But since there is no return JSON since they selected Person Account - I have no data
                }
               
            }
            try{ 
                update caseobj;  //This gives me any picklist values they chose.
                caseCreationStatus = 'Success';             
                return null;
                }
               catch(exception e) {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There was a problem creating the Case. '+ e));
                    return null;    
               }
               */
        }
            
          else {  //They searched for a Name - now check that they selected one and if they did, add it to selectedConsumers   
              if (Test.isRunningTest()) {
                  for(wrapcsr wrapcsrRec : wrapcsrList) {
                      selcsr=wrapcsrRec.ccsr;
                      j=0;
                      break;
                  }    
              }
              else{
                  i=0;
                  for(wrapcsr wrapcsrRec : wrapcsrList) {
                    if(wrapcsrRec.isSelected == true) {                      
                        selcsr=wrapcsrRec.ccsr;
                        j=i; 
                        break;
                    }
                    else {
                        i++;
                    }
                 }
                 //Need to run thru wrapper and count number of checkboxes 
                 
                 for(wrapcsr wrapcsrRec : wrapcsrList) {
                        if(wrapcsrRec.isSelected == true) {                      
                            selcsr=wrapcsrRec.ccsr;
                            numChecked+=1;                       
                        }   
                 }
             }
      
      if((j==-1 || numchecked >1) && param1!='true'){       
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select one record in the search result list.'));
             return null;
      }
     
     //Now we have the selected record in selectedConsumers.  Need to determine if they are already in SF as a PA
     //Need to get ConsumerID from selected Results
    
     consumerId = selcsr.consumerId__c;
     if(consumerId == null || consumerId == ''){
         integer considx = selcsr.ConsClientDivIDs__c.indexOf(' '); 
         consumerId = (selcsr.ConsClientDivIDs__c).left(considx); //Sometimes the ConsumerID gets whacked.....
     }
     System.debug('###consumerid = '+consumerid);
     Consumers = new List<Account>([SELECT Id, Name, Client_Name__pc, Client_ID__pc, Member_Id__pc, Division_Id__pc,Policy_Id__pc, ConsumerId__c, Member_Type__pc, Birthdate__pc, As_of_Date__pc 
                                     FROM Account
                                     WHERE ConsumerId__c=:consumerId]);    
     
     String mpId;
     Account acct = new Account();
         
     if(Consumers == null || Consumers.size()==0){
         // That means the Consumer was not found in the Person Accounts
         // Need to create them first with the info From Consumer Search and then put that record into Consumers record        
         System.debug('### Consumer not found '+ consumerId);
         RecordType personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'];
         
         acct = new Account();
         acct.FirstName = selcsr.firstName__c;
         acct.LastName = selcsr.lastName__c;
         acct.RecordType = personAccountRecordType;
         acct.ConsumerID__c = consumerId;
         acct.personEmail = selcsr.email__c;
         acct.Phone = selcsr.phone__c;
         insert acct;
         cId = acct.Id; 
         
         mp = new MemberPlan();
         mp.MemberId = acct.Id;
         mp=addToMP(mp,selcsr);
         mp.Name = 'Created from Search'; //this will be changed to MP-## when saved
         insert mp;
         mpId = mp.Id;
         
         //Get Consumers List again since this is used when one is found or just created,
         Consumers = new List<Account>([SELECT Id, Name, Email__c
                                     FROM Account
                                     WHERE id=:cId]);  
      }
      else{  //Found Consumer using ConsumerID - get the Person AccountId
          
          cId = Consumers[0].Id;
          
          List<MemberPlan> mpList = new List<MemberPlan>([Select Id, Client_Name__c, Client_ID__c, relation__c,Strategic_Alliance_Code__c,Population_Indicator__c,consumerid__c,Division_Id__c,Coverage__c,asofdate__c
                                                       FROM MemberPlan 
                                                       WHERE memberId =: cid 
                                                       AND Division_ID__c =:selcsr.divid__c
                                                       AND Client_Id__c = :selcsr.client_Id__c]);
          if(mpList!=null && mpList.size()>0){
               mpId = mpList[0].id;
               mp = mpList[0];
               mp.MemberId = cId;
               mp=addToMP(mp,selcsr);
               update mp;
          }
          else{
             mp = new MemberPlan();
             mp.MemberId = cId;
             mp = addToMP(mp,selcsr);        
             mp.Name = 'Created from Search'; //this will be changed to MP-## when saved
             insert mp;
             mpId = mp.Id;
          }
         
      }
      
      RecordType contactRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Consumer' and SObjectType = 'Contact'];
         
        Contact pcon = [SELECT id, email,phone, consumer_Id__C, Birthdate__c, Current_Age__c
                        FROM Contact
                        WHERE Accountid =: cId];  
        
        //pcon.recordtypeid = contactRecordtype.Id; //Get error when I try to do this....
        
        pcon.email = selcsr.email__c;
        pcon.phone = selcsr.phone__c;
        pcon.consumer_Id__c = selcsr.consumerId__c;
        if(selcsr.dob__c != null){
            pcon.BirthDate__c = date.parse(selcsr.dob__c);
            if(selcsr.dob__c != '01/01/1901'){
   
                pcon.Current_Age__c = (date.parse(selcsr.dob__c).daysBetween(date.today()))/365.2425;
            }
            System.debug('### pcon.current_Age__c = '+ pcon.current_Age__c);
        }    
        try{
            update pcon;
        }
        catch(exception e) {
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There was a problem updating the Contact '+ e));
           return null;    
        }
        
                       
        caseobj.AccountId = cId;
        caseobj.RecordTypeId = rtId;
        caseobj.ContactId = pcon.Id;
        caseobj.OwnerId = UserInfo.getUserId();
        caseobj.Status = 'New';
        caseobj.Origin = 'Phone'; 
        caseobj.Client_Id__c = selcsr.client_Id__c;
        caseobj.Consumer_Id__c = selcsr.consumerId__c;            
        caseobj.Member_Plan__c = mpId;
        caseobj.DivisionId__c = selcsr.divId__c;
        caseobj.primaryMemberConsumerId__c = selcsr.primaryMemberConsumerId__c; 
       try{ 
        update caseobj;
        }
       catch(exception e) {
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There was a problem creating the Case. '+ e));
           return null;    
           }
      
        divId = selcsr.divId__c;
        if(divid == null || divid ==''){
            divid=(selcsr.ConsClientDivIDs__c).right(4) ;
        }
        clientId = selcsr.client_Id__c;
        primaryMemberConsumerId = selcsr.PrimaryMemberConsumerId__c;
       
       }     
     
        if (tocase){         
            caseCreationStatus = 'Success';          
        } 
        //Call the @future to set some other fields that come with the Retrieve
        getMPData(mp.Id);
        caseobj = new Case();
        consumerIdCCP = selcsr.ConsumerId__c;
        system.debug('consumerIdCCP = '+consumerIdCCP);
        consumerId='';
        System.debug('jrh asofdateformattedCCP = '+ asofdateformattedCCP); 
        return null;       
    }
      
   
    public MemberPlan addToMP(MemberPlan mp, ConsumerSeachResults__c selcsr){
   
       mp.Client_Name__c = selcsr.client_Name__c;
       mp.Primary_Member__c = selcsr.primaryMemberName__c;
       mp.Client_Id__c = selcsr.client_ID__c;
       mp.relation__c = selcsr.Relation_to_Member__c;
       mp.Strategic_Alliance_Code__c = selcsr.strategicAlliance__c;
       mp.Population_Indicator__c = selcsr.populationIndicator__c;
       mp.consumerId__c = selcsr.consumerId__c;
       mp.Division_Id__c = selcsr.divId__c;
       mp.Coverage__c = selcsr.coverageCode__c;
       mp.primaryMemberConsumerId__c = selcsr.PrimaryMemberConsumerId__c;
       
       if(selcsr.Consumer_Client_Status__c != null || selcsr.Consumer_Client_Status__c !=''){
           String ClientStatus = selcsr.Consumer_Client_Status__c.Left(selcsr.Consumer_Client_Status__c.indexOf('/'));
           if(clientStatus == '' || ClientStatus =='?'){
               mp.ClientStatus__c = 'Inactive';
           }
           else{
           mp.ClientStatus__c = clientStatus;
           }
       }
       else{
           mp.ClientStatus__c = 'Inactive';    
       }
       mp.asofdate__c = system.today();
       
       if(selcsr.effectiveDate__c != null){
           string effDate = selcsr.effectiveDate__c.mid(5,2)+'/'+selcsr.effectiveDate__c.right(2)+'/'+selcsr.effectiveDate__c.left(4);
           mp.EffectiveFrom = date.parse(effDate); 
       }
       if(selcsr.termDate__c != null){
           string termDate = selcsr.termDate__c.mid(5,2)+'/'+selcsr.termDate__c.right(2)+'/'+selcsr.termDate__c.left(4);
           mp.EffectiveTo = date.parse(termDate); 
       }
       
       return mp; 
    }
    public String getcontactId() {
        return contactId;
    }       
    public String getbirthdate() { 
        return birthdate; 
    }
    public String getasofdate() {
        return asofdate;
    }
    public String getdob() {
        return dob;
    }
    public String getstate() {
        return state;
    }
    public String getcity() {
        return city;
    }
    public String getemail() {
        return email; 
    }
    public String getlast4() {
        return last4;
    }
    public String getlastname() {
        return lastname;      
    }
    public String getrelation() {
        return relation;      
    }
    public String getfirstname() {
        return firstname;      
    }
    public String getmidname() {
        return midname;      
    }   
    public String getcname() {
        return clientname;      
    }   
    public String getclientid() {
        return clientid ;      
    }
    public Boolean getactiveOnly() {
        return activeOnly;
    }
    public Boolean getremdob() {
        return remdob;      
    }
    public Boolean getinclude() {
        return include;      
    }
    public Boolean gettocase() {
        return tocase;
    }
    public String getphone() {
        return phone;      
    }
    public String getclassification() {
        return classification;
    }
    public String getcallerintent() {
        return callerintent;
    }
    public String getivrCallType() {
        return ivrCallType;
    }
    public String getcalltype() {
        return calltype;
    }    
    public String getsubject() {
        return subject;
    }
    public String getcallername() {
        return callername;
    }
    public Boolean getauthenticated() {
        return authenticated;
    }
    public String getconsumerId() {
        return consumerId;
    }
    public String getauth() {
        return auth;
    }
    public String getmemberId() {
        return memberId;
    }
    public Boolean getrefresh() {
        return refresh;
    }
    public String getQ() {
        return Q;
    }
    public List<Account> getConsumers() {
        return Consumers;
    }
    
    public List<String> getmemberIDs() {
        return memberIDs;
    }
    public List<String> getconsumerIDs() {
        return consumerIDs;
    }
    public List<String> getauths() {
        return auths;
    }
    public List<String> getnames() {
        return names;
    }
    public String getsortfield() {
        return sortfield;
    }
    public String getname() {
        return name;
    }
    public String getcaseId() {
        return caseId;
    }

  // the current sort direction. defaults to asc
  public String sortDir {
    get  { if (sortDir == null) {  sortDir = 'asc'; } return sortDir;  }
    set;
  }
  
  // the current field to sort by defaults to name
  public String sortField {
    get  { if (sortField == null) {sortField = 'Name__c'; } return sortField;  }
    set;
  }
  
  // format the soql for display on the visualforce page
  public String debugSoql {
    get { return soql + ' order by ' + sortField + ' ' + sortDir ; }
    set;
  }
  
  // toggles the sorting of query from asc<-->desc
  public void toggleSort() {
    // simply toggle the direction
    sortDir = sortDir.equals('asc') ? 'desc' : 'asc';
    // run the query again
    runQuery();
  }
  
  // runs the actual query
  public void runQuery() {
      try {
      searchResults = Database.query(soql + ' order by ' + sortField + ' ' + sortDir + ' NULLS LAST');
          wrapcsrList =new list<wrapcsr>();
          for(ConsumerSeachResults__c a:searchResults){
              wrapcsrlist.add(new wrapcsr(a));
           }
    
    } 
    catch (Exception e) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Ooops!'+e));
    }
  }
  @future(callout=true)
  public static void getMPData(Id mpId){
  //This calls out using the Retrieve functinality and updates the fields on the MP with the results                       
        MemberPlan mp;
        if (!Test.isRunningTest()) { 
            mp = [SELECT id, consumerID__C, primaryMemberConsumerId__c,client_Id__c, division_id__c
                  FROM MemberPlan
                  WHERE id =: mpId]; 
        }
        else{
            id aid = testDataFactory.createPersonAccount('Test');
            mp = testDataFactory.createMemberPlan(aid, 'MemberPlan');
        }               
        String Q='{"consumerId":"'+mp.consumerID__c+'","primaryMemberConsumerId":"'+mp.primaryMemberConsumerId__c+'","divIds":"'+mp.division_id__c+'","clientIds":"'+ mp.client_Id__c+'"}';
        System.debug('### q = '+Q);                       
        String body; 
        
        integer responseCode;
                
        if (!Test.isRunningTest()) { 
           // String webServiceURL = DVIWebService__c.getInstance('DVI Values').DVI_Web_Service__c;
           // String tokenHeader = DVIWebService__c.getInstance('DVI Values').DVI_Token_Header__c;       
            String webServiceURL = Consumer_Search_Web_Service__c.getInstance('Consumer Search Values').Consumer_Search_Web_Service__c;
            String tokenHeader = Consumer_Search_Web_Service__c.getInstance('Consumer Search Values').Consumer_Search_Token_Header__c;
            String requestEndPoint=webServiceURL+'/as/token.oauth2';      
               
            HttpRequest oauthReq = new HttpRequest(); 
            String access_token='';   
             
            oauthReq.setEndpoint(requestEndPoint); 
            oauthReq.setMethod('POST');
            String authorizationHeader = 'Basic '+ tokenHeader; 
            oauthReq.setHeader('Accept', 'application/json');
            oauthReq.setHeader('Authorization', authorizationHeader); 
            oauthReq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
          
            oauthReq.setBody('grant_type=client_credentials&scope=read:vc.sfdc_consumer_exp');
            oauthReq.setTimeout(2 * 60 * 1000);
                               
            Http oauthHttp = new Http(); 
            HTTPResponse oauthResp = oauthHttp.send(oauthReq); //This just gets the access token   
                        
            String oauthRespJSON=oauthResp.getBody();
            
            JSONParser parser=JSON.createParser(oauthRespJSON);
            
                   while(parser.nextToken()!=null){
                      if((parser.getCurrentToken()==JSONToken.FIELD_NAME)&&(parser.getText()=='access_token')){
                            parser.nextToken();
                            access_token+=parser.getText();
                             
                      }
                   }     
                              
            HttpRequest memReq = new HttpRequest(); 
            
            String consumerIDEndPoint = webServiceURL+'/sfdc-consumer-exp/SFDCConsumers';
            memReq.setEndpoint(consumerIDEndPoint); 
            memReq.setMethod('POST');
            memReq.setHeader('Accept','application/json');
            memReq.setHeader('Content-Type','application/json');
           
            string jsonBody=Q;
            memReq.setBody(jsonBody);
            
            String memHeaders = 'Bearer ' + access_token; 
            memReq.setHeader('Authorization', memHeaders); 
            
            Http memHttp = new Http(); 
            HTTPResponse memResp = new HttpResponse();
            memResp = memHttp.send(memReq);
            body = memResp.getbody();
            responseCode = memResp.getStatusCode();
        }
    else{
      //test running need to create json body manually - use bogus name and consumerid
      body = '{"statusType":"OK","entity":{"consumers":[{"firstName":"ABCDEF","lastName":"GHIJKL","primaryMemberName":"ABCDEF GHIJKL","consumerId":"999999999","primaryMemberConsumerId":"312397511","clientId":"30023319","divId":"0061","expandedId":"U35696729","addresses":[{"street1":"14 MAIN ST","city":"ANYTOWN","stateCode":"MA","zipCode":"02771"}],"consumerStatus":"Active","clientStatus":"Active","clientDivisionStatus":"Active","coverageCode":"Member + Famiy",';
      body+='"clientName":"RBSELECT HEALTHPLAN (CIG VIS)","clientDivisionName":"ALL CITIZENS ACTIVE - FULL","populationIndicator": "C","strategicAlliance": "AMERL",';
      body+='"dependents":[{"firstName": "JKLM","lastName": "STUV","consumerId": "999999993","relationToMember": "S"}],';
      body+='"relationToMember":"M","primaryMemberConsumerId": "999999999","dateOfBirth":"19580816","phones":[{"number":"3366838","prefix":"508"}]}]},"entityType":"com.vsp.api.salesforce.consumerexperience.model.ConsumerExperienceSearchResult","status":200}';
     
           responseCode = 200;
    }
        if (responseCode == 200){   
           
            Map<String,Object> entities = (Map<String,Object>)JSON.deserializeUntyped(body);
            Map<String,Object> entityResults = (Map<String,Object>)entities.get('entity');     
            List<Object>consumerResults = (List<Object>)entityResults.get('consumers');
              
            if(consumerResults == null){
                //Unlikely but just in case...
            }
            else{   
                Integer i=0;
                Map<String,Object> subscriber;
               
                    List<ConsumerSeachResults__c> csResultsList = new List<ConsumerSeachResults__c>();  //This is where we save the Search results from API
                    ConsumerSeachResults__c csResult;
                   
                    //create list of Consumers adding fields that are needed later but not needed for display(e.g. divid, consumerId...)
                 for(Object mapa:consumerResults){
                     subscriber = (Map<String,Object>)mapa;   
                     System.debug('### pop indic = '+ (String)subscriber.get('populationIndicator'));            
                     mp.population_Indicator__c = (String)subscriber.get('populationIndicator');
                     mp.Strategic_Alliance_Code__c = (String)subscriber.get('strategicAlliance'); 
                 }
                 update mp;                
             }
         }        
        else{
            System.debug('### There was a problem accessing ConsumedB to udate the MemberPlan.');           
        }
    
    }

}