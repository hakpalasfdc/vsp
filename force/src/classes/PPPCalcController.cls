public class PPPCalcController {

    @auraenabled
    public static string getcopytocase(string tab, string label, string value, string recordId){
        Case CC = [select id, comments from Case where Id =: recordId];    
        if (tab=='1') tab='Glasses';
        if (tab=='2') tab='Glasses-Total Copay';
        if (tab=='3') tab='Contacts-Allowance Combined';
        if (tab=='4') tab='Contacts-Exams, Fees with Material Allowance';
        if (tab=='5') tab='Contacts-Recipts Combined';
        if (tab=='6') tab='Contacts-Covered or Necessary';
        
        String calcResults = 'VSP Provider PPP Reimbursement'+'\n'+
                             tab+'\n'+label+'\n'+
                             'Total Reimbursement Amount is:'+value;

        CC.comments = calcResults;
        update CC;
        return 'Success';
    }
        
 }