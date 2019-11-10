@isTest
public class VSP_Premier_Benefit_Dupe_Validation_Test {
    
    @TestSetup
    static void testData(){
        
        Premier_Benefit__c firstBenefit = new Premier_Benefit__c();
        firstBenefit.Name = 'First Benefit';
        firstBenefit.Benefit_Type__c = 'Currency';
        firstBenefit.Benefit_Amount__c = 10;
        
        insert firstBenefit;
    } 
    static testmethod void insertDup(){
        try{
            Test.startTest();
            Premier_Benefit__c dupFirstBenefit = new Premier_Benefit__c();
            dupFirstBenefit.Name = 'First Benefit';
            dupFirstBenefit.Benefit_Type__c = 'Currency';
            dupFirstBenefit.Benefit_Amount__c = 10;
            
            insert dupFirstBenefit;
            
            Test.stopTest();
        }
        catch(Exception e){
            system.assert(e.getMessage().contains('This benefit already exists'));
        }
    }
    
}