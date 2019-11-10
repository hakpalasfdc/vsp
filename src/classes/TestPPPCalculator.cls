@isTest
public class TestPPPCalculator {
    
    private static testmethod void TestCopyToCase()
    {
        DVIWebService__c dviCustSetting = new DVIWebService__c();
        dviCustSetting.name = 'DVI Values';
        dviCustSetting.DVI_Web_Service__c = 'webserviceURL'; 
        dviCustSetting.DVI_Token_Header__c = 'tokenheader';
        insert dviCustSetting;
        
		case caseobj = new case(); 
       	Id rtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Vision Benefits').getRecordTypeId();
       	caseobj.recordtypeId = rtId;
       	insert caseobj;  

       	String result = PPPCalcController.getcopytocase('2', '2', '200', caseobj.Id);
		System.assertEquals('Success', result);        
    }
}