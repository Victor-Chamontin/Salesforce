public class test {

public static List<Account> getAllActiveAccounts() {
        return [SELECT Id,Name,Active__c FROM Account WHERE Active__C = 'Yes'];
        
    }
}