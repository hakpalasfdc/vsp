trigger AccountTrigger on Account (before insert, before update, after insert, after update, after delete, after undelete) {
    if(!VSPUtility.stopAccountTrigger){
        
        if(trigger.isBefore){
            
            if(trigger.isInsert){
                VSPR19b_ValidateTaxID valTaxId = new VSPR19b_ValidateTaxID();
                valTaxId.VSPR19b_ValidateTaxID(trigger.new, null, false);
                
                VSPR31_BusAccContractTypeCalculation contractTypeCalculation = new VSPR31_BusAccContractTypeCalculation();
                contractTypeCalculation.ContractTypeCalculationBeforeInsert(Trigger.new);
            }
            
            if(trigger.isUpdate){
                            
                VSPR19b_ValidateTaxID valTaxId = new VSPR19b_ValidateTaxID();
                valTaxId.VSPR19b_ValidateTaxID(trigger.new, trigger.oldmap, true);
                
                VSPR11_ValidateBusinessHours validateBizHrs = new VSPR11_ValidateBusinessHours();
                validateBizHrs.VSPR11_ValidateBusinessHours(trigger.new);
                
                VSPR31_BusAccContractTypeCalculation contractTypeCalculation = new VSPR31_BusAccContractTypeCalculation();
                contractTypeCalculation.ContractTypeCalculationBeforeUpdate(trigger.new, trigger.oldMap);
            } 
        }
        
        
        if(trigger.isAfter){
            if(trigger.isInsert){
                
                VSPR19b_PopulateVisionCareKey popVCKey = new VSPR19b_PopulateVisionCareKey();
                popVCKey.VSPR19b_PopulateVisionCareKey(trigger.new, null, false);
                
                VSPR19b_PopulateBAVCEndDate bizAcctEndDate = new VSPR19b_PopulateBAVCEndDate();
                bizAcctEndDate.VSPR19b_PopulateBAVCEndDate(trigger.new, null, false);
                
                VSPR19b_AddVCEndDateAccRelatedRecords relRecVCEndDate = new VSPR19b_AddVCEndDateAccRelatedRecords();
                relRecVCEndDate.VSPR19b_AddVCEndDateAccRelatedRecords(trigger.new);
                
                VSPR19b_UpdatePracticeAccountEndDate pracAccEndDate = new VSPR19b_UpdatePracticeAccountEndDate();
                pracAccEndDate.VSPR19b_UpdatePracticeAccountEndDate(trigger.new, null, false, false);
                
                VSPR19b_UpdateVisionCareCurrentCustomer currentCustomer = new VSPR19b_UpdateVisionCareCurrentCustomer();
                currentCustomer.VSPR19b_UpdateVisionCareCurrentCustomer(trigger.new);
                
                VSPR19b_PopulateGeoCode_Handler popGeoCode = new VSPR19b_PopulateGeoCode_Handler();
                popGeoCode.VSPR19b_PopulateGeoCode_Handler(trigger.new, null, false); 
                
                VSPR19b_PopulateBankName_Handler popBankName = new VSPR19b_PopulateBankName_Handler();
                popBankName.VSPR19b_PopulateBankName_Handler(trigger.new);
                
                VSPR25_UpdatePracticeProdAssets.setPracticeAccountProdAssets(Trigger.isDelete ? trigger.old : trigger.New,Trigger.oldmap);
                
               
                                
            }
            
            if(trigger.isUpdate){
                
                VSPR19b_AddExceptionToRelatedNRRecords addException = new VSPR19b_AddExceptionToRelatedNRRecords();
                addException.VSPR19b_AddExceptionToRelatedNRRecords(trigger.new, trigger.oldmap, true);
                
                VSPR19b_PopulateBAVCEndDate bizAcctEndDate = new VSPR19b_PopulateBAVCEndDate();
                bizAcctEndDate.VSPR19b_PopulateBAVCEndDate(trigger.new, trigger.oldmap, true);
                
                VSPR19b_PopulateVisionCareKey popVCKey = new VSPR19b_PopulateVisionCareKey();
                popVCKey.VSPR19b_PopulateVisionCareKey(trigger.new, trigger.oldmap, true);
                
                VSPR19b_AddVCEndDateAccRelatedRecords relRecVCEndDate = new VSPR19b_AddVCEndDateAccRelatedRecords();
                relRecVCEndDate.VSPR19b_AddVCEndDateAccRelatedRecords(trigger.new);
                
                VSPR19b_UpdatePracticeAccountEndDate pracAccEndDate = new VSPR19b_UpdatePracticeAccountEndDate();
                pracAccEndDate.VSPR19b_UpdatePracticeAccountEndDate(trigger.new, null, false, false);
                
                VSPR19b_UpdateVisionCareCurrentCustomer currentCustomer = new VSPR19b_UpdateVisionCareCurrentCustomer();
                currentCustomer.VSPR19b_UpdateVisionCareCurrentCustomer(trigger.new);
                
                VSPR19b_PopulateGeoCode_Handler popGeoCode = new VSPR19b_PopulateGeoCode_Handler();
                popGeoCode.VSPR19b_PopulateGeoCode_Handler(trigger.new, trigger.oldmap, true);  //added this for testing
                
                VSPR19b_PopulateBankName_Handler popBankName = new VSPR19b_PopulateBankName_Handler();
                popBankName.VSPR19b_PopulateBankName_Handler(trigger.new);
                
                VSPR25_UpdatePracticeProdAssets.setPracticeAccountProdAssets(Trigger.isDelete ? trigger.old : trigger.New,Trigger.oldmap);

                VSPR31_BusAccContractTypeCalculation contractTypeCalculation = new VSPR31_BusAccContractTypeCalculation();
                contractTypeCalculation.ContractTypeCalculationAfterUpdate(trigger.new, trigger.oldMap);
                                              
            }
            
            if (trigger.isDelete){
                VSPR25_UpdatePracticeProdAssets.setPracticeAccountProdAssets(Trigger.isDelete ? trigger.old : trigger.New,Trigger.oldmap);
                                
            }
            
        }
    }
    
}