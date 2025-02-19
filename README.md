# Salesforce-AsyncValidation-Using-Queueable-Apex

### **Pros and Cons of Using Queueable Apex**

**Queueable Apex** is a powerful tool in Salesforce for performing asynchronous operations, especially when working with large volumes of data or external integrations. However, like any technology, it has its strengths and weaknesses depending on your use case.

### **Pros of Queueable Apex:**

1. **Flexibility**:
   - Queueable Apex is more **flexible** than **Future Methods**. You can pass **complex data types** (like lists, maps, custom objects) to Queueable Apex jobs, making it much more versatile in handling complex use cases.
   - **Chaining Jobs**: You can **chain multiple queueable jobs**, meaning you can pass the result of one job to another, creating a sequence of jobs to perform complex workflows.

2. **Non-blocking Execution**:
   - Queueable Apex runs **asynchronously**, meaning it doesn’t block the main transaction. This is important when you need to perform time-consuming operations like **callouts** or **heavy computations** without blocking user interactions or other Salesforce processes.

3. **Governor Limits**:
   - **Governor Limits**: Each Queueable Apex job has its own set of limits, so it’s not constrained by the **transaction limits** that govern synchronous operations. For example, you can make **up to 100 callouts per job**, whereas synchronous methods are limited to 100 per transaction.
   - It can also **use heap space** and **CPU time** more efficiently than a synchronous process.

4. **Error Handling**:
   - **Better Error Handling**: Queueable Apex allows more fine-grained control over error handling and retry mechanisms. You can catch exceptions in your `execute` method and log them, or even trigger different actions depending on the outcome.

5. **Easier to Use for Complex Operations**:
   - Queueable Apex can be easier to work with when handling **complex workflows** as it allows you to use **complex data structures** and manage them within a job. This is harder with **future methods** that don't support complex data types.

6. **Visibility**:
   - **Job Monitoring**: You can monitor the execution of Queueable jobs in the **Apex Jobs** interface in Salesforce, making it easier to track job progress and handle retries.

7. **Better for Bulk Processing**:
   - For **bulk data** processing, Queueable Apex is better than future methods, as it allows you to handle records in batches and chain jobs together for further processing.

---

### **Cons of Queueable Apex:**

1. **Complexity**:
   - **More complex** to implement than **Future Methods**. For simple use cases, Queueable Apex might feel like overkill. If your job doesn't require complex logic or passing of large data sets, a **future method** might be simpler and sufficient.

2. **Limit on Queueable Jobs**:
   - While **Queueable Apex** has its own set of limits, it can still hit limits such as **50 jobs per transaction** (when chaining jobs). If you are handling a very large volume of data, you might need to take extra steps to manage these limits.

3. **Delayed Execution**:
   - Since Queueable Apex executes **asynchronously**, there is a **delay** between when the job is enqueued and when it is actually executed. This delay could impact real-time processing scenarios where you need immediate results (e.g., showing the user real-time validation results).

4. **Single Job Timeout**:
   - A single Queueable job has a **maximum execution time** of 5 minutes. If your job takes longer than that to process, it will **time out**. For long-running processes, you may need to implement job chaining or consider using **Batch Apex** instead.

5. **DML Limitations**:
   - Each **Queueable job** can only perform **DML operations** (insert, update, delete) in its own context. This means if you try to update too many records in a single job, you might hit the **DML governor limits**. It’s essential to manage how much data you're working with in a single job.

6. **Visibility and Monitoring**:
   - While you can monitor jobs through the **Apex Jobs** page, understanding the **progress** of a **chained Queueable job** or finding out where an issue occurred in long-running processes can sometimes be more difficult than tracking synchronous operations.

7. **Asynchronous Limit**:
   - Salesforce limits you to **50 asynchronous operations** (Queueable, Future, Batch, and scheduled jobs combined) per transaction. This can be restrictive in scenarios where you need to perform multiple asynchronous operations simultaneously.

---

