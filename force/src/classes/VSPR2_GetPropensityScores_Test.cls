@isTest
public class VSPR2_GetPropensityScores_Test {
    @isTest 
    public static void getScoresWithCallout(){  
        DVIWebService__c dviCustSetting = testDataFactory.setDVISettings();
        Consumer_Search_Web_Service__c CSCustSetting = testDataFactory.setCSSettings();
        CC_Portal__c ccPortalSettings = testDataFactory.setCCPortalSettings();        
        Test.setMock(HttpCalloutMock.Class, new VSPR2_GetPropensityCalloutMock());
        
        Account acc = new Account();
        Id rt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        acc.FirstName = 'TestDummy';
        acc.LastName = 'TheThird';
        acc.RecordTypeId = rt;
        insert acc; 
        
        MemberPlan mp = New MemberPlan();
        mp.ConsumerId__c = '306032315';
        mp.Division_ID__c = '0001';
        mp.Client_ID__c = '12006950';
        mp.primaryMemberConsumerId__c= '306032315';
        mp.Name = 'MP-100';
        mp.MemberId = acc.Id;
        insert mp;
        
        case caseobj = new case(); 
        Id rtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Vision Benefits').getRecordTypeId();
        caseObj.accountId = acc.Id;
        caseObj.Member_Plan__c = mp.Id;
        caseObj.Consumer_ID__c = mp.ConsumerId__c;
        caseObj.Client_Id__c = mp.Client_ID__c;
        caseobj.recordtypeId = rtId;
        insert caseobj;  
        
        String requestsId = caseobj.Id;
        VSPR2_GetPropensityScores props = new VSPR2_GetPropensityScores();
        List<VSPR2_GetPropensityScores.Requests> requests = new List<VSPR2_GetPropensityScores.Requests>(); 
        VSPR2_GetPropensityScores.Requests request = new VSPR2_GetPropensityScores.Requests();
        
        request.caseIdSB = requestsId;
        requests.add(request);
        Test.startTest();
        VSPR2_GetPropensityScores.getPropensityScores(requests);
        Test.stopTest();
        
        List<Propensity_Score_Management__mdt> IPpsm = [SELECT Channel__c,Customer__c,Priority__c,States__c,Time_Span_Begin__c,Time_Span_End__c FROM Propensity_Score_Management__mdt WHERE DeveloperName = 'IP' LIMIT 1];
        //List<Propensity_Score_Management__mdt> OONpsm = [SELECT Channel__c,Customer__c,Priority__c,States__c,Time_Span_Begin__c,Time_Span_End__c FROM Propensity_Score_Management__mdt WHERE DeveloperName = 'OON' LIMIT 1];
        
        PropensityScores__c IPScores = new PropensityScores__c();
        PropensityScores__c OONScores = new PropensityScores__c();
        
        IPScores = [SELECT Offer_To__c,Channel__c,Time_Span_Begin__c FROM PropensityScores__c WHERE Case__c =: requestsId AND Code__c = 'IP'];
        //OONScores = [SELECT Offer_To__c,Channel__c,Time_Span_Begin__c FROM PropensityScores__c WHERE Case__c =: requestsId AND Code__c = 'OON'];
        
        system.assertEquals(IPpsm[0].Customer__c, IPScores.Offer_To__c);
        system.assertEquals(IPpsm[0].Channel__c, IPScores.Channel__c);
        system.assertEquals(IPpsm[0].Time_Span_Begin__c, IPScores.Time_Span_Begin__c);
        
        //system.assertEquals(OONpsm[0].Customer__c, OONScores.Offer_To__c);
        //system.assertEquals(OONpsm[0].Channel__c, OONScores.Channel__c);
        //system.assertEquals(OONpsm[0].Time_Span_Begin__c, OONScores.Time_Span_Begin__c);
    } 

