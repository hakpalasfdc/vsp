@isTest
public class VSPR2_ConsumerSearch_Test {
    @isTest
    public static void testConsumerSearch(){
     
        //create Person Account
        Id paId = testdatafactory.createPersonAccount('personAccount');
       
        //Need to create Custom Setting so that VSPR16_GetConsumerID.getConsumerID2 doesnt error
        DVIWebService__c dviCustSetting = testDataFactory.setDVISettings();
        Consumer_Search_Web_Service__c CSCustSetting =testDataFactory.setCSSettings();
        CC_Portal__c ccPortalSettings = testDataFactory.setCCPortalSettings();
       
        case caseobj = new case(); 
        Id rtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Vision Benefits').getRecordTypeId();
       
        caseobj.recordtypeId = rtId;
           
        insert caseobj;  
      
        Test.startTest();
        Test.setCurrentPageReference(new PageReference('VSPR2_ConsumerSearch.VSPR2_ConsumerSearch'));      
         
         ApexPages.StandardController sc = new ApexPages.standardController(caseobj);
   
        VSPR2_ConsumerSearch cs = new VSPR2_ConsumerSearch(sc);
        cs.reset();
      
        cs.firstname='ABCDEF';
        cs.lastName='GHIJKL';
        cs.callername='test';
        cs.calltype = 'Member';
        cs.midname='';
        cs.remdob = false;
        cs.activeOnly = false;
        cs.include = true;
        cs.primaryMemberConsumerID = '';
        
        cs.setparams();
        cs.storeIVRparameters();
        cs.APIsearchRecords();
        cs.togglesort();
        cs.createcase();  //This creates case from JSON
        
        cs.caseobj.PersonAccount__c = paId;      
        cs.createcase();  //This creates case from Person Account
        
        cs.setparams(); 
        cs.getfirstname();
        cs.getlastname();         
        cs.getrelation();         
        cs.getcontactId(); 
        cs.getbirthdate();
        cs.getasofdate();
        cs.getcity();
        cs.getemail();
        cs.getlast4();  
        cs.getlastname();
        cs.getfirstname();
        cs.getrelation();
        cs.getmidname();
        cs.getclientid();
        cs.getinclude();
        cs.getremdob();
        cs.getdob();
        cs.getcname();
        cs.getclassification();
        cs.getphone();
        cs.getactiveOnly();
        cs.getQ();
        cs.getrefresh();
        cs.getmemberId();
        cs.getauth();
        cs.getconsumerId();
        cs.getauthenticated();
        cs.getcallername();
        cs.getsubject();
        cs.getcallerintent();
        cs.getstate();
        cs.gettocase();
        cs.getIVRCalltype();
        cs.getcalltype();
        cs.getConsumers();
        cs.setConsumerID();
        cs.getmemberIds();
        cs.getconsumerids();
        cs.getsortfield();
        cs.getauths();
        cs.getnames();
        cs.getname();
        cs.getcaseid();
        String result = VSPR2_ConsumerSearch.getCCPURL();
        PageReference result2 = VSPR2_ConsumerSearch.finalReset();
        Test.stopTest();
        
        //Assert that case was created and Person Account and Member Plan
        //Contact field = Consumer_ID__c and on Account = Consumer_ID__pc
        String cid = '999999999';
        List<Account> pList = new List<Account>([SELECT id 
                                                 FROM Account 
                                                 WHERE Consumer_Id__pc=:cId]);
        List<Case> caseList = new List<Case>([SELECT ID, Member_Plan__c, AccountId from Case 
                                                WHERE createddate=TODAY 
                                                AND AccountId =:paId
                                                ]);
        //System.Assertequals(caseList.size(),1);
        
        
       
    }
}