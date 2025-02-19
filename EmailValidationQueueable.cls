public class EmailValidationQueueable implements Queueable, Database.AllowsCallouts  {
    private String contactId;
    private static final String Email_API_KEY = ''; // Replace with your actual API key

    public EmailValidationQueueable(String contactId) {
        this.contactId = contactId;
    }

    public void execute(QueueableContext context) {
        Contact contact = [SELECT Id, Email FROM Contact WHERE Id = :contactId LIMIT 1];
        
        if (String.isEmpty(contact.Email)) {
            return;  // No email to validate
        }

        // Make the callout to the Email Validation API
        String endpoint = 'callout:Email_Validation/v1/?api_key=' + Email_API_KEY + '&email=' + EncodingUtil.urlEncode(contact.Email, 'UTF-8');
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        
        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            Map<String, Object> emailDetails = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

            // Update the contact fields based on the email validation response
            // Map the API response to valid picklist values
            String emailValidationStatus = (String) emailDetails.get('deliverability');
            
            // Map the response to a valid picklist value
            if (emailValidationStatus == 'DELIVERABLE') {
                contact.Email_Validation_Status__c = 'Valid'; // Update with valid picklist value
            } else {
                contact.Email_Validation_Status__c = 'Invalid'; // Update with valid picklist value
            }
            contact.Quality_Score__c = (String) emailDetails.get('quality_score');
            update contact;
        } else {
            // Handle the error if the email validation API fails
            System.debug('Email Validation API Error: ' + res.getStatusCode());
        }
    }
}