### **When to Use Queueable Apex**:
- **Asynchronous processing** is needed for tasks like **external system integrations (API callouts)**, **large-scale data processing**, or **heavy computations** that should not block the user experience.
- When you need to handle **complex data structures** or **job chaining**.
- For operations that can take a long time but shouldn't block the user or the main transaction, such as **bulk email validation**, **phone number validation**, or **complex workflows** that need to run independently of user actions.
- If you're dealing with more than **100 records** and need more flexibility than a **future method** can offer.

---

### **When NOT to Use Queueable Apex**:
- For **simple asynchronous operations**, such as a simple callout or database update, where **Future Methods** would suffice and be simpler.
- For **real-time processes** where immediate execution is required, as **Queueable Apex** introduces some **delay** between job submission and execution.
- When your processing logic needs to run **within 5 minutes** or less, or if you’re dealing with **very large data** where the execution might exceed the **time limit** for a single job.

---

### **Conclusion**:
Queueable Apex is a **very powerful tool** for handling **asynchronous tasks**, especially when dealing with large data volumes or complex operations that require flexibility. It is the best choice when you're dealing with bulk operations, external system calls, or chaining jobs for more complex workflows. However, it’s a bit more **complex** than future methods and introduces **some delay** in execution, so consider your use case carefully before choosing this approach.
## **Step-by-Step Guide**:

### **Step 1: Create External Credentials (Custom)**

External Credentials are used in Salesforce to store the credentials for an external service, typically used for integration. You can define **External Credentials** for services like phone/email validation APIs.

#### **Steps to Create External Credentials**:
1. **Go to Setup**:
   - In Salesforce, click the gear icon at the top right and select **Setup**.
   
2. **Search for External Credentials**:
   - In the Quick Find box, type **"External Credentials"** and select **External Credentials** under **Security**.

3. **Create New External Credential**:
   - Click **New** to create a new External Credential.
   - Name it something like **Phone_Validation_API_Credentials** or **Email_Validation_API_Credentials**, depending on the service you’re configuring.

4. **Choose the Type**:
   - For Phone Validation API and Email Validation API, you will likely choose **Custom** for your authentication type.

5. **Fill Out Required Information**:
   - **Principal Type**: Select **Named Principal** if you are using a single set of credentials for the entire org.

6. **Save**:
   - After filling in the required fields, click **Save** to create the external credential.

