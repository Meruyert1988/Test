public with sharing class InvSmartyStreetCaller {
    @InvocableMethod(label = 'Call SmartyStreet'
                     description = 'Makes callout to SmartyStreets API')
public static void makeCallout(List<ID> locationIds){
    run (locationIds[0]);
}
    @future(callout= true)
    public static void run(Id locId){
        try{
            smartyStreetCreds__c apiCreds = smartyStreetCreds__c.getOrgDefaults();
            Locations__c loc = [Select Street__c, State__c, Postal_Code__c FROM Locations__c WHERE Id= :locId With SECURITY_ENFORCED];
            String path = 'street-address?'
            + 'street =' + EncodingUtil.urlEncode(loc.State__c, 'UTF-8')
            + '&auth-id =' + apiCreds.AuthId__C
            + '&auth-token =' + apiCreds.AuthToken__c
            + '&state =' + loc.State__c
            + '&zipcode =' + loc.Postal_Code__c
            + '&match = enhanced';
            Http http = new Http();
            HttpRequest request= new HttpRequest();
            request.setEndpoint('callout: SmartyStreet/' + path);
            request.setMethod('GET');
            HttpResponse response = http.send(request);
            system.debug ('resp:' + response.getBody());
            Boolean isSuccess = response.getStatusCode() == 200;
            update new Locations__c (Id = locId, Verified__c = isSuccess);
        }
        catch(Exception exc){
        ErrorLogHelper.createErrorLog('Call SmartyStreet', exc.getMessage());
    }
    }
}