public class VSP_Premier_Benefit_Dupe_Validation {
    public static boolean VSP_Premier_Benefit_Dupe_Validation_Recursion = true;
    public static void VSP_Premier_Benefit_Dupe_Validation(List<Premier_Benefit__c> newBenefitRecs){
        VSP_Premier_Benefit_Dupe_Validation_Recursion = false;
        system.debug('***** entered VSP_Premier_Benefit_Dupe_Validation ***** ');
        
        Set<String> newBenefitName = new Set<String>();
        
        for(Premier_Benefit__c nBenRec :newBenefitRecs){
            newBenefitName.add(nBenRec.Name);
        }
        
        System.debug('Benifit Name ' + newBenefitName);
        
        
        
        List<Premier_Benefit__c> exBenefitList = [Select Id, Name, Benefit_Type__c From Premier_Benefit__c
                                                  Where Name IN :newBenefitName
                                                  AND Id NOT IN :newBenefitRecs];
        
        if(!exBenefitList.isEmpty()){
            for(Premier_Benefit__c newRec :newBenefitRecs){
                for(Premier_Benefit__c exRec :exBenefitList){
                    if(exRec.Name == newRec.Name && exRec.Benefit_Type__c == newRec.Benefit_Type__c){
                        newRec.addError('This benefit already exists');
                    }
                }
                
            }
            
        }
        
    }
}