![image](https://github.com/user-attachments/assets/8e38030c-8785-462d-80f4-6091595bf99d)
![image](https://github.com/user-attachments/assets/16dfee29-2274-41db-bf0c-e98406d7545f)

---

### **Step 2: Create Named Credentials**

Named Credentials store authentication settings securely and are linked to an external service. These credentials will be used to interact with the phone/email validation APIs.

#### **Steps to Create Named Credentials**:
1. **Go to Setup**:
   - In Salesforce, click the gear icon and select **Setup**.
   
2. **Search for Named Credentials**:
   - In the Quick Find box, type **"Named Credentials"** and select **Named Credentials** under **Security**.

3. **Create New Named Credential**:
   - Click **New Named Credential**.

4. **Fill Out Named Credential Information**:
   - **Label**: Give it a name like **Phone_Validation_API**.
   - **Name**: This should automatically fill in when you type the label.
   - **URL**: Enter the endpoint URL for the Phone Validation or Email Validation API (e.g., `https://api.example.com`).
   - **Authentication Protocol**: Choose the appropriate authentication method (e.g., **No Authentication**, **OAuth**, **Basic Authentication**).
     - If you're using **OAuth 2.0**, select **OAuth 2.0** and configure the **Consumer Key**, **Consumer Secret**, etc., according to the external service's requirements.

5. **Link External Credentials**:
   - In the **External Credential** section, choose the **External Credential** you created in **Step 1**.

6. **Save the Named Credential**.

![image](https://github.com/user-attachments/assets/53c6972f-f004-4e7d-8956-4d1b9c99cb05)
![image](https://github.com/user-attachments/assets/956b5fc4-2aa5-45b5-8317-fcd39a6702cc)

---

### **Step 3: Create Principals for External Credentials**

In Salesforce, **Principals** refer to the identity used for accessing external systems. You’ll need to create a **Principal** for the **External Credentials** to assign it to the **Named Credential**.

#### **Steps to Create Principals**:
1. **Go to Setup**:
   - In Salesforce, click the gear icon and select **Setup**.

2. **Search for Principal**:
   - In the Quick Find box, type **"Principals"**.

3. **Create a New Principal**:
   - Click **New** to create a new principal.

4. **Fill Out the Principal Information**:
   - **Label**: Give it a name, such as **PhoneValidation_Principal**.
   - **Name**: This should automatically populate when you type the label.
   - **Principal Type**: Choose the appropriate **Principal Type** (e.g., **Named Principal** for a shared access identity).
   - **Authentication Method**: Choose the method matching your integration (e.g., **Basic Authentication**, **OAuth**).

5. **Associate Principal with External Credential**:
   - Link the Principal to the **External Credential** you created earlier in **Step 1**.

6. **Save the Principal**.

![image](https://github.com/user-attachments/assets/76db1dc5-131a-44d0-8720-e872de76188f)

---

### **Step 4: Assign the External Credential Principal to Permission Sets**

Now that you’ve created the **External Credentials**, **Named Credentials**, and **Principals**, the next step is to assign them to the **Permission Set** so that users can access these external services securely.

#### **Steps to Assign Credentials to a Permission Set**:
1. **Go to Setup**:
   - In Salesforce, click the gear icon and select **Setup**.

2. **Search for Permission Sets**:
   - In the Quick Find box, type **"Permission Sets"** and select **Permission Sets**.

3. **Create a New Permission Set**:
   - Click **New** to create a new Permission Set.
   - Name the Permission Set (e.g., **API Access for Validation**).
   - Set the **User License** according to your use case.

4. **Assign Permission Set to External Credentials**:
   - Under **System Permissions**, click **Edit**.
   - Scroll down and find **"API Enabled"**. Ensure this permission is checked for the users who need access to the external credentials.

5. **Assign the Named Credentials**:
   - Scroll down to **Apex Class Access** and ensure that the **Apex Classes** for your validation methods (like **PhoneValidationQueueable** and **EmailValidationQueueable**) are selected.

6. **Save the Permission Set**.

7. **Assign the Permission Set to Users**:
   - Go to the **Permission Set** detail page and click **Manage Assignments**.
   - Click **Add Assignments**, select the users you want to assign the permission set to, and click **Assign**.

---

### **Step 5: Create Custom Fields for Phone and Email Validation**

Now, you'll need to create custom fields in the **Contact** object to store the validation details.

#### **For Phone Validation**:
1. Go to **Setup** → **Object Manager** → **Contact** → **Fields & Relationships**.
2. Click **New Field**.
3. Create the following fields:
   - **Phone Validation Status (Phone_Validation_Status__c)**: Type: **Checkbox** (Valid/Invalid).
   - **Phone Type (Phone_Type__c)**: Type: **Picklist** (e.g., Mobile, Landline, VoIP).
   - **Phone Country (Phone_Country__c)**: Type: **Text** (Country name).
   - **Phone Location (Phone_Location__c)**: Type: **Text** (City or Region).

#### **For Email Validation**:
1. Go to **Setup** → **Object Manager** → **Contact** → **Fields & Relationships**.
2. Click **New Field**.
3. Create the following fields:
   - **Email Deliverability (Email_Validation_Status__c)**: Type: **Picklist** (Valid/Invalid).
   - **Quality Score (Quality_Score__c)**: Type: **Decimal** (0-100 scale).

Add all these fields to the **layout** for the **Contact** object.

![image](https://github.com/user-attachments/assets/fe5ef553-a923-43f3-95a3-8d7219fa97dd)

---

### **Step 6: Create two Queueable class I mention below**

PhoneValidationQueueable
EmailValidationQueueable
---

### **Step 7: Trigger to Call the Queueable classes**

Here’s the `ContactValidationTrigger` to call the Queueable classes:



### **References**:
- [Phone Validation API - Abstract API](https://app.abstractapi.com/api/phone-validation/tester)
- [YouTube Tutorial](https://www.youtube.com/watch?v=sE6MX8vz1Y0)