    @isTest
    public static void getScoresOnCase(){
        DVIWebService__c dviCustSetting = testDataFactory.setDVISettings();
        Consumer_Search_Web_Service__c CSCustSetting = testDataFactory.setCSSettings();
        CC_Portal__c ccPortalSettings = testDataFactory.setCCPortalSettings();
        List<Propensity_Score_Management__mdt> IPpsm = [SELECT Channel__c,Customer__c,Priority__c,States__c,Time_Span_Begin__c,Time_Span_End__c FROM Propensity_Score_Management__mdt WHERE DeveloperName = 'IP' LIMIT 1];
        List<Propensity_Score_Management__mdt> OONpsm = [SELECT Channel__c,Customer__c,Priority__c,States__c,Time_Span_Begin__c,Time_Span_End__c FROM Propensity_Score_Management__mdt WHERE DeveloperName = 'OON' LIMIT 1];
        
        Account acc = new Account();
        Id rt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        acc.FirstName = 'TestDummy';
        acc.LastName = 'TheThird';
        acc.RecordTypeId = rt;
        insert acc;
        
        MemberPlan mp = New MemberPlan();
        mp.ConsumerId__c = '3060323333';
        mp.Division_ID__c = '0001';
        mp.Client_ID__c = '12006950';
        mp.primaryMemberConsumerId__c= '3060323333';
        mp.Name = 'MP-100';
        mp.MemberId = acc.Id;
        insert mp;
        
        case caseobj = new case(); 
        Id rtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Vision Benefits').getRecordTypeId();
        caseObj.accountId = acc.Id;
        caseObj.Member_Plan__c = mp.Id;
        caseObj.Consumer_ID__c = mp.ConsumerId__c;
        caseObj.Client_Id__c = mp.Client_ID__c;
        caseobj.recordtypeId = rtId;
        insert caseobj;  
        
        PropensityScores__c ps = new PropensityScores__c();
        ps.Case__c = caseobj.Id;
        ps.ConsumerId__c = mp.ConsumerId__c;
        ps.Classification__c = 'N';
        ps.Code__c = 'IP';
        ps.PersonAccount__c = acc.Id;
        ps.States__c = IPpsm[0].States__c;
        ps.Channel__c = IPpsm[0].Channel__c;
        ps.Time_Span_Begin__c = IPpsm[0].Time_Span_Begin__c;
        ps.Offer_To__c = IPpsm[0].Customer__c;
        insert ps;
        /*
        PropensityScores__c ps2 = new PropensityScores__c();
        ps2.Case__c = caseobj.Id;
        ps2.ConsumerId__c = mp.ConsumerId__c;
        ps2.Classification__c = 'N';
        ps2.Code__c = 'OON';
        ps2.PersonAccount__c = acc.Id;
        ps2.States__c = OONpsm[0].States__c;
        ps2.Channel__c = OONpsm[0].Channel__c;
        ps2.Time_Span_Begin__c = OONpsm[0].Time_Span_Begin__c;
        ps2.Offer_To__c = OONpsm[0].Customer__c;
        insert ps2;
		*/
            
        String requestsId = caseobj.Id;
        VSPR2_GetPropensityScores props = new VSPR2_GetPropensityScores();
        List<VSPR2_GetPropensityScores.Requests> requests = new List<VSPR2_GetPropensityScores.Requests>(); 
        VSPR2_GetPropensityScores.Requests request = new VSPR2_GetPropensityScores.Requests();
        request.caseIdSB = requestsId;
        requests.add(request);
        
        Test.startTest();
        VSPR2_GetPropensityScores.getPropensityScores(requests); 
        Test.stopTest();
        
        PropensityScores__c IPScores = new PropensityScores__c();
        IPScores = [SELECT Offer_To__c,Channel__c,Time_Span_Begin__c FROM PropensityScores__c WHERE Case__c =: requestsId AND Code__c = 'IP'];
        PropensityScores__c OONscores = new PropensityScores__c();
        //OONscores = [SELECT Offer_To__c,Channel__c,Time_Span_Begin__c FROM PropensityScores__c WHERE Case__c =: requestsId AND Code__c = 'OON'];
        
        system.assertEquals(IPpsm[0].Customer__c, IPScores.Offer_To__c);
        system.assertEquals(IPpsm[0].Channel__c, IPScores.Channel__c);
        system.assertEquals(IPpsm[0].Time_Span_Begin__c, IPScores.Time_Span_Begin__c);
        
        //system.assertEquals(OONpsm[0].Customer__c, OONscores.Offer_To__c);
        //system.assertEquals(OONpsm[0].Channel__c, OONscores.Channel__c);
        //system.assertEquals(OONpsm[0].Time_Span_Begin__c, OONscores.Time_Span_Begin__c);
    }
    
    @isTest
    public static void CalloutWithNoScores(){
        Test.setMock(HttpCalloutMock.Class, new VSPR2_GetPropensityCalloutNoScoresMock());
        DVIWebService__c dviCustSetting = testDataFactory.setDVISettings();
        Consumer_Search_Web_Service__c CSCustSetting = testDataFactory.setCSSettings();
        CC_Portal__c ccPortalSettings = testDataFactory.setCCPortalSettings();
        
        Account acc = new Account();
        Id rt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        acc.FirstName = 'TestDummy';
        acc.LastName = 'TheThird';
        acc.RecordTypeId = rt;
        insert acc;
        
        MemberPlan mp = New MemberPlan();
        mp.ConsumerId__c = '3060323333';
        mp.Division_ID__c = '0001';
        mp.Client_ID__c = '12006950';
        mp.primaryMemberConsumerId__c= '3060323333';
        mp.Name = 'MP-100';
        mp.MemberId = acc.Id;
        insert mp;
        
        case caseobj = new case(); 
        Id rtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Vision Benefits').getRecordTypeId();
        caseObj.accountId = acc.Id;
        caseObj.Member_Plan__c = mp.Id;
        caseObj.Consumer_ID__c = mp.ConsumerId__c;
        caseObj.Client_Id__c = mp.Client_ID__c;
        caseobj.recordtypeId = rtId;
        insert caseobj;  
        
        String requestsId = caseobj.Id;
        VSPR2_GetPropensityScores props = new VSPR2_GetPropensityScores();
        List<VSPR2_GetPropensityScores.Requests> requests = new List<VSPR2_GetPropensityScores.Requests>(); 
        VSPR2_GetPropensityScores.Requests request = new VSPR2_GetPropensityScores.Requests();
        
        request.caseIdSB = requestsId;
        requests.add(request); 
        
        Test.startTest();
        List<VSPR2_GetPropensityScores.Results> resultsList = VSPR2_GetPropensityScores.getPropensityScores(requests);
        Test.stopTest();
        
        List<PropensityScores__c> updatedScores = new List<PropensityScores__c>();
        updatedScores = [SELECT Id,Offer_To__c,Channel__c,Time_Span_Begin__c FROM PropensityScores__c WHERE Case__c =: requestsId];
        
        system.assertEquals(0, updatedScores.size());
        system.assertEquals('No Offer', resultsList[0].propensityScoreFieldIP); 
    }
}