public class PhoneValidationQueueable implements Queueable, Database.AllowsCallouts  {
    private String contactId;
    private static final String Phone_API_KEY = 'd90b7df724114ec59a326b81afca3e4e'; // Replace with your actual API key

    public PhoneValidationQueueable(String contactId) {
        this.contactId = contactId;
    }

    public void execute(QueueableContext context) {
        // Retrieve the contact
        Contact contact = [SELECT Id, Phone FROM Contact WHERE Id = :contactId LIMIT 1];
        
        if (String.isEmpty(contact.Phone)) {
            return;  // No phone to validate
        }

        // Make the callout to the Phone Validation API
        String endpoint = 'callout:Phone_Number_Validation/v1/?api_key=' + Phone_API_KEY + '&phone=' + EncodingUtil.urlEncode(contact.Phone, 'UTF-8');
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        
        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            Map<String, Object> phoneDetails = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            
            // Cast the 'country' field to Map to access the 'name' and 'code'
            Map<String, Object> countryDetails = (Map<String, Object>) phoneDetails.get('country');
            
            // Update the contact fields based on the phone validation response
            contact.Phone_Validation_Status__c = (Boolean) phoneDetails.get('valid');
            contact.Phone_Type__c = (String) phoneDetails.get('type');
            contact.Phone_Country__c = (String) countryDetails.get('name');
            contact.Phone_Location__c = (String) phoneDetails.get('location');
            update contact;
        } else {
            // Handle the error if the phone validation API fails
            System.debug('Phone Validation API Error: ' + res.getStatusCode());
        }
    }
}