public class VSP_Premier_Tier_Dupe_Validation {
    public static boolean VSP_Premier_Tier_Dupe_Validation_Recursion = true;
    public static void checkVSP_Premier_Tier_Dupe_Validation(List<Premier_Tier__c> newTierRecs){
        if(VSP_Premier_Tier_Dupe_Validation_Recursion){
            VSP_Premier_Tier_Dupe_Validation_Recursion = false;
            
            List<Profile> getUserProfile = [SELECT Id, Name FROM Profile WHERE Id = :userinfo.getProfileId() LIMIT 1];
            String profileName = getUserProfile[0].Name;
            
            List<String> nTierList = new List<String>();
            List<Premier_Tier__c> exTierList = new List<Premier_Tier__c>();
            for(Premier_Tier__c pt : newTierRecs){
                if(pt.Status__c != 'Inactive'){
                    nTierList.add(pt.Name);
                }
            }
            System.debug('New Tier Record Name = ' + nTierList);
            if(!nTierList.isEmpty()){
                exTierList = [SELECT Id, Name, Effective_Date__c, End_Date__c, Status__c, Contract_Type__c 
                                                    FROM Premier_Tier__c 
                                                    WHERE Name IN : nTierList                                                
                                                    //     AND Id != :newTierRecs
                                                    AND (Status__c = 'Active' OR Status__c = 'Future')];
                System.debug('Queried Tier Records = ' + exTierList);
            }
            //Compare the new Tier record with an existing Tier if found.
            if(!exTierList.isEmpty()){
                for(Premier_Tier__c nTier : newTierRecs){
                    for(Premier_Tier__c exTier : exTierList){ 
                        //Check if it's a duplicate Tier. Fail it if it is.
                        if(exTier.Id != nTier.Id && exTier.Name == nTier.Name && exTier.Contract_Type__c == nTier.Contract_Type__c &&
                           (
                               ((exTier.Effective_Date__c <= nTier.End_Date__c && exTier.End_Date__c >= nTier.Effective_Date__c)
                                ||
                                (exTier.End_Date__c >= nTier.Effective_Date__c && nTier.End_Date__c == NULL)
                                ||
                                (exTier.End_Date__c == NULL && (exTier.Effective_Date__c >= nTier.Effective_Date__c || exTier.Effective_Date__c <= nTier.Effective_Date__c))
                               )
                           )){
                               if(profileName != 'VSP Technical User' && 
                                  profileName != 'System Administrator'){
                                      nTier.addError('Tier with same Name and Practice Type exists within the date range');                                     
                                  }
                           }
                    }
                }
            }            
        }        
    }
}