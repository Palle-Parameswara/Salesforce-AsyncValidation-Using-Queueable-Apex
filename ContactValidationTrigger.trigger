trigger ContactValidationTrigger on Contact (after insert, after update) {

    // Loop through all the contacts in the trigger context
    for (Contact c : Trigger.new) {

        // Phone Validation: Check if the phone number field is not empty and has been updated
        if (c.Phone != null && (Trigger.isInsert || (c.Phone != Trigger.oldMap.get(c.Id).Phone))) {
            try {
                // Enqueue the Queueable job for phone validation
                System.enqueueJob(new PhoneValidationQueueable(c.Id));
            } catch (Exception e) {
                System.debug('Phone Validation API Error: ' + e.getMessage());
            }
        }

        // Email Validation: Check if the email field is not empty and has been updated
        if (c.Email != null && (Trigger.isInsert || (c.Email != Trigger.oldMap.get(c.Id).Email))) {
            try {
                // Enqueue the Queueable job for email validation
                System.enqueueJob(new EmailValidationQueueable(c.Id));
            } catch (Exception e) {
                System.debug('Email Validation API Error: ' + e.getMessage());
            }
        }
    }
